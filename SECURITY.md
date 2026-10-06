# Security policy

tokenome runs on your machine and indexes your AI conversations, so we
take reports about it seriously. If you believe you have found a
vulnerability in the desktop app, the command-line tool, the Claude Code
plugin, or the team server, please report it privately rather than in a
public issue.

## How to report

- **Preferred:** use GitHub's private vulnerability reporting for this
  repository ("Report a vulnerability" under the Security tab). Only the
  tokenome team can see it.
- **Or:** email **hello@tokenome.ai** with "security" in the subject.
  It reaches the three people who build tokenome, nobody else.

Please include the version (Settings → Updates in the app, or
`tokenome --version`), your operating system, and enough detail to
reproduce. Do not include conversation content from your index.

## What to expect

We will acknowledge your report within a few business days, keep you
informed as we work on it, and credit you in the release notes if you
would like. Please give us reasonable time to ship a fix before
disclosing publicly; the desktop app offers each update and installs it
on confirmation, so most users are on a fix within days of its release.

## Scope

In scope: the desktop app and its bundled daemon, the `tokenome`
command-line tool, the Claude Code plugin and MCP tools, and the team
server container image. Out of scope: the marketing site at tokenome.ai
unless it exposes user data, and third-party services the app talks to
only on your instruction.

## What tokenome already does

Everything is local by default: the index, the embedding model and the
search engine run on your machine, and nothing leaves it unless you join
a team and opt a project in. The local API is bound to the loopback,
refuses requests with a foreign Host header, and is guarded by a token
that is minted on your machine and never leaves it; secrets and personal
data are scrubbed before anything is shared with a team server. The
daemon log never contains the API token, and from 0.5.5 on it never
contains conversation text or the text of searches either (earlier
versions logged search text, so skim the log before pasting it).
