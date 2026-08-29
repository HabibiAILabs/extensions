local path_schema = {
  type = "object",
  properties = {
    path = { type = "string", description = "Absolute path inside a granted filesystem root." }
  },
  required = { "path" }
}

local function register(name, description, input_schema, operation)
  habibi.tools.register({
    name = "workspace." .. name,
    description = description,
    input_schema = input_schema
  }, function(arguments, _context)
    return { result = operation(arguments) }
  end)
end

register(
  "list",
  "List files and directories at one absolute path inside a granted workspace root.",
  path_schema,
  habibi.files.list
)

register(
  "read",
  "Read one UTF-8 text file inside a granted workspace root, including its SHA-256 hash.",
  path_schema,
  habibi.files.read
)

register(
  "search",
  "Search UTF-8 files recursively for literal text inside a granted workspace root.",
  {
    type = "object",
    properties = {
      path = { type = "string", description = "Absolute directory inside a granted filesystem root." },
      query = { type = "string", description = "Case-insensitive literal text to find." },
      limit = { type = "integer", minimum = 1, maximum = 200 }
    },
    required = { "path", "query" }
  },
  habibi.files.search
)

register(
  "write",
  "Atomically create or replace one UTF-8 text file. expected_sha256 is required when the file already exists.",
  {
    type = "object",
    properties = {
      path = { type = "string", description = "Absolute file path inside a granted filesystem root." },
      content = { type = "string" },
      expected_sha256 = { type = "string", description = "Hash returned by workspace.read; required when replacing an existing file." }
    },
    required = { "path", "content" }
  },
  habibi.files.write
)

register(
  "patch",
  "Atomically replace one unique exact text block in a UTF-8 file. Fails when old_text is missing, repeated, or stale.",
  {
    type = "object",
    properties = {
      path = { type = "string", description = "Absolute file path inside a granted filesystem root." },
      old_text = { type = "string" },
      new_text = { type = "string" },
      expected_sha256 = { type = "string", description = "Hash returned by workspace.read." }
    },
    required = { "path", "old_text", "new_text", "expected_sha256" }
  },
  habibi.files.patch
)

register(
  "mkdir",
  "Create one directory inside a granted workspace root. Its parent must already exist.",
  path_schema,
  habibi.files.mkdir
)

register(
  "move",
  "Move or rename one file or directory between absolute paths inside one granted workspace root. The destination must not exist.",
  {
    type = "object",
    properties = {
      from = { type = "string", description = "Existing absolute source path." },
      to = { type = "string", description = "New absolute destination path." }
    },
    required = { "from", "to" }
  },
  habibi.files.move
)

register(
  "delete",
  "Delete one regular file or empty directory inside a granted workspace root. Recursive deletion and deleting a granted root are not supported.",
  path_schema,
  habibi.files.delete
)
