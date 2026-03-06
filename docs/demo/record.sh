#!/bin/bash
# Record a real keel workflow demo in Claude Code
#
# Usage: ./docs/demo/record.sh
#
# This creates a temp project, opens Claude Code, and records everything.
# You manually walk through the workflow — the script handles setup and conversion.
#
# Workflow to demo:
#   1. /keel:init        → detect project, pick rules, generate files
#   2. /keel:plan        → plan a small feature (e.g. "JWT auth for an API")
#   3. /keel:status      → show dashboard
#   4. exit              → end recording
#
# Outputs:
#   docs/demo/keel-workflow.cast  (asciinema source)
#   docs/demo/keel-workflow.gif   (for README/docs)
#   docs/demo/keel-workflow.mp4   (alternative format)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CAST_FILE="$REPO_ROOT/docs/demo/keel-workflow.cast"
GIF_FILE="$REPO_ROOT/docs/demo/keel-workflow.gif"
MP4_FILE="$REPO_ROOT/docs/demo/keel-workflow.mp4"

# Check dependencies
for cmd in asciinema agg; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Missing: $cmd"
    echo "Install: brew install $cmd"
    exit 1
  fi
done

# Create a clean temp project
DEMO_DIR=$(mktemp -d)
trap "rm -rf $DEMO_DIR" EXIT

cd "$DEMO_DIR"
git init -q
mkdir -p internal/users internal/auth
echo "module github.com/demo/invoicer" > go.mod
echo "go 1.22" >> go.mod

# Seed a couple files so keel detects Go
cat > main.go << 'GOEOF'
package main

import "fmt"

func main() {
	fmt.Println("invoicer")
}
GOEOF

cat > internal/users/user.go << 'GOEOF'
package users

type User struct {
	ID    string
	Email string
}
GOEOF

git add -A && git commit -q -m "init"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Keel Demo Recording"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Project: $DEMO_DIR"
echo "  Stack:   Go (pre-seeded)"
echo ""
echo "  Walk through this workflow:"
echo ""
echo "    1. /keel:init"
echo "       → accept recommended rules"
echo ""
echo "    2. /keel:plan"
echo "       → \"JWT authentication — register, login, protected routes\""
echo ""
echo "    3. /keel:status"
echo "       → show the dashboard"
echo ""
echo "    4. Type 'exit' to end"
echo ""
echo "  Recording starts in 3 seconds..."
echo ""
sleep 3

# Record the session
asciinema rec -c "claude" "$CAST_FILE" --overwrite

# Convert to GIF and MP4
echo ""
echo "Converting recording..."

echo "  → GIF..."
agg "$CAST_FILE" "$GIF_FILE"

if command -v ffmpeg &>/dev/null; then
  echo "  → MP4..."
  agg "$CAST_FILE" /tmp/keel-demo-frames.gif
  ffmpeg -y -i /tmp/keel-demo-frames.gif -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "$MP4_FILE" 2>/dev/null
  rm -f /tmp/keel-demo-frames.gif
else
  echo "  → MP4 skipped (install ffmpeg for MP4 output)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Recording complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Files:"
echo "    $CAST_FILE"
echo "    $GIF_FILE"
[ -f "$MP4_FILE" ] && echo "    $MP4_FILE"
echo ""
echo "  Replay: asciinema play $CAST_FILE"
echo "  Re-record: ./docs/demo/record.sh"
echo ""
