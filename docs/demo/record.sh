#!/bin/bash
# Keel demo recorder — records individual flows or all at once
#
# Usage:
#   ./docs/demo/record.sh              # list available flows
#   ./docs/demo/record.sh 01-init      # record one flow
#   ./docs/demo/record.sh all          # record all flows
#
# Prereqs: vhs, claude, git, tree

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TAPES_DIR="$SCRIPT_DIR/tapes"
OUTPUT_DIR="$SCRIPT_DIR/output"

cd "$REPO_ROOT"

# Check dependencies
for cmd in vhs claude git; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Missing: $cmd"
        exit 1
    fi
done

mkdir -p "$OUTPUT_DIR"

# Map flows to their setup scripts
setup_for() {
    case "$1" in
        01-init|07-workflow)  echo "setup-demo-project.sh" ;;
        06-intake)            echo "setup-messy-project.sh" ;;
        *)                    echo "setup-established-project.sh" ;;
    esac
}

# Record a single flow
record_flow() {
    local tape="$TAPES_DIR/$1.tape"
    if [ ! -f "$tape" ]; then
        echo "Tape not found: $tape"
        return 1
    fi

    local setup_script="$SCRIPT_DIR/$(setup_for "$1")"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Recording: $1"
    echo "  Setup:     $(basename "$setup_script")"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Create temp project
    echo "  Setting up demo project..."
    DEMO_DIR=$(bash "$setup_script")
    trap "rm -rf $DEMO_DIR" RETURN

    echo "  Project: $DEMO_DIR"

    # Pre-trust the directory so the interactive trust dialog doesn't appear.
    # claude -p skips the trust prompt and registers the workspace as trusted.
    echo "  Pre-trusting workspace..."
    (cd "$DEMO_DIR" && claude -p "exit" --output-format text 2>/dev/null || true)

    # Write env.tape for VHS
    cat > "$SCRIPT_DIR/env.tape" << EOF
# Auto-generated — do not edit
Hide
Type "cd $DEMO_DIR && unset CLAUDECODE && clear"
Enter
Sleep 1
Show
EOF

    echo "  Recording with VHS..."
    vhs "$tape"

    # Clean up
    rm -f "$SCRIPT_DIR/env.tape"
    rm -rf "$DEMO_DIR"
    trap - RETURN

    echo "  Done: $OUTPUT_DIR/$1.gif"
}

# No args — list available flows
if [ -z "${1:-}" ]; then
    echo ""
    echo "Keel Demo Recorder"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Available flows:"
    for tape in "$TAPES_DIR"/*.tape; do
        name=$(basename "$tape" .tape)
        desc=$(grep '^# Flow' "$tape" | head -1 | sed 's/^# Flow [0-9]*: //')
        printf "  %-16s %s\n" "$name" "$desc"
    done
    echo ""
    echo "Usage:"
    echo "  ./docs/demo/record.sh 01-init    # record one flow"
    echo "  ./docs/demo/record.sh all        # record all flows"
    echo ""
    exit 0
fi

# Record all or a specific flow
if [ "$1" = "all" ]; then
    for tape in "$TAPES_DIR"/*.tape; do
        name=$(basename "$tape" .tape)
        record_flow "$name"
    done
else
    record_flow "$1"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  All recordings complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
ls -lh "$OUTPUT_DIR"/*.gif 2>/dev/null
echo ""
