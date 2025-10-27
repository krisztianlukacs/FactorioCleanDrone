-- Item prototype for the CleanDrone
data:extend({
  {
    type = "item",
    name = "clean-drone",
    localised_name = {"item-name.clean-drone"},
    localised_description = {"item-description.clean-drone"},
    icon = "__base__/graphics/icons/construction-robot.png",
    icon_size = 64,
    subgroup = "logistic-network",
    order = "a[robot]-z[clean-drone]",
    place_result = "clean-drone",
    stack_size = 50
  }
})
