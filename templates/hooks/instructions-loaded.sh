#!/usr/bin/env bash
# keel: InstructionsLoaded hook — log which rule packs are active
# Fires every time a .claude/rules/*.md file is loaded. Logs the rule
# name to session-signals.log for visibility in /keel:status.

# Only run in keel projects
if [ ! -f ".keel/config.yaml" ]; then exit 0; fi

# The loaded file path is available via hook input
FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-${CLAUDE_TOOL_INPUT_PATH:-}}"
if [ -z "$FILE" ]; then exit 0; fi

# Only log .claude/rules/ files
case "$FILE" in
  *.claude/rules/*.md)
    RULE_NAME=$(basename "$FILE" .md)
    mkdir -p "$HOME/.keel" 2>/dev/null || true
    LOG_FILE="$HOME/.keel/session-signals.log"
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "${TIMESTAMP} RULE_LOADED ${RULE_NAME}" >> "$LOG_FILE"
    ;;
esac

exit 0
