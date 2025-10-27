local util = require("util")

-- CleanDrone entity prototype
-- We clone a construction-robot as a base flying entity, but the logic is fully scripted in control.lua
local drone = table.deepcopy(data.raw["construction-robot"]["construction-robot"])
drone.name = "clean-drone"
drone.icon = "__base__/graphics/icons/construction-robot.png"
drone.icon_size = 64
drone.max_health = 100
-- Movement/energy are controlled by script; set these so it never needs charging.
drone.speed = 0.06
drone.max_speed = 0.08
drone.energy_per_move = "0J"
drone.energy_per_tick = "0J"
drone.max_energy = "0J"
drone.minable = { mining_time = 0.1, result = "clean-drone" }
-- No collisions so it can fly over things.
drone.collision_mask = {}
drone.flags = {"placeable-player", "player-creation"}

data:extend({ drone })
