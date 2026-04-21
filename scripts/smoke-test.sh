#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PORT=3100 DB_USER=smoke_user DB_PASSWORD=smoke_password node app.js > /tmp/atelier-k8s-app.log 2>&1 &
APP_PID=$!

cleanup() {
  kill "$APP_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

sleep 1

RESPONSE="$(curl -s http://127.0.0.1:3100/)"
echo "$RESPONSE" | grep -q 'smoke_user'
echo "$RESPONSE" | grep -q '"password":"\*\*\*\*\*\*"'

HEALTH="$(curl -s http://127.0.0.1:3100/healthz)"
echo "$HEALTH" | grep -q '"status":"ok"'

echo "Smoke test passed"
