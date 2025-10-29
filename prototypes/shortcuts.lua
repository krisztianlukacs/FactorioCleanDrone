data:extend({
  {
    type = "shortcut",
    name = "cleandrone-recall",
    action = "lua",
    toggleable = false,
    icon = "__CleanDrone__/graphics/clean_drone_shortcut.png",
    small_icon = "__CleanDrone__/graphics/clean_drone_shortcut.png",
    icon_size = 64,
    small_icon_size = 64,
    associated_control_input = "cleandrone-recall",
    order = "z[cleandrone]-a[recall]",
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
