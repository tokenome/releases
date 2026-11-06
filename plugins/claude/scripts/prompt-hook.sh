#!/bin/sh
# UserPromptSubmit hook: hand the prompt to the local tokenome daemon, which
# answers with a nudge when the prompt is about a past decision and with
# nothing otherwise. Loopback only, never fails the prompt.
TOKEN_FILE="${TOKENOME_API_TOKEN_FILE:-$HOME/.tokenome/api.token}"
TOKEN="$(cat "$TOKEN_FILE" 2>/dev/null)"
curl -sf --max-time 3 -X POST \
  -H 'Content-Type: application/json' \
  -H "X-Tokenome-Token: $TOKEN" \
  --data-binary @- \
  http://127.0.0.1:8741/api/hooks/prompt 2>/dev/null || true
exit 0
