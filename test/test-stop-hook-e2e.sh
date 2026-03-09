#!/bin/bash
# E2E Test: Stop hook signal detection
#
# Invokes stop-hook.sh directly with simulated last_assistant_message payloads
# to verify signal detection and systemMessage output. No API key required.
#
# Verifies:
#   1. Neutral responses produce {"continue": true} — no false positives
#   2. Architecture signals produce systemMessage with ADR suggestion
#   3. Security signals produce systemMessage with audit suggestion
#   4. Doc gap signals produce systemMessage with docs suggestion
#   5. Bug fix / refactor responses produce {"continue": true}
#   6. Output is always valid JSON

set -uo pipefail

PROJECT_ROOT="$(cd "${1:-.}" && pwd)"
source "$(dirname "$0")/helpers.sh"

echo ""

STOP_HOOK_SCRIPT="$PROJECT_ROOT/templates/hooks/stop-hook.sh"
if [ ! -f "$STOP_HOOK_SCRIPT" ]; then
    fail "stop-hook.sh not found at templates/hooks/stop-hook.sh"
    test_summary; exit 1
fi
pass "stop-hook.sh found"

# ─── Helper: invoke stop-hook.sh with a simulated last_assistant_message ──────

run_stop_hook() {
    local message="$1"

    local tmpdir
    tmpdir=$(mktemp -d)
    mkdir -p "$tmpdir/.keel"
    echo "base: docs" > "$tmpdir/.keel/config.yaml"

    local stdin_payload
    stdin_payload=$(python3 -c "
import json, sys
print(json.dumps({
    'session_id': 'test',
    'cwd': '$tmpdir',
    'hook_event_name': 'Stop',
    'transcript_path': '/dev/null',
    'stop_hook_active': False,
    'last_assistant_message': sys.argv[1]
}))" "$message" 2>/dev/null)

    local output
    output=$(cd "$tmpdir" && echo "$stdin_payload" | bash "$STOP_HOOK_SCRIPT" 2>/dev/null)
    rm -rf "$tmpdir"
    echo "$output"
}

is_valid_json() {
    python3 -c "import json,sys; json.loads(sys.argv[1])" "$1" 2>/dev/null
}

has_system_message() {
    python3 -c "
import json,sys
obj = json.loads(sys.argv[1])
sys.exit(0 if obj.get('systemMessage') else 1)
" "$1" 2>/dev/null
}

is_continue_true() {
    python3 -c "
import json,sys
obj = json.loads(sys.argv[1])
# continue:true or absent (absent = allowed to stop)
sys.exit(0 if obj.get('continue', True) is True and 'systemMessage' not in obj else 1)
" "$1" 2>/dev/null
}

get_message() {
    python3 -c "import json,sys; print(json.loads(sys.argv[1]).get('systemMessage',''))" "$1" 2>/dev/null
}

# ─── TEST 1: Neutral response — no signals ────────────────────────────────────

OUT=$(run_stop_hook "I refactored the formatDate helper to remove a duplicate null check. The function now reads more clearly and has better variable names.")

if is_valid_json "$OUT"; then
    pass "Neutral: output is valid JSON"
else
    fail "Neutral: output is valid JSON" "Got: $OUT"
fi

if is_continue_true "$OUT"; then
    pass "Neutral: no false signals — {\"continue\": true}"
else
    fail "Neutral: no false signals — {\"continue\": true}" "Got: $OUT"
fi

# ─── TEST 2: Architecture signal — "chose X over Y" with trade-offs ───────────

OUT=$(run_stop_hook "I implemented the new caching layer using Redis as the primary cache. This is a significant trade-off: I chose Redis over Memcached because we need key expiry and pub/sub. This decision affects every service that reads sessions.")

if is_valid_json "$OUT"; then
    pass "Architecture: output is valid JSON"
else
    fail "Architecture: output is valid JSON" "Got: $OUT"
fi

if has_system_message "$OUT"; then
    pass "Architecture: systemMessage present (signal detected)"
else
    fail "Architecture: systemMessage present (signal detected)" "Got: $OUT"
fi

MSG=$(get_message "$OUT")
if echo "$MSG" | grep -qi "ADR\|keel:adr"; then
    pass "Architecture: message references ADR/keel:adr"
else
    fail "Architecture: message references ADR/keel:adr" "Message: $MSG"
fi

# ─── TEST 3: Security signal — JWT + auth central focus ───────────────────────

OUT=$(run_stop_hook "I added JWT token validation to the payments endpoint. The middleware now checks the Authorization header, validates the JWT signature using RS256, and rejects expired bearer tokens with a 401. PII like email addresses are now masked.")

if is_valid_json "$OUT"; then
    pass "Security: output is valid JSON"
else
    fail "Security: output is valid JSON" "Got: $OUT"
fi

if has_system_message "$OUT"; then
    pass "Security: systemMessage present (signal detected)"
else
    fail "Security: systemMessage present (signal detected)" "Got: $OUT"
fi

MSG=$(get_message "$OUT")
if echo "$MSG" | grep -qi "security\|audit\|keel:audit"; then
    pass "Security: message references security audit"
else
    fail "Security: message references security audit" "Message: $MSG"
fi

# ─── TEST 4: Doc gap signal — new HTTP routes ─────────────────────────────────

OUT=$(run_stop_hook "I added three new API endpoints: POST /api/v2/webhooks to register, DELETE /api/v2/webhooks/:id to remove, and GET /api/v2/webhooks to list all registered webhooks.")

if is_valid_json "$OUT"; then
    pass "Doc gap (routes): output is valid JSON"
else
    fail "Doc gap (routes): output is valid JSON" "Got: $OUT"
fi

if has_system_message "$OUT"; then
    pass "Doc gap (routes): systemMessage present (signal detected)"
else
    fail "Doc gap (routes): systemMessage present (signal detected)" "Got: $OUT"
fi

MSG=$(get_message "$OUT")
if echo "$MSG" | grep -qi "doc gap\|keel:docs"; then
    pass "Doc gap (routes): message references keel:docs"
else
    fail "Doc gap (routes): message references keel:docs" "Message: $MSG"
fi

# ─── TEST 5: Bug fix — no false signals ───────────────────────────────────────

OUT=$(run_stop_hook "Fixed the off-by-one error in the pagination helper. The calculateOffset function was returning page * size instead of (page - 1) * size, causing the first page to be skipped.")

if is_valid_json "$OUT"; then
    pass "Bug fix: output is valid JSON"
else
    fail "Bug fix: output is valid JSON" "Got: $OUT"
fi

if is_continue_true "$OUT"; then
    pass "Bug fix: no false signals — {\"continue\": true}"
else
    echo "  WARN  Bug fix: expected no signals, got: $OUT"
fi

# ─── TEST 6: stop_hook_active guard — exits silently ──────────────────────────

TMPDIR2=$(mktemp -d)
mkdir -p "$TMPDIR2/.keel"
echo "base: docs" > "$TMPDIR2/.keel/config.yaml"

LOOP_PAYLOAD=$(python3 -c "
import json
print(json.dumps({
    'session_id': 'test',
    'cwd': '$TMPDIR2',
    'hook_event_name': 'Stop',
    'transcript_path': '/dev/null',
    'stop_hook_active': True,
    'last_assistant_message': 'I chose Redis over Memcached — significant trade-off decision.'
}))")

OUT=$(cd "$TMPDIR2" && echo "$LOOP_PAYLOAD" | bash "$STOP_HOOK_SCRIPT" 2>/dev/null)
rm -rf "$TMPDIR2"

if [ -z "$OUT" ]; then
    pass "Loop guard: exits silently when stop_hook_active=true"
else
    fail "Loop guard: exits silently when stop_hook_active=true" "Got: $OUT"
fi

# ─── TEST 7: Signal logging — signals written to session log ──────────────────

LOG_TMPDIR=$(mktemp -d)
mkdir -p "$LOG_TMPDIR/.keel"
echo "base: docs" > "$LOG_TMPDIR/.keel/config.yaml"

# Override HOME so the log goes to our temp dir
LOG_PAYLOAD=$(python3 -c "
import json
print(json.dumps({
    'session_id': 'test',
    'cwd': '$LOG_TMPDIR',
    'hook_event_name': 'Stop',
    'transcript_path': '/dev/null',
    'stop_hook_active': False,
    'last_assistant_message': 'I added JWT token validation to the payments endpoint. The middleware validates the JWT signature and rejects expired bearer tokens.'
}))")

HOME="$LOG_TMPDIR" cd "$LOG_TMPDIR" && echo "$LOG_PAYLOAD" | HOME="$LOG_TMPDIR" bash "$STOP_HOOK_SCRIPT" > /dev/null 2>/dev/null
LOG_FILE="$LOG_TMPDIR/.keel/session-signals.log"

if [ -f "$LOG_FILE" ]; then
    pass "Signal logging: session-signals.log created after signal fires"
else
    fail "Signal logging: session-signals.log created after signal fires" "File not found: $LOG_FILE"
fi

if [ -f "$LOG_FILE" ] && grep -q "keel:audit\|Security\|security" "$LOG_FILE" 2>/dev/null; then
    pass "Signal logging: log contains the security signal"
else
    fail "Signal logging: log contains the security signal" "Log contents: $(cat "$LOG_FILE" 2>/dev/null || echo 'empty')"
fi

if [ -f "$LOG_FILE" ] && grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T' "$LOG_FILE" 2>/dev/null; then
    pass "Signal logging: log entries have ISO8601 timestamp"
else
    fail "Signal logging: log entries have ISO8601 timestamp" "Log: $(cat "$LOG_FILE" 2>/dev/null || echo 'empty')"
fi

rm -rf "$LOG_TMPDIR"

# ─── TEST 8: Session rotation — log rotated to .prev on session start ──────────

SESSION_TMPDIR=$(mktemp -d)
mkdir -p "$SESSION_TMPDIR/.keel"
echo "base: docs" > "$SESSION_TMPDIR/.keel/config.yaml"
SESSION_LOG="$SESSION_TMPDIR/.keel/session-signals.log"
echo "2026-03-09T10:00:00Z 💡 previous session signal" > "$SESSION_LOG"

SESSION_HOOK_SCRIPT="$PROJECT_ROOT/templates/hooks/session-start.sh"

# Run session-start hook — it should rotate the log
(cd "$SESSION_TMPDIR" && HOME="$SESSION_TMPDIR" bash "$SESSION_HOOK_SCRIPT" 2>/dev/null || true)

if [ ! -f "$SESSION_LOG" ]; then
    pass "Session rotation: current log cleared on new session"
else
    fail "Session rotation: current log cleared on new session" "Log still exists with: $(cat "$SESSION_LOG")"
fi

if [ -f "${SESSION_LOG}.prev" ]; then
    pass "Session rotation: previous log archived to .prev"
else
    fail "Session rotation: previous log archived to .prev" "File not found: ${SESSION_LOG}.prev"
fi

if grep -q "previous session signal" "${SESSION_LOG}.prev" 2>/dev/null; then
    pass "Session rotation: .prev contains previous session's signals"
else
    fail "Session rotation: .prev contains previous session's signals"
fi

rm -rf "$SESSION_TMPDIR"

test_summary
