<p align="center">
  <img src="assets/habibi-logo.svg" alt="Habibi" width="140">
</p>

<h1 align="center">Official Habibi extensions</h1>

Official, versioned extensions maintained by the [Habibi Assistant](https://github.com/HabibiAssistant) organization.

## Install

Install directly from GitHub:

```sh
habibi install https://github.com/HabibiAssistant/extensions.git --subdir chat
```

Or install from a local checkout while developing:

```sh
git clone https://github.com/HabibiAssistant/extensions.git
habibi install ./extensions --subdir chat
```

Habibi stages and automatically security/privacy scans every install and update before enabling it. It records the scan report, source URL, selected subdirectory, resolved Git revision, semantic version, content hash, capabilities, and installation timestamp. Check and apply updates from Habibi’s Extensions page or run:

```sh
habibi update chat
```

## Extensions

| Extension | Version | Description |
| --- | ---: | --- |
| [`chat`](chat/) | `0.1.0` | Multi-session web chat over Habibi’s durable event history. |

## Versioning and releases

Each extension owns the semantic version in its `extension.toml`. Any distributed content change must increase that version. Habibi refuses same-version updates whose content hash changed.

Official releases use extension-scoped tags:

```text
chat-v0.1.0
chat-v0.2.0
```

A repository commit may update several extensions independently. Installations remain reproducible because Habibi records both the extension version and exact Git commit.

## Repository layout

```text
extensions/
  chat/
    extension.toml
    extension.lua
    web/
```

Extensions must not use install scripts or symbolic links. Runtime capabilities are declared explicitly in `extension.toml` and are shown before or during management operations.

## Development

Run Habibi against a disposable extensions directory, install the local package, then run the core test suite:

```sh
HABIBI_EXTENSIONS_DIR=/tmp/habibi-extensions habibi install . --subdir chat
```

See the [extension authoring documentation](https://github.com/HabibiAssistant/habibi/blob/main/docs/extensions.md) in the main repository.
