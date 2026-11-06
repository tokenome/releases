#!/bin/sh
# SessionEnd hook: ask the local tokenome daemon to index this session's
# transcript (the daemon's default format is claude-code). Loopback only;
# silent when the daemon is not running.
TOKEN_FILE="${TOKENOME_API_TOKEN_FILE:-$HOME/.tokenome/api.token}"
TOKEN="$(cat "$TOKEN_FILE" 2>/dev/null)"
curl -sf --max-time 280 -X POST \
  -H 'Content-Type: application/json' \
  -H "X-Tokenome-Token: $TOKEN" \
  --data-binary @- \
  http://127.0.0.1:8741/api/hooks/ingest >/dev/null 2>&1 || true
exit 0
