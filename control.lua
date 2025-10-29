if not global then global = {} end

local function get_settings()
  return {
    radius = settings.global["cd_search_radius"] and settings.global["cd_search_radius"].value or 64,
    interval = settings.global["cd_tick_interval"] and settings.global["cd_tick_interval"].value or 3,
    step = settings.global["cd_step_speed"] and settings.global["cd_step_speed"].value or 0.06,
    controller_required = settings.global["cd_controller_required"] and settings.global["cd_controller_required"].value or true,
    leash = settings.global["cd_leash_distance"] and settings.global["cd_leash_distance"].value or 80,
    debug = settings.global["cd_debug"] and settings.global["cd_debug"].value or false,
    work_divisor = settings.global["cd_work_divisor"] and settings.global["cd_work_divisor"].value or 6
  }
end

local function is_clean_drone(ent)
  return ent and ent.valid and ent.name == "clean-drone"
end

local function ensure_player_state(pindex)
  global.players = global.players or {}
  global.players[pindex] = global.players[pindex] or {active = true, drones = {}, scan_offset = math.random(0, 5)}
  return global.players[pindex]
end

local function nearest_ground_item(surface, pos, radius)
  local items = surface.find_entities_filtered{type="item-entity", position=pos, radius=radius}
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


local function cd_status(surface, pos, msg)
  local s = get_settings()
  if not s.debug then return end
  rendering.draw_text{
    text = msg,
    surface = surface,
    target = pos,
    color = {1,1,1,1},
    alignment = "center",
    scale = 1.0,
    time_to_live = 60
  }
end

local function step_towards(from, to, step)
  local dx, dy = to.x - from.x, to.y - from.y
  local dist = math.sqrt(dx*dx + dy*dy)
  if dist <= step or dist == 0 then
    return {x = to.x, y = to.y}
  else
    return {x = from.x + dx/dist * step, y = from.y + dy/dist * step}
  end
end

script.on_init(function()
  global.players = global.players or {}
end)

script.on_configuration_changed(function(cfg)
  global.players = global.players or {}
  for _, st in pairs(global.players) do
    for id, d in pairs(st.drones or {}) do
      if not (d.entity and d.entity.valid) then st.drones[id] = nil end
    end
  end
end)

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(e)
  local ent = e.created_entity or e.entity
  if is_clean_drone(ent) then
    -- Prefer the player who placed it; fall back to last_user; finally to Player 1.
    local owner_index = e.player_index or (ent.last_user and ent.last_user.index) or 1
    local st = ensure_player_state(owner_index)
    local key = ent.unit_number or ent.id or ent.registered_index or math.random(1,1000000)
    st.drones[key] = {entity = ent, target_item = nil, owner = owner_index, last_status_tick = 0, mode = "seek"}
    -- Immediate feedback
    cd_status(ent.surface, ent.position, {"", "[CleanDrone] Owner: Player ", owner_index})
  end
end)

script.on_event({defines.events.on_entity_died, defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, function(e)
  if is_clean_drone(e.entity) then
    for pindex, st in pairs(global.players or {}) do
      for id, d in pairs(st.drones or {}) do
        if d.entity == e.entity then st.drones[id] = nil return end
      end
    end
  end
end)

local function select_owner_for(ent, desired_index)
  if desired_index then
    local p = game.get_player(desired_index)
    if p and p.valid and p.connected and p.force == ent.force and p.character then
      return p
    end
  end
  local best_p, bestd
  for _, p in pairs(game.players) do
    if p.valid and p.connected and p.force == ent.force and p.character then
      local st = ensure_player_state(p.index)
      if st.active then
        local s = get_settings()
        local has_controller = (p.get_item_count("clean-drone-controller") > 0)
        if (not s.controller_required) or has_controller then
          local dx = p.position.x - ent.position.x
          local dy = p.position.y - ent.position.y
          local d = dx*dx + dy*dy
          if not best_p or d < bestd then best_p, bestd = p, d end
        end
      end
    end
  end
  return best_p
end

script.on_event(defines.events.on_tick, function(e)
  local s = get_settings()
  for pindex, st in pairs(global.players or {}) do
    for id, d in pairs(st.drones or {}) do
      local ent = d.entity
      if not (ent and ent.valid) then st.drones[id] = nil goto cont end
      local owner = select_owner_for(ent, d.owner)
      if not owner then goto cont end

      -- keep near owner
      local dx = ent.position.x - owner.position.x
      local dy = ent.position.y - owner.position.y
      if (dx*dx + dy*dy) > (s.leash*s.leash) then
        local near = {x = owner.position.x + (math.random()-0.5), y = owner.position.y + (math.random()-0.5)}
        ent.teleport(near)
        d.target_item = nil
      end

      -- scanning
      -- status tick
      if (e.tick - (d.last_status_tick or 0)) >= 60 then
        local label = d.target_item and "moving" or "searching"
        cd_status(ent.surface, ent.position, {"", "[CD] ", label})
        d.last_status_tick = e.tick
      end

      local extra = (d.backoff or 0)
      local need_scan = (not (d.target_item and d.target_item.valid)) or (((e.tick + (st.scan_offset or 0) + (id % 5)) % (s.interval + extra)) == 0)
      if need_scan then
        d.target_item = nearest_ground_item(ent.surface, ent.position, s.radius)
        if (not d.target_item) then
          d.target_item = nearest_ground_item(ent.surface, owner.position, s.radius)
        end
        if d.target_item then d.backoff = 0 else d.backoff = math.min((d.backoff or 0) + 1, 20) end
      end
      if not (d.target_item and d.target_item.valid) then goto cont end

      -- move
      local tpos = d.target_item.position
      local nextp = step_towards(ent.position, tpos, s.step)
      local tp_ok = ent.teleport(nextp)
      if not tp_ok then ent.teleport{ x = nextp.x, y = nextp.y } end

      -- pickup
      local pdx = ent.position.x - tpos.x
      local pdy = ent.position.y - tpos.y
      if (pdx*pdx + pdy*pdy) <= (0.6*0.6) then
        if d.target_item and d.target_item.valid then
          local gs = d.target_item.stack
          if gs and gs.valid_for_read then
            local name = gs.name
            local count = gs.count or 0
            if count > 0 then
              if owner.can_insert{name=name, count=count} then
                local inserted = owner.insert{name=name, count=count}
                if inserted >= count then
                  cd_status(ent.surface, ent.position, {"", "[CD] picked ", name})
                  if d.target_item and d.target_item.valid then d.target_item.destroy() end
                  d.target_item = nil
                else
                  local remain = count - inserted
                  if d.target_item and d.target_item.valid then
                    local gs2 = d.target_item.stack
                    if gs2 then gs2.set_stack{name=name, count=remain} end
                  end
                  cd_status(ent.surface, ent.position, {"", "[CD] picked ", name, " (", inserted, "/", count, ")"})
                end
              else
                cd_status(ent.surface, ent.position, {"", "[CD] inventory full"})
                d.target_item = nil
              end
            else
              d.target_item = nil
            end
          else
            d.target_item = nil
          end
        end
      end

      ::cont::
    end
  end
end)
