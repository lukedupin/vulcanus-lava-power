-- Allows the user to configure power output and total value
-- File: settings.lua

data:extend({
  {
    type = "int-setting",
    name = "power-production",
    setting_type = "startup",
    default_value = 80,
    minimum_value = 5,
    maximum_value = 200,
    order = "a-a"
  },
  {
    type = "int-setting", 
    name = "lava-consumption",
    setting_type = "startup",
    default_value = 60,
    minimum_value = 1,
    maximum_value = 500,
    order = "a-b"
  }
})
