#!/bin/bash
# Strips <governance_checkpoint>...</governance_checkpoint> blocks from rule files.
# Usage: ./strip-checkpoints.sh path/to/.claude/rules/
#
# Run this on a copy of the rules to create the "without checkpoint" condition.
# Do NOT run on the templates directory.

set -euo pipefail

RULES_DIR="${1:?Usage: $0 <rules-directory>}"

if [[ "$RULES_DIR" == *"templates/rules"* ]]; then
    echo "ERROR: Do not run this on the templates directory. Copy rules first."
    exit 1
fi

count=0
for rule in "$RULES_DIR"/*.md; do
    [ -f "$rule" ] || continue
    if grep -q '<governance_checkpoint>' "$rule" 2>/dev/null; then
        perl -i -0pe 's/\n<governance_checkpoint>.*?<\/governance_checkpoint>\n//s' "$rule"
        echo "Stripped: $(basename "$rule")"
        ((count++))
    fi
done

echo "Done. Stripped checkpoints from $count files."
