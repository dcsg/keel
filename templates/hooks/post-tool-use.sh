#!/usr/bin/env bash
# keel: PostToolUse hook (Write|Edit) — auto-format files after edits
# Runs the appropriate formatter for the file's language silently.

# Disable flags
if [ "${KEEL_FORMAT_SKIP:-0}" = "1" ]; then exit 0; fi
if [ ! -f ".keel/config.yaml" ]; then exit 0; fi
if grep -q "post-tool-use: false" .keel/config.yaml 2>/dev/null; then exit 0; fi

FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-${CLAUDE_TOOL_INPUT_PATH:-}}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then exit 0; fi

EXT="${FILE##*.}"

case "$EXT" in
  go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE"
    ;;
  ts|tsx|js|jsx)
    if [ -f "node_modules/.bin/prettier" ]; then
      node_modules/.bin/prettier --write "$FILE" 2>/dev/null
    elif command -v prettier >/dev/null 2>&1; then
      prettier --write "$FILE" 2>/dev/null
    fi
    ;;
  py)
    if command -v black >/dev/null 2>&1; then
      black "$FILE" 2>/dev/null
    elif command -v ruff >/dev/null 2>&1; then
      ruff format "$FILE" 2>/dev/null
    fi
    ;;
  rb)
    command -v rubocop >/dev/null 2>&1 && rubocop -A "$FILE" 2>/dev/null
    ;;
  php)
    command -v php-cs-fixer >/dev/null 2>&1 && php-cs-fixer fix "$FILE" 2>/dev/null
    ;;
  rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE" 2>/dev/null
    ;;
esac

exit 0
