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
# Use session-summary: false so the hook doesn't need a git repo
printf "base: docs\nsession-summary: false\n" > "$MEM_FRESH/.keel/config.yaml"
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

# PreToolUse: keel config exists but project-context.md missing → warns
NOSOUL=$(mktemp -d)
mkdir -p "$NOSOUL/.keel"
echo "base: docs" > "$NOSOUL/.keel/config.yaml"
OUTPUT=$(run_pretool_hook "$NOSOUL")
if [ -n "$OUTPUT" ]; then
    pass "PreToolUse: warns when project-context.md is missing"
else
    fail "PreToolUse: warns when project-context.md is missing" "Got empty output"
fi
rm -rf "$NOSOUL"

# PreToolUse: keel config AND project-context.md both exist → silent
COMPLETE=$(mktemp -d)
mkdir -p "$COMPLETE/.keel" "$COMPLETE/docs"
echo "base: docs" > "$COMPLETE/.keel/config.yaml"
echo "# My App" > "$COMPLETE/docs/project-context.md"
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

# SessionStart hook respects session-summary disable flag
if grep -q 'session-summary: false' "$SESSION_HOOK"; then
    pass "SessionStart hook respects session-summary disable flag"
else
    fail "SessionStart hook respects session-summary disable flag"
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

# ============================================================
# v4.0 — New hook scripts exist
# ============================================================

UPS_HOOK="$HOOKS_DIR/user-prompt-submit.sh"
POSTCOMPACT_HOOK="$HOOKS_DIR/post-compact.sh"
SUBAGENT_HOOK="$HOOKS_DIR/subagent-stop.sh"
INSTRUCTIONS_HOOK="$HOOKS_DIR/instructions-loaded.sh"

assert_file_exists "$UPS_HOOK" "Hook script exists: templates/hooks/user-prompt-submit.sh"
assert_file_exists "$POSTCOMPACT_HOOK" "Hook script exists: templates/hooks/post-compact.sh"
assert_file_exists "$SUBAGENT_HOOK" "Hook script exists: templates/hooks/subagent-stop.sh"
assert_file_exists "$INSTRUCTIONS_HOOK" "Hook script exists: templates/hooks/instructions-loaded.sh"

# ============================================================
# v4.0 — New hooks present in settings.json.tmpl
# ============================================================

for hook_type in UserPromptSubmit PostCompact SubagentStop InstructionsLoaded; do
    if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
if '$hook_type' not in s.get('hooks', {}):
    sys.exit(1)
" 2>/dev/null; then
        pass "settings.json.tmpl has $hook_type hook"
    else
        fail "settings.json.tmpl has $hook_type hook"
    fi
done

# Total hook count should be 9
if python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
count = len(s.get('hooks', {}))
if count != 9:
    print(f'Expected 9 hooks, found {count}')
    sys.exit(1)
" 2>/dev/null; then
    pass "settings.json.tmpl has exactly 9 hook types"
else
    fail "settings.json.tmpl has exactly 9 hook types"
fi

# ============================================================
# v4.0 — UserPromptSubmit behavior tests
# ============================================================

run_ups_hook() {
    local dir="$1"
    (cd "$dir" && bash "$UPS_HOOK" 2>/dev/null)
}

# UserPromptSubmit: no keel config → silent
NOKEEL_UPS=$(mktemp -d)
OUTPUT=$(run_ups_hook "$NOKEEL_UPS")
if [ -z "$OUTPUT" ]; then
    pass "UserPromptSubmit: silent when no .keel/config.yaml"
else
    fail "UserPromptSubmit: silent when no .keel/config.yaml" "Got: $OUTPUT"
fi
rm -rf "$NOKEEL_UPS"

# UserPromptSubmit: keel config but no plan → silent
NOPLAN=$(mktemp -d)
mkdir -p "$NOPLAN/.keel"
echo "base: docs" > "$NOPLAN/.keel/config.yaml"
OUTPUT=$(run_ups_hook "$NOPLAN")
if [ -z "$OUTPUT" ]; then
    pass "UserPromptSubmit: silent when no plan files"
else
    fail "UserPromptSubmit: silent when no plan files" "Got: $OUTPUT"
fi
rm -rf "$NOPLAN"

# UserPromptSubmit: plan exists with in-progress phase → outputs systemMessage
WITHPLAN=$(mktemp -d)
mkdir -p "$WITHPLAN/.keel" "$WITHPLAN/docs/plans"
echo "base: docs" > "$WITHPLAN/.keel/config.yaml"
cat > "$WITHPLAN/docs/plans/PLAN-001-test.md" << 'PLAN'
# Plan: Test Plan

## Progress

| Phase | Theme | Status | Updated |
|-------|-------|--------|---------|
| 1 | Setup | done | 2026-03-20 |
| 2 | Build | in progress | 2026-03-20 |
| 3 | Ship | not started | — |
PLAN
OUTPUT=$(run_ups_hook "$WITHPLAN")
if echo "$OUTPUT" | grep -q 'systemMessage'; then
    pass "UserPromptSubmit: outputs systemMessage when plan has in-progress phase"
else
    fail "UserPromptSubmit: outputs systemMessage when plan has in-progress phase" "Got: $OUTPUT"
fi
rm -rf "$WITHPLAN"

# UserPromptSubmit: plan exists but all phases done → silent
ALLDONE=$(mktemp -d)
mkdir -p "$ALLDONE/.keel" "$ALLDONE/docs/plans"
echo "base: docs" > "$ALLDONE/.keel/config.yaml"
cat > "$ALLDONE/docs/plans/PLAN-001-test.md" << 'PLAN'
# Plan: Test Plan

## Progress

| Phase | Status | Updated |
|-------|--------|---------|
| 1 | done | 2026-03-20 |
| 2 | done | 2026-03-20 |
PLAN
OUTPUT=$(run_ups_hook "$ALLDONE")
if [ -z "$OUTPUT" ]; then
    pass "UserPromptSubmit: silent when all phases done"
else
    fail "UserPromptSubmit: silent when all phases done" "Got: $OUTPUT"
fi
rm -rf "$ALLDONE"

# ============================================================
# v4.0 — PostCompact behavior tests
# ============================================================

run_postcompact_hook() {
    local dir="$1"
    (cd "$dir" && bash "$POSTCOMPACT_HOOK" 2>/dev/null)
}

# PostCompact: no keel config → silent
NOKEEL_PC=$(mktemp -d)
OUTPUT=$(run_postcompact_hook "$NOKEEL_PC")
if [ -z "$OUTPUT" ]; then
    pass "PostCompact: silent when no .keel/config.yaml"
else
    fail "PostCompact: silent when no .keel/config.yaml" "Got: $OUTPUT"
fi
rm -rf "$NOKEEL_PC"

# PostCompact: plan + invariants → outputs systemMessage with both
WITHBOTH=$(mktemp -d)
mkdir -p "$WITHBOTH/.keel" "$WITHBOTH/docs/plans" "$WITHBOTH/docs/architecture/invariants"
echo "base: docs" > "$WITHBOTH/.keel/config.yaml"
cat > "$WITHBOTH/docs/plans/PLAN-001-test.md" << 'PLAN'
# Plan: Test Plan

## Progress

| Phase | Theme | Status | Updated |
|-------|-------|--------|---------|
| 1 | Build | in progress | 2026-03-20 |
PLAN
echo "# INV-001 — No compiled code" > "$WITHBOTH/docs/architecture/invariants/INV-001-test.md"
OUTPUT=$(run_postcompact_hook "$WITHBOTH")
if echo "$OUTPUT" | grep -q 'systemMessage' && echo "$OUTPUT" | grep -q 'compaction'; then
    pass "PostCompact: outputs systemMessage with plan + invariants after compaction"
else
    fail "PostCompact: outputs systemMessage with plan + invariants after compaction" "Got: $OUTPUT"
fi
rm -rf "$WITHBOTH"

# ============================================================
# v4.0 — SubagentStop behavior tests
# ============================================================

run_subagent_hook() {
    local dir="$1"
    local input="$2"
    (cd "$dir" && echo "$input" | bash "$SUBAGENT_HOOK" 2>/dev/null)
}

# SubagentStop: no keel config → silent with continue
NOKEEL_SA=$(mktemp -d)
OUTPUT=$(run_subagent_hook "$NOKEEL_SA" "test output")
if [ -z "$OUTPUT" ]; then
    pass "SubagentStop: silent when no .keel/config.yaml"
else
    fail "SubagentStop: silent when no .keel/config.yaml" "Got: $OUTPUT"
fi
rm -rf "$NOKEEL_SA"

# SubagentStop: known agent in output → logs to session-signals.log
WITHAGENT=$(mktemp -d)
mkdir -p "$WITHAGENT/.keel"
echo "base: docs" > "$WITHAGENT/.keel/config.yaml"
# Clean any existing log
rm -f "$HOME/.keel/session-signals.log" 2>/dev/null
OUTPUT=$(run_subagent_hook "$WITHAGENT" "As DBA specialist, I reviewed the migration and found no issues.")
if [ -f "$HOME/.keel/session-signals.log" ] && grep -q "dba" "$HOME/.keel/session-signals.log"; then
    pass "SubagentStop: logs agent name to session-signals.log"
else
    fail "SubagentStop: logs agent name to session-signals.log"
fi
rm -rf "$WITHAGENT"

# SubagentStop: always returns continue in v4.0
if echo "$OUTPUT" | grep -q 'continue'; then
    pass "SubagentStop: returns continue (no blocking in v4.0)"
else
    fail "SubagentStop: returns continue (no blocking in v4.0)" "Got: $OUTPUT"
fi

# ============================================================
# v4.0 — InstructionsLoaded content assertions
# ============================================================

assert_file_contains "$INSTRUCTIONS_HOOK" "session-signals.log" "InstructionsLoaded: writes to session-signals.log"
assert_file_contains "$INSTRUCTIONS_HOOK" "RULE_LOADED" "InstructionsLoaded: logs RULE_LOADED events"

# ============================================================
# v4.0 — UserPromptSubmit content assertions
# ============================================================

assert_file_contains "$UPS_HOOK" "systemMessage" "UserPromptSubmit: outputs systemMessage"
assert_file_contains "$UPS_HOOK" "in.progress\|in_progress\|in-progress" "UserPromptSubmit: detects in-progress phases"

# ============================================================
# v4.0 — PostCompact content assertions
# ============================================================

assert_file_contains "$POSTCOMPACT_HOOK" "systemMessage" "PostCompact: outputs systemMessage"
assert_file_contains "$POSTCOMPACT_HOOK" "invariant" "PostCompact: reads invariants"
assert_file_contains "$POSTCOMPACT_HOOK" "compaction" "PostCompact: mentions compaction recovery"

# ============================================================
# v4.0 — SubagentStop content assertions
# ============================================================

assert_file_contains "$SUBAGENT_HOOK" "session-signals.log" "SubagentStop: writes to session-signals.log"
assert_file_contains "$SUBAGENT_HOOK" "continue" "SubagentStop: returns continue"
assert_file_contains "$SUBAGENT_HOOK" "gate" "SubagentStop: has gate logic"

# ============================================================
# v4.0 — Skills frontmatter on read-only commands
# ============================================================

assert_file_contains "$PROJECT_ROOT/commands/doctor.md" "context: fork" "doctor.md has context: fork"
assert_file_contains "$PROJECT_ROOT/commands/status.md" "context: fork" "status.md has context: fork"
assert_file_contains "$PROJECT_ROOT/commands/docs.md" "context: fork" "docs.md has context: fork"

# ============================================================
# v4.0 — Agent memory: project
# ============================================================

assert_file_contains "$PROJECT_ROOT/templates/agents/dba.md" "memory: project" "dba.md has memory: project"
assert_file_contains "$PROJECT_ROOT/templates/agents/security.md" "memory: project" "security.md has memory: project"

# ============================================================
# v4.1 — Event logging utility
# ============================================================

EVENT_LOG="$HOOKS_DIR/event-log.sh"
assert_file_exists "$EVENT_LOG" "Event logging utility exists: templates/hooks/event-log.sh"
assert_file_contains "$EVENT_LOG" "keel_log_event" "event-log.sh defines keel_log_event function"
assert_file_contains "$EVENT_LOG" "events.jsonl" "event-log.sh writes to events.jsonl"
assert_file_contains "$EVENT_LOG" "git config user.email" "event-log.sh captures git identity"

# ============================================================
# v4.1 — SubagentStop gate logic
# ============================================================

assert_file_contains "$SUBAGENT_HOOK" "gates:" "SubagentStop: reads gates from config"
assert_file_contains "$SUBAGENT_HOOK" "IS_GATE" "SubagentStop: has gate detection logic"
assert_file_contains "$SUBAGENT_HOOK" "block" "SubagentStop: can block on critical gate finding"
assert_file_contains "$SUBAGENT_HOOK" "event-log.sh" "SubagentStop: sources event logging"

# SubagentStop: no gate configured → continues even on critical
NOGATE=$(mktemp -d)
mkdir -p "$NOGATE/.keel"
echo "base: docs" > "$NOGATE/.keel/config.yaml"
OUTPUT=$(cd "$NOGATE" && echo "As Staff Security Engineer, 🔴 critical: hardcoded JWT secret" | bash "$SUBAGENT_HOOK" 2>/dev/null)
if echo "$OUTPUT" | grep -q 'continue'; then
    pass "SubagentStop: no gate configured → continues on critical"
else
    fail "SubagentStop: no gate configured → continues on critical" "Got: $OUTPUT"
fi
rm -rf "$NOGATE"

# SubagentStop: gate configured + critical → blocks
WITHGATE=$(mktemp -d)
mkdir -p "$WITHGATE/.keel"
cat > "$WITHGATE/.keel/config.yaml" << 'YAML'
base: docs
gates:
  - security
YAML
OUTPUT=$(cd "$WITHGATE" && echo "As Staff Security Engineer, 🔴 critical: hardcoded JWT secret" | bash "$SUBAGENT_HOOK" 2>/dev/null)
if echo "$OUTPUT" | grep -q 'block'; then
    pass "SubagentStop: gate configured + critical → blocks"
else
    fail "SubagentStop: gate configured + critical → blocks" "Got: $OUTPUT"
fi
rm -rf "$WITHGATE"

# SubagentStop: gate configured + warning → continues
WARNGATE=$(mktemp -d)
mkdir -p "$WARNGATE/.keel"
cat > "$WARNGATE/.keel/config.yaml" << 'YAML'
base: docs
gates:
  - security
YAML
OUTPUT=$(cd "$WARNGATE" && echo "As Staff Security Engineer, 🟡 warning: consider rate limiting" | bash "$SUBAGENT_HOOK" 2>/dev/null)
if echo "$OUTPUT" | grep -q 'continue'; then
    pass "SubagentStop: gate configured + warning → continues (only critical blocks)"
else
    fail "SubagentStop: gate configured + warning → continues (only critical blocks)" "Got: $OUTPUT"
fi
rm -rf "$WARNGATE"

# ============================================================
# v4.1 — Pre-push invariant check
# ============================================================

PREPUSH="$PROJECT_ROOT/templates/hooks/pre-push"

assert_file_contains "$PREPUSH" "KEEL_INVARIANT_SKIP" "pre-push has invariant skip flag"
assert_file_contains "$PREPUSH" "invariant" "pre-push checks invariants"
assert_file_contains "$PREPUSH" "exit 1" "pre-push can block on invariant violation"
assert_file_contains "$PREPUSH" "event-log.sh" "pre-push sources event logging"

# ============================================================
# v4.1 — Doctor decision graph validation
# ============================================================

DOCTOR="$PROJECT_ROOT/commands/doctor.md"

assert_file_contains "$DOCTOR" "ADR contradiction" "doctor checks for ADR contradictions"
assert_file_contains "$DOCTOR" "Rule-invariant consistency" "doctor checks rule-invariant consistency"
assert_file_contains "$DOCTOR" "Plan-ADR dependencies" "doctor checks plan-ADR dependencies"
assert_file_contains "$DOCTOR" "Invariant enforcement" "doctor checks invariant enforcement"
assert_file_contains "$DOCTOR" "Orphan artifacts" "doctor checks for orphan artifacts"
assert_file_contains "$DOCTOR" "State machine" "doctor checks state machine violations"

# ============================================================
# v4.2 — Spec Layer
# ============================================================

# Spec command exists with correct structure
SPEC_CMD="$PROJECT_ROOT/commands/spec.md"
assert_file_exists "$SPEC_CMD" "commands/spec.md exists"
assert_file_contains "$SPEC_CMD" "name: keel:spec" "spec.md has correct name"
assert_file_contains "$SPEC_CMD" "implements:" "spec.md references source PRD in template"
assert_file_contains "$SPEC_CMD" "architecture_source" "spec.md has archway integration field"
assert_file_contains "$SPEC_CMD" "references:" "spec.md has references field in template"
assert_file_contains "$SPEC_CMD" "created_at:" "spec.md has created_at in template"
assert_file_contains "$SPEC_CMD" "status: draft" "spec.md outputs draft status"
assert_file_contains "$SPEC_CMD" "architect" "spec.md routes to architect"
assert_file_contains "$SPEC_CMD" "accepted" "spec.md checks PRD acceptance status"
assert_file_contains "$SPEC_CMD" "Existing Architecture" "spec.md includes Existing Architecture section"
assert_file_contains "$SPEC_CMD" "Conflict Detection" "spec.md has ADR conflict detection"
assert_file_contains "$SPEC_CMD" "artifacts" "spec.md suggests spec-artifacts as next step"

# Spec-artifacts command exists with correct structure
SPECART_CMD="$PROJECT_ROOT/commands/spec-artifacts.md"
assert_file_exists "$SPECART_CMD" "commands/spec-artifacts.md exists"
assert_file_contains "$SPECART_CMD" "name: keel:spec-artifacts" "spec-artifacts.md has correct name"
assert_file_contains "$SPECART_CMD" "data-model" "spec-artifacts.md generates data model"
assert_file_contains "$SPECART_CMD" "api-contract\|contracts/api" "spec-artifacts.md generates API contracts"
assert_file_contains "$SPECART_CMD" "test-strategy" "spec-artifacts.md generates test strategy"
assert_file_contains "$SPECART_CMD" "migrations" "spec-artifacts.md generates migrations"
assert_file_contains "$SPECART_CMD" "dba" "spec-artifacts.md routes to dba"
assert_file_contains "$SPECART_CMD" "api" "spec-artifacts.md routes to api"
assert_file_contains "$SPECART_CMD" "qa" "spec-artifacts.md routes to qa"
assert_file_contains "$SPECART_CMD" "accepted" "spec-artifacts.md checks spec acceptance status"
assert_file_contains "$SPECART_CMD" "reviewed_by" "spec-artifacts.md tracks reviewer in frontmatter"

# Artifact status workflow — existing commands updated
assert_file_contains "$PROJECT_ROOT/commands/prd.md" "type: prd" "prd.md has type field in frontmatter template"
assert_file_contains "$PROJECT_ROOT/commands/prd.md" "created_at:" "prd.md has created_at in frontmatter template"
assert_file_contains "$PROJECT_ROOT/commands/adr.md" "type: adr" "adr.md has type field in frontmatter template"
assert_file_contains "$PROJECT_ROOT/commands/adr.md" "created_at:" "adr.md has created_at in frontmatter template"
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" "type: invariant" "invariant.md has type field in frontmatter template"
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" "created_at:" "invariant.md has created_at in frontmatter template"

# Plan command has governance chain check
assert_file_contains "$PROJECT_ROOT/commands/plan.md" "governance chain" "plan.md checks governance chain"
assert_file_contains "$PROJECT_ROOT/commands/plan.md" "spec-artifacts" "plan.md reads spec-artifacts as context"

# Init creates specs directory
assert_file_contains "$PROJECT_ROOT/commands/init.md" "product/specs" "init.md creates specs directory"
assert_file_contains "$PROJECT_ROOT/commands/init.md" "specs:" "init.md adds specs config"

# Install includes new commands
assert_file_contains "$PROJECT_ROOT/install.sh" "spec-artifacts" "install.sh includes spec-artifacts command"

# ============================================================
# v4.3 — Drift Detection
# ============================================================

DRIFT_CMD="$PROJECT_ROOT/commands/drift.md"
assert_file_exists "$DRIFT_CMD" "commands/drift.md exists"
assert_file_contains "$DRIFT_CMD" "name: keel:drift" "drift.md has correct name"
assert_file_contains "$DRIFT_CMD" "scope" "drift.md supports scoping"
assert_file_contains "$DRIFT_CMD" "prd" "drift.md checks PRD acceptance criteria"
assert_file_contains "$DRIFT_CMD" "spec" "drift.md checks spec requirements"
assert_file_contains "$DRIFT_CMD" "artifact" "drift.md checks artifact contracts"
assert_file_contains "$DRIFT_CMD" "ADR" "drift.md checks ADR compliance"
assert_file_contains "$DRIFT_CMD" "invariant" "drift.md checks invariant compliance"
assert_file_contains "$DRIFT_CMD" "Compliant" "drift.md has compliant severity"
assert_file_contains "$DRIFT_CMD" "Diverged" "drift.md has diverged severity"
assert_file_contains "$DRIFT_CMD" "Unknown" "drift.md has unknown severity"
assert_file_contains "$DRIFT_CMD" "output=json" "drift.md supports JSON output for CI"
assert_file_contains "$DRIFT_CMD" "Exit code" "drift.md has exit codes for CI"
assert_file_contains "$DRIFT_CMD" "drift-report" "drift.md persists reports as files"
assert_file_contains "$DRIFT_CMD" "events.jsonl\|event-log" "drift.md logs drift events"
assert_file_contains "$DRIFT_CMD" "architect" "drift.md routes to architect"

# Review integration
assert_file_contains "$PROJECT_ROOT/commands/review.md" "DRIFT CHECK" "review.md integrates drift detection"
assert_file_contains "$PROJECT_ROOT/commands/review.md" "keel:drift" "review.md references drift command"

# Install includes drift
assert_file_contains "$PROJECT_ROOT/install.sh" "drift" "install.sh includes drift command"

# ============================================================
# v4.0 — Compile command
# ============================================================

COMPILE_CMD="$PROJECT_ROOT/commands/compile.md"
assert_file_exists "$COMPILE_CMD" "commands/compile.md exists"
assert_file_contains "$COMPILE_CMD" "name: keel:compile" "compile.md has correct name"
assert_file_contains "$COMPILE_CMD" "governance.md" "compile.md outputs to governance.md"
assert_file_contains "$COMPILE_CMD" "accepted" "compile.md filters by accepted status"
assert_file_contains "$COMPILE_CMD" "superseded" "compile.md handles superseded ADRs"
assert_file_contains "$COMPILE_CMD" "active" "compile.md filters invariants by active status"
assert_file_contains "$COMPILE_CMD" "Contradiction" "compile.md detects contradictions"
assert_file_contains "$COMPILE_CMD" "ref:" "compile.md includes source references"
assert_file_contains "$COMPILE_CMD" "check" "compile.md supports --check for CI"
assert_file_contains "$COMPILE_CMD" "keel:compiled" "compile.md uses sentinel comments"
assert_file_contains "$COMPILE_CMD" "event_log\|keel_log_event" "compile.md logs compilation events"

# ADR and invariant suggest compile
assert_file_contains "$PROJECT_ROOT/commands/adr.md" "keel:compile" "adr.md suggests /keel:compile after creation"
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" "keel:compile" "invariant.md suggests /keel:compile after creation"

# Install includes compile
assert_file_contains "$PROJECT_ROOT/install.sh" "compile" "install.sh includes compile command"

test_summary
