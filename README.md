# tokenome releases

This repository is where tokenome is distributed: the **desktop app**
builds, the **command-line package** on PyPI, the **Claude Code plugin**
marketplace, and the **team server** image with its deployment bundle.
There is no source code here. Every release is on the
[Releases page](https://github.com/tokenome/releases/releases).

For more about tokenome, see **[tokenome.ai](https://tokenome.ai)**.

## What tokenome is

Tokenome is code provenance for AI-assisted work. Your code says what
changed; tokenome says why. It captures your conversations with AI coding
tools - Claude Code, Claude Desktop, ChatGPT and Gemini - indexes them on
your own machine, and links every line of code to the conversation that
produced it.

The desktop app includes:

- **Capture and search.** Conversations are indexed locally as they
  happen, and searched by meaning as well as by keyword, from the app,
  a command-line tool, or by an AI agent over MCP.
- **Code provenance.** Point at a file and a line, and see the
  conversations from the change that last touched it.
- **A daily journal and FAQ.** Once a day, tokenome writes down what was
  decided and why, quoting the turn each reason came from.
- **Privacy by construction.** Everything runs on your machine: the
  index, the embedding model, the search engine. Nothing leaves it
  unless you join a team and opt a project in.

## Free app, paid team server

The desktop app is **free** - not a trial, and not a free tier with a
clock on it. The paid product is the **tokenome team server**: a service
your organization runs on its own infrastructure, so a team can search
across everyone's opted-in projects with attribution. The team server is
not in this repository; it is licensed separately. See
[tokenome.ai](https://tokenome.ai) for team pricing and how to get
started.

## Install

### Desktop app

| Platform | File | Notes |
|---|---|---|
| macOS, Apple Silicon (macOS 13 or later) | `tokenome_<version>_aarch64.dmg` | Signed and notarized. Open the DMG and drag tokenome to Applications. |
| Linux x86_64 | `tokenome_<version>_amd64.AppImage`, `tokenome_<version>_amd64.deb` | The AppImage is the form the in-app updater can replace. |
| Linux aarch64 | `tokenome_<version>_aarch64.AppImage`, `tokenome_<version>_arm64.deb` | Same. |

A `.sha256` file accompanies every download; the `.sig` files and
`latest.json` are the in-app updater's, and `THIRD_PARTY_LICENSES.md`
lists the open-source components each build contains. The app installs a
`tokenome` command at `~/.local/bin/tokenome` that uses its own runtime.

There is no Intel Mac build and no Windows build at present. If you'd like
either one, file or vote on an issue.

### Command line only

For Linux, servers, or any machine with [uv](https://docs.astral.sh/uv/):

```bash
uv tool install tokenome-ai
```

The package on PyPI is `tokenome-ai`; the command is `tokenome`. The same
wheels are attached to every release. If the desktop app is installed on
the same machine, this replaces the app's `tokenome` command with the
wheel's own; keep one or the other.

### Claude Code plugin

```
/plugin marketplace add tokenome/releases
/plugin install tokenome@tokenome
```

The desktop app does this for you (Settings, Connect Claude Code), and
bundles a copy of the plugin for offline installs. The plugin's version
follows the app's.

### Team server

The team server ships as a container image,
`ghcr.io/tokenome/tokenome-server:<version>`, and this repository's
[`deploy/`](deploy/) folder is the bundle that runs it: a compose file
pinned to the latest release, Caddy for TLS, and the runbook. A Railway
deployment uses the same image as a Docker Image service.

The two "Source code" entries GitHub attaches to every release are
archives of this repository's own files, not the app's source, which is
not published.

### Updates

The app checks this repository for new releases and offers to install
them; nothing is installed without your confirmation. That check is the
app's only outbound connection besides downloading the embedding model on
first run. It sends no conversations and no code.

## Support

- Bugs and questions about the app: open an issue in this repository,
  [github.com/tokenome/releases/issues](https://github.com/tokenome/releases/issues).
- Everything else: **contact@tokenome.ai**.

## License

- **Desktop app:** proprietary, free of charge, under the terms in
  [LICENSE](LICENSE). The open-source components it bundles are listed,
  with their licenses, in `THIRD_PARTY_LICENSES.md` on every release.
- **Command-line package (`tokenome-ai`, `tokenome-core`) and the Claude
  Code plugin:** Business Source License 1.1. Use, modify and redistribute,
  including in production, except to offer a competing product; each
  version converts to the Apache License 2.0 four years after it is
  published. The text ships inside the packages and at
  [`plugins/claude/LICENSE`](plugins/claude/LICENSE).
- **Team server:** proprietary, licensed separately under the Tokenome Team
  terms.
