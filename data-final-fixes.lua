-- data.lua for Lava Heating Tower mod

-- Create the lava heating tower entity by copying the heating tower
local lava_heating_tower = table.deepcopy(data.raw["reactor"]["heating-tower"])

lava_heating_tower.name = "lava-heating-tower"
lava_heating_tower.minable.result = "lava-heating-tower"

-- Remove the burner (fuel slot) and add fluid box for lava instead
lava_heating_tower.burner = {
  type = "burner",
  fuel_categories = {"lava"},
  effectivity = 2.5,
  fuel_inventory_size = 0,
  burnt_inventory_size = 0,
  burns_fluid = true,
  smoke = {},
  light_flicker = {color = {0, 0, 0}},
  emissions_per_minute = {},
  fluid_box = {
    volume = 200,
    pipe_connections = {
      { flow_direction = "input-output", direction = defines.direction.north, position = {0, -1} },
      { flow_direction = "input-output", direction = defines.direction.east, position = {1, 0} },
      { flow_direction = "input-output", direction = defines.direction.south, position = {0, 1} },
      { flow_direction = "input-output", direction = defines.direction.west, position = {-1, 0} }
    },
    production_type = "input-output",
    filter = "lava"
  }
}

-- Set up energy source as fluid-burning
lava_heating_tower.energy_source = {
  type = "fluid",
  effectivity = 2.5, -- 250% efficiency like heating tower
  fluid_box = {
    volume = 200,
    pipe_connections = {
      { flow_direction = "input-output", direction = defines.direction.north, position = {0, -1} },
      { flow_direction = "input-output", direction = defines.direction.east, position = {1, 0} },
      { flow_direction = "input-output", direction = defines.direction.south, position = {0, 1} },
      { flow_direction = "input-output", direction = defines.direction.west, position = {-1, 0} }
    },
    production_type = "input-output",
    filter = "lava"
  },
  burns_fluid = true,
  scale_fluid_usage = true,
  maximum_temperature = 1000,
  specific_heat = settings.startup['vlp-power-production'].value .. "MW",
  max_transfer = settings.startup['vlp-power-production'].value .. "MW",
  min_working_temperature = 15
}
lava_heating_tower.consumption = settings.startup['vlp-power-production'].value .. "MW"
lava_heating_tower.fixed_direction = false

-- Maximum heat is still 1000°C like heating tower
lava_heating_tower.max_temperature = 1000

-- Set consumption rate (adjust as needed for balance)
lava_heating_tower.fluid_usage_per_tick = 1 --settings.startup['vlp-lava-consumption'].value -- Consumes 1 lava per tick (60/sec)

-- Add tint to make it visually distinct (purple)
lava_heating_tower.heating_tower_tint = {r = 0.6, g = 0.2, b = 0.9, a = 1.0}

-- Register the entity
data:extend({lava_heating_tower})

-- Create the item
local lava_heating_tower_item = table.deepcopy(data.raw["item"]["heating-tower"])
lava_heating_tower_item.name = "lava-heating-tower"
lava_heating_tower_item.place_result = "lava-heating-tower"
lava_heating_tower_item.order = "b[steam-power]-d[lava-heating-tower]"

data:extend({lava_heating_tower_item})

-- Create the recipe (requires tungsten plates, pipes, and copper)
data:extend({
  {
    type = "recipe",
    name = "lava-heating-tower",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "tungsten-carbide", amount = 40},
      {type = "item", name = "pipe", amount = 10},
      {type = "item", name = "copper-plate", amount = 50}
    },
    results = {{type = "item", name = "lava-heating-tower", amount = 1}}
  }
})

-- Add recipe unlock to tungsten-carbide technology
table.insert(data.raw.technology["tungsten-carbide"].effects, {
  type = "unlock-recipe",
  recipe = "lava-heating-tower"
})

-- Modify acid neutralization to produce cold steam (120°C)
if data.raw.recipe["acid-neutralisation"] then
  local acid_recipe = data.raw.recipe["acid-neutralisation"]

  -- Update the results to specify cold steam temperature
  for _, result in pairs(acid_recipe.results) do
    if result.name == "steam" or result[1] == "steam" then
      result.temperature = 40
    end
  end
end

if data.raw.fluid["lava"] then
  data.raw.fluid["lava"].fuel_value = settings.startup['vlp-lava-energy'].value .. "kJ"
  --data.raw.fluid["lava"].fuel_value = "kJ" -- Energy per unit of lava
  data.raw.fluid["lava"].fuel_category = "lava" -- Or create custom category
end
