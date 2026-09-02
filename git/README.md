# Git

Read-only repository inspection through Habibi's sandboxed process API.

```sh
habibi install https://github.com/HabibiAILabs/extensions.git --subdir git
```

On Habibi's **Settings** page:

1. Include each repository, or a parent directory, in the global directory boundary.
2. Include the canonical Git executable path, usually `/usr/bin/git`, in the global program boundary.

## Tools

- `git.status`
- `git.diff`
- `git.log`
- `git.show`

Every invocation requests a read-only mount of the exact repository working directory. Git hooks,
fsmonitor, pagers, optional locks, external diff/textconv, signatures, networking, and submodule
traversal are disabled where relevant. Revisions must be full object IDs. Paths are bounded literal
repository-relative pathspecs.

Git and its runtime libraries are trusted native dependencies. Repository-local configuration and
metadata remain visible to Git; do not use this extension on untrusted repositories.
