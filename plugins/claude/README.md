# tokenome plugin for Claude Code

Gives Claude the provenance of your code: which conversation produced a
line, why a decision was made, what was tried. Served by the tokenome
daemon on your machine.

## What it installs

- **Skill `tokenome`**: teaches Claude when to reach for the record, which
  tool answers which question, how to chain them, how to attribute
  teammates' shared conversations, and what to do when the daemon is down.
  Loaded on demand; costs nothing when the prompt has no history angle.
- **Slash commands**: `/tokenome:why <decision>` and
  `/tokenome:search <query> [mine|team|all]`.

The plugin carries no hooks and reads nothing from your machine. The MCP
server is served by the daemon at `http://127.0.0.1:8741/mcp` and is
registered separately, because the registration carries your machine's
token. The two hooks (`UserPromptSubmit` nudges tokenome-first on
retrospective prompts; `SessionEnd` indexes the session transcript) are
written into your own Claude Code settings by `tokenome claude install`,
pointing at the installed `tokenome` command, for the same reason.

## Install

With the tokenome app running (or `uv run tokenome app`):

```
tokenome claude install
```

That registers the MCP server with Claude Code (user scope), installs
this plugin, and adds the two hooks to `~/.claude/settings.json`. If the `claude` CLI is not on your PATH, it prints the exact
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

- A running tokenome daemon on `127.0.0.1:8741`: the tokenome desktop app
  or `tokenome app`. The record is unavailable (and the skill says so) when
  it is not running.
- For the hooks, the `tokenome` command on your PATH (the app installs
  it; so does the PyPI package). macOS and Linux; Windows support is
  tracked in DESIGN_8 §9.

## Developing the plugin

- Install from your checkout so an unmerged branch is testable:
  `tokenome claude install` does this automatically when run from a source
  tree (it adds the marketplace from the checkout path). The installed copy
  is a cached snapshot, so after editing anything under `plugins/claude/`
  run `claude plugin update tokenome@tokenome` and start a new session.
- `/plugin list` shows ✘ for a plugin that failed to load; read the reason
  with `claude plugin list --json`. `claude plugin validate plugins/claude`
  checks the manifests only and does not catch load-time errors.
- Anthropic's plugin directory accepts command hooks only from verified
  organizations, which is why the hooks live in user settings, not here.
- `claude plugin details tokenome@tokenome` shows the component inventory
  and the projected token cost of the skills (always-on vs. on-invoke).

## Uninstall

```
tokenome claude uninstall      # removes the MCP registration
/plugin uninstall tokenome@tokenome
```

Privacy: [tokenome.ai/docs/privacy](https://tokenome.ai/docs/privacy), what
stays on your machine and the exceptions, stated plainly.

Design: `docs/design/DESIGN_8_CLAUDE_SKILL.md`.
