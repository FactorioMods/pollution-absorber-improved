--[[
  Runtime script: active pollution absorption.
  Only absorbs when the reactor is burning fuel.
]]

local absorbers = {}

local ABSORBER_NAME = "pollution-absorber"
local ABSORPTION_RADIUS = 80
local ABSORPTION_RATE = 800
local CHECK_INTERVAL = 60

local effective_rate = ABSORPTION_RATE * (CHECK_INTERVAL / 60)

local function is_absorber(entity)
  return entity.valid and entity.name == ABSORBER_NAME
end

local function track_entity(event)
  local entity = event.entity or event.created_entity
  if not entity or not entity.valid then return end
  if not is_absorber(entity) then return end
  absorbers[entity.unit_number] = {
    entity = entity,
    surface = entity.surface,
    position = entity.position,
  }
end

local function untrack_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if not is_absorber(entity) then return end
  absorbers[entity.unit_number] = nil
end

script.on_event(defines.events.on_built_entity, track_entity)
script.on_event(defines.events.on_robot_built_entity, track_entity)
script.on_event(defines.events.script_raised_built, track_entity)
script.on_event(defines.events.script_raised_revive, track_entity)

script.on_event(defines.events.on_entity_died, untrack_entity)
script.on_event(defines.events.on_player_mined_entity, untrack_entity)
script.on_event(defines.events.on_robot_mined_entity, untrack_entity)
script.on_event(defines.events.script_raised_destroy, untrack_entity)

local function absorb_pollution(entry)
  local entity = entry.entity
  if not entity.energy or entity.energy <= 0 then return end

  local surface = entry.surface
  local pos = entry.position

  local center_pollution = surface.get_pollution(pos)
  if center_pollution > 0 then
    local to_absorb = math.min(effective_rate * 0.3, center_pollution)
    surface.pollute(pos, -to_absorb)
  end

  local step = 16
  local half = ABSORPTION_RADIUS
  local sample_count = 0
  for dx = -half, half, step do
    for dy = -half, half, step do
      if dx * dx + dy * dy <= half * half then
        sample_count = sample_count + 1
      end
    end
  end
  if sample_count == 0 then return end

  local per_point = effective_rate * 0.7 / sample_count
  for dx = -half, half, step do
    for dy = -half, half, step do
      if dx * dx + dy * dy <= half * half then
        local sample_pos = {x = pos.x + dx, y = pos.y + dy}
        local pollution = surface.get_pollution(sample_pos)
        if pollution > 0 then
          local to_absorb = math.min(per_point, pollution)
          surface.pollute(sample_pos, -to_absorb)
        end
      end
    end
  end
end

script.on_nth_tick(CHECK_INTERVAL, function()
  for unit_number, entry in pairs(absorbers) do
    if not entry.entity.valid then
      absorbers[unit_number] = nil
    else
      absorb_pollution(entry)
    end
  end
end)

local function scan_surfaces()
  absorbers = {}
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{name = ABSORBER_NAME}) do
      if entity.valid then
        absorbers[entity.unit_number] = {
          entity = entity,
          surface = surface,
          position = entity.position,
        }
      end
    end
  end
end

script.on_init(function()
  absorbers = {}
  scan_surfaces()
end)

script.on_configuration_changed(function()
  scan_surfaces()
end)

local first_tick = true
script.on_event(defines.events.on_tick, function()
  if first_tick then
    first_tick = false
    scan_surfaces()
  end
end)
