#!/bin/bash
# Record keel demo video + e2e test recording
# Produces reproducible GIF + MP4 for docs

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

# ── Demo video (user-facing workflow) ──
echo "Rendering workflow demo..."
vhs docs/demo/demo.tape

echo ""
echo "Demo outputs:"
echo "  - docs/demo/keel-workflow.gif"
echo "  - docs/demo/keel-workflow.mp4"

# ── Test recording (CI test suite) ──
echo ""
echo "Recording test suite..."
asciinema rec -c "./test/run.sh" test/workflow-e2e.cast --overwrite

echo ""
echo "Converting test recording to GIF..."
agg test/workflow-e2e.cast test/workflow-e2e.gif

echo ""
echo "Done:"
echo "  - docs/demo/keel-workflow.gif  (user-facing demo)"
echo "  - docs/demo/keel-workflow.mp4  (user-facing demo)"
echo "  - test/workflow-e2e.cast       (test suite recording)"
echo "  - test/workflow-e2e.gif        (test suite GIF)"
