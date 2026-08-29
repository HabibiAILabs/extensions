local function inside(path, root)
  return path == root or path:sub(1, #root + 1) == root .. "/"
end

local function validate_oid(oid)
  if type(oid) ~= "string" or (#oid ~= 40 and #oid ~= 64) or not oid:match("^[0-9a-fA-F]+$") then
    error("revision must be a full 40- or 64-hex object ID")
  end
  return oid:lower()
end

local function validate_paths(paths)
  local total = 0
  if #(paths or {}) > 64 then error("at most 64 paths are allowed") end
  for _, path in ipairs(paths or {}) do
    total = total + #path
    if #path == 0 or #path > 4096 or path:sub(1, 1) == "/" or path:sub(1, 2) == ":(" or
       path == "." or path == ".." or path:find("/../", 1, true) or path:find("/./", 1, true) or
       path:sub(1, 3) == "../" or path:sub(1, 2) == "./" or
       path:sub(-3) == "/.." or path:sub(-2) == "/." then
      error("paths must be bounded literal repository-relative paths without '.' or '..' components")
    end
  end
  if total > 32768 then error("path arguments exceed 32 KiB") end
end

local function run_git(arguments, command)
  local args = habibi.array({
    "--no-pager",
    "--no-optional-locks",
    "--literal-pathspecs",
    "-c", "core.hooksPath=/dev/null",
    "-c", "core.fsmonitor=false",
    "-c", "core.untrackedCache=false",
    "-c", "submodule.recurse=false",
    "-c", "core.pager=cat",
    "-c", "color.ui=false",
    "-c", "diff.external=",
    "-c", "interactive.diffFilter=",
  })
  for _, value in ipairs(command) do
    args[#args + 1] = value
  end
  local result = habibi.process.run({
    executable = "git",
    args = args,
    cwd = arguments.repository,
    timeout_ms = arguments.timeout_ms or 30000,
    filesystem_root = arguments.repository,
    filesystem_access = "read_only",
  })
  if not result.stdout_utf8 or not result.stderr_utf8 then
    error("git returned non-UTF-8 output, which version 0.1 does not support")
  end
  if not result.success then
    error("git command failed: " .. result.stderr)
  end
  return result
end

local function git(arguments, command)
  if type(arguments.repository) ~= "string" or arguments.repository:find("\n", 1, true) then
    error("repository must be an absolute canonical path")
  end
  local repository = run_git(arguments, {
    "rev-parse", "--path-format=absolute", "--show-toplevel", "--absolute-git-dir", "--git-common-dir"
  })
  local top, git_dir, common_dir = repository.stdout:match("([^\n]+)\n([^\n]+)\n([^\n]+)\n?")
  if top ~= arguments.repository or not inside(git_dir or "", top or "") or not inside(common_dir or "", top or "") then
    error("repository must be an exact granted non-bare root with internal Git metadata")
  end
  return { result = run_git(arguments, command) }
end

habibi.tools.register({
  name = "git.status",
  description = "Read concise branch and working-tree status for a repository. This is read-only and disables hooks, filesystem monitors, pagers, color, and submodule traversal.",
  input_schema = {
    type = "object",
    additionalProperties = false,
    properties = {
      repository = { type = "string", description = "Absolute canonical repository working-tree path inside a granted root." },
      timeout_ms = { type = "integer", minimum = 1, maximum = 120000 }
    },
    required = { "repository" }
  }
}, function(arguments)
  return git(arguments, { "status", "--short", "--branch", "--untracked-files=all", "--ignore-submodules=all" })
end)

habibi.tools.register({
  name = "git.diff",
  description = "Read a bounded textual Git diff without external diff commands or text-conversion filters. This is read-only.",
  input_schema = {
    type = "object",
    additionalProperties = false,
    properties = {
      repository = { type = "string", description = "Absolute canonical repository working-tree path inside a granted root." },
      staged = { type = "boolean", description = "Compare the index to HEAD instead of the working tree to the index." },
      paths = { type = "array", items = { type = "string" }, maxItems = 64, description = "Optional repository-relative pathspecs." },
      context_lines = { type = "integer", minimum = 0, maximum = 20 },
      timeout_ms = { type = "integer", minimum = 1, maximum = 120000 }
    },
    required = { "repository" }
  }
}, function(arguments)
  validate_paths(arguments.paths)
  local command = { "diff", "--no-ext-diff", "--no-textconv", "--ignore-submodules=all", "--unified=" .. tostring(arguments.context_lines or 3) }
  if arguments.staged then command[#command + 1] = "--cached" end
  command[#command + 1] = "--"
  for _, path in ipairs(arguments.paths or {}) do command[#command + 1] = path end
  return git(arguments, command)
end)

habibi.tools.register({
  name = "git.log",
  description = "Read recent commit history with stable machine-generated fields. This is read-only and does not verify signatures or invoke pagers.",
  input_schema = {
    type = "object",
    additionalProperties = false,
    properties = {
      repository = { type = "string", description = "Absolute canonical repository working-tree path inside a granted root." },
      revision = { type = "string", pattern = "^[0-9a-fA-F]{40}([0-9a-fA-F]{24})?$", description = "Optional full commit ID; defaults to a resolved HEAD snapshot." },
      limit = { type = "integer", minimum = 1, maximum = 100 },
      timeout_ms = { type = "integer", minimum = 1, maximum = 120000 }
    },
    required = { "repository" }
  }
}, function(arguments)
  local oid = arguments.revision and validate_oid(arguments.revision) or nil
  if not oid then
    local resolved = run_git(arguments, { "rev-parse", "--verify", "HEAD^{commit}" })
    oid = validate_oid(resolved.stdout:match("^([^\n]+)"))
  end
  local command = {
    "log", "--no-decorate", "--no-show-signature", "--date=iso-strict",
    "--format=commit %H%nauthor %an <%ae>%ndate %aI%nsubject %s%n",
    "--max-count=" .. tostring(arguments.limit or 20),
    "--end-of-options", oid,
  }
  return git(arguments, command)
end)

habibi.tools.register({
  name = "git.show",
  description = "Read one commit or object with its patch while disabling external diff and text-conversion commands. This is read-only.",
  input_schema = {
    type = "object",
    additionalProperties = false,
    properties = {
      repository = { type = "string", description = "Absolute canonical repository working-tree path inside a granted root." },
      revision = { type = "string", pattern = "^[0-9a-fA-F]{40}([0-9a-fA-F]{24})?$", description = "Full 40- or 64-hex commit or object ID." },
      paths = { type = "array", items = { type = "string" }, maxItems = 64 },
      timeout_ms = { type = "integer", minimum = 1, maximum = 120000 }
    },
    required = { "repository", "revision" }
  }
}, function(arguments)
  validate_paths(arguments.paths)
  local command = { "show", "--no-ext-diff", "--no-textconv", "--no-show-signature", "--format=fuller", "--end-of-options", validate_oid(arguments.revision), "--" }
  for _, path in ipairs(arguments.paths or {}) do command[#command + 1] = path end
  return git(arguments, command)
end)
