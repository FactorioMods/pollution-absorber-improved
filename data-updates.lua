data:extend({
  -- Placement recipe: craftable by hand
  {
    type = "recipe",
    name = "pollution-absorber",
    icon = "__pollution-absorber-improved__/graphics/pollution-absorber-icon.png",
    icon_size = 64,
    categories = {"crafting"},
    enabled = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 100},
      {type = "item", name = "copper-plate", amount = 100},
    },
    results = {
      {type = "item", name = "pollution-absorber", amount = 1},
    },
    allow_productivity = false,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },

  -- Item
  {
    type = "item",
    name = "pollution-absorber",
    icon = "__pollution-absorber-improved__/graphics/pollution-absorber-icon.png",
    icon_size = 64,
    subgroup = "production-machine",
    order = "z[pollution-absorber]",
    place_result = "pollution-absorber",
    stack_size = 10,
  },
})
