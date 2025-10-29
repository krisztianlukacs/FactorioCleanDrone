-- CleanDrone shortcuts & input (Factorio 2.0)
data:extend({
  {
    type = "shortcut",
    name = "cleandrone-recall",
    action = "lua",
    toggleable = false,
    icon = "__CleanDrone__/graphics/clean_drone_shortcut.png",
    small_icon = "__CleanDrone__/graphics/clean_drone_shortcut.png",
    order = "z[cleandrone]-a[recall]",
    associated_control_input = "cleandrone-recall",
    localised_name = {"shortcut-name.cleandrone-recall"},
    localised_description = {"shortcut-description.cleandrone-recall"}
  }
})

data:extend({
  {
    type = "custom-input",
    name = "cleandrone-recall",
    key_sequence = "CONTROL + SHIFT + R",
    consuming = "none"
  }
})
