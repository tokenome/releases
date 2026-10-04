#!/usr/bin/env bash
# Back up the tokenome team server: identity DB + JWT secret + a
# point-in-time Typesense snapshot, tarred with a timestamp.
#
#   ./backup.sh [output-dir]        # default: ./backups
#
# Run from the deploy/ directory with the stack up. Restore procedure is
# documented in README.md. Ship the resulting .tar.gz off-box.

set -euo pipefail
cd "$(dirname "$0")"

STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_ROOT="${1:-./backups}"
OUT="$OUT_ROOT/tokenome-backup-$STAMP"
mkdir -p "$OUT"

echo "[1/3] Identity DB (consistent copy via VACUUM INTO) + JWT secret"
docker compose exec -T server python - <<'PY'
import sqlite3

sqlite3.connect("/data/server.db").execute("VACUUM INTO '/data/backup.db'")
PY
docker compose cp server:/data/backup.db "$OUT/server.db"
docker compose cp server:/data/jwt.secret "$OUT/jwt.secret"
docker compose exec -T server rm -f /data/backup.db

echo "[2/3] Typesense point-in-time snapshot"
docker compose exec -T -e SNAP="/data/snapshots/$STAMP" server python - <<'PY'
import os

import httpx

resp = httpx.post(
    "http://typesense:8108/operations/snapshot",
    params={"snapshot_path": os.environ["SNAP"]},
    headers={"x-typesense-api-key": os.environ["TOKENOME_TYPESENSE_API_KEY"]},
    timeout=300,
)
resp.raise_for_status()
print(resp.json())
PY
docker compose cp "typesense:/data/snapshots/$STAMP" "$OUT/typesense-snapshot"
docker compose exec -T typesense rm -rf "/data/snapshots/$STAMP"

echo "[3/3] Packaging"
tar -czf "$OUT.tar.gz" -C "$OUT_ROOT" "tokenome-backup-$STAMP"
rm -rf "$OUT"
echo "Backup written: $OUT.tar.gz"
