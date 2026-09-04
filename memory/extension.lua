local MAX_CAUSAL_EVENTS = 20
local MAX_SEMANTIC_EVENTS = 20
local MINIMUM_SIMILARITY = 0.50
local MAX_QUERY_BYTES = 16 * 1024
local MAX_CONTEXT_BYTES = 96 * 1024

local function append_bounded(items, value, budget)
  local encoded = habibi.json.encode(value)
  if #encoded > budget.remaining then
    budget.truncated = true
    return
  end
  table.insert(items, value)
  budget.remaining = budget.remaining - #encoded
end

local function label(value)
  return tostring(value):gsub("_", " "):gsub("^%l", string.upper)
end

local function scalar(value)
  if value == nil then return "—" end
  if type(value) == "boolean" then return value and "yes" or "no" end
  return tostring(value):gsub("\n", "\n  ")
end

local function render_fields(value, indent, lines)
  if type(value) ~= "table" then
    table.insert(lines, indent .. scalar(value))
    return
  end
  if #value > 0 then
    for _, item in ipairs(value) do
      if type(item) == "table" then
        table.insert(lines, indent .. "-")
        render_fields(item, indent .. "  ", lines)
      else
        table.insert(lines, indent .. "- " .. scalar(item))
      end
    end
    return
  end
  local keys = {}
  for key, _ in pairs(value) do table.insert(keys, key) end
  table.sort(keys)
  for _, key in ipairs(keys) do
    local item = value[key]
    if type(item) == "table" then
      table.insert(lines, indent .. "- **" .. label(key) .. ":**")
      render_fields(item, indent .. "  ", lines)
    else
      table.insert(lines, indent .. "- **" .. label(key) .. ":** " .. scalar(item))
    end
  end
end

local function render_section(lines, title, items)
  if #items == 0 then return end
  table.insert(lines, "## " .. title)
  for _, item in ipairs(items) do
    local event = item.event or item
    table.insert(lines, "### " .. tostring(event.event_type or "Memory"))
    render_fields(item, "", lines)
  end
end

local function retrieve(trigger)
  local causal_newest_first = habibi.array({})
  local seen = {}
  local event_id = trigger.causation_id

  while type(event_id) == "string" and #causal_newest_first < MAX_CAUSAL_EVENTS do
    if seen[event_id] then break end
    local event = habibi.events.get(event_id)
    if not event then break end
    seen[event_id] = true
    table.insert(causal_newest_first, event)
    event_id = event.causation_id
  end

  local budget = { remaining = MAX_CONTEXT_BYTES, truncated = false }
  local causal = habibi.array({})
  for index = #causal_newest_first, 1, -1 do
    append_bounded(causal, causal_newest_first[index], budget)
  end

  local referenced = habibi.array({})
  local result_ids = trigger.payload.result_event_ids
  if type(result_ids) == "table" then
    for _, id in ipairs(result_ids) do
      if type(id) == "string" and not seen[id] then
        local event = habibi.events.get(id)
        if event then
          seen[id] = true
          append_bounded(referenced, event, budget)
        end
      end
    end
  end

  local semantic = habibi.array({})
  local semantic_metadata = nil
  local stored_trigger = habibi.events.get(trigger.id)
  if stored_trigger then
    local query = trigger.event_type .. "\n" .. habibi.json.encode(trigger.payload)
    if #query > MAX_QUERY_BYTES then query = query:sub(1, MAX_QUERY_BYTES) end
    local ok, matches = pcall(habibi.events.semantic, {
      text = query,
      before_sequence = stored_trigger.sequence,
      limit = MAX_SEMANTIC_EVENTS,
      minimum_similarity = MINIMUM_SIMILARITY
    })
    if ok then
      semantic_metadata = {
        embedding_model = matches.embedding_model,
        embedding_revision = matches.embedding_revision,
        candidates_scanned = matches.candidates_scanned
      }
      for _, match in ipairs(matches.matches) do
        local id = match.event.id
        if not seen[id] then
          seen[id] = true
          append_bounded(semantic, match, budget)
        end
      end
    end
  end

  if #causal == 0 and #referenced == 0 and #semantic == 0 then return { content = "" } end
  local lines = { "# Retrieved memory" }
  render_section(lines, "Causal history", causal)
  render_section(lines, "Referenced results", referenced)
  render_section(lines, "Semantically related events", semantic)
  if semantic_metadata then
    table.insert(lines, "## Retrieval details")
    render_fields(semantic_metadata, "", lines)
  end
  if budget.truncated then
    table.insert(lines, "\n> Memory was truncated to fit the context budget.")
  end
  return { content = table.concat(lines, "\n") }
end

habibi.context.register("retrieve", retrieve)
