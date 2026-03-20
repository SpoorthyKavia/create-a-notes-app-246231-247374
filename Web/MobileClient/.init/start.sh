#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/create-a-notes-app-246231-247374/Web/MobileClient"
cd "$WORKSPACE"
[ -f /etc/profile.d/web_mobileclient_env.sh ] && source /etc/profile.d/web_mobileclient_env.sh || true
PORT=${PORT:-3000}
# start dev server headless in new session and capture logs
SETSID_LOG="$WORKSPACE/dev-start.log"
setsid env NODE_ENV=development BROWSER=none HOST=127.0.0.1 PORT="$PORT" npm start >"$SETSID_LOG" 2>&1 &
# record PID and PGID for later stop
PID=$!
echo "$PID" > "$WORKSPACE/.devserver.pid"
PGID=$(ps -o pgid= -p "$PID" | tr -d ' ')
echo "$PGID" > "$WORKSPACE/.devserver.pgid"
echo "started PID=$PID PGID=$PGID log=$SETSID_LOG"
