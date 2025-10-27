-- CleanDrone control script
-- Behavior:
-- 1) Search for the nearest item-on-ground (item entity) on the same surface.
-- 2) Fly to it, pick it up (destroy the entity and add to internal cargo).
-- 3) Find the nearest Active provider chest owned by the same force.
-- 4) Fly there and insert the cargo.
-- 5) Repeat.
-- Notes:
-- * Movement is simulated by teleporting a tiny step every tick to keep logic simple.
-- * We cap the cargo to roughly one stack (100 items heuristic) to avoid infinite hoarding.

local PICK_RADIUS = 0.8
local CHEST_RADIUS = 1.5
local SPEED = 0.06  -- tiles per tick

script.on_init(function()
  global.drones = global.drones or {}
end)

local function is_clean_drone(entity)
  return entity and entity.valid and entity.name == "clean-drone"
end

-- Track placed/removed drones
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(e)
  local ent = e.created_entity or e.entity
  if is_clean_drone(ent) then
    table.insert(global.drones, {
      unit = ent,
      phase = "seek_item",
      cargo = {},            -- [item_name] = count
      cargo_count = 0
    })
  end
end)

script.on_event({defines.events.on_entity_died, defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, function(e)
  local ent = e.entity
  if is_clean_drone(ent) then
    for i, d in ipairs(global.drones) do
      if d.unit == ent then table.remove(global.drones, i) break end
    end
  end
end)

local function step_towards(from, to, step)
  local dx, dy = to.x - from.x, to.y - from.y
  local dist = math.sqrt(dx*dx + dy*dy)
  if dist < step or dist == 0 then
    return {x = to.x, y = to.y}
  else
    return {x = from.x + dx/dist * step, y = from.y + dy/dist * step}
  end
end

local function nearest_ground_item(surface, pos)
  -- In 2.0 the ground item entity type is "item-entity".
  local items = surface.find_entities_filtered{type="item-entity", position=pos, radius=32}
  local best, bestd
  for _, it in ipairs(items) do
    if it.valid and it.stack and it.stack.valid_for_read then
      local dx = it.position.x - pos.x
      local dy = it.position.y - pos.y
      local d = dx*dx + dy*dy
      if not best or d < bestd then best, bestd = it, d end
    end
  end
  return best
end

local function nearest_active_provider(surface, pos, force)
  local chests = surface.find_entities_filtered{
    type = "logistic-container",
    force = force,
    logistic_container_type = "active-provider",
    position = pos, radius = 128
  }
  local best, bestd
  for _, c in ipairs(chests) do
    local dx = c.position.x - pos.x
    local dy = c.position.y - pos.y
    local d = dx*dx + dy*dy
    if not best or d < bestd then best, bestd = c, d end
  end
  return best
end

local function insert_all(chest, cargo)
  for name, count in pairs(cargo) do
    if count > 0 then
      local inserted = chest.insert{name=name, count=count}
      cargo[name] = cargo[name] - inserted
    end
  end
  for _, cnt in pairs(cargo) do
    if cnt > 0 then return true end
  end
  return false
end

script.on_event(defines.events.on_tick, function(e)
  -- Update every other tick to reduce overhead.
  if (e.tick % 2) ~= 0 then return end
  for _, d in ipairs(global.drones) do
    if not (d.unit and d.unit.valid) then goto continue end
    local surf = d.unit.surface
    local pos = d.unit.position
    if d.phase == "seek_item" then
      d.target_item = (d.target_item and d.target_item.valid) and d.target_item or nearest_ground_item(surf, pos)
      if not d.target_item then goto continue end
      local tpos = d.target_item.position
      local nextp = step_towards(pos, tpos, SPEED)
      d.unit.teleport(nextp)
      local dx, dy = d.unit.position.x - tpos.x, d.unit.position.y - tpos.y
      if (dx*dx + dy*dy) <= (PICK_RADIUS*PICK_RADIUS) then
        local stack = d.target_item.stack
        if stack and stack.valid_for_read then
          local name, count = stack.name, stack.count
          d.cargo[name] = (d.cargo[name] or 0) + count
          d.cargo_count = d.cargo_count + count
        end
        d.target_item.destroy()
        if d.cargo_count >= 100 then
          d.phase = "to_chest"
          d.target_chest = nil
        end
      end

    elseif d.phase == "to_chest" then
      d.target_chest = (d.target_chest and d.target_chest.valid) and d.target_chest
                       or nearest_active_provider(surf, pos, d.unit.force)
      if not d.target_chest then
        -- No purple chest available: idle/circle (do nothing this tick).
        goto continue
      end
      local cpos = d.target_chest.position
      local nextp = step_towards(pos, cpos, SPEED)
      d.unit.teleport(nextp)
      local dx, dy = d.unit.position.x - cpos.x, d.unit.position.y - cpos.y
      if (dx*dx + dy*dy) <= (CHEST_RADIUS*CHEST_RADIUS) then
        local leftover = insert_all(d.target_chest, d.cargo)
        if not leftover then
          d.cargo = {}
          d.cargo_count = 0
          d.phase = "seek_item"
          d.target_item = nil
        end
      end
    end
    ::continue::
  end
end)
