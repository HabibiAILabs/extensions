local function register(name, description, schema, handler)
  habibi.tools.register({
    name = name,
    description = description,
    input_schema = schema
  }, handler)
end

register("extension-studio.list", "List isolated extension drafts available for authoring.", {
  type = "object", additionalProperties = false, properties = {}
}, function()
  return { result = { drafts = habibi.studio.list() } }
end)

register("extension-studio.create", "Create a minimal API v2 extension draft without overwriting existing files. Installation always requires explicit user approval in the Studio UI.", {
  type = "object", additionalProperties = false,
  properties = {
    id = { type = "string", pattern = "^[a-z][a-z0-9_-]{0,63}$" },
    name = { type = "string", minLength = 1, maxLength = 100 },
    description = { type = "string", minLength = 1, maxLength = 500 }
  },
  required = { "id", "name", "description" }
}, function(arguments)
  return { result = habibi.studio.create(arguments) }
end)

register("extension-studio.files", "List allowlisted UTF-8 source files in one extension draft.", {
  type = "object", additionalProperties = false,
  properties = { draft_id = { type = "string" } }, required = { "draft_id" }
}, function(arguments)
  return { result = { files = habibi.studio.list_files(arguments.draft_id) } }
end)

register("extension-studio.read", "Read one UTF-8 draft source file with its SHA-256 for checked editing.", {
  type = "object", additionalProperties = false,
  properties = {
    draft_id = { type = "string" },
    path = { type = "string", description = "Relative allowlisted source path." }
  },
  required = { "draft_id", "path" }
}, function(arguments)
  return { result = habibi.studio.read(arguments) }
end)

register("extension-studio.write", "Create or hash-check replace one UTF-8 draft source file. Existing files require the SHA-256 returned by extension-studio.read.", {
  type = "object", additionalProperties = false,
  properties = {
    draft_id = { type = "string" },
    path = { type = "string", description = "Relative .toml, .lua, .html, .css, .js, .md, or .json path." },
    content = { type = "string", maxLength = 1048576 },
    expected_sha256 = { type = "string", description = "Required for an existing file; omit only when creating." }
  },
  required = { "draft_id", "path", "content" }
}, function(arguments)
  return { result = habibi.studio.write(arguments) }
end)

register("extension-studio.mkdir", "Create one directory level inside an extension draft. This never creates parents recursively.", {
  type = "object", additionalProperties = false,
  properties = {
    draft_id = { type = "string" },
    path = { type = "string", description = "Relative directory path whose parent already exists." }
  },
  required = { "draft_id", "path" }
}, function(arguments)
  habibi.studio.mkdir(arguments)
  return { result = { created = true, path = arguments.path } }
end)

register("extension-studio.validate", "Run the real package hash, security/privacy scanner, manifest checks, and isolated runtime loading for a draft. This cannot install it.", {
  type = "object", additionalProperties = false,
  properties = { draft_id = { type = "string" } }, required = { "draft_id" }
}, function(arguments)
  return { result = habibi.studio.validate(arguments.draft_id) }
end)
