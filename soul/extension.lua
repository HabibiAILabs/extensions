habibi.web.home({ path = "/", icon = "/icon.svg", title = "Soul Config" })

local MAX_PROMPT_BYTES = 16 * 1024
local KEY = "prompt"

local function prompt()
  local value = habibi.kv.get(KEY)
  if type(value) ~= "string" then return "" end
  return value
end

habibi.web.route("GET", "/api/soul", function()
  return { status = 200, json = { prompt = prompt(), max_bytes = MAX_PROMPT_BYTES } }
end)

habibi.web.route("PUT", "/api/soul", function(request)
  if type(request.json) ~= "table" or type(request.json.prompt) ~= "string" then
    return { status = 400, json = { error = "prompt must be a string" } }
  end
  if #request.json.prompt > MAX_PROMPT_BYTES then
    return { status = 400, json = { error = "prompt exceeds 16 KiB" } }
  end
  habibi.kv.set(KEY, request.json.prompt)
  return { status = 200, json = { prompt = request.json.prompt, max_bytes = MAX_PROMPT_BYTES } }
end)

habibi.context.register("soul", function()
  local value = prompt()
  if value:match("^%s*$") then return { content = "" } end
  return {
    content = "# Agent soul\n\nUser-authored identity, personality, and behavioral preferences:\n\n" .. value
  }
end)
