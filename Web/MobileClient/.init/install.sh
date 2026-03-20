#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/create-a-notes-app-246231-247374/Web/MobileClient"
cd "$WORKSPACE"
[ -f package.json ] || { echo "package.json missing; scaffold step should have created it" >&2; exit 4; }
# inject missing deps if needed; node exits 0 when it changed the file
if node -e "const fs=require('fs');const p=require('./package.json');p.dependencies=p.dependencies||{};const req={'react':'^18.2.0','react-dom':'^18.2.0','react-scripts':'^5.0.1'};let changed=false;for(const k of Object.keys(req)){if(!p.dependencies[k] && !(p.devDependencies && p.devDependencies[k])){p.dependencies[k]=req[k];changed=true;}}if(changed){fs.writeFileSync('package.json',JSON.stringify(p,null,2));process.exit(0);}process.exit(1);"; then CHANGED=1; else CHANGED=0; fi
# if we changed package.json and a lock exists, remove lock to avoid inconsistency
if [ "$CHANGED" -eq 1 ] && [ -f package-lock.json ]; then rm -f package-lock.json || true; fi
# install reproducibly if lock exists else install and generate lockfile
if [ -f package-lock.json ]; then npm ci --no-audit --no-fund --silent; else npm i --no-audit --no-fund --silent; fi
# ensure minimal canonical scripts exist
node -e "const fs=require('fs');const p=require('./package.json');p.scripts=p.scripts||{};p.scripts.start=p.scripts.start||'react-scripts start';p.scripts.build=p.scripts.build||'react-scripts build';p.scripts.test=p.scripts.test||'react-scripts test --watchAll=false';fs.writeFileSync('package.json',JSON.stringify(p,null,2));"
# verify react-scripts installed (node_modules) or available via npx
if [ ! -d node_modules/react-scripts ]; then npx --no-install react-scripts --version >/dev/null 2>&1 || { echo "react-scripts not found after install" >&2; exit 5; }; fi
# print minimal tool versions
node --version || true; npm --version || true; npm bin -g || true
