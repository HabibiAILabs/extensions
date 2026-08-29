habibi.tools.register({
  name = "process.run",
  description = "Run an explicitly granted native executable in a bounded Linux sandbox. Arguments are passed directly without implicit shell evaluation. The process has no network, receives a fixed non-secret environment, and can access only this extension's granted filesystem root containing cwd. Output returned by this tool becomes durable Habibi action history; do not use it for secrets.",
  input_schema = {
    type = "object",
    additionalProperties = false,
    properties = {
      executable = {
        type = "string",
        description = "User-granted executable alias, not a path."
      },
      args = {
        type = "array",
        items = { type = "string" },
        maxItems = 128,
        description = "Literal argv entries. No shell interpretation occurs."
      },
      cwd = {
        type = "string",
        description = "Absolute canonical working directory inside a filesystem grant."
      },
      timeout_ms = {
        type = "integer",
        minimum = 1,
        maximum = 120000,
        description = "Optional timeout; defaults to 30000 ms."
      }
    },
    required = { "executable", "cwd" }
  }
}, function(arguments)
  return { result = habibi.process.run(arguments) }
end)
