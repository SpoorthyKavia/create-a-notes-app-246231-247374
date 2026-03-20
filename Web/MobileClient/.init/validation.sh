#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/create-a-notes-app-246231-247374/Web/MobileClient"
cd "$WORKSPACE"
[ -f /etc/profile.d/web_mobileclient_env.sh ] && source /etc/profile.d/web_mobileclient_env.sh || true
PORT=${PORT:-3000}
# build
npm run build --silent || { echo "build failed" >&2; exit 7; }
# start in new session
SETSID_LOG="$WORKSPACE/dev-start.log"
setsid env NODE_ENV=development BROWSER=none HOST=127.0.0.1 PORT="$PORT" npm start >"$SETSID_LOG" 2>&1 &
PID=$!
PGID=$(ps -o pgid= -p "$PID" | tr -d ' ')
# save identifiers
echo "$PID" > "$WORKSPACE/.devserver.pid"; echo "$PGID" > "$WORKSPACE/.devserver.pgid"
# wait for server to become responsive (max 30s)
SUCCESS=0
for i in {1..30}; do sleep 1; HTTP_STATUS=$(curl -sS -o /dev/null -w "%{http_code}" "http://127.0.0.1:$PORT" 2>/dev/null || true); if [ -n "$HTTP_STATUS" ] && [ "$HTTP_STATUS" -ge 200 ]; then SUCCESS=1; break; fi; done
if [ "$SUCCESS" -ne 1 ]; then echo "server did not respond; tail of log:" >&2; tail -n 200 "$SETSID_LOG" >&2 || true; kill -- -"$PGID" >/dev/null 2>&1 || true; wait "$PID" 2>/dev/null || true; exit 8; fi
echo "validation: server responding (HTTP $HTTP_STATUS) at http://127.0.0.1:$PORT"
# terminate process group cleanly
kill -TERM -- -"$PGID" || kill -- -"$PGID" || true
sleep 2
# verify port closed using available tool fallback
CLOSED=0
if command -v ss >/dev/null 2>&1; then ss -ltn "sport = :$PORT" | grep -q LISTEN || CLOSED=1; elif command -v netstat >/dev/null 2>&1; then netstat -ltn | grep -q ":$PORT" || CLOSED=1; elif command -v lsof >/dev/null 2>&1; then lsof -iTCP -sTCP:LISTEN -P | grep -q ":$PORT" || CLOSED=1; else CLOSED=1; fi
if [ "$CLOSED" -ne 1 ]; then echo "port $PORT still listening" >&2; exit 9; fi
# evidence
echo "dev-start log tail:"
tail -n 40 "$SETSID_LOG" || true
# cleanup pid files
rm -f "$WORKSPACE/.devserver.pid" "$WORKSPACE/.devserver.pgid"
