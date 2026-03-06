#!/bin/bash
# Record a keel workflow demo
#
# Usage: ./docs/demo/record.sh
#
# Sets up a temp Go project, tells you what to do,
# opens Claude Code inside asciinema, and converts to GIF when done.
#
# ~3-5 minutes of your time. Fully reproducible output.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CAST_FILE="$REPO_ROOT/docs/demo/keel-workflow.cast"
GIF_FILE="$REPO_ROOT/docs/demo/keel-workflow.gif"

for cmd in asciinema agg claude; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Missing: $cmd — brew install $cmd"
    exit 1
  fi
done

# Create temp project
DEMO_DIR=$(mktemp -d)
trap "rm -rf $DEMO_DIR" EXIT

cd "$DEMO_DIR"
git init -q
mkdir -p internal/users internal/auth

cat > go.mod << 'EOF'
module github.com/demo/invoicer

go 1.22
EOF

cat > main.go << 'EOF'
package main

import "fmt"

func main() {
	fmt.Println("invoicer")
}
EOF

cat > internal/users/user.go << 'EOF'
package users

type User struct {
	ID    string
	Email string
}
EOF

git add -A && git commit -q -m "init: go project scaffold"

clear
echo ""
echo "  ┌─────────────────────────────────────────────┐"
echo "  │         Keel Demo — Recording Guide          │"
echo "  ├─────────────────────────────────────────────┤"
echo "  │                                             │"
echo "  │  Project: temp Go backend (auto-cleaned)    │"
echo "  │                                             │"
echo "  │  Run these 3 commands inside Claude:        │"
echo "  │                                             │"
echo "  │  1. /keel:init                              │"
echo "  │     → accept recommended rules              │"
echo "  │                                             │"
echo "  │  2. /keel:plan                              │"
echo "  │     → \"JWT auth: register, login,           │"
echo "  │        protected routes, 24h token expiry\"  │"
echo "  │                                             │"
echo "  │  3. /keel:status                            │"
echo "  │     → show the dashboard                    │"
echo "  │                                             │"
echo "  │  4. /exit to quit Claude and stop recording │"
echo "  │                                             │"
echo "  └─────────────────────────────────────────────┘"
echo ""
echo "  Press ENTER to start recording..."
read -r

# Allow nested if run from inside claude
unset CLAUDECODE

asciinema rec -c "claude" "$CAST_FILE" --overwrite

# Post-recording conversion
echo ""
echo "  Converting to GIF..."
agg "$CAST_FILE" "$GIF_FILE"

echo ""
echo "  ┌─────────────────────────────────────────────┐"
echo "  │  Done!                                       │"
echo "  ├─────────────────────────────────────────────┤"
echo "  │  $CAST_FILE"
echo "  │  $GIF_FILE"
echo "  │                                             │"
echo "  │  Replay:  asciinema play docs/demo/keel-workflow.cast"
echo "  │  Re-do:   ./docs/demo/record.sh             │"
echo "  └─────────────────────────────────────────────┘"
echo ""
