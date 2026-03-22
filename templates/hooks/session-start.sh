#!/usr/bin/env bash
# keel: SessionStart hook — git-aware session summary
# Surfaces what changed since last session and which specialist agents are relevant.

set -euo pipefail

# Only run in keel projects
if [ ! -f '.keel/config.yaml' ]; then exit 0; fi

# Rotate session signals log — archive previous session, start fresh
mkdir -p "$HOME/.keel" 2>/dev/null || true
LOG_FILE="$HOME/.keel/session-signals.log"
if [ -f "$LOG_FILE" ]; then
    mv "$LOG_FILE" "${LOG_FILE}.prev" 2>/dev/null || true
fi

ENCODED=$(echo "$PWD" | sed 's|/|-|g')
MEMORY="$HOME/.claude/projects/${ENCODED}/memory/MEMORY.md"

# Compute memory age
if [ -f "$MEMORY" ]; then
  AGE=$(( ($(date +%s) - $(date -r "$MEMORY" +%s 2>/dev/null || stat -f %m "$MEMORY" 2>/dev/null || echo 0)) / 86400 ))
else
  AGE=0
fi

# If git analysis is disabled, fall back to simple age check
if grep -q 'session-summary: false' .keel/config.yaml 2>/dev/null; then
  if [ ! -f "$MEMORY" ]; then
    echo "📋 Keel project detected. Run /keel:context to load project context before writing code."
  elif [ "$AGE" -gt 7 ]; then
    echo "⚠️  Keel memory is ${AGE}d old. Run /keel:context to refresh."
  else
    echo "📋 Keel project — memory ${AGE}d old. Run /keel:context to load context."
  fi
  exit 0
fi

# No memory file yet
if [ ! -f "$MEMORY" ]; then
  echo "📋 Keel project detected. Run /keel:context to load project context before writing code."
  exit 0
fi

# Stale memory — skip git analysis, just warn
if [ "$AGE" -gt 7 ]; then
  echo "⚠️  Keel memory is ${AGE}d old. Run /keel:context to refresh."
  exit 0
fi

# Get changed files since last session
MTIME=$(date -r "$MEMORY" '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || stat -f '%Sm' -t '%Y-%m-%dT%H:%M:%S' "$MEMORY" 2>/dev/null)
CHANGED=$(git log --since="$MTIME" --name-only --pretty=format: 2>/dev/null | grep -v '^$' | sort -u)

if [ -z "$CHANGED" ]; then
  echo "📋 Keel — ${AGE}d since last session. Run /keel:context to load context."
  exit 0
fi

# Classify by domain
AGENTS=''
SUMMARY=''

N_MIGRATION=$(echo "$CHANGED" | grep -ciE 'migration|schema|\.sql' || true)
N_INFRA=$(echo "$CHANGED"     | grep -ciE 'docker|compose|\.tf|helm|k8s|Dockerfile' || true)
N_SECURITY=$(echo "$CHANGED"  | grep -ciE 'auth|jwt|oauth|payment|token|secret' || true)
N_API=$(echo "$CHANGED"       | grep -ciE 'route|handler|controller|api|endpoint' || true)

[ "$N_MIGRATION" -gt 0 ] && SUMMARY="${SUMMARY}${N_MIGRATION} migration/schema file(s), " && AGENTS="${AGENTS}dba, "
[ "$N_INFRA" -gt 0 ]     && SUMMARY="${SUMMARY}${N_INFRA} infra file(s), "              && AGENTS="${AGENTS}sre, "
[ "$N_SECURITY" -gt 0 ]  && SUMMARY="${SUMMARY}${N_SECURITY} security file(s), "        && AGENTS="${AGENTS}security, "
[ "$N_API" -gt 0 ]       && SUMMARY="${SUMMARY}${N_API} API file(s), "                  && AGENTS="${AGENTS}api, "

SUMMARY=$(echo "$SUMMARY" | sed 's/, $//')
AGENTS=$(echo "$AGENTS"   | sed 's/, $//')

if [ -n "$AGENTS" ]; then
  printf '📋 Keel — since your last session (%sd ago):\n   %s changed\n   Relevant agents: %s\n   Run /keel:context to load full project context.\n' \
    "$AGE" "$SUMMARY" "$AGENTS"
else
  echo "📋 Keel — ${AGE}d since last session. Run /keel:context to load context."
fi
