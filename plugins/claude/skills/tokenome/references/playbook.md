# Playbook — worked examples

## "Why do we use Typesense instead of Postgres?"

1. `why_was("use Typesense instead of Postgres")`
2. A record with `status: stated`, `confidence: high`, evidence span
   quoting "hybrid BM25 + vector in one engine, fine to 10^7 docs".
3. Answer: the decision, the reason, the date, and the quote. Offer to open
   the conversation (`conversation_id`) if they want the full discussion.

Good: "You chose Typesense on 2026-07-03 because it gives hybrid keyword +
vector search in one engine and was judged fine up to ~10^7 documents;
Postgres was the fallback if the corpus outgrew that. (Journal, stated;
evidence in conversation `…`.)"

Bad: pasting three paragraphs of the original transcript; or answering
from general knowledge about Typesense vs Postgres without checking.

## "What did we try to fix the flaky queue ordering?"

1. `search_memory("flaky queue ordering oldest-first")`
2. Best hit excerpt mentions millisecond filenames; `get_conversation` shows
   the fix moved to nanosecond stamps plus a chunk sequence.
3. Answer with attempts and outcomes: "Millisecond timestamps in queue
   filenames collided → nondeterministic order. Fixed by `time.time_ns()`
   plus a per-batch sequence. Nothing else was tried."

## Team-scoped question while enrolled

`search_memory("retry-after backpressure", scope="auto")` returns
`source: remote` with an `owner` on each hit.

Good: "Bob's session on 2026-08-20 settled this: the server answers 429
with Retry-After and the client honors it (…)." — attributed.

Bad: "We decided to honor Retry-After…" — presenting Bob's conversation as
the user's own.

## Team unavailable

The result carries `warning: "Team results unavailable — showing local
only (timeout)"`. Say: "The team server didn't answer in time, so this is
from your local index only:" and proceed. Do not retry the same call.

## "What was going on at src/tokenome/remote/sink.py:212?"

`git blame -L 212,212 src/tokenome/remote/sink.py` gives the commit and its
timestamp → `find_conversations_near("2026-08-26T14:03:00")` → the
conversations within 30 minutes of that edit. Summarize the reasoning that
led to it; mention the commit and date.

## Daemon down

The tool returns "cannot reach the tokenome daemon". Say once: "tokenome
isn't running — launch the tokenome app to use memory." Then answer the
rest of the question from source without further memory calls.

## Nothing found

"tokenome has no conversations about X." Do not fabricate. Optionally
suggest a reformulation or ask whether it happened in a different project.
