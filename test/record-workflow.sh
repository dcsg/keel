#!/bin/bash
# Record e2e workflow test as asciinema + animated GIF

set -e

CAST_FILE="test/workflow-e2e.cast"
GIF_FILE="test/workflow-e2e.mp4"

echo "Recording workflow test..."
asciinema rec -c "./test/run.sh" "$CAST_FILE" --overwrite

echo ""
echo "Converting to animated GIF..."
agg "$CAST_FILE" "$GIF_FILE"

echo ""
echo "✓ Recording complete:"
echo "  - $CAST_FILE (source, reproducible)"
echo "  - $GIF_FILE (for docs)"
