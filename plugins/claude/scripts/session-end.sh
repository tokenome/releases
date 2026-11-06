#!/bin/sh
# SessionEnd hook: ask the local tokenome daemon to index this session's
# transcript. Loopback only; silent when the daemon is not running.
TOKEN_FILE="${TOKENOME_API_TOKEN_FILE:-$HOME/.tokenome/api.token}"
TOKEN="$(cat "$TOKEN_FILE" 2>/dev/null)"
curl -sf --max-time 280 -o /dev/null -X POST \
  -H 'Content-Type: application/json' \
  -H "X-Tokenome-Token: $TOKEN" \
  --data-binary @- \
  'http://127.0.0.1:8741/api/hooks/ingest?format=claude-code' 2>/dev/null || true
exit 0
