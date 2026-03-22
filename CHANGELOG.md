# Keel Changelog

## v0.1.0 (2026-03-21)

### First public release — The Agentic Engineering Governance Layer

keel governs the full engineering cycle — from requirements through execution to verification. Standards are enforced, decisions compile into directives, and drift is detected automatically.

**Rule Packs (20 packs, v2.0.0)**
- Context-engineering optimized: 14-17 instructions per pack (research sweet spot)
- Domain-specific `<governance_checkpoint>` blocks with pre-action and post-result verification
- Three-tier system: base (10 language-agnostic), lang (4), framework (6)
- Deduped: lang/framework packs depend on base packs, no redundant rules
- EXP-004 validated: 15/15 compliance on invented conventions vs 0/15 without rules (123 eval runs)

**Rule Pack Audit**
- 47 opinionated best-practice rules removed — architecture opinions belong in ADRs, not rule packs
- 11 correctness guardrails added: hallucinated API prevention, placeholder code detection, codebase consistency, race conditions, edge cases, timing attack prevention, tautological test detection, deprecated API prevention (Go: `ioutil`), over-engineering prevention, Go data race detection, error exposure ownership
- Cross-pack ownership clarified: security.md owns error exposure and input validation; seo.md owns alt text; database.md owns index rules; code-quality.md owns handler separation
- Archway integration: `/keel:init` detects `archway.yaml` and skips the architecture pack — keel defers architecture enforcement to archway when it's present

**Automation Layer**
- `UserPromptSubmit` hook injects the active plan phase into every prompt — no more losing track after compaction
- `PostCompact` hook re-injects plan phase + invariants after context compaction — zero-touch recovery
- `SubagentStop` hook logs specialist agent activity to `session-signals.log`
- `InstructionsLoaded` hook logs which rule packs load each session
- `context: fork` on `/keel:doctor`, `/keel:status`, `/keel:docs` — diagnostic commands don't pollute main context
- `memory: project` on `principal-dba` and `staff-security` — specialists accumulate project-specific knowledge

**Enforcement**
- Quality gates: configure agents as gates in `.keel/config.yaml` (`gates: [staff-security]`). Critical findings block progression with logged override.
- Pre-push invariant check: staged files validated against invariants. Violations block the push (exit 1). Override with `KEEL_INVARIANT_SKIP=1`.
- `/keel:doctor` decision graph validation: ADR contradiction detection, rule-invariant consistency, plan-ADR dependency check, orphan artifact detection, state machine validation.
- Structured event logging to `~/.keel/events.jsonl` — every gate firing, override, and status change logged with ISO8601 timestamp and git identity.

**Spec Layer**
- `/keel:spec` — technical specification from an accepted PRD. Codebase-aware interview, outline confirmation, ADR conflict detection, routed through principal-architect.
- `/keel:spec-artifacts` — implementable artifacts (data model, API contracts, migrations, test strategy) from an accepted spec. Per-artifact agent routing.
- Artifact status workflow: `draft → accepted → in-progress → implemented → superseded`. State machine enforced — PRD must be accepted before spec, spec before artifacts, artifacts before plan.
- All artifacts get `created_at`, `references:`, and consistent ID format in frontmatter.

**Drift Detection**
- `/keel:drift` — compares implementation against the full governance chain (PRD criteria, spec requirements, artifact contracts, ADR compliance, invariant compliance).
- Severity model with confidence: compliant (high), likely compliant (medium), diverged (high), unknown.
- Scoping: `--scope=prd|spec|artifacts|adrs` for focused checks.
- CI support: `--output=json` with exit code 1 on diverged findings.
- Reports persisted as `drift-YYYY-MM-DD.md` in the spec folder.
- Integrated with `/keel:review` — drift check appended when spec exists.

**Observability**
- `/keel:status` rebuilt as a governance dashboard: chain status, gate activity, agent activity, hook activity, detected signals.
- Stop hook upgraded with ADR dedup — checks if a detected decision already exists before suggesting capture.

**Brand**
- Positioned as "governance layer for agentic engineering" (retired "context engine")
- Voice: Precise. Direct. Authoritative. Forward.
- K monogram logo
- README rewritten with full governance chain and loop

**Traceability chain:**
```
/keel:prd → /keel:spec → /keel:spec-artifacts → /keel:plan → execute → /keel:drift
```

**Compiled Governance**
- `/keel:compile` — reads accepted ADRs and active invariants, produces `.claude/rules/governance.md` with short, actionable directives Claude follows automatically. Status-aware: only compiles accepted/active decisions. Contradiction detection blocks compilation until conflicts are resolved. `--check` flag for CI validation. ADRs are the source of truth — no manual edits to the compiled output.

**New Command: `/keel:review-governance`**
- Scores governance document language on specificity, actionability, phrasing, and testability
- Document-level checks on compiled output: directive count, phrasing consistency, primacy/recency, redundancy
- Every finding includes the original text and a concrete rewrite
- Research-grounded criteria from EXP-004, IFEval++, IFScale, and "lost in the middle"

**Drift Report Redesign**
- Emoji severity summary (✅ 🟡 ⚠️ ❓) at top for quick read
- Table shows only non-compliant findings — compliant items stay in the summary line
- Ends with "Want me to prioritize them?" — user drives priority, not the tool

**Agent Roster Redesign (ADR-007)**
- 18 specialist agents with flat naming (no principal-/staff-/senior- prefixes)
- Model selection belongs to the plan phase, not the agent definition
- Agents: architect, api, backend, dba, docs, frontend, performance, platform, pm, qa, security, sre, ux, data, mobile, compliance, seo, gtm

**Template Redesign**
- PRD: numbered requirements (FR-001), acceptance criteria (AC-001), NEEDS CLARIFICATION markers
- ADR: MADR structure with Confirmation section for drift detection
- Invariant: severity, scope, violation consequences, verification method
- Spec: non-goals, alternatives considered, risks, numbered acceptance criteria

**Rename: soul.md → project-context.md**
- Dropped the jargon — "project context" is self-explanatory
- Keeps the separate file for future multi-tool support (Cursor, Copilot)

**Website (keel.dcsg.me)**
- Full documentation site with VitePress, custom theme (Space Grotesk, IBM Plex Sans, JetBrains Mono)
- Guides: solo engineer, teams, multi-project, greenfield, brownfield, monorepo, security, daily workflow
- Governance section: chain, gates, compile, drift, review-governance
- Experiments section with EXP-004 write-up
- Terminal TUI components for code examples
- SEO: meta tags, sitemap, robots.txt, JSON-LD structured data

**Eval Harness**
- Reproducible compliance testing: `test/eval/v2/` (60 runs) and `test/eval/v3/` (63 runs)
- Auto-scoring from files on disk, not output text parsing
- 3 commands: `setup.sh` → `run.sh` → `score.py`

**New commands:** `/keel:spec`, `/keel:spec-artifacts`, `/keel:drift`, `/keel:compile`, `/keel:review-governance`
**Total hooks:** 9 (was 5)
**Total agents:** 18 (was 7)
**Total rule packs:** 20 (10 base + 4 lang + 6 framework)
**Experiments:** EXP-001 through EXP-004 (EXP-004 completed with 123 runs)

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
