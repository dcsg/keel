# Keel Changelog

## v3.1 (2026-03-08)

### Bug fix: Stop hook JSON validation error

The Stop hook prompt previously asked Claude to "end your next response with..." free text. Claude Code's `type: prompt` hooks require a JSON response (`{"ok": true}` or `{"ok": false, "reason": "..."}`). The prompt has been corrected — signals now appear in the `reason` field and are fed back as context.

**Action required:** Run `/keel:upgrade` to apply the fix to your project.

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
