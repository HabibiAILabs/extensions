# Extension Studio

Scoped model tools for creating, reading, checked editing, and validating extension drafts.

```sh
habibi install https://github.com/HabibiAssistant/extensions.git --subdir extension-studio
```

Drafts live under Habibi's host-owned `HABIBI_EXTENSION_DRAFTS_DIR`, not an arbitrary Workspace
grant. Paths are draft IDs plus relative allowlisted text files. Existing-file writes require the
SHA-256 returned by `extension-studio.read`. Symbolic links, binary files, traversal, recursive
deletion, draft deletion, and model-triggered installation are unsupported.

Use `/studio` to review files, capabilities, package hash, scanner findings, and isolated runtime
validation. Installation is enabled only for the latest passing hash and always requires an explicit
browser confirmation. Habibi reruns the complete installer pipeline and rejects edits made after
validation. Updating an installed draft requires a semantic-version increase.

Installed extensions are fully trusted local code. Scanning assists review but cannot prove hostile
code safe.
