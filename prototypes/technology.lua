-- Technology that unlocks the CleanDrone. Costs 1 red + 1 green science per unit.
data:extend({
  {
    type = "technology",
    name = "clean-drone-tech",
    localised_name = {"technology-name.clean-drone-tech"},
    localised_description = {"technology-description.clean-drone-tech"},
    icon = "__base__/graphics/technology/logistic-robotics.png",
    icon_size = 256,
    prerequisites = {"logistics", "automation"},
    effects = {
      { type = "unlock-recipe", recipe = "clean-drone" }
    },
    unit = {
      count = 50,
      ingredients = {
        {"automation-science-pack", 1}, -- red
        {"logistic-science-pack", 1}    -- green
      },
      time = 15
    },
    order = "a-lz[clean-drone]"
  }
})
