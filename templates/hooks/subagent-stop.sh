#!/usr/bin/env bash
# keel: SubagentStop hook — log specialist agent activity + quality gates
# Fires after any subagent completes. Logs agent name and outcome to
# session-signals.log. If the agent is configured as a gate and returns
# a critical finding, blocks progression with an acknowledged override flow.

# Only run in keel projects
if [ ! -f ".keel/config.yaml" ]; then exit 0; fi

# Source event logging
if [ -f "$HOME/.keel/hooks/event-log.sh" ]; then
  source "$HOME/.keel/hooks/event-log.sh"
fi

# Read last assistant message from stdin
INPUT=$(cat)

# Extract agent name from the response
# Agents declare themselves by domain (e.g., "architecture specialist", "database specialist")
AGENT_NAME=""
INPUT_LOWER=$(echo "$INPUT" | tr '[:upper:]' '[:lower:]')

# Check domain keywords (how agents declare themselves in v0.1.0+)
if echo "$INPUT_LOWER" | grep -qE "architect|architecture specialist"; then AGENT_NAME="architect"
elif echo "$INPUT_LOWER" | grep -qE "database|dba|schema|migration specialist"; then AGENT_NAME="dba"
elif echo "$INPUT_LOWER" | grep -qE "security specialist|security engineer|appsec"; then AGENT_NAME="security"
elif echo "$INPUT_LOWER" | grep -qE "api specialist|api engineer|api design"; then AGENT_NAME="api"
elif echo "$INPUT_LOWER" | grep -qE "backend specialist|backend engineer"; then AGENT_NAME="backend"
elif echo "$INPUT_LOWER" | grep -qE "frontend specialist|frontend engineer"; then AGENT_NAME="frontend"
elif echo "$INPUT_LOWER" | grep -qE "qa specialist|testing specialist|quality"; then AGENT_NAME="qa"
elif echo "$INPUT_LOWER" | grep -qE "sre specialist|reliability|observability"; then AGENT_NAME="sre"
elif echo "$INPUT_LOWER" | grep -qE "platform specialist|ci/cd|infrastructure"; then AGENT_NAME="platform"
elif echo "$INPUT_LOWER" | grep -qE "documentation specialist|docs specialist"; then AGENT_NAME="docs"
elif echo "$INPUT_LOWER" | grep -qE "product manager|product specialist|pm specialist"; then AGENT_NAME="pm"
elif echo "$INPUT_LOWER" | grep -qE "ux specialist|accessibility specialist"; then AGENT_NAME="ux"
elif echo "$INPUT_LOWER" | grep -qE "data specialist|data engineer|pipeline"; then AGENT_NAME="data"
elif echo "$INPUT_LOWER" | grep -qE "performance specialist|optimization"; then AGENT_NAME="performance"
elif echo "$INPUT_LOWER" | grep -qE "compliance specialist|regulatory"; then AGENT_NAME="compliance"
elif echo "$INPUT_LOWER" | grep -qE "mobile specialist|ios|android|flutter"; then AGENT_NAME="mobile"
elif echo "$INPUT_LOWER" | grep -qE "seo specialist|search engine"; then AGENT_NAME="seo"
elif echo "$INPUT_LOWER" | grep -qE "gtm specialist|analytics|tracking"; then AGENT_NAME="gtm"
fi

# Fallback: check for agent slug directly in the text
if [ -z "$AGENT_NAME" ]; then
  for agent in architect dba security api backend frontend qa sre platform docs pm ux data performance compliance mobile seo gtm; do
    if echo "$INPUT_LOWER" | grep -qF "$agent"; then
      AGENT_NAME="$agent"
      break
    fi
  done
fi

# If no known agent detected, try to extract from "As <Role>" pattern
if [ -z "$AGENT_NAME" ]; then
  AGENT_NAME=$(echo "$INPUT" | grep -oiE 'As (Staff|Senior|Principal) [A-Za-z]+' | head -1 | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
fi

# If still no agent name, exit silently
if [ -z "$AGENT_NAME" ]; then
  printf '{"continue": true}'
  exit 0
fi

# Detect severity from output
SEVERITY="info"
FINDING=""
if echo "$INPUT" | grep -qiE '🔴|critical|CRITICAL|must be addressed|security vulnerability|data loss'; then
  SEVERITY="critical"
  FINDING=$(echo "$INPUT" | grep -iE '🔴|critical|CRITICAL|must be addressed|security vulnerability|data loss' | head -1 | sed 's/^[[:space:]]*//' | cut -c1-120)
elif echo "$INPUT" | grep -qiE '🟡|warning|WARNING|should be addressed|missing index|no rollback'; then
  SEVERITY="warning"
  FINDING=$(echo "$INPUT" | grep -iE '🟡|warning|WARNING|should be addressed' | head -1 | sed 's/^[[:space:]]*//' | cut -c1-120)
elif echo "$INPUT" | grep -qiE '🟢|OK|looks (good|stable|healthy)'; then
  SEVERITY="ok"
fi

# Log to session signals
mkdir -p "$HOME/.keel" 2>/dev/null || true
LOG_FILE="$HOME/.keel/session-signals.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "${TIMESTAMP} AGENT ${AGENT_NAME} severity=${SEVERITY}" >> "$LOG_FILE"

# ============================================================
# Quality gate logic
# ============================================================

# Check if quality gates are disabled
if grep -q 'quality-gates: false' .keel/config.yaml 2>/dev/null; then
  exit 0
fi

# Check if this agent is configured as a gate
IS_GATE=false
GATE_CHECK=$(awk '/^gates:/{found=1} found && /'"${AGENT_NAME}"'/{print "yes"; exit}' .keel/config.yaml 2>/dev/null)
if [ "$GATE_CHECK" = "yes" ]; then
  IS_GATE=true
fi

# If agent is a gate AND severity is critical, block progression
if [ "$IS_GATE" = true ] && [ "$SEVERITY" = "critical" ]; then
  # Log gate event
  if type keel_log_event >/dev/null 2>&1; then
    ESCAPED_FINDING=$(echo "$FINDING" | sed 's/"/\\"/g')
    keel_log_event "gate_fired" "{\"agent\":\"${AGENT_NAME}\",\"severity\":\"critical\",\"finding\":\"${ESCAPED_FINDING}\"}"
  fi

  # Block with the finding surfaced as a systemMessage
  # The systemMessage asks Claude to present the gate to the user
  GATE_MSG="GATE BLOCKED: ${AGENT_NAME} found a critical issue: ${FINDING}. Ask the user if they want to override this gate. If they override, log it. If not, stop and let them fix the issue."
  printf '{"decision": "block", "systemMessage": "%s"}' "$(echo "$GATE_MSG" | sed 's/"/\\"/g')"
  exit 0
fi

# No gate or not critical — continue
printf '{"continue": true}'
