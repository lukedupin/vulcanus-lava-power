-- Allows the user to configure power output and total value
-- File: settings.lua

data:extend({
  {
    type = "int-setting",
    name = "vlp-power-production",
    setting_type = "startup",
    default_value = 80,
    minimum_value = 5,
    maximum_value = 200,
    order = "a-a"
  },
  {
    type = "int-setting", 
    name = "vlp-lava-energy",
    setting_type = "startup",
    default_value = 180,
    minimum_value = 1,
    maximum_value = 1000,
    order = "a-b"
  }
})
