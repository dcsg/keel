#!/bin/bash
# Test: PreToolUse hook produces correct output across project configurations
set -uo pipefail

PROJECT_ROOT="${1:-.}"
source "$(dirname "$0")/helpers.sh"

echo ""

SETTINGS="$PROJECT_ROOT/templates/settings.json.tmpl"

# Extract the hook command from the template
HOOK_CMD=$(python3 -c "
import json
with open('$SETTINGS') as f:
    s = json.load(f)
print(s['hooks']['PreToolUse'][0]['command'])
")

if [ -z "$HOOK_CMD" ]; then
    fail "Could not extract PreToolUse hook command"
    test_summary
    exit $?
fi

pass "Extracted PreToolUse hook command from template"

# --- Helper: run hook in a temp project ---
run_hook_in() {
    local dir="$1"
    # Clear any sentinel for this dir
    local sentinel="/tmp/keel-$(echo "$dir" | md5sum 2>/dev/null | cut -c1-8 || echo "$dir" | md5 2>/dev/null | cut -c1-8)"
    rm -f "$sentinel"
    # Run hook from that directory
    (cd "$dir" && bash -c "$HOOK_CMD" 2>/dev/null)
}

# ============================================================
# Test 1: Full project — all counts correct
# ============================================================
FULL=$(mktemp -d)
mkdir -p "$FULL/.keel" "$FULL/docs/decisions" "$FULL/docs/invariants" "$FULL/docs/plans" "$FULL/docs/product/prds" "$FULL/.claude/rules"
echo "base: docs" > "$FULL/.keel/config.yaml"
echo "# My App" > "$FULL/docs/soul.md"
echo "adr1" > "$FULL/docs/decisions/001.md"
echo "adr2" > "$FULL/docs/decisions/002.md"
echo "adr3" > "$FULL/docs/decisions/003.md"
echo "inv1" > "$FULL/docs/invariants/INV-001.md"
echo "inv2" > "$FULL/docs/invariants/INV-002.md"
echo "plan" > "$FULL/docs/plans/PLAN-001-mvp.md"
echo "prd1" > "$FULL/docs/product/prds/PRD-001.md"
echo "prd2" > "$FULL/docs/product/prds/PRD-002.md"
echo "rule" > "$FULL/.claude/rules/code-quality.md"
echo "rule" > "$FULL/.claude/rules/go.md"

OUTPUT=$(run_hook_in "$FULL")

echo "$OUTPUT" | grep -q "Project: My App" && pass "Full project: shows project name" || fail "Full project: shows project name" "Got: $OUTPUT"
echo "$OUTPUT" | grep -q "Decisions: 3" && pass "Full project: decisions count = 3" || fail "Full project: decisions count = 3"
echo "$OUTPUT" | grep -q "Invariants: 2" && pass "Full project: invariants count = 2" || fail "Full project: invariants count = 2"
echo "$OUTPUT" | grep -q "Rules: 2 packs" && pass "Full project: rules count = 2" || fail "Full project: rules count = 2"
echo "$OUTPUT" | grep -q "Plans: 1" && pass "Full project: plans count = 1" || fail "Full project: plans count = 1"
echo "$OUTPUT" | grep -q "PRDs: 2" && pass "Full project: PRDs count = 2" || fail "Full project: PRDs count = 2"

rm -rf "$FULL"

# ============================================================
# Test 2: Empty project — zeroes, no errors
# ============================================================
EMPTY=$(mktemp -d)
mkdir -p "$EMPTY/.keel"
echo "base: docs" > "$EMPTY/.keel/config.yaml"

OUTPUT=$(run_hook_in "$EMPTY")

echo "$OUTPUT" | grep -q "Keel context available" && pass "Empty project: shows banner" || fail "Empty project: shows banner" "Got: $OUTPUT"
echo "$OUTPUT" | grep -q "Decisions: 0" && pass "Empty project: decisions = 0" || fail "Empty project: decisions = 0"
echo "$OUTPUT" | grep -q "Invariants: 0" && pass "Empty project: invariants = 0" || fail "Empty project: invariants = 0"
echo "$OUTPUT" | grep -q "Rules: 0 packs" && pass "Empty project: rules = 0" || fail "Empty project: rules = 0"
echo "$OUTPUT" | grep -q "Plans: 0" && pass "Empty project: plans = 0" || fail "Empty project: plans = 0"
echo "$OUTPUT" | grep -q "PRDs: 0" && pass "Empty project: PRDs = 0" || fail "Empty project: PRDs = 0"

rm -rf "$EMPTY"

# ============================================================
# Test 3: No keel config — silent (no output)
# ============================================================
NOKEEL=$(mktemp -d)

OUTPUT=$(run_hook_in "$NOKEEL")

[ -z "$OUTPUT" ] && pass "No config: hook is silent" || fail "No config: hook is silent" "Got unexpected output: $OUTPUT"

rm -rf "$NOKEEL"

# ============================================================
# Test 4: Sentinel — fires once, silent on second call
# ============================================================
SENTINEL_TEST=$(mktemp -d)
mkdir -p "$SENTINEL_TEST/.keel"
echo "base: docs" > "$SENTINEL_TEST/.keel/config.yaml"

OUTPUT1=$(run_hook_in "$SENTINEL_TEST")
# Don't clear sentinel — run again
OUTPUT2=$( (cd "$SENTINEL_TEST" && bash -c "$HOOK_CMD" 2>/dev/null) )

[ -n "$OUTPUT1" ] && pass "Sentinel: first call produces output" || fail "Sentinel: first call produces output"
[ -z "$OUTPUT2" ] && pass "Sentinel: second call is silent" || fail "Sentinel: second call is silent" "Got: $OUTPUT2"

rm -rf "$SENTINEL_TEST"

# ============================================================
# Test 5: Plans in docs/product/plans/ (alternate location)
# ============================================================
ALT=$(mktemp -d)
mkdir -p "$ALT/.keel" "$ALT/docs/product/plans"
echo "base: docs" > "$ALT/.keel/config.yaml"
echo "plan" > "$ALT/docs/product/plans/PLAN-001-alt.md"
echo "plan" > "$ALT/docs/product/plans/PLAN-002-alt.md"

OUTPUT=$(run_hook_in "$ALT")

echo "$OUTPUT" | grep -q "Plans: 2" && pass "Alt plans dir: plans count = 2" || fail "Alt plans dir: plans count = 2" "Got: $OUTPUT"

rm -rf "$ALT"

# ============================================================
# Test 6: Plans in both locations — no double-count
# ============================================================
BOTH=$(mktemp -d)
mkdir -p "$BOTH/.keel" "$BOTH/docs/plans" "$BOTH/docs/product/plans"
echo "base: docs" > "$BOTH/.keel/config.yaml"
echo "plan" > "$BOTH/docs/plans/PLAN-001.md"
echo "plan" > "$BOTH/docs/product/plans/PLAN-002.md"

OUTPUT=$(run_hook_in "$BOTH")

echo "$OUTPUT" | grep -q "Plans: 2" && pass "Both plan dirs: plans count = 2" || fail "Both plan dirs: plans count = 2" "Got: $OUTPUT"

rm -rf "$BOTH"

test_summary
