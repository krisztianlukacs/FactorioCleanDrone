data:extend({
  {
    type = "technology",
    name = "clean-drone-tech",
    icon = "__CleanDrone__/graphics/clean_drone.png",
    icon_size = 32,
    prerequisites = {"logistic-robotics"},
    unit = {
      count = 50,
      ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
      time = 15
    },
    effects = {
      { type = "unlock-recipe", recipe = "clean-drone" }
    },
    order = "a-b-z[clean-drone]"
  }
})
