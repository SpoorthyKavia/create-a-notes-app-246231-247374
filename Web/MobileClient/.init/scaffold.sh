#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/create-a-notes-app-246231-247374/Web/MobileClient"
cd "$WORKSPACE"
LOG="$WORKSPACE/cra-scaffold.log"
# only scaffold when no package.json and no src directory
if [ ! -f package.json ] && [ ! -d src ]; then
  if command -v create-react-app >/dev/null 2>&1; then
    timeout 300s create-react-app . --use-npm 2>>"$LOG" || { echo "CRA scaffold failed, see $LOG" >&2; exit 4; }
  else
    timeout 300s npx create-react-app@5.0.1 . --use-npm --ignore-existing 2>>"$LOG" || { echo "CRA scaffold failed, see $LOG" >&2; exit 4; }
  fi
fi
# write notes storage helper aligned with package.json.type
MODULE_TYPE=$(node -e "try{const p=require('./package.json');console.log(p.type||'');}catch(e){console.log('');}") || true
mkdir -p src/utils
NOTE_FILE="src/utils/notesStorage.js"
if [ "$MODULE_TYPE" = "module" ]; then
  cat > "$NOTE_FILE" <<'EOF'
// minimal localStorage-backed notes API (ESM)
const KEY = 'dev_notes_v1'
export function loadNotes(){try{return JSON.parse(localStorage.getItem(KEY)||'[]')}catch(e){return []}}
export function saveNotes(notes){localStorage.setItem(KEY,JSON.stringify(notes||[]))}
export function addNote(note){const n=loadNotes();n.push(note);saveNotes(n);return n}
EOF
else
  cat > "$NOTE_FILE" <<'EOF'
// minimal localStorage-backed notes API (CommonJS-friendly)
const KEY = 'dev_notes_v1'
function loadNotes(){try{return JSON.parse(localStorage.getItem(KEY)||'[]')}catch(e){return []}}
function saveNotes(notes){localStorage.setItem(KEY,JSON.stringify(notes||[]))}
function addNote(note){const n=loadNotes();n.push(note);saveNotes(n);return n}
module.exports = { loadNotes, saveNotes, addNote }
EOF
fi
# idempotency: ensure at least an entrypoint exists (no-op if CRA created files)
[ -f src/index.js ] || [ -f src/main.js ] || true
