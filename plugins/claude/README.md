# tokenome plugin for Claude Code

Gives Claude memory of your past AI conversations — why decisions were
made, what was tried, what a session said — through the tokenome daemon.

## What it installs

- **Skill `tokenome`** — teaches Claude when to reach for memory, which
  tool answers which question, how to chain them, how to attribute
  teammates' shared conversations, and what to do when the daemon is down.
  Loaded on demand; costs nothing when the prompt has no history angle.
- **Hooks** — `UserPromptSubmit` nudges tokenome-first on retrospective
  prompts; `SessionEnd` indexes the session transcript. Both are plain
  `curl` calls to the daemon, authenticated with `~/.tokenome/api.token`,
  so nothing here needs `tokenome` on your PATH.
- **Slash commands** — `/tokenome:why <decision>` and
  `/tokenome:search <query> [mine|team|all]`.

The MCP server itself is served by the daemon at
`http://127.0.0.1:8741/mcp`; it is registered separately because the
registration carries your machine's token.

## Install

With the tokenome app running (or `uv run tokenome app`):

```sh
tokenome claude install
```

That registers the MCP server with Claude Code (user scope) and installs
this plugin. If the `claude` CLI is not on your PATH, it prints the exact
commands to run yourself, and the in-session fallback is:

```
/plugin marketplace add tokenome/releases
/plugin install tokenome@tokenome
```

## Where it comes from

The marketplace is the `tokenome/releases` repository, which carries this
plugin at the version of each app release, so `claude plugin update
tokenome@tokenome` follows the app. The app also bundles a copy, used
when GitHub cannot be reached. This directory in the source tree is the
development copy: a checkout installs it from itself (`tokenome claude
install` finds the checkout's marketplace first).

## Requirements

- A running tokenome daemon on `127.0.0.1:8741` — the tokenome desktop app
  or `tokenome app`. Memory is unavailable (and the skill says so) when it
  is not running.
- `curl` and a POSIX shell for the hooks (macOS and Linux; Windows support
  is tracked in DESIGN_8 §9).

## Developing the plugin

- Install from your checkout so an unmerged branch is testable:
  `tokenome claude install` does this automatically when run from a source
  tree (it adds the marketplace from the checkout path). The installed copy
  is a cached snapshot, so after editing anything under `plugins/claude/`
  run `claude plugin update tokenome@tokenome` and start a new session.
- `/plugin list` shows ✘ for a plugin that failed to load; read the reason
  with `claude plugin list --json`. `claude plugin validate plugins/claude`
  checks the manifests only and does not catch load-time errors (a hooks
  file named in `manifest.hooks` is one — `hooks/hooks.json` is loaded by
  convention, so naming it registers it twice).
- `claude plugin details tokenome@tokenome` shows the component inventory
  and the projected token cost of the skills (always-on vs. on-invoke).

## Uninstall

```sh
tokenome claude uninstall      # removes the MCP registration
/plugin uninstall tokenome@tokenome
```

Design: `docs/design/DESIGN_8_CLAUDE_SKILL.md`.
