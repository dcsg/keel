#!/bin/bash
# Test: settings.json.tmpl hook schema and hook command behavior
set -uo pipefail

PROJECT_ROOT="${1:-.}"
source "$(dirname "$0")/helpers.sh"

echo ""

SETTINGS="$PROJECT_ROOT/templates/settings.json.tmpl"

# ============================================================
# Schema validation — ensure new nested hook format is correct
# ============================================================

# Validate JSON is parseable
if python3 -c "import json; json.load(open('$SETTINGS'))" 2>/dev/null; then
    pass "settings.json.tmpl is valid JSON"
else
    fail "settings.json.tmpl is valid JSON"
    test_summary; exit 1
fi

# Check all four required hook types exist
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
hooks = s.get('hooks', {})
required = ['SessionStart', 'PreToolUse', 'Stop', 'PreCompact']
for h in required:
    if h not in hooks:
        print(f'MISSING: {h}')
        sys.exit(1)
" 2>/dev/null; then
    pass "All four hook types present (SessionStart, PreToolUse, Stop, PreCompact)"
else
    fail "All four hook types present (SessionStart, PreToolUse, Stop, PreCompact)"
fi

# Check nested hooks[] array format for each hook
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
hooks = s.get('hooks', {})
for name, entries in hooks.items():
    for entry in entries:
        nested = entry.get('hooks', [])
        if not nested:
            print(f'{name}: missing nested hooks[] array')
            sys.exit(1)
        for h in nested:
            if 'type' not in h:
                print(f'{name}: nested hook missing type field')
                sys.exit(1)
" 2>/dev/null; then
    pass "All hooks use nested hooks[] array with type field"
else
    fail "All hooks use nested hooks[] array with type field"
fi

# Stop hook must be type:prompt (not type:command)
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
stop = s['hooks']['Stop'][0]['hooks'][0]
if stop['type'] != 'prompt':
    print(f'Stop hook type is {stop[\"type\"]}, expected prompt')
    sys.exit(1)
if 'prompt' not in stop:
    print('Stop hook missing prompt field')
    sys.exit(1)
" 2>/dev/null; then
    pass "Stop hook is type:prompt with prompt field"
else
    fail "Stop hook is type:prompt with prompt field"
fi

# Stop prompt mentions ADR, invariant, PRD
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
prompt = s['hooks']['Stop'][0]['hooks'][0]['prompt']
for kw in ['ADR', 'invariant', 'PRD']:
    if kw not in prompt:
        print(f'Stop prompt missing keyword: {kw}')
        sys.exit(1)
" 2>/dev/null; then
    pass "Stop hook prompt references ADR, invariant, PRD"
else
    fail "Stop hook prompt references ADR, invariant, PRD"
fi

# PreToolUse must have matcher: Write|Edit
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
entry = s['hooks']['PreToolUse'][0]
if 'matcher' not in entry:
    print('PreToolUse missing matcher field')
    sys.exit(1)
if entry['matcher'] != 'Write|Edit':
    print(f'PreToolUse matcher is {entry[\"matcher\"]}, expected Write|Edit')
    sys.exit(1)
" 2>/dev/null; then
    pass "PreToolUse has matcher: Write|Edit"
else
    fail "PreToolUse has matcher: Write|Edit"
fi

# Extract commands for behavior tests
SESSION_CMD=$(python3 -c "
import json
s = json.load(open('$SETTINGS'))
print(s['hooks']['SessionStart'][0]['hooks'][0]['command'])
")

PRETOOL_CMD=$(python3 -c "
import json
s = json.load(open('$SETTINGS'))
print(s['hooks']['PreToolUse'][0]['hooks'][0]['command'])
")

# ============================================================
# SessionStart behavior tests
# ============================================================

run_session_hook() {
    local dir="$1"
    (cd "$dir" && bash -c "$SESSION_CMD" 2>/dev/null)
}

# SessionStart: no keel config → silent
NOKEEL=$(mktemp -d)
OUTPUT=$(run_session_hook "$NOKEEL")
if [ -z "$OUTPUT" ]; then
    pass "SessionStart: silent when no .keel/config.yaml"
else
    fail "SessionStart: silent when no .keel/config.yaml" "Got: $OUTPUT"
fi
rm -rf "$NOKEEL"

# SessionStart: keel config exists, no memory → prompts to run keel:context
FRESH=$(mktemp -d)
mkdir -p "$FRESH/.keel"
echo "base: docs" > "$FRESH/.keel/config.yaml"
OUTPUT=$(run_session_hook "$FRESH")
if echo "$OUTPUT" | grep -q "keel:context\|Keel"; then
    pass "SessionStart: prompts to run keel:context when no memory"
else
    fail "SessionStart: prompts to run keel:context when no memory" "Got: $OUTPUT"
fi
rm -rf "$FRESH"

# SessionStart: memory exists and is fresh → produces output
MEM_FRESH=$(mktemp -d)
mkdir -p "$MEM_FRESH/.keel"
echo "base: docs" > "$MEM_FRESH/.keel/config.yaml"
ENCODED=$(echo "$MEM_FRESH" | sed 's|/|-|g')
MEM_DIR="$HOME/.claude/projects/${ENCODED}/memory"
mkdir -p "$MEM_DIR"
echo "# Test Project" > "$MEM_DIR/MEMORY.md"
OUTPUT=$(run_session_hook "$MEM_FRESH")
if [ -n "$OUTPUT" ]; then
    pass "SessionStart: outputs something when memory exists"
else
    fail "SessionStart: outputs something when memory exists" "Got empty output"
fi
rm -rf "$MEM_FRESH"
rm -rf "$HOME/.claude/projects/${ENCODED}" 2>/dev/null || true

# ============================================================
# PreToolUse behavior tests
# ============================================================

run_pretool_hook() {
    local dir="$1"
    (cd "$dir" && bash -c "$PRETOOL_CMD" 2>/dev/null)
}

# PreToolUse: no keel config → silent
NOKEEL2=$(mktemp -d)
OUTPUT=$(run_pretool_hook "$NOKEEL2")
if [ -z "$OUTPUT" ]; then
    pass "PreToolUse: silent when no .keel/config.yaml"
else
    fail "PreToolUse: silent when no .keel/config.yaml" "Got: $OUTPUT"
fi
rm -rf "$NOKEEL2"

# PreToolUse: keel config exists but soul.md missing → warns
NOSOUL=$(mktemp -d)
mkdir -p "$NOSOUL/.keel"
echo "base: docs" > "$NOSOUL/.keel/config.yaml"
OUTPUT=$(run_pretool_hook "$NOSOUL")
if [ -n "$OUTPUT" ]; then
    pass "PreToolUse: warns when soul.md is missing"
else
    fail "PreToolUse: warns when soul.md is missing" "Got empty output"
fi
rm -rf "$NOSOUL"

# PreToolUse: keel config AND soul.md both exist → silent
COMPLETE=$(mktemp -d)
mkdir -p "$COMPLETE/.keel" "$COMPLETE/docs"
echo "base: docs" > "$COMPLETE/.keel/config.yaml"
echo "# My App" > "$COMPLETE/docs/soul.md"
OUTPUT=$(run_pretool_hook "$COMPLETE")
if [ -z "$OUTPUT" ]; then
    pass "PreToolUse: silent when setup is complete"
else
    fail "PreToolUse: silent when setup is complete" "Got: $OUTPUT"
fi
rm -rf "$COMPLETE"

test_summary
