#!/usr/bin/env bash
# keel: Stop hook — detect signals in the last assistant response and surface them
# as a non-blocking systemMessage shown to the user.
#
# Uses regex pattern matching — no API key required.
# Outputs {"systemMessage": "..."} for signals, {"continue": true} when clean.

set -uo pipefail

# Only run in keel projects
if [ ! -f '.keel/config.yaml' ]; then exit 0; fi

# Prevent infinite loops — stop_hook_active means we're already in a continuation
INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print('true' if d.get('stop_hook_active') else 'false')
" 2>/dev/null || echo "false")

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then exit 0; fi

# Extract the last assistant message
LAST_MSG=$(echo "$INPUT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('last_assistant_message', '').strip())
" 2>/dev/null || echo "")

if [ -z "$LAST_MSG" ]; then exit 0; fi

# ─── Signal detection (regex-based, no API key required) ──────────────────────

SIGNALS=()

# ARCHITECTURE: explicit trade-off language or "chose X over Y" patterns
if echo "$LAST_MSG" | grep -qiE \
    'chose .+ over |trade.?off|architectural (decision|constraint|choice)|going forward .*(all|every|must)|hard (constraint|rule|requirement)|ADR|decision record'; then
    SIGNALS+=("💡 ADR candidate — run /keel:adr to capture this decision.")
fi

# DOC GAP: new HTTP routes or env vars added
NEW_ROUTES=$(echo "$LAST_MSG" | grep -oiE '(POST|GET|PUT|DELETE|PATCH) /[a-zA-Z0-9/_:.-]+' | head -3)
NEW_ENV=$(echo "$LAST_MSG" | grep -oiE '(added|new|required).{0,30}[A-Z][A-Z0-9_]{3,}[A-Z0-9]' | grep -v 'ADR\|ARCH\|HTTP\|API\|JSON\|HTML\|CSS' | head -2)

if [ -n "$NEW_ROUTES" ]; then
    FIRST_ROUTE=$(echo "$NEW_ROUTES" | head -1)
    SIGNALS+=("📄 Doc gap: new route $FIRST_ROUTE — run /keel:docs to review.")
elif [ -n "$NEW_ENV" ]; then
    ENV_VAR=$(echo "$NEW_ENV" | grep -oiE '[A-Z][A-Z0-9_]{3,}[A-Z0-9]' | grep -v 'ADR\|ARCH\|HTTP\|API\|JSON\|HTML\|CSS' | head -1)
    if [ -n "$ENV_VAR" ]; then
        SIGNALS+=("📄 Doc gap: new env var $ENV_VAR — run /keel:docs to review.")
    fi
fi

# SECURITY: auth/payments/PII/crypto was the central focus
if echo "$LAST_MSG" | grep -qiE \
    '(JWT|OAuth|PKCE|auth[a-z]*|payment|PII|encrypt|decrypt|secret|signing key|private key|bearer token|bcrypt|password hash)'; then
    # Only flag if it's a substantive change (multiple security terms or central to the response)
    SEC_COUNT=$(echo "$LAST_MSG" | grep -ioE '(JWT|OAuth|PKCE|auth[a-z]*|payment|PII|encrypt|decrypt|secret|signing key|private key|bearer token|bcrypt|password hash)' | wc -l | tr -d ' ')
    if [ "$SEC_COUNT" -ge 2 ]; then
        SIGNALS+=("🔒 Security-sensitive change — run /keel:audit before shipping.")
    fi
fi

# ─── Output ───────────────────────────────────────────────────────────────────

if [ ${#SIGNALS[@]} -eq 0 ]; then
    echo '{"continue": true}'
    exit 0
fi

# Log signals to session file so /keel:status can show them
LOG_FILE="$HOME/.keel/session-signals.log"
mkdir -p "$HOME/.keel" 2>/dev/null || true
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%SZ)
for SIGNAL in "${SIGNALS[@]}"; do
    echo "${TIMESTAMP} ${SIGNAL}" >> "$LOG_FILE" 2>/dev/null || true
done

python3 - "${SIGNALS[@]}" <<'PYEOF'
import json, sys
signals = sys.argv[1:]
msg = "\n".join(signals)
print(json.dumps({"systemMessage": msg}))
PYEOF
