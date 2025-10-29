

local function recall_for_player(player)
  if not (player and player.valid) then return end
  local recalled = 0
  for _, surface in pairs(game.surfaces) do
    local drones = surface.find_entities_filtered{name="clean-drone", force=player.force}
    for _, ent in ipairs(drones) do
      if ent.valid then
        local ins = player.insert{name="clean-drone", count=1}
        if ins > 0 then
          ent.destroy()
          recalled = recalled + 1
        end
      end
    end
  end
  player.print({"", "[CleanDrone] Recalled drones: ", recalled})
end

script.on_event(defines.events.on_lua_shortcut, function(e)
  if e.prototype_name == "cleandrone-recall" then
    local p = game.get_player(e.player_index)
    recall_for_player(p)
  end
end)

script.on_event("cleandrone-recall", function(e)
  local p = game.get_player(e.player_index)
  recall_for_player(p)
end)
