---
name: why
description: Explain why something was decided, using tokenome's journal why-records and past conversations. Usage — /tokenome:why <decision or thing>
disable-model-invocation: true
---

The user wants to know why this was decided or why it is the way it is:

> $ARGUMENTS

Follow the tokenome skill's playbook for "why" questions:

1. Call `why_was` with the decision. If a record has solid evidence, answer
   from it: the decision, the stated reason, the date, the decisive quote.
2. If records are thin or empty, call `search_memory` with the same
   wording, open the best conversation with `get_conversation`, and widen
   with `find_related` to catch later revisions.
3. Relay any `warning`; attribute any hit carrying `owner` by name.
4. If memory has nothing, say so; do not invent history. If the daemon is
   unreachable, say so once and stop.

Answer with decisions and outcomes, cited so the user can open the source
conversation in tokenome.
