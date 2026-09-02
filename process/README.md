# Process

Bounded Linux process execution for Habibi.

```sh
habibi install https://github.com/HabibiAILabs/extensions.git --subdir process
```

Configure Habibi's global boundaries on **Settings**:

1. Add absolute directory include/exclude patterns for where extensions may work.
2. Add native ELF program include/exclude patterns as absolute paths or basenames.

Patterns support `*` and `?`. The most specific matching rule wins; includes win ties. This permits
specific include patterns to override a broad `*` exclusion. Program basename rules also work, so
include `*` with exclude `rm` permits matching system programs except executables named `rm`.

The model invokes an unambiguous approved basename or an approved absolute path. Basenames resolve
only from explicit entries, concrete pattern directories, or fixed system locations under `*`; the
ambient `PATH` is never searched. Program bytes are
read at execution time and run from a sealed memory file. Scripts/shebangs, ambient PATH lookup,
implicit shell evaluation, caller environments, stdin, network access, and detached processes are
unsupported. Approved programs may invoke helpers; approve an interpreter or shell only when its
full argv authority is intended.

Each run uses Bubblewrap namespaces and a delegated cgroup v2 leaf. The sandbox exposes the selected
working directory, `/usr`, runtime libraries, minimal `/dev`, `/proc`, and an empty `/tmp`. Stdout and
stderr are capped at 1 MiB each. Timeout defaults to 30 seconds and cannot exceed 120 seconds. The
entire cgroup is killed after completion, timeout, or output overflow. Execution fails closed if
Bubblewrap or delegated cgroup v2 support is unavailable.

Process arguments, results, and exact model traffic are retained by Habibi. Do not pass or print
secrets. Host-authored `process.execution.completed` effects omit argv and output.
