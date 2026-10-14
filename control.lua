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

-- Pollution is stored per 32-tile chunk. Cache the original sample grid,
-- grouped by chunk, so repeated visits need only one engine read/write.
local sample_offsets = {}
for dx = -ABSORPTION_RADIUS, ABSORPTION_RADIUS, 16 do
  for dy = -ABSORPTION_RADIUS, ABSORPTION_RADIUS, 16 do
    if dx * dx + dy * dy <= ABSORPTION_RADIUS * ABSORPTION_RADIUS then
      sample_offsets[#sample_offsets + 1] = {dx, dy}
    end
  end
end
local per_point = effective_rate * 0.7 / #sample_offsets

local function cache_samples(entry)
  local samples, chunks = {}, {}
  for _, offset in ipairs(sample_offsets) do
    local x, y = entry.position.x + offset[1], entry.position.y + offset[2]
    local cx, cy = math.floor(x / 32), math.floor(y / 32)
    local column = chunks[cx]
    if not column then column = {}; chunks[cx] = column end
    local sample = column[cy]
    if sample then
      sample.count = sample.count + 1
    else
      sample = {position = {x = x, y = y}, count = 1}
      column[cy] = sample
      samples[#samples + 1] = sample
    end
  end
  entry.samples = samples
end

local function make_entry(entity)
  local entry = {entity = entity, surface = entity.surface, position = entity.position}
  cache_samples(entry)
  return entry
end

local function is_absorber(entity)
  return entity.valid and entity.name == ABSORBER_NAME
end

local function track_entity(event)
  local entity = event.entity or event.created_entity
  if not entity or not entity.valid then return end
  if not is_absorber(entity) then return end
  absorbers[entity.unit_number] = make_entry(entity)
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
  local energy = entry.entity.energy
  if not energy or energy <= 0 then return end
  local surface, pos = entry.surface, entry.position
  local center_pollution = surface.get_pollution(pos)
  if center_pollution > 0 then
    surface.pollute(pos, -math.min(effective_rate * 0.3, center_pollution))
  end
  for _, sample in ipairs(entry.samples) do
    local pollution = surface.get_pollution(sample.position)
    if pollution > 0 then
      local remaining = pollution
      -- Keep the original repeated subtraction and zero clamp.
      for i = 1, sample.count do
        remaining = remaining - math.min(per_point, remaining)
      end
      surface.pollute(sample.position, remaining - pollution)
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
        absorbers[entity.unit_number] = make_entry(entity)
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

-- Local entity references are rebuilt after loading a save. The one-time
-- handler is removed immediately; ordinary ticks need no script callback.
script.on_load(function()
  script.on_event(defines.events.on_tick, function()
    scan_surfaces()
    script.on_event(defines.events.on_tick, nil)
  end)
end)
