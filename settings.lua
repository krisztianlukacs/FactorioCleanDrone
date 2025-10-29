data:extend({
  { type = "int-setting", name = "cd_search_radius", setting_type = "runtime-global", default_value = 32, minimum_value = 8, maximum_value = 128, order = "a[radius]" },
  { type = "int-setting", name = "cd_tick_interval", setting_type = "runtime-global", default_value = 30, minimum_value = 1, maximum_value = 120, order = "b[interval]" },
  { type = "double-setting", name = "cd_step_speed", setting_type = "runtime-global", default_value = 0.25, minimum_value = 0.01, maximum_value = 1.0, order = "c[speed]" },
  { type = "bool-setting", name = "cd_controller_required", setting_type = "runtime-global", default_value = false, order = "d[controller]" },
  { type = "int-setting", name = "cd_leash_distance", setting_type = "runtime-global", default_value = 80, minimum_value = 10, maximum_value = 200, order = "e[leash]" },
  { type = "bool-setting", name = "cd_debug", setting_type = "runtime-global", default_value = false, order = "f[debug]" },
  { type = "int-setting", name = "cd_work_divisor", setting_type = "runtime-global", default_value = 6, minimum_value = 1, maximum_value = 60, order = "g[workdiv]" }
})
