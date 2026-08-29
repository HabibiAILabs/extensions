# Git

Read-only repository inspection through Habibi's Linux Process sandbox.

```sh
habibi install https://github.com/HabibiAssistant/extensions.git --subdir git
```

On Habibi's **Extensions** page, grant:

1. The exact canonical repository root as a filesystem grant.
2. `git=/usr/bin/git` as a process executable.

## Tools

- `git.status`
- `git.diff`
- `git.log`
- `git.show`

Version 0.1 is intentionally read-only. Commands receive literal argv without an implicit shell,
run without network or ambient environment access, and are bounded by Process output/time limits.
Hooks, filesystem monitors, pagers, external diff commands, text-conversion filters, signature
verification, color, and submodule traversal are disabled where relevant.

The exact repository grant is mounted read-only. Linked worktrees, bare repositories, external Git
metadata, and parent-workspace grants are unsupported in version 0.1. Do not grant untrusted native
interpreters under the Git extension.

Git output and arguments become durable Habibi action/model history. Do not inspect repositories
whose output contains secrets.
