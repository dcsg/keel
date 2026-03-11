# Keel Changelog

## v3.9 (2026-03-11)

### fix(agents): inline formatting instructions for subagent PostToolUse gap

The `PostToolUse` hook auto-formats files after Write/Edit calls in the main session, but subagents spawned via the Agent tool run in a subprocess and do not trigger the parent session's hooks. Files edited by subagents (staff-engineer, senior-backend, staff-qa, staff-frontend, debugger) were bypassing auto-formatting, causing CI failures.

**Fix:** Added a `## File Formatting` section to each code-writing agent template instructing the agent to run the appropriate formatter immediately after each Write or Edit call. Added a comment to `post-tool-use.sh` documenting the gap and the compensating control.

Affected templates: `staff-engineer`, `senior-backend`, `staff-qa`, `staff-frontend`, `debugger`.
Read-only agents are unchanged.

## v3.8 (2026-03-09)

### feat: attribution prefix, --no-keel flag, session signal log

Three UX improvements to make keel's activity visible and controllable:

**1. Attribution prefix** — `/keel:audit` and `/keel:review` now output `🪝 keel: routing to {agent}...` before spawning subagents, so you always know which specialist agent is handling the work.

**2. `--no-keel` flag** — Pass `--no-keel` to `/keel:audit` or `/keel:review` to bypass agent routing and have Claude perform the analysis inline. Useful when you want direct output without delegation.
```
/keel:audit --no-keel auth
/keel:review --no-keel --staged
```

**3. Session signal log** — The Stop hook now writes every signal it detects to `~/.keel/session-signals.log` with an ISO8601 timestamp. The log rotates on each new session (previous session archived to `.prev`). `/keel:status` displays the signals fired this session under a new "HOOK ACTIVITY" section.

## v3.7 (2026-03-08)

### Fix: Stop hook no longer requires ANTHROPIC_API_KEY — regex-based detection

v3.6 switched to `type: command` with an external Claude API call to avoid the "Prompt hook condition was not met" UX issue. But this required `ANTHROPIC_API_KEY` to be set as an environment variable — which Claude Code OAuth users don't have.

The Stop hook now uses **regex-based signal detection** in the shell script — no API key, no external calls, instant execution. Signals are still surfaced as `systemMessage` (non-blocking, no error label).

Detection patterns:
- **Architecture:** "chose X over Y", "trade-off", "going forward all/every/must", "hard constraint"
- **Doc gap:** New HTTP routes (`POST /path`, `GET /path`, etc.), new env vars (UPPER_CASE pattern)
- **Security:** 2+ security terms (JWT, OAuth, payment, PII, encrypt, secret, etc.)

Also added `test/test-stop-hook-e2e.sh` — runs the hook script directly with simulated payloads, no API key needed.

## v3.6 (2026-03-08)

### Bug fix: Stop hook signals were silently lost (JSON validation failed)

The Stop hook prompt told Claude to output signal lines followed by `{"ok": true}` on the last line. Claude Code validates the **entire** response as JSON — so any plain text before the JSON caused a `JSON validation failed` error and signals were never shown.

**Root cause:** Mixed plain-text + JSON output is never valid JSON.

**Fix:** Signals are now encoded as `{"ok": false, "reason": "signal text"}`. Claude Code surfaces the `reason` to the user, making signals visible. When no signals are detected, the hook returns `{"ok": true}` as before.

The prompt was also tightened to be more conservative — it now only flags clear, unambiguous signals to avoid false positives that would interrupt normal flow.

Added `test/test-stop-hook-e2e.sh` — an e2e test that calls the Claude API with simulated responses and validates the hook output format and signal detection behavior.

## v3.5 (2026-03-08)

### Bug fix: upgrade and rules-update incorrectly flagged rules as outdated when none were installed

When `.claude/rules/` was missing or empty, the upgrade command showed a stale icon for rule packs despite there being nothing to compare. Both `upgrade` and `rules-update` now explicitly handle this case — showing "no rule packs installed" instead of a false outdated indicator.

## v3.4 (2026-03-08)

### Improvement: Release notes shown after upgrade completes

The "WHAT'S NEW" section now appears at the bottom of the upgrade output — after the summary and commit instructions — so you can review what changed at your own pace without it blocking the upgrade flow.

## v3.3 (2026-03-08)

### Bug fix: Stop hook response leaking into chat

The Stop hook prompt used "always end your response with `{"ok": true}`" — broad enough that Claude applied it to every regular response, not just hook evaluations. The `{"ok": true}` line was appearing at the bottom of every reply in the chat.

The prompt is now evaluation-specific: "This is a hook evaluation — not a user message." Claude Code consumes the hook response silently; it never appears in the conversation.

**Action required:** Run `/keel:upgrade` to apply the fix to your project.

## v3.2 (2026-03-08)

### Bug fix: Stop hook "Prompt hook condition was not met" error

The v3.1 Stop hook fix was incomplete. Using `{"ok": false, "reason": "..."}` to deliver signals causes Claude Code to throw **"Prompt hook condition was not met"** — a blocking error — instead of showing them as helpful hints.

The correct behaviour: always return `{"ok": true}`. If signals are present, output them as plain text **before** the JSON line. They appear as informational output, never as errors.

**Action required:** Run `/keel:upgrade` to apply the fix to your project.

## v3.1 (2026-03-08)

### Hook scripts moved to `~/.keel/hooks/`

All hook logic extracted from inline bash strings in `.claude/settings.json` into readable shell scripts:

- `session-start.sh` — git-aware session summary with domain classification
- `pre-tool-use.sh` — warns if soul.md is missing
- `post-tool-use.sh` — auto-formats files after edits
- `pre-compact.sh` — PreCompact reminder

Your `settings.json` now references these scripts instead of embedding bash.

### Hook scripts moved to `~/.keel/hooks/`

All hook logic has been extracted from inline bash strings in `.claude/settings.json` into readable shell scripts at `~/.keel/hooks/`:

- `session-start.sh` — git-aware session summary with domain classification
- `pre-tool-use.sh` — warns if `docs/soul.md` is missing
- `post-tool-use.sh` — auto-formats files after edits
- `pre-compact.sh` — PreCompact reminder

Your `settings.json` now references these scripts instead of embedding bash. The scripts are readable, version-controlled, and easier to understand.

**Action required:** Run `/keel:upgrade` to migrate your project's hooks to script references.

---

## v3.0 (2026-03-01)

### New commands

- `/keel:review` — post-implementation specialist review, routes to domain agents
- `/keel:audit` — OWASP security audit via staff-security agent
- `/keel:session` — end-of-session sweep, surfaces missed ADRs/invariants/doc gaps
- `/keel:upgrade` — upgrade hooks, agents, and rules in an existing project

### Git-aware SessionStart hook

The SessionStart hook now reads `git log` since your last session and surfaces relevant specialist agents based on what changed (migrations → principal-dba, auth files → staff-security, etc.).

### New guides

- `daily-workflow.md` — standard keel session flow
- `upgrading.md` — how to upgrade existing projects
- `specialist-agents.md` — when and how to use each agent
- `security.md` — security workflow with keel

---

## v2.0 (2026-02-01)

### Specialist agents

17 specialist agent templates across domains: principal-architect, staff-engineer, senior-backend, principal-dba, staff-security, staff-sre, staff-qa, staff-frontend, principal-ux, senior-pm, senior-api, senior-performance, principal-data, staff-docs.

### Five-hook system

Added PostToolUse (auto-format) and PreCompact hooks. Stop hook detects ADR, invariant, PRD, doc gap, and security signals.

### Rule registry

Three-tier rule system: base (language-agnostic), lang, framework. Registry at `templates/rules/_registry.yaml`.

---

## v1.0 (2026-01-01)

Initial release. `/keel:init`, `/keel:context`, `/keel:plan`, `/keel:status`, `/keel:intake`.
