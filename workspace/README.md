# Workspace

Scoped filesystem tools for Habibi.

```sh
habibi install https://github.com/HabibiAssistant/extensions.git --subdir workspace
```

After installation, open Habibi's **Extensions** page and save one or more existing absolute root
directories. No roots are granted automatically.

## Tools

- `workspace.list`
- `workspace.read`
- `workspace.search`
- `workspace.write`
- `workspace.patch`
- `workspace.mkdir`
- `workspace.move`
- `workspace.delete`

Paths must remain inside a granted root. Symbolic links and special files are not followed. Reads,
writes, and patches are limited to 2 MiB. Search is bounded and literal. Existing-file writes and
patches require the SHA-256 returned by `workspace.read`. Deletes are nonrecursive, root deletion is
forbidden, and moves cannot cross roots or overwrite an existing destination.

Filesystem mutation effects are authored by the Habibi host rather than Lua. Effect events contain
paths, hashes, and sizes but not file contents. Tool arguments and exact model logs retain content
under Habibi's normal observability policy.
