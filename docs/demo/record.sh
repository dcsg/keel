#!/bin/bash
# Automated keel workflow demo recording
#
# Usage: ./docs/demo/record.sh
#
# Creates a temp Go project, runs keel commands via claude -p,
# records everything with asciinema, converts to GIF + MP4.
# Fully automated — no manual interaction needed.
#
# Outputs:
#   docs/demo/keel-workflow.cast  (asciinema source)
#   docs/demo/keel-workflow.gif   (for README/docs)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CAST_FILE="$REPO_ROOT/docs/demo/keel-workflow.cast"
GIF_FILE="$REPO_ROOT/docs/demo/keel-workflow.gif"

# Check dependencies
for cmd in asciinema agg claude; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Missing: $cmd"
    exit 1
  fi
done

# Create a clean temp project
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

# Allow running claude -p even if invoked from within a Claude Code session
unset CLAUDECODE

# ── The demo script that asciinema will record ──
cat > "$DEMO_DIR/_run_demo.sh" << 'DEMO'
#!/bin/bash
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

section() {
  echo ""
  echo -e "${BOLD}${CYAN}━━━ $1 ━━━${RESET}"
  echo ""
  sleep 1
}

# Show project context
echo -e "${DIM}~/projects/invoicer${RESET}"
echo -e "${DIM}Go backend · greenfield · 1 commit${RESET}"
sleep 1

# ── Step 1: keel:init ──
section "Step 1: /keel:init"
echo -e "${DIM}Initializing keel — detecting project, installing rules...${RESET}"
echo ""

claude -p "Run /keel:init for this project. It's a Go backend for a SaaS invoicing tool. Accept all recommended rules and generate everything. Be concise in your output — show what was detected and what was generated." \
  --dangerously-skip-permissions \
  --allow-dangerously-skip-permissions

sleep 2

# ── Step 2: keel:plan ──
section "Step 2: /keel:plan"
echo -e "${DIM}Planning a feature — JWT authentication...${RESET}"
echo ""

claude -p "Run /keel:plan to plan JWT authentication for this API. Requirements: user registration (POST /auth/register), login (POST /auth/login returns JWT), protected routes (all /api/* need Authorization header), token expiry after 24 hours. Create a 2-phase plan. Be concise." \
  --dangerously-skip-permissions \
  --allow-dangerously-skip-permissions \
  -c 2>/dev/null

sleep 2

# ── Step 3: keel:status ──
section "Step 3: /keel:status"
echo -e "${DIM}Checking project status...${RESET}"
echo ""

claude -p "Run /keel:status to show the project dashboard — installed rules, plan progress, governance health. Be concise." \
  --dangerously-skip-permissions \
  --allow-dangerously-skip-permissions \
  -c 2>/dev/null

sleep 2

# ── Done ──
echo ""
echo -e "${BOLD}${GREEN}That's keel.${RESET}"
echo -e "${DIM}Context loaded. Rules enforced. Every session.${RESET}"
echo ""
echo -e "${DIM}Install:  curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash${RESET}"
echo -e "${DIM}Start:    /keel:init${RESET}"
echo ""
sleep 3
DEMO

chmod +x "$DEMO_DIR/_run_demo.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Recording keel demo (automated)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Record the automated demo
asciinema rec \
  -c "bash $DEMO_DIR/_run_demo.sh" \
  "$CAST_FILE" \
  --overwrite

# Convert to GIF
echo ""
echo "Converting to GIF..."
agg --theme mocha "$CAST_FILE" "$GIF_FILE" 2>/dev/null || agg "$CAST_FILE" "$GIF_FILE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  $CAST_FILE"
echo "  $GIF_FILE"
echo ""
echo "  Replay:    asciinema play $CAST_FILE"
echo "  Re-record: ./docs/demo/record.sh"
echo ""
