<p align="center">
  <img src="assets/habibi-logo.svg" alt="Habibi" width="140">
</p>

<h1 align="center">Official Habibi extensions</h1>

Official, versioned extensions maintained by the [Habibi Assistant](https://github.com/HabibiAssistant) organization.

## Install

Install directly from GitHub:

```sh
habibi install https://github.com/HabibiAssistant/extensions.git --subdir chat
habibi install https://github.com/HabibiAssistant/extensions.git --subdir workspace
habibi install https://github.com/HabibiAssistant/extensions.git --subdir process
habibi install https://github.com/HabibiAssistant/extensions.git --subdir git
habibi install https://github.com/HabibiAssistant/extensions.git --subdir extension-studio
habibi install https://github.com/HabibiAssistant/extensions.git --subdir web-search
```

Or install from a local checkout while developing:

```sh
git clone https://github.com/HabibiAssistant/extensions.git
habibi install ./extensions --subdir chat
```

Habibi stages and automatically security/privacy scans every install and update before enabling it. It records the scan report, source URL, selected subdirectory, resolved Git revision, semantic version, content hash, capabilities, and installation timestamp. Check and apply updates from Habibi’s Extensions page or run:

```sh
habibi update chat
habibi update workspace
habibi update process
habibi update git
habibi update extension-studio
habibi update web-search
```

## Extensions

| Extension | Version | Description |
| --- | ---: | --- |
| [`chat`](chat/) | `0.2.1` | Multi-session web chat with owned context and tool-suggestion hooks. |
| [`workspace`](workspace/) | `0.1.0` | Scoped file reading, search, and checked workspace mutations. |
| [`process`](process/) | `0.1.1` | Granted native executables in bounded Linux sandboxes. |
| [`git`](git/) | `0.1.0` | Read-only repository inspection through sandboxed Git. |
| [`extension-studio`](extension-studio/) | `0.1.0` | Scoped extension draft authoring and validation. |
| [`web-search`](web-search/) | `0.1.2` | Brave or self-hosted SearXNG public-web discovery. |

Workspace starts with no filesystem access. After installation, grant one or more existing absolute
directories from Habibi's Extensions page. Existing-file writes and patches require the SHA-256
returned by `workspace.read`; deletion is nonrecursive.

## Versioning and releases

Each extension owns the semantic version in its `extension.toml`. Any distributed content change must increase that version. Habibi refuses same-version updates whose content hash changed.

Official releases use extension-scoped tags:

```text
chat-v0.1.0
chat-v0.2.0
chat-v0.2.1
workspace-v0.1.0
process-v0.1.0
process-v0.1.1
git-v0.1.0
extension-studio-v0.1.0
web-search-v0.1.0
web-search-v0.1.1
web-search-v0.1.2
```

A repository commit may update several extensions independently. Installations remain reproducible because Habibi records both the extension version and exact Git commit.

## Repository layout

```text
extensions/
  chat/
    extension.toml
    extension.lua
    web/
  workspace/
    extension.toml
    extension.lua
  process/
    extension.toml
    extension.lua
  git/
    extension.toml
    extension.lua
  extension-studio/
    extension.toml
    extension.lua
  web-search/
    extension.toml
    extension.lua
```

Extensions must not use install scripts or symbolic links. Runtime capabilities are declared explicitly in `extension.toml` and are shown before or during management operations.

## Development

Run Habibi against a disposable extensions directory, install the local package, then run the core test suite:

```sh
HABIBI_EXTENSIONS_DIR=/tmp/habibi-extensions habibi install . --subdir chat
HABIBI_EXTENSIONS_DIR=/tmp/habibi-extensions habibi install . --subdir workspace
```

See the [extension authoring documentation](https://github.com/HabibiAssistant/habibi/blob/main/docs/extensions.md) in the main repository.
