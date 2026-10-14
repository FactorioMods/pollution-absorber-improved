local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

-- Pollution Absorber: reactor type, identical to heating tower.
-- Burns chemical fuel → absorbs pollution when burning.
-- control.lua handles active absorption (800/s in 80-tile radius).
-- energy_source.emissions_per_minute handles passive absorption (-327/min).

data:extend({
  {
    type = "reactor",
    name = "pollution-absorber",
    icon = "__pollution-absorber-improved__/graphics/pollution-absorber-icon.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "pollution-absorber"},
    max_health = 500,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      {type = "fire", percent = 70},
    },
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    consumption = "250kW",
    neighbour_bonus = 0,
    energy_source = {
      type = "burner",
      fuel_categories = {"chemical"},
      effectivity = 1,
      fuel_inventory_size = 1,
      emissions_per_minute = {pollution = -327},
    },
    heat_buffer = {
      max_temperature = 1000,
      specific_heat = "1MJ",
      max_transfer = "1GW",
      minimum_glow_temperature = 350,
      connections = {
        {position = {0, -1.5}, direction = defines.direction.north},
        {position = {1.5, 0}, direction = defines.direction.east},
        {position = {0, 1.5}, direction = defines.direction.south},
        {position = {-1.5, 0}, direction = defines.direction.west},
      },
    },
    picture = {
      layers = {
        {
          filename = "__pollution-absorber-improved__/graphics/pollution-absorber.png",
          priority = "high",
          width = 192,
          height = 192,
          frame_count = 1,
          shift = util.by_pixel(0, 0),
          scale = 0.7,
        },
      },
    },
    light = {
      intensity = 0.6,
      size = 8,
      color = {r = 0.2, g = 1.0, b = 0.2},
    },
    impact_category = "metal-large",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    working_sound = {
      sound = {
        filename = "__base__/sound/heat-exchanger.ogg",
        volume = 0.6,
      },
      match_speed_to_activity = true,
    },
  },
})
