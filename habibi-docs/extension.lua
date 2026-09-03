local sections = {
  {
    title = "Runtime architecture",
    content = [[Habibi is a local event-sourced AI runtime. Durable domain facts are immutable events in SQLite. Operational diagnostics are logs, not events. One global durable inbox processes events serially. Every model invocation processes exactly one immutable current event, supplied as the invocation's sole user message. Tools produce immutable action.requested, result, effect, and actions.completed events. Provider conversations are rebuilt for each invocation.]]
  },
  {
    title = "Extension package and manifest",
    content = [[An extension is a directory containing extension.toml and extension.lua, with an optional web directory. Context extensions use api_version 3 or newer; global filesystem/process boundaries require api_version 4. Manifest fields are id, name, version, description, api_version, capabilities, and optional [web] static_dir. IDs use lowercase letters, digits, and hyphens. Tool names must use the extension ID namespace. Content changes require a semantic version increase. Installed extensions are trusted local code.]]
  },
  {
    title = "Capabilities",
    content = [[Capabilities default to false. Available capabilities are web, kv, events, tools, context, filesystem, process, and search. Capabilities expose only the corresponding habibi host APIs and make behavior visible for review. Lua has no io, os, package, debug, generic network, shell, filesystem, or secret access. Filesystem and process are additionally bounded by global core include/exclude settings.]]
  },
  {
    title = "Context hooks",
    content = [[API version 3 context hooks are registered with habibi.context.register(name, function(trigger) ... end). The trigger is the immutable current event. Return { content = "extension-formatted UTF-8 text" }. Core bounds and labels each contribution and places it in the system message. The extension owns selection and formatting. Return an empty content string when there is no relevant context. Context hooks run synchronously, deterministically, and independently; failures are logged and skipped.]]
  },
  {
    title = "Tools and actions",
    content = [[Register a tool with habibi.tools.register(definition, handler). A definition has name, description, and JSON Schema input_schema. The handler receives validated arguments and context and returns { result = ..., events = ... }. Core pins schemas and handlers to a catalog generation, validates the complete concurrent action group before executing anything, and records requests/results durably. User-visible replies and external effects must use tools; plain model text is ignored.]]
  },
  {
    title = "Events API",
    content = [[With events capability, habibi.events.get(id) returns one stored event or nil. habibi.events.query supports type, prefix, before_sequence, after_sequence, and bounded limit. habibi.events.semantic accepts text, before_sequence, limit, and minimum_similarity and returns local embedding model metadata plus ranked event matches. Extensions decide how to merge, deduplicate, and format retrieved events. Event causation, correlation, direct chat replies, and semantic links are distinct facts.]]
  },
  {
    title = "KV storage",
    content = [[With kv capability, use habibi.kv.get(key), set(key, JSON-compatible value), delete(key), and list(prefix). Core always supplies the extension namespace; extensions cannot access another extension's KV values. KV is appropriate for extension settings such as a user-authored soul prompt. Durable domain facts should remain events rather than mutable KV. The core Extensions page provides a read-only KV explorer. An extension may declare [config] schema = \"config.schema.json\" for a schema-validated configuration page and read the result with habibi.config.get().]]
  },
  {
    title = "Web routes and static UI",
    content = [[With web capability, register namespaced routes using habibi.web.route(method, path, handler). Requests include method, path, path_params, query, headers, body, and parsed json. Responses use status plus json or body/content_type. Configure [web] static_dir = "web" to serve package assets below /extensions/EXTENSION_ID/. Call habibi.web.home({ path = "/", icon = "/icon.svg" }) to designate an optional app shown on Habibi's homepage and opened in the shared /apps shell. Routes and static content share Habibi's origin and are trusted local application code.]]
  },
  {
    title = "Filesystem, process, and search",
    content = [[Filesystem access is default-deny, bounded by global directory wildcard patterns, no-follow, hash-checked, atomic, and output-bounded. The most specific boundary rule wins and includes win ties. Process execution is Linux-only, bounded by global program and directory patterns, output-limited, and sandboxed with Bubblewrap and cgroup v2. Essentials deliberately exposes Bash when it is approved. Search exposes only configured Brave or SearXNG adapters, not generic HTTP. These host APIs are action-only where external effects are possible.]]
  },
  {
    title = "Installation and development workflow",
    content = [[Install with: habibi install PATH_OR_GIT_URL [--subdir ID] [--ref TAG]. Update with habibi update ID and roll back with habibi rollback ID. Installation copies and scans the package, rejects symlinks and unsafe paths, validates Lua in isolation, records provenance/hash, and atomically replaces the installed generation. To modify behavior, use an available coding extension to edit an extension package, increment its version, validate locally, then install or update it.]]
  },
  {
    title = "Minimal extension example",
    content = [[extension.toml: id = "example", name = "Example", version = "0.1.0", api_version = 3, then [capabilities] tools = true and context = true. extension.lua may register a context hook returning { content = "Relevant context" } and a tool named example.lookup whose handler returns { result = { value = "..." }, events = {} }. Add [web] static_dir = "web" plus web = true for a UI, or kv = true for private settings.]]
  }
}

local function words(value)
  local result = {}
  for word in value:lower():gmatch("[%w_%-%.]+") do result[word] = true end
  return result
end

habibi.tools.register({
  name = "habibi-docs.search",
  description = "Search Habibi's authoritative local runtime and extension-development documentation. Use for questions about how Habibi works or how to create, inspect, or modify extensions, including events, context, tools, KV, web routes, capabilities, installation, and security.",
  input_schema = {
    type = "object",
    additionalProperties = false,
    properties = {
      query = { type = "string", minLength = 1, maxLength = 4096, description = "The Habibi runtime or extension-development question." }
    },
    required = { "query" }
  }
}, function(arguments)
  local query_words = words(arguments.query)
  local ranked = {}
  for index, section in ipairs(sections) do
    local title = section.title:lower()
    local content = section.content:lower()
    local score = 0
    for word in pairs(query_words) do
      if title:find(word, 1, true) then score = score + 4 end
      if content:find(word, 1, true) then score = score + 1 end
    end
    table.insert(ranked, { index = index, score = score, section = section })
  end
  table.sort(ranked, function(left, right)
    if left.score ~= right.score then return left.score > right.score end
    return left.index < right.index
  end)
  local matches = habibi.array({})
  for _, candidate in ipairs(ranked) do
    if #matches == 5 or candidate.score == 0 then break end
    table.insert(matches, {
      title = candidate.section.title,
      content = candidate.section.content,
      score = candidate.score
    })
  end
  if #matches == 0 then
    table.insert(matches, { title = sections[1].title, content = sections[1].content, score = 0 })
  end
  return { result = { query = arguments.query, sections = matches } }
end)
