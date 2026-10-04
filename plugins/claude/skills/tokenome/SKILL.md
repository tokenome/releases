---
name: tokenome
description: >
  Search the user's AI conversation memory (tokenome) when a question is
  about the past: why a decision was made, what was tried before and how it
  went, what a previous conversation or session said, who on the team
  worked on something, what was discussed around a given file, line,
  commit, or date, or whether an error has been seen before. Also for daily
  journal and FAQ lookups. Not for general coding questions with no history
  angle, and not for establishing what the code does now — read the source
  for that.
---

# tokenome — memory of past AI conversations

tokenome indexes the user's (and, when enrolled, their team's) past AI
conversations — Claude Code, Claude Desktop, ChatGPT, Gemini — and exposes
them as MCP tools. Conversations record **intent and reasoning**: why
something was chosen, what was tried and rejected, who agreed to what. They
never reached a file, so the source cannot answer them. The source *is*
authoritative for what the code does now. Most real questions have both
halves: answer the *what* from source and the *why* from memory.

## When to use it

Reach for memory when the prompt is about the settled past:

- "why did we…", "why is X the way it is", "what was the reasoning for…"
- "what did we try", "did we already…", "have we seen this error before"
- "last time", "again", "previously", "that conversation where…"
- "what did [colleague] say about…", "who worked on…"
- a file and line, a commit, or a date with "what was going on"
- "what happened on/around <date>", journal or FAQ questions

Do **not** reach for it when the question is greenfield, or asks about
present behavior ("what does this function do", "where is X defined") —
that is a read-the-source question, and routing it to history measurably
loses accuracy. If the `tokenome` tools are not available, memory is not
connected; do not guess at history.

## Tools (all under the `tokenome` MCP server)

| Question | Tool |
|---|---|
| Why was something decided? Distilled rationale + the quote that proves it | `why_was(decision)` |
| What was discussed / tried / rejected? (routed: team when enrolled) | `search_memory(query, scope?, filters…)` |
| Read a whole thread compactly, or verbatim | `get_conversation(conversation_id, full?)` |
| The text around one hit | `get_document(doc_id)` |
| Widen from one good hit to its neighbors | `find_related(doc_id)` |
| What was discussed around an edit (blame/commit timestamp → conversations) | `find_conversations_near(timestamp, window_minutes?)` |
| Is there a known answer already? | `ask_faq(question)` |
| What happened on a day / recently? | `get_journal(date?, days?)`, `get_recent(limit?)` |
| Browse by tool/model label | `browse_by_label(ai_label)` |

Full signatures and return shapes: `references/tools.md`. Worked examples:
`references/playbook.md`.

## Playbook

1. **"Why is X the way it is?"** → `why_was(X)`. If a why-record has strong
   evidence, answer from it and cite the date. If it is thin or empty, →
   `search_memory(X)` → `get_conversation` on the best hit → `find_related`
   to catch later revisions of the decision.
2. **"What did we try for Y?"** → `search_memory(Y)` → follow the best one
   or two conversations. Report attempts *with outcomes* (worked, failed,
   abandoned, and why), not a list of mentions.
3. **"What's the story behind this line?"** → get the line's commit
   timestamp (`git blame -L <line>,<line> <file>`) →
   `find_conversations_near(timestamp)` → open the top conversation.
4. **"Have we seen this error before?"** → `ask_faq` first, then
   `search_memory` with the distinctive part of the error text.
5. **"What happened on <date> / lately?"** → `get_journal` / `get_recent`.
6. Prefer the returned `excerpt`; open a conversation only when the excerpt
   is not enough. Never issue the same query twice hoping for a different
   answer — reformulate, or widen with `find_related`.

## Scope and attribution

`search_memory` routes the way tokenome does: `scope="auto"` searches the
team server when the user is enrolled, else the local index. Use `mine`
only when the user asks for *their own* conversations, `team` for "what has
the team said", `all` for both.

- The result's `scope`/`source` say what answered. If it carries a
  `warning` (e.g. "Team results unavailable — showing local only"),
  **relay it** — the user must know they are seeing less than the scope
  promised.
- Hits carrying `owner` are colleagues' shared conversations. **Attribute
  them by name** ("per Alice's session on 2026-08-12…"), never present them
  as the user's own, do not speculate beyond what the hit says, and do not
  re-share them into other channels on the user's behalf.

## Reporting what you found

- Summarize **decisions and outcomes**, not chatter. Quote the decisive
  sentence when there is one.
- Cite so the user can open it in tokenome: the conversation title or id
  and the date (and `owner` for team hits).
- Never paste whole transcripts into the reply. `get_conversation` with
  `full=True` is for *your* reading, not for relaying.
- If memory has nothing, say so plainly. Do not invent history.

## Fallbacks

- A tool error like "daemon unreachable" or "cannot reach the tokenome
  daemon": say it once, tell the user to launch the **tokenome app** (or run
  `tokenome app`), and continue *without* memory. Do not retry in a loop.
- Very recent sessions may not be indexed yet — the poller runs every few
  seconds and this session is captured when it ends. Say so when the user
  asks about "just now".
