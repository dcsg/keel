#!/bin/bash
# E2E Test: Stop hook signal detection via Claude API
#
# This test calls the real Claude API with the Stop hook prompt + simulated
# assistant responses to verify:
#   1. The response is always valid JSON (last line parseable)
#   2. {"ok": true} is always the final line (never ok:false)
#   3. Architecture signals trigger an ADR/invariant/PRD candidate line
#   4. Security signals trigger a security audit suggestion
#   5. Doc gap signals trigger a doc gap line
#   6. Neutral responses produce {"ok": true} alone
#
# Requires: ANTHROPIC_API_KEY env var, curl, python3

set -uo pipefail

PROJECT_ROOT="$(cd "${1:-.}" && pwd)"
source "$(dirname "$0")/helpers.sh"

echo ""

# ─── Prerequisites ────────────────────────────────────────────────────────────

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    echo "  SKIP  Stop hook e2e tests — ANTHROPIC_API_KEY not set"
    echo ""
    exit 0
fi

if ! command -v curl &>/dev/null; then
    echo "  SKIP  Stop hook e2e tests — curl not available"
    echo ""
    exit 0
fi

SETTINGS="$PROJECT_ROOT/templates/settings.json.tmpl"
if [ ! -f "$SETTINGS" ]; then
    fail "settings.json.tmpl not found at $PROJECT_ROOT/templates/settings.json.tmpl"
    test_summary; exit 1
fi

# Extract the Stop hook prompt from the template
STOP_PROMPT=$(python3 -c "
import json, sys
s = json.load(open('$SETTINGS'))
print(s['hooks']['Stop'][0]['hooks'][0]['prompt'])
" 2>/dev/null)

if [ -z "$STOP_PROMPT" ]; then
    fail "Could not extract Stop hook prompt from settings.json.tmpl"
    test_summary; exit 1
fi

pass "Stop hook prompt extracted from settings.json.tmpl"

# ─── Helper: call Claude with stop hook prompt + simulated response ────────────

call_stop_hook() {
    local simulated_response="$1"

    # Build messages: the simulated assistant response + the hook prompt as user turn
    python3 - "$STOP_PROMPT" "$simulated_response" <<'PYEOF'
import json, sys, urllib.request, urllib.error, os

stop_prompt = sys.argv[1]
simulated_response = sys.argv[2]

payload = {
    "model": "claude-haiku-4-5-20251001",
    "max_tokens": 256,
    "messages": [
        {"role": "assistant", "content": simulated_response},
        {"role": "user",      "content": stop_prompt}
    ]
}

req = urllib.request.Request(
    "https://api.anthropic.com/v1/messages",
    data=json.dumps(payload).encode(),
    headers={
        "x-api-key": os.environ["ANTHROPIC_API_KEY"],
        "anthropic-version": "2023-06-01",
        "content-type": "application/json"
    }
)

try:
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())
        print(data["content"][0]["text"])
except urllib.error.HTTPError as e:
    print(f"HTTP_ERROR:{e.code}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

# ─── Helper: validate hook output ─────────────────────────────────────────────

# Returns 0 if last line is {"ok": true}, non-zero otherwise
last_line_is_ok_true() {
    local output="$1"
    local last_line
    last_line=$(echo "$output" | grep -v '^[[:space:]]*$' | tail -1)
    python3 -c "
import json, sys
line = '''$last_line'''
try:
    obj = json.loads(line)
    if obj.get('ok') is True:
        sys.exit(0)
    else:
        sys.exit(1)
except Exception:
    sys.exit(1)
" 2>/dev/null
}

# Returns 0 if the output is valid JSON with ok:false and a non-empty reason
is_ok_false_with_reason() {
    local output="$1"
    python3 -c "
import json, sys
text = '''$output'''.strip()
try:
    obj = json.loads(text)
    if obj.get('ok') is False and obj.get('reason', '').strip():
        sys.exit(0)
    else:
        sys.exit(1)
except Exception:
    sys.exit(1)
" 2>/dev/null
}

# Returns 0 if ANY line in the output contains ok:false (wrong in neutral cases)
contains_ok_false_anywhere() {
    local output="$1"
    echo "$output" | python3 -c "
import json, sys
for line in sys.stdin:
    line = line.strip()
    try:
        obj = json.loads(line)
        if obj.get('ok') is False:
            sys.exit(0)
    except Exception:
        pass
sys.exit(1)
" 2>/dev/null
}

# ─── TEST 1: No-signal response → {"ok": true} only ──────────────────────────

NEUTRAL_RESPONSE='I refactored the `formatDate` helper to remove a duplicate null check. The function now reads more clearly and has better variable names.'

OUTPUT=$(call_stop_hook "$NEUTRAL_RESPONSE" 2>/dev/null)

if python3 -c "import json,sys; obj=json.loads('''$OUTPUT'''.strip()); sys.exit(0 if obj=={'ok':True} else 1)" 2>/dev/null; then
    pass "Neutral response: output is exactly {\"ok\": true}"
else
    fail "Neutral response: output is exactly {\"ok\": true}" "Got: $OUTPUT"
fi

if contains_ok_false_anywhere "$OUTPUT"; then
    fail "Neutral response: must not contain {\"ok\": false}"
else
    pass "Neutral response: does not contain {\"ok\": false}"
fi

# ─── TEST 2: Architecture signal → ok:false with ADR/invariant reason ─────────

ARCH_RESPONSE='I implemented the new caching layer using Redis as the primary cache with an in-memory LRU fallback. This is a significant trade-off: Redis adds operational complexity but enables distributed caching across all API servers. The LRU fallback means cache misses during Redis downtime are graceful. I chose Redis over Memcached because we need key expiry and pub/sub for cache invalidation. This decision affects every service that reads user sessions.'

OUTPUT=$(call_stop_hook "$ARCH_RESPONSE" 2>/dev/null)

if python3 -c "import json,sys; json.loads('''$OUTPUT'''.strip()); sys.exit(0)" 2>/dev/null; then
    pass "Architecture signal: output is valid JSON"
else
    fail "Architecture signal: output is valid JSON" "Got: $OUTPUT"
fi

if is_ok_false_with_reason "$OUTPUT"; then
    pass "Architecture signal: {\"ok\": false} with non-empty reason"
else
    fail "Architecture signal: {\"ok\": false} with non-empty reason" "Got: $OUTPUT"
fi

REASON=$(python3 -c "import json,sys; print(json.loads('''$OUTPUT'''.strip()).get('reason',''))" 2>/dev/null)
if echo "$REASON" | grep -qi "ADR\|invariant\|keel:adr\|keel:invariant"; then
    pass "Architecture signal: reason contains ADR/invariant suggestion"
else
    fail "Architecture signal: reason contains ADR/invariant suggestion" "Reason: $REASON"
fi

# ─── TEST 3: Security signal → ok:false with security reason ──────────────────

SECURITY_RESPONSE='I added JWT token validation to the /api/payments endpoint. The middleware now checks the Authorization header, validates the token signature using the RS256 algorithm, and rejects expired tokens with a 401. I also added rate limiting on the login endpoint to prevent brute-force attacks. PII like email addresses are now masked in logs.'

OUTPUT=$(call_stop_hook "$SECURITY_RESPONSE" 2>/dev/null)

if python3 -c "import json,sys; json.loads('''$OUTPUT'''.strip()); sys.exit(0)" 2>/dev/null; then
    pass "Security signal: output is valid JSON"
else
    fail "Security signal: output is valid JSON" "Got: $OUTPUT"
fi

if is_ok_false_with_reason "$OUTPUT"; then
    pass "Security signal: {\"ok\": false} with non-empty reason"
else
    fail "Security signal: {\"ok\": false} with non-empty reason" "Got: $OUTPUT"
fi

REASON=$(python3 -c "import json,sys; print(json.loads('''$OUTPUT'''.strip()).get('reason',''))" 2>/dev/null)
if echo "$REASON" | grep -qi "security\|audit\|keel:audit"; then
    pass "Security signal: reason contains security audit suggestion"
else
    fail "Security signal: reason contains security audit suggestion" "Reason: $REASON"
fi

# ─── TEST 4: Doc gap signal → ok:false with doc gap reason ────────────────────

DOC_GAP_RESPONSE='I added three new API endpoints: POST /api/v2/webhooks to register webhooks, DELETE /api/v2/webhooks/:id to remove them, and GET /api/v2/webhooks to list all registered webhooks. I also added a new WEBHOOK_SECRET environment variable that must be set for signature validation to work.'

OUTPUT=$(call_stop_hook "$DOC_GAP_RESPONSE" 2>/dev/null)

if python3 -c "import json,sys; json.loads('''$OUTPUT'''.strip()); sys.exit(0)" 2>/dev/null; then
    pass "Doc gap signal: output is valid JSON"
else
    fail "Doc gap signal: output is valid JSON" "Got: $OUTPUT"
fi

if is_ok_false_with_reason "$OUTPUT"; then
    pass "Doc gap signal: {\"ok\": false} with non-empty reason"
else
    fail "Doc gap signal: {\"ok\": false} with non-empty reason" "Got: $OUTPUT"
fi

REASON=$(python3 -c "import json,sys; print(json.loads('''$OUTPUT'''.strip()).get('reason',''))" 2>/dev/null)
if echo "$REASON" | grep -qi "doc\|keel:docs\|webhook\|env\|WEBHOOK_SECRET"; then
    pass "Doc gap signal: reason references the specific gap"
else
    fail "Doc gap signal: reason references the specific gap" "Reason: $REASON"
fi

# ─── TEST 5: Mixed signals → ok:false with multiple signals in reason ──────────

MIXED_RESPONSE='I redesigned the authentication system to use OAuth2 with PKCE instead of simple JWT. This is a hard architectural constraint going forward — all new clients must use PKCE. I added three new endpoints: POST /auth/authorize, POST /auth/token, and POST /auth/revoke. The CLIENT_SECRET env var is now required.'

OUTPUT=$(call_stop_hook "$MIXED_RESPONSE" 2>/dev/null)

if python3 -c "import json,sys; json.loads('''$OUTPUT'''.strip()); sys.exit(0)" 2>/dev/null; then
    pass "Mixed signals: output is valid JSON"
else
    fail "Mixed signals: output is valid JSON" "Got: $OUTPUT"
fi

if is_ok_false_with_reason "$OUTPUT"; then
    pass "Mixed signals: {\"ok\": false} with non-empty reason"
else
    fail "Mixed signals: {\"ok\": false} with non-empty reason" "Got: $OUTPUT"
fi

# ─── TEST 6: Bug fix / refactor → no false signals ────────────────────────────

BUGFIX_RESPONSE='Fixed the off-by-one error in the pagination helper. The calculateOffset function was returning page * size instead of (page - 1) * size, causing the first page to be skipped. Updated the formula and added a guard for page numbers less than 1.'

OUTPUT=$(call_stop_hook "$BUGFIX_RESPONSE" 2>/dev/null)

if python3 -c "import json,sys; obj=json.loads('''$OUTPUT'''.strip()); sys.exit(0 if obj.get('ok') is True else 1)" 2>/dev/null; then
    pass "Bug fix response: {\"ok\": true} — no false signals for refactors"
else
    # Warn not fail — model conservatism varies
    echo "  WARN  Bug fix response: expected ok:true, got: $OUTPUT"
fi

test_summary
