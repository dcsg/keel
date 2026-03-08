# Keel Changelog

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
