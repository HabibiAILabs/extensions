local function register(name, description, input_schema, operation)
  habibi.tools.register({
    name = "essentials." .. name,
    description = description,
    input_schema = input_schema
  }, function(arguments)
    return { result = operation(arguments) }
  end)
end

local path_schema = {
  type = "object",
  additionalProperties = false,
  properties = {
    path = { type = "string", description = "Absolute path inside Habibi's global directory boundary." }
  },
  required = { "path" }
}

register(
  "ls",
  "List files and directories at an absolute path. Use this to inspect a directory, discover projects, or see what files are available. Returns at most 500 sorted entries.",
  {
    type = "object",
    additionalProperties = false,
    properties = {
      path = path_schema.properties.path,
      limit = { type = "integer", minimum = 1, maximum = 500, description = "Maximum entries to return; defaults to 200." }
    },
    required = { "path" }
  },
  function(arguments)
    local entries = habibi.files.list({ path = arguments.path })
    local limit = arguments.limit or 200
    local bounded = habibi.array({})
    for index = 1, math.min(#entries, limit) do table.insert(bounded, entries[index]) end
    return { entries = bounded, total = #entries, truncated = #entries > limit }
  end
)

register(
  "read",
  "Read a bounded range of lines from one UTF-8 text file. Use this to inspect source code, configuration, documentation, or other text without loading the entire file.",
  {
    type = "object",
    additionalProperties = false,
    properties = {
      path = path_schema.properties.path,
      offset = { type = "integer", minimum = 1, description = "One-based line at which to start; defaults to 1." },
      limit = { type = "integer", minimum = 1, maximum = 2000, description = "Maximum lines to return; defaults to 2000. Output is also capped by bytes." }
    },
    required = { "path" }
  },
  function(arguments)
    local file = habibi.files.read({ path = arguments.path })
    local offset = arguments.offset or 1
    local limit = arguments.limit or 2000
    local selected = {}
    local line_number = 0
    local selected_bytes = 0
    local total_lines = 0
    local byte_limit = 48 * 1024
    for line in (file.content .. "\n"):gmatch("(.-)\n") do
      total_lines = total_lines + 1
      if total_lines >= offset and line_number < limit then
        local rendered = line .. "\n"
        if selected_bytes + #rendered <= byte_limit then
          table.insert(selected, rendered)
          selected_bytes = selected_bytes + #rendered
          line_number = line_number + 1
        end
      end
    end
    return {
      path = file.path,
      content = table.concat(selected),
      sha256 = file.sha256,
      bytes = file.bytes,
      offset = offset,
      lines = line_number,
      total_lines = total_lines,
      truncated = offset > 1 or line_number < total_lines
    }
  end
)

register(
  "edit",
  "Atomically replace one unique exact text block in a UTF-8 file. Use the SHA-256 returned by essentials.read to prevent stale writes. The edit fails if old_text is missing or repeated.",
  {
    type = "object",
    additionalProperties = false,
    properties = {
      path = path_schema.properties.path,
      old_text = { type = "string", minLength = 1, description = "Exact text to replace once." },
      new_text = { type = "string", description = "Replacement text." },
      expected_sha256 = { type = "string", description = "SHA-256 returned by essentials.read." }
    },
    required = { "path", "old_text", "new_text", "expected_sha256" }
  },
  habibi.files.patch
)

register(
  "grep",
  "Search UTF-8 files recursively for case-insensitive literal text. Use this to find symbols, messages, configuration values, or references across a directory tree.",
  {
    type = "object",
    additionalProperties = false,
    properties = {
      path = { type = "string", description = "Absolute directory to search." },
      query = { type = "string", minLength = 1, maxLength = 1024, description = "Literal text to find." },
      limit = { type = "integer", minimum = 1, maximum = 200, description = "Maximum matches; defaults to 50." }
    },
    required = { "path", "query" }
  },
  habibi.files.search
)

register(
  "find",
  "Find files and directories recursively by name pattern beneath an absolute directory. Use this for file discovery when the location or filename is uncertain.",
  {
    type = "object",
    additionalProperties = false,
    properties = {
      path = { type = "string", description = "Absolute directory from which to search." },
      pattern = { type = "string", description = "Optional find name pattern such as '*.rs'; defaults to '*'." },
      timeout_ms = { type = "integer", minimum = 1, maximum = 120000, description = "Timeout; defaults to 30000 ms." }
    },
    required = { "path" }
  },
  function(arguments)
    return habibi.process.run({
      program = "find",
      args = habibi.array({ ".", "-name", arguments.pattern or "*", "-print" }),
      cwd = arguments.path,
      timeout_ms = arguments.timeout_ms,
      filesystem_access = "read_only"
    })
  end
)

register(
  "bash",
  "Run a Bash command in a bounded Linux sandbox. Use this for shell pipelines or operating-system tasks not covered by essentials.read, edit, find, grep, or ls. The command has no network and can access only its approved working directory.",
  {
    type = "object",
    additionalProperties = false,
    properties = {
      command = { type = "string", minLength = 1, description = "Bash command evaluated with 'bash -lc'." },
      cwd = { type = "string", description = "Absolute working directory inside Habibi's global directory boundary." },
      timeout_ms = { type = "integer", minimum = 1, maximum = 120000, description = "Timeout; defaults to 30000 ms." }
    },
    required = { "command", "cwd" }
  },
  function(arguments)
    return habibi.process.run({
      program = "bash",
      args = habibi.array({ "-lc", arguments.command }),
      cwd = arguments.cwd,
      timeout_ms = arguments.timeout_ms,
      filesystem_access = "read_write"
    })
  end
)
