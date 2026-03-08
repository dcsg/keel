#!/bin/bash
# Test: settings.json.tmpl hook schema and hook command behavior
set -uo pipefail

PROJECT_ROOT="$(cd "${1:-.}" && pwd)"
source "$(dirname "$0")/helpers.sh"

echo ""

SETTINGS="$PROJECT_ROOT/templates/settings.json.tmpl"
HOOKS_DIR="$PROJECT_ROOT/templates/hooks"

SESSION_HOOK="$HOOKS_DIR/session-start.sh"
PRETOOL_HOOK="$HOOKS_DIR/pre-tool-use.sh"
POSTTOOL_HOOK="$HOOKS_DIR/post-tool-use.sh"
PRECOMPACT_HOOK="$HOOKS_DIR/pre-compact.sh"

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

# Check all five required hook types exist
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
hooks = s.get('hooks', {})
required = ['SessionStart', 'PreToolUse', 'PostToolUse', 'Stop', 'PreCompact']
for h in required:
    if h not in hooks:
        print(f'MISSING: {h}')
        sys.exit(1)
" 2>/dev/null; then
    pass "All five hook types present (SessionStart, PreToolUse, PostToolUse, Stop, PreCompact)"
else
    fail "All five hook types present (SessionStart, PreToolUse, PostToolUse, Stop, PreCompact)"
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

# Stop hook must be type:command referencing stop-hook.sh
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
stop = s['hooks']['Stop'][0]['hooks'][0]
if stop['type'] != 'command':
    print(f'Stop hook type is {stop[\"type\"]}, expected command')
    sys.exit(1)
if '.keel/hooks/stop-hook.sh' not in stop.get('command', ''):
    print('Stop hook command does not reference stop-hook.sh')
    sys.exit(1)
" 2>/dev/null; then
    pass "Stop hook is type:command referencing stop-hook.sh"
else
    fail "Stop hook is type:command referencing stop-hook.sh"
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

# Hook scripts exist in templates/hooks/
for hook_file in session-start.sh pre-tool-use.sh post-tool-use.sh pre-compact.sh; do
    if [ -f "$HOOKS_DIR/$hook_file" ]; then
        pass "Hook script exists: templates/hooks/$hook_file"
    else
        fail "Hook script exists: templates/hooks/$hook_file"
    fi
done

# Settings.json.tmpl references .keel/hooks/ scripts (not inline bash)
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
hooks = s.get('hooks', {})
for name, entries in hooks.items():
    for entry in entries:
        for h in entry.get('hooks', []):
            if h.get('type') == 'command':
                cmd = h.get('command', '')
                if '.keel/hooks/' not in cmd:
                    print(f'{name}: command does not reference .keel/hooks/: {cmd}')
                    sys.exit(1)
" 2>/dev/null; then
    pass "All command hooks reference \$HOME/.keel/hooks/ scripts"
else
    fail "All command hooks reference \$HOME/.keel/hooks/ scripts"
fi

# ============================================================
# SessionStart behavior tests
# ============================================================

run_session_hook() {
    local dir="$1"
    (cd "$dir" && bash "$SESSION_HOOK" 2>/dev/null)
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
# Use session-start-git: false so the hook doesn't need a git repo
printf "base: docs\nsession-start-git: false\n" > "$MEM_FRESH/.keel/config.yaml"
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
    (cd "$dir" && bash "$PRETOOL_HOOK" 2>/dev/null)
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

# ============================================================
# SessionStart script content assertions
# ============================================================

# SessionStart hook is git-aware (contains git log)
if grep -q 'git log' "$SESSION_HOOK"; then
    pass "SessionStart hook is git-aware (contains 'git log')"
else
    fail "SessionStart hook is git-aware (contains 'git log')"
fi

# SessionStart hook contains migration domain signal
if grep -q 'migration' "$SESSION_HOOK"; then
    pass "SessionStart hook contains 'migration' domain signal"
else
    fail "SessionStart hook contains 'migration' domain signal"
fi

# SessionStart hook contains docker domain signal
if grep -q 'docker' "$SESSION_HOOK"; then
    pass "SessionStart hook contains 'docker' domain signal"
else
    fail "SessionStart hook contains 'docker' domain signal"
fi

# SessionStart hook respects session-start-git disable flag
if grep -q 'session-start-git' "$SESSION_HOOK"; then
    pass "SessionStart hook respects session-start-git disable flag"
else
    fail "SessionStart hook respects session-start-git disable flag"
fi

# ============================================================
# PostToolUse script content assertions
# ============================================================

# PostToolUse hook has KEEL_FORMAT_SKIP disable guard
if grep -q 'KEEL_FORMAT_SKIP' "$POSTTOOL_HOOK"; then
    pass "PostToolUse hook has KEEL_FORMAT_SKIP disable guard"
else
    fail "PostToolUse hook has KEEL_FORMAT_SKIP disable guard"
fi

# PostToolUse hook always exits 0
if grep -q 'exit 0' "$POSTTOOL_HOOK"; then
    pass "PostToolUse hook always exits 0 (has exit 0 at end)"
else
    fail "PostToolUse hook always exits 0 (has exit 0 at end)"
fi

# PostToolUse hook present in settings.json.tmpl
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
if 'PostToolUse' not in s.get('hooks', {}):
    sys.exit(1)
" 2>/dev/null; then
    pass "PostToolUse hook present in settings.json.tmpl"
else
    fail "PostToolUse hook present in settings.json.tmpl"
fi

# PostToolUse has Write|Edit matcher
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
entries = s['hooks'].get('PostToolUse', [])
if not any(e.get('matcher') == 'Write|Edit' for e in entries):
    sys.exit(1)
" 2>/dev/null; then
    pass "PostToolUse hook has Write|Edit matcher"
else
    fail "PostToolUse hook has Write|Edit matcher"
fi

# ============================================================
# PreCompact script content assertions
# ============================================================

# PreCompact hook contains /keel:session
if grep -q '/keel:session' "$PRECOMPACT_HOOK"; then
    pass "PreCompact hook contains '/keel:session'"
else
    fail "PreCompact hook contains '/keel:session'"
fi

# ============================================================
# Stop hook script content assertions
# ============================================================

STOP_HOOK="$HOOKS_DIR/stop-hook.sh"

# Stop hook script exists
if [ -f "$STOP_HOOK" ]; then
    pass "Stop hook script exists: templates/hooks/stop-hook.sh"
else
    fail "Stop hook script exists: templates/hooks/stop-hook.sh"
fi

# Stop hook contains keel:audit signal
if grep -q 'keel:audit' "$STOP_HOOK" 2>/dev/null; then
    pass "Stop hook script references keel:audit"
else
    fail "Stop hook script references keel:audit"
fi

# Stop hook contains security signal
if grep -q 'Security-sensitive' "$STOP_HOOK" 2>/dev/null; then
    pass "Stop hook script contains Security-sensitive signal"
else
    fail "Stop hook script contains Security-sensitive signal"
fi

# Stop hook outputs systemMessage (non-blocking notification)
if grep -q 'systemMessage' "$STOP_HOOK" 2>/dev/null; then
    pass "Stop hook uses systemMessage for non-blocking signal display"
else
    fail "Stop hook uses systemMessage for non-blocking signal display"
fi

# Stop hook guards against infinite loops via stop_hook_active
if grep -q 'stop_hook_active' "$STOP_HOOK" 2>/dev/null; then
    pass "Stop hook guards against infinite loops (stop_hook_active check)"
else
    fail "Stop hook guards against infinite loops (stop_hook_active check)"
fi

# Stop hook references ADR signal
if grep -q 'keel:adr' "$STOP_HOOK" 2>/dev/null; then
    pass "Stop hook script references keel:adr"
else
    fail "Stop hook script references keel:adr"
fi

# Pre-push hook contains KEEL_SECURITY_SKIP
assert_file_contains "$PROJECT_ROOT/templates/hooks/pre-push" "KEEL_SECURITY_SKIP" "pre-push has security skip flag"

test_summary
