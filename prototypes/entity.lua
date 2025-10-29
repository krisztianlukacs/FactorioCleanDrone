local drone = {
  type = "simple-entity-with-owner",
  name = "clean-drone",
  icon = "__CleanDrone__/graphics/clean_drone.png",
  icon_size = 32,
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  selectable_in_game = true,
  selection_box = {{-0.2, -0.2}, {0.2, 0.2}},
  minable = {mining_time = 0.1, result = "clean-drone"},
  max_health = 100,
  render_layer = "object",
  animations = {
    {
      filename = "__CleanDrone__/graphics/clean_drone_anim.png",
      width = 32,
      height = 36,
      frame_count = 8,
      line_length = 8,
      animation_speed = 0.4
    }
  }
}
data:extend({drone})
