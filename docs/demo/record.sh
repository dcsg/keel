#!/bin/bash
# Automated keel demo recording
#
# Usage: ./docs/demo/record.sh
#
# 1. Creates a temp Go project
# 2. Runs VHS with Wait-based automation (handles variable response times)
# 3. Outputs GIF + MP4 to docs/demo/
#
# Fully automated. No manual interaction. Re-run anytime.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

for cmd in vhs claude git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Missing: $cmd"
    exit 1
  fi
done

# Create temp demo project
echo "Setting up demo project..."
DEMO_DIR=$(bash docs/demo/setup-demo-project.sh)
trap "rm -rf $DEMO_DIR" EXIT

echo "Demo project: $DEMO_DIR"

# Write env.tape that VHS sources (sets working directory)
cat > docs/demo/env.tape << EOF
# Auto-generated — do not edit
# Points VHS to the temp demo project
Hide
Type "cd $DEMO_DIR && unset CLAUDECODE && clear"
Enter
Sleep 1
Show
EOF

echo "Recording with VHS (this takes a few minutes)..."
echo ""

vhs docs/demo/demo.tape

# Clean up generated env.tape
rm -f docs/demo/env.tape

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
ls -lh docs/demo/keel-workflow.* 2>/dev/null
echo ""
echo "  Re-record: ./docs/demo/record.sh"
echo ""
