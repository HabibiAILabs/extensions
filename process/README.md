# Process

Bounded Linux process execution for Habibi.

```sh
habibi install https://github.com/HabibiAILabs/extensions.git --subdir process
```

On Habibi's **Extensions** page, configure both:

1. Filesystem roots available read-write to the sandbox.
2. Exact native ELF executables as `alias=/absolute/path`.

The model invokes aliases, never paths. Extension-owned callers may additionally require one exact
grant and mount it read-only; the generic `process.run` tool keeps the containing read-write default.
Executable identity and SHA-256 are checked on every run,
then the verified bytes are executed from a sealed memory file. Scripts/shebangs, implicit shell
evaluation, PATH lookup, custom environments, stdin, network access, and detached processes are
unsupported. Grant a native interpreter only when its full argv authority is intended.

Each run uses Bubblewrap namespaces and a delegated cgroup v2 leaf. The sandbox exposes the selected
filesystem root, `/usr`, runtime libraries, minimal `/dev`, `/proc`, and an empty `/tmp`. Stdout and
stderr are capped at 1 MiB each. Timeout defaults to 30 seconds and cannot exceed 120 seconds. The
entire cgroup is killed after completion, timeout, or output overflow. Execution fails closed if
Bubblewrap or delegated cgroup v2 support is unavailable.

Process arguments, results, and exact model traffic are retained by Habibi. Do not pass or print
secrets. Host-authored `process.execution.completed` effects omit argv and output.
