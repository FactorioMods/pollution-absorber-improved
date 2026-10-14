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

local chunk_pool = {}
local update_id = 0

local function acquire_chunk(surface, cx, cy)
  local columns = chunk_pool[surface.index]
  if not columns then columns = {}; chunk_pool[surface.index] = columns end
  local column = columns[cx]
  if not column then column = {}; columns[cx] = column end
  local chunk = column[cy]
  if not chunk then
    chunk = {position = {x = cx * 32, y = cy * 32}, cx = cx, cy = cy,
      surface_index = surface.index, references = 0}
    column[cy] = chunk
  end
  chunk.references = chunk.references + 1
  return chunk
end

local function release_chunk(chunk)
  chunk.references = chunk.references - 1
  if chunk.references > 0 then return end
  local columns = chunk_pool[chunk.surface_index]
  local column = columns[chunk.cx]
  column[chunk.cy] = nil
  if next(column) == nil then columns[chunk.cx] = nil end
  if next(columns) == nil then chunk_pool[chunk.surface_index] = nil end
end

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
      sample = {chunk = acquire_chunk(entry.surface, cx, cy), count = 1}
      column[cy] = sample
      samples[#samples + 1] = sample
    end
  end
  entry.samples = samples
end

local function make_entry(entity)
  local entry = {entity = entity, surface = entity.surface, position = entity.position}
  entry.center = acquire_chunk(entry.surface, math.floor(entry.position.x / 32), math.floor(entry.position.y / 32))
  cache_samples(entry)
  return entry
end

local function remove_entry(id)
  local entry = absorbers[id]
  if not entry then return end
  release_chunk(entry.center)
  for _, sample in ipairs(entry.samples) do release_chunk(sample.chunk) end
  absorbers[id] = nil
end

local function is_absorber(entity)
  return entity.valid and entity.name == ABSORBER_NAME
end

local function track_entity(event)
  local entity = event.entity or event.created_entity
  if not entity or not entity.valid then return end
  if not is_absorber(entity) then return end
  remove_entry(entity.unit_number)
  absorbers[entity.unit_number] = make_entry(entity)
end

local function untrack_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if not is_absorber(entity) then return end
  remove_entry(entity.unit_number)
end

script.on_event(defines.events.on_built_entity, track_entity)
script.on_event(defines.events.on_robot_built_entity, track_entity)
script.on_event(defines.events.script_raised_built, track_entity)
script.on_event(defines.events.script_raised_revive, track_entity)

script.on_event(defines.events.on_entity_died, untrack_entity)
script.on_event(defines.events.on_player_mined_entity, untrack_entity)
script.on_event(defines.events.on_robot_mined_entity, untrack_entity)
script.on_event(defines.events.script_raised_destroy, untrack_entity)


-- Values are shared only within one synchronous update and every write
-- updates the cached value. The next update always reads fresh pollution.
local function read_chunk(surface, chunk)
  if chunk.update_id ~= update_id then
    chunk.pollution = surface.get_pollution(chunk.position)
    chunk.update_id = update_id
  end
  return chunk.pollution
end

local function absorb_pollution(entry)
  local energy = entry.entity.energy
  if not energy or energy <= 0 then return end
  local surface = entry.surface
  local center = entry.center
  local center_pollution = read_chunk(surface, center)
  if center_pollution > 0 then
    local amount = math.min(effective_rate * 0.3, center_pollution)
    surface.pollute(entry.position, -amount)
    center.pollution = center_pollution - amount
  end
  for _, sample in ipairs(entry.samples) do
    local chunk = sample.chunk
    local pollution = read_chunk(surface, chunk)
    if pollution > 0 then
      local remaining = pollution
      for i = 1, sample.count do
        remaining = remaining - math.min(per_point, remaining)
      end
      local change = remaining - pollution
      surface.pollute(chunk.position, change)
      chunk.pollution = pollution + change
    end
  end
end

script.on_nth_tick(CHECK_INTERVAL, function()
  update_id = update_id + 1
  storage.update_id = update_id
  for unit_number, entry in pairs(absorbers) do
    if not entry.entity.valid then
      remove_entry(unit_number)
    else
      absorb_pollution(entry)
    end
  end
end)

local function scan_surfaces()
  absorbers = {}
  chunk_pool = {}
  update_id = 0
  storage.absorbers = absorbers
  storage.chunk_pool = chunk_pool
  storage.update_id = update_id
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

-- Loading and multiplayer joins must restore the same local references without
-- changing event registrations or mutating the saved state.
script.on_load(function()
  absorbers = storage.absorbers or {}
  chunk_pool = storage.chunk_pool or {}
  update_id = storage.update_id or 0
end)
