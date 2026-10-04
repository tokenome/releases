---
name: search
description: Search tokenome's conversation memory explicitly. Usage — /tokenome:search <query> [mine|team|all]
disable-model-invocation: true
---

Search the user's AI conversation memory for:

> $ARGUMENTS

If the arguments end with `mine`, `team`, or `all`, use that as the
`scope` of `search_memory` and drop it from the query; otherwise use
`scope="auto"`.

Report the best hits compactly — title or conversation, date, `owner` for
team hits, and the excerpt's gist — then offer to open one with
`get_conversation`. Relay any `warning`. Follow the tokenome skill's
attribution and reporting rules; never paste whole transcripts.
