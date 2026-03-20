#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/create-a-notes-app-246231-247374/Web/MobileClient"
cd "$WORKSPACE"
[ -f /etc/profile.d/web_mobileclient_env.sh ] && source /etc/profile.d/web_mobileclient_env.sh || true
# run lightweight jest smoke test once non-interactively
CI=true BROWSER=none npm test --silent -- --watchAll=false || { echo "tests failed" >&2; exit 6; }
