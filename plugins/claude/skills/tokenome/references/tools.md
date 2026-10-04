# tokenome MCP tools — reference

All tools return compact JSON strings. `doc_id` identifies one segment
(a user query + AI response); `conversation_id` identifies the thread.

## search_memory(query, top_k=10, ai_label=None, platform=None, model=None, project=None, scope="auto")

Hybrid (keyword + semantic) search over conversation segments, **routed**:

- `scope`: `auto` (team when enrolled, else local — the default), `team`,
  `mine` (local only), `all` (both; team hits first, local duplicates of
  team hits removed).
- Filters: `platform` (`claude-code`, `claude-desktop`, `claude-cowork`,
  `chatgpt`, `gemini`, `generic`), `model`, `project` (repo name for Claude
  Code), `ai_label` (derived label: model, else platform).

Returns:

```json
{
  "scope": "team", "source": "remote",
  "total_hits": 12, "returned": 8,
  "results": [
    {"doc_id": "…", "conversation_id": "…", "title": "…",
     "ai_label": "claude-opus-4-8", "platform": "claude-code", "model": "…",
     "project": "tokenome", "timestamp": "2026-08-12T10:00:00+00:00",
     "score": 0.91, "topics": ["auth"], "query": "…first 160 chars…",
     "excerpt": "…highlighted match…", "owner": "Alice"}
  ],
  "warning": "Team results unavailable — showing local only (timeout)",
  "attribution": "Results carrying 'owner' are colleagues' shared conversations…",
  "hint": "Expand one result with get_document(doc_id)…"
}
```

`source` is one of `remote`, `local`, `local-fallback`, `both`. `warning`
and `attribution` are present only when relevant. `owner` appears only on
team hits.

## why_was(decision, top_k=5)

Searches **journal why-records** (distilled rationale generated from past
conversations), not raw turns. Local only. Returns records with
`decision`, `why`, `confidence`, `status` (stated / inferred), `date`, a
`score`, and up to two `evidence` spans each carrying `doc_id` and
`conversation_id` for verification. An empty result with a hint means no
journal entries exist yet (`tokenome journal --backfill`).

## get_conversation(conversation_id, full=False, max_segments=20)

Compact per-turn excerpts of a whole thread; `full=True` returns verbatim
text — use sparingly, for reading, never for relaying. Threads longer than
`max_segments` turns are elided after that many (the note says how many
were cut); raise it only when the elided part is what you need.

## get_document(doc_id, match=None, window=1200, full=False)

The text around one match — the segment's query and response. Returns
`window` characters centred on `match` (a phrase from the excerpt you are
expanding; falls back to the start of the segment). Raise `window` rather
than calling repeatedly; `full=True` returns the whole segment.

## find_related(doc_id, top_k=5)

Nearest neighbors by embedding similarity from a known segment. Local
only. Use to walk from one good hit to earlier arguments and later
revisions without a fresh query.

## find_conversations_near(timestamp, window_minutes=30)

Conversations within `window_minutes` (max 120) of an ISO 8601 timestamp —
the reasoning that surrounded an edit. The tool takes the *time*, not the
file: get it first (`git blame -L <line>,<line> <file>` or `git log` for
the commit), then pass its timestamp. `tokenome context <file> <line>` on
the CLI does the blame step for you.

## ask_faq(question, top_k=5)

Curated / pinned answers, `top_k` (1–20) at most. Cheap; try before a raw
search for "known answer" questions.

## get_journal(date=None, days=1), get_recent(limit=20)

The daily development journal (what happened, decisions, open threads)
and the most recent indexed segments.

## browse_by_label(ai_label, limit=20)

Segments by derived label (a model name, else a platform), `limit` (1–100)
at most.

## Errors

Tool errors are returned as `{"error": "…"}`. "daemon unreachable" or
"cannot reach the tokenome daemon" means the tokenome daemon is not
running: tell the user to launch the tokenome app and continue without
memory.
