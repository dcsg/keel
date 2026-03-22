#!/usr/bin/env bash
# keel: Event logging utility — append structured events to ~/.keel/events.jsonl
# Sourced by other hook scripts, not executed directly.
#
# Usage:
#   source "$HOME/.keel/hooks/event-log.sh"
#   keel_log_event "gate_fired" '{"agent":"security","severity":"critical","finding":"Hardcoded JWT secret"}'
#   keel_log_event "status_change" '{"artifact":"SPEC-005","from":"draft","to":"accepted"}'
#   keel_log_event "gate_override" '{"agent":"security","finding":"Hardcoded JWT secret"}'

keel_log_event() {
  local event_type="$1"
  local data="$2"

  mkdir -p "$HOME/.keel" 2>/dev/null || true

  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  local user
  user=$(git config user.email 2>/dev/null || echo "unknown")

  local event
  event=$(printf '{"type":"%s","at":"%s","by":"%s",%s}' \
    "$event_type" "$timestamp" "$user" \
    "$(echo "$data" | sed 's/^{//;s/}$//')")

  echo "$event" >> "$HOME/.keel/events.jsonl"
}

# Rotate events monthly (call from session-start if needed)
keel_rotate_events() {
  local events_file="$HOME/.keel/events.jsonl"
  if [ ! -f "$events_file" ]; then return; fi

  local file_month
  file_month=$(date -r "$events_file" +"%Y-%m" 2>/dev/null || stat -f '%Sm' -t '%Y-%m' "$events_file" 2>/dev/null)
  local current_month
  current_month=$(date +"%Y-%m")

  if [ "$file_month" != "$current_month" ] && [ -n "$file_month" ]; then
    mv "$events_file" "$HOME/.keel/events-${file_month}.jsonl" 2>/dev/null || true
  fi
}
