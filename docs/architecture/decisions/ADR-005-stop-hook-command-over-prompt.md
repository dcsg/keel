# ADR-005: Stop Hook as type:command with regex detection over type:prompt

**Status:** accepted
**Date:** 2026-03-09

---

## Context

The keel Stop hook needs to detect signals in Claude's responses (architecture decisions, doc gaps, security changes) and surface them to the user after each turn.

The initial design used a `type: prompt` hook where Claude Code re-invokes Claude with a detection prompt and expects a JSON response. Two iterations of this approach were tried:

1. **Plain text before `{"ok": true}`** — the prompt asked Claude to output signal lines followed by `{"ok": true}` on the last line. Claude Code validates the *entire* response as JSON, so any plain text before the JSON caused `JSON validation failed` errors and signals were silently lost.

2. **`{"ok": false, "reason": "signals"}`** — signals were encoded in the `reason` field of an `ok: false` response. Claude Code surfaced the reason but always prefixed it with `"Prompt hook condition was not met:"` — an error-framed label that misrepresented informational signals as failures.

Neither approach could produce a clean, non-blocking, non-error-labelled notification from a `type: prompt` hook. The `type: prompt` response schema supports only `{ok: boolean, reason?: string}` with no informational message path.

## Decision

Replace the `type: prompt` Stop hook with a `type: command` shell script (`stop-hook.sh`) that:

1. Reads `last_assistant_message` from stdin (provided by Claude Code)
2. Detects signals using regex pattern matching (no API key required)
3. Logs detected signals to `~/.keel/session-signals.log`
4. Outputs `{"systemMessage": "signals"}` for non-blocking user-visible notification, or `{"continue": true}` when nothing to flag

## Rationale

The `type: command` hook response format supports a `systemMessage` field that Claude Code displays to the user as an informational notification — no error label, no blocking. This is exactly the right mechanism for keel's signals.

Regex-based detection was chosen over an external Claude API call because:
- Claude Code users authenticate via OAuth and do not have `ANTHROPIC_API_KEY` as an environment variable
- Regex is instant, transparent, and requires no external dependencies
- The signal patterns (trade-off language, HTTP routes, security term density) are well-defined enough to capture with regex reliably

## Alternatives Considered

### type:prompt with ok:false for signals
- **Pros:** Uses Claude's intelligence for nuanced detection; no shell script required
- **Cons:** `"Prompt hook condition was not met:"` prefix hardcoded by Claude Code; signals look like errors; cannot be suppressed; UX is confusing regardless of signal content

### type:command with external Claude API call
- **Pros:** More accurate detection using Claude's language understanding
- **Cons:** Requires `ANTHROPIC_API_KEY` environment variable; OAuth users (the majority) cannot use it without extra setup; adds latency and external dependency to every response

### type:prompt with ok:true (signals embedded in JSON)
- **Pros:** Valid JSON, never blocks
- **Cons:** Claude Code does not display any fields from `ok:true` responses to the user; signals would be completely invisible

## Consequences

### Positive
- Signals appear as clean `systemMessage` notifications — no error label, non-blocking
- No API key or network call required; works for all Claude Code users
- Shell script is transparent and auditable
- Session signal log (`~/.keel/session-signals.log`) enables `/keel:status` to show hook activity history
- Infinite loop prevention via `stop_hook_active` guard

### Negative / Trade-offs
- Regex detection is less accurate than Claude-based detection — may miss subtle architectural decisions that don't use explicit trade-off language
- Regex patterns require maintenance as new signal types are added
- Shell script adds operational complexity vs. a self-contained prompt string in `settings.json`

---

*Captured by keel:adr — 2026-03-09*
