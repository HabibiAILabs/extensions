<p align="center">
  <img src="assets/habibi-logo.svg" alt="Habibi" width="140">
</p>

<h1 align="center">Official Habibi extensions</h1>

Official, versioned extensions maintained by the [Habibi Assistant](https://github.com/HabibiAILabs) organization.

## Install

Install directly from GitHub:

```sh
habibi install https://github.com/HabibiAILabs/extensions.git --subdir chat
habibi install https://github.com/HabibiAILabs/extensions.git --subdir process
habibi install https://github.com/HabibiAILabs/extensions.git --subdir git
habibi install https://github.com/HabibiAILabs/extensions.git --subdir memory
habibi install https://github.com/HabibiAILabs/extensions.git --subdir habibi-docs
habibi install https://github.com/HabibiAILabs/extensions.git --subdir soul
habibi install https://github.com/HabibiAILabs/extensions.git --subdir web-search
```

Or install from a local checkout while developing:

```sh
git clone https://github.com/HabibiAILabs/extensions.git
habibi install ./extensions --subdir chat
```

Habibi stages and automatically security/privacy scans every install and update before enabling it. It records the scan report, source URL, selected subdirectory, resolved Git revision, semantic version, content hash, capabilities, and installation timestamp. Check and apply updates from Habibi’s Extensions page or run:

```sh
habibi update chat
habibi update process
habibi update git
habibi update habibi-docs
habibi update soul
habibi update web-search
```

## Extensions

| Extension | Version | Description |
| --- | ---: | --- |
| [`chat`](chat/) | `0.3.6` | Event-streamed multi-session chat with explicit and automatic reply relationships. |
| [`memory`](memory/) | `0.1.0` | Causal and semantic durable-event context retrieval. |
| [`process`](process/) | `0.1.1` | Granted native executables in bounded Linux sandboxes. |
| [`git`](git/) | `0.1.0` | Read-only repository inspection through sandboxed Git. |
| [`habibi-docs`](habibi-docs/) | `0.1.2` | Searchable runtime and extension-development documentation. |
| [`soul`](soul/) | `0.1.2` | User-authored agent personality with a local editor. |
| [`web-search`](web-search/) | `0.1.7` | Brave or self-hosted SearXNG public-web discovery. |

## Versioning and releases

Each extension owns the semantic version in its `extension.toml`. Any distributed content change must increase that version. Habibi refuses same-version updates whose content hash changed.

Official releases use extension-scoped tags:

```text
chat-v0.1.0
chat-v0.2.0
chat-v0.2.1
chat-v0.2.2
chat-v0.2.3
chat-v0.3.0
chat-v0.3.1
chat-v0.3.2
chat-v0.3.3
chat-v0.3.4
chat-v0.3.5
chat-v0.3.6
process-v0.1.0
process-v0.1.1
git-v0.1.0
habibi-docs-v0.1.0
habibi-docs-v0.1.1
habibi-docs-v0.1.2
soul-v0.1.0
soul-v0.1.1
soul-v0.1.2
web-search-v0.1.0
web-search-v0.1.1
web-search-v0.1.2
web-search-v0.1.3
web-search-v0.1.4
web-search-v0.1.5
web-search-v0.1.6
web-search-v0.1.7
memory-v0.1.0
```

A repository commit may update several extensions independently. Installations remain reproducible because Habibi records both the extension version and exact Git commit.

## Repository layout

```text
extensions/
  chat/
    extension.toml
    extension.lua
    web/
  memory/
    extension.toml
    extension.lua
  process/
    extension.toml
    extension.lua
  git/
    extension.toml
    extension.lua
  habibi-docs/
    extension.toml
    extension.lua
  soul/
    extension.toml
    extension.lua
    web/
  web-search/
    extension.toml
    extension.lua
```

Extensions must not use install scripts or symbolic links. Runtime capabilities are declared explicitly in `extension.toml` and are shown before or during management operations.

## Development

Run Habibi against a disposable extensions directory, install the local package, then run the core test suite:

```sh
HABIBI_EXTENSIONS_DIR=/tmp/habibi-extensions habibi install . --subdir chat
HABIBI_EXTENSIONS_DIR=/tmp/habibi-extensions habibi install . --subdir habibi-docs
HABIBI_EXTENSIONS_DIR=/tmp/habibi-extensions habibi install . --subdir soul
```

See the [extension authoring documentation](https://github.com/HabibiAILabs/habibi/blob/main/docs/extensions.md) in the main repository.
