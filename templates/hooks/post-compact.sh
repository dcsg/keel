#!/usr/bin/env bash
# keel: PostCompact hook — re-inject plan phase and invariants after compaction
# Fires immediately after context compaction. Ensures the engineer never has to
# manually run /keel:context to recover plan state.

# Only run in keel projects
if [ ! -f ".keel/config.yaml" ]; then exit 0; fi

# Read base directory from config
BASE=$(grep '^base:' .keel/config.yaml 2>/dev/null | awk '{print $2}' | tr -d '"' || echo "docs")
[ -z "$BASE" ] && BASE="docs"

# --- Find active plan phase ---
PLAN_DIR=$(grep -A1 '^plans:' .keel/config.yaml 2>/dev/null | grep 'dir:' | awk '{print $2}' | tr -d '"')
[ -z "$PLAN_DIR" ] && PLAN_DIR="$BASE/plans"

PLAN_MSG=""
if [ -d "$PLAN_DIR" ]; then
  PLAN=$(ls -t "$PLAN_DIR"/*.md 2>/dev/null | head -1)
  if [ -n "$PLAN" ] && [ -f "$PLAN" ]; then
    PHASE=$(grep -iE '\| *(Phase )?[0-9]+ *\|.*in[_ -]progress' "$PLAN" 2>/dev/null | head -1)
    if [ -n "$PHASE" ]; then
      PHASE_NUM=$(echo "$PHASE" | sed 's/|/\n/g' | sed -n '2p' | tr -d ' ' | grep -oE '[0-9]+')
      PHASE_THEME=$(echo "$PHASE" | sed 's/|/\n/g' | sed -n '3p' | sed 's/^ *//;s/ *$//')
      PLAN_NAME=$(head -5 "$PLAN" | grep '^# ' | head -1 | sed 's/^# //')
      PLAN_MSG="Active plan: ${PLAN_NAME}. Phase ${PHASE_NUM}"
      [ -n "$PHASE_THEME" ] && PLAN_MSG="${PLAN_MSG} — ${PHASE_THEME}"
      PLAN_MSG="${PLAN_MSG}. Re-read ${PLAN} for full phase details."
    fi
  fi
fi

# --- Collect invariants ---
INV_DIR=""
for dir in "$BASE/invariants" "$BASE/architecture/invariants"; do
  if [ -d "$dir" ]; then
    INV_DIR="$dir"
    break
  fi
done

INV_MSG=""
if [ -n "$INV_DIR" ]; then
  INV_COUNT=$(ls "$INV_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$INV_COUNT" -gt 0 ]; then
    INV_NAMES=$(ls "$INV_DIR"/*.md 2>/dev/null | xargs -I{} head -1 {} | sed 's/^# //' | paste -sd', ' -)
    INV_MSG="Invariants (${INV_COUNT}): ${INV_NAMES}. These are hard constraints — never violate them."
  fi
fi

# --- Build output ---
if [ -z "$PLAN_MSG" ] && [ -z "$INV_MSG" ]; then
  exit 0
fi

MSG="Context recovered after compaction."
[ -n "$PLAN_MSG" ] && MSG="${MSG} ${PLAN_MSG}"
[ -n "$INV_MSG" ] && MSG="${MSG} ${INV_MSG}"

printf '{"systemMessage": "%s"}' "$(echo "$MSG" | sed 's/"/\\"/g')"
