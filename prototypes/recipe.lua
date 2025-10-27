-- Recipe: 1 logistic-robot + 1 coal -> 1 CleanDrone
data:extend({
  {
    type = "recipe",
    name = "clean-drone",
    localised_name = {"recipe-name.clean-drone"},
    enabled = false,
    ingredients = {
      {"logistic-robot", 1},
      {"coal", 1}
    },
    result = "clean-drone"
  }
})
