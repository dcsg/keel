# Plan: Keel v4 — Agentic Engineering Control Plane

## Overview
**Task:** Close the governance loop — automation, enforcement, spec layer, drift detection, observability
**Source PRD:** PRD-005
**Design Session:** v4 Design Session — 2026-03-20
**Total Phases:** 5
**Created:** 2026-03-20

## Progress

| Phase | Theme | Status | Updated |
|-------|-------|--------|---------|
| 1 | Automation Layer | done | 2026-03-20 |
| 2 | Enforcement | done | 2026-03-20 |
| 3 | Spec Layer | done | 2026-03-20 |
| 4 | Drift Detection | done | 2026-03-20 |
| 5 | Observability | done | 2026-03-20 |

**IMPORTANT:** Update this table as phases complete. This table is the persistent state that survives context compaction.

## Context

### Why this plan exists

Keel v3 solved proactive intelligence — agents show up when needed. But everything is advisory. Nothing blocks, nothing enforces, nothing verifies that what was decided is what got built.

v4 closes the loop:
- **Automation:** plan context always present, compaction recovery automatic
- **Enforcement:** quality gates that block on critical findings
- **Spec layer:** technical specifications + implementable artifacts from PRDs
- **Drift detection:** verify implementation matches decisions
- **Observability:** governance dashboard, not a text dump

### The governance chain state machine

```
PRD (draft → accepted)
  → SPEC (draft → accepted)
    → ARTIFACTS (draft → accepted)
      → PLAN (draft → accepted)
        → execute
          → DRIFT (validates against all of the above)
```

### Data requirements (all phases)

Every artifact created in v4 must include:
- `created_at` and `status_changed_at` timestamps in frontmatter
- `references:` field (ADRs, invariants, other artifacts)
- Consistent ID format: PRD-NNN, SPEC-NNN, ADR-NNN, INV-NNN, PLAN-NNN

Events logged to `~/.keel/events.jsonl` (append-only) for every status change, gate firing, and drift report. Each event includes `at` (ISO8601) and `by` (git identity).

---

## Phase 1: Automation Layer (v4.0)

**Goal:** The governance loop runs automatically — no manual context loading after compaction, plan phase always present, agent and rule activity visible.

**Requirements:** R1–R6

### Tasks

#### 1.1 — `UserPromptSubmit` hook script
- Create `templates/hooks/user-prompt-submit.sh`
- Read `.keel/config.yaml` for `base:` directory
- Find most recent plan file, extract current in-progress phase from progress table
- Output `{"systemMessage": "..."}` with phase title + tasks
- Exit silently (no output) when no plan active or no `.keel/config.yaml`
- Add to `templates/settings.json.tmpl` as a new hook type

**Files:** `templates/hooks/user-prompt-submit.sh`, `templates/settings.json.tmpl`

#### 1.2 — `PostCompact` hook script
- Create `templates/hooks/post-compact.sh`
- Read active plan phase (same logic as 1.1)
- Read all invariants from `{base}/invariants/` or `{base}/architecture/invariants/`
- Output `{"systemMessage": "..."}` with phase + invariants summary
- Add to `templates/settings.json.tmpl`

**Files:** `templates/hooks/post-compact.sh`, `templates/settings.json.tmpl`

#### 1.3 — `SubagentStop` hook script
- Create `templates/hooks/subagent-stop.sh`
- Read `last_assistant_message` from stdin
- Extract agent name, outcome summary, severity from the response
- Append to `~/.keel/session-signals.log` with ISO8601 timestamp
- Output `{"continue": true}` (never block in phase 1 — blocking comes in phase 2)
- Add to `templates/settings.json.tmpl`

**Files:** `templates/hooks/subagent-stop.sh`, `templates/settings.json.tmpl`

#### 1.4 — `InstructionsLoaded` hook script
- Create `templates/hooks/instructions-loaded.sh`
- Read the loaded rule file path from hook input
- Append rule name to `~/.keel/session-signals.log`
- Exit silently, never block

**Files:** `templates/hooks/instructions-loaded.sh`, `templates/settings.json.tmpl`

#### 1.5 — Skills frontmatter on read-only commands
- Add `context: fork` to frontmatter of: `commands/doctor.md`, `commands/status.md`, `commands/docs.md`
- Add `allowed-tools` to scope tools per command (Read, Grep, Glob, Bash only)

**Files:** `commands/doctor.md`, `commands/status.md`, `commands/docs.md`

#### 1.6 — Agent `memory: project`
- Add `memory: project` to frontmatter of `templates/agents/principal-dba.md` and `templates/agents/staff-security.md`

**Files:** `templates/agents/principal-dba.md`, `templates/agents/staff-security.md`

#### 1.7 — Update `install.sh` and `/keel:upgrade`
- `install.sh` copies new hook scripts to `~/.keel/hooks/`
- `/keel:upgrade` detects new hooks and adds them to `.claude/settings.json`
- Update `templates/settings.json.tmpl` with all 4 new hook types

**Files:** `install.sh`, `commands/upgrade.md`, `templates/settings.json.tmpl`

#### 1.8 — Tests
- Add tests for new hooks to `test/run.sh`
- Test: UserPromptSubmit silent when no plan
- Test: PostCompact outputs systemMessage with phase
- Test: SubagentStop writes to session-signals.log
- Test: InstructionsLoaded writes to session-signals.log
- Test: read-only commands have context:fork in frontmatter
- Test: agent templates have memory:project where expected

**Files:** `test/run.sh` or `test/test-hooks.sh`

### Completion promise
After phase 1: every session has the active plan phase injected on every prompt. Compaction recovery is automatic. Agent and rule activity is logged. Read-only commands run in isolation.

---

## Phase 2: Enforcement (v4.1)

**Goal:** At least one genuine enforcement gate exists. Pre-push validates against invariants. Doctor checks the decision graph.

**Requirements:** R7–R9
**Depends on:** Phase 1 (SubagentStop hook must exist to extend into a gate)

### Tasks

#### 2.1 — Quality gate config schema
- Add `gates:` section to `.keel/config.yaml` schema
- Example: `gates: [staff-security, principal-dba]`
- Update config parsing in relevant commands

**Files:** `.keel/config.yaml` schema, `commands/init.md` (ask about gates during init)

#### 2.2 — `SubagentStop` gate logic
- Extend `templates/hooks/subagent-stop.sh` (or create a new `agent` type hook)
- Read `.keel/config.yaml` for `gates:` list
- If the completing agent is in the gates list AND finding severity is critical:
  - Output `{"decision": "block", "reason": "..."}`
  - Log gate event to `~/.keel/events.jsonl`
- If override requested:
  - Read git identity: `git config user.email`
  - Log override to `~/.keel/events.jsonl` with identity and finding
  - Output `{"decision": "allow"}`

**Files:** `templates/hooks/subagent-stop.sh`, event logging logic

#### 2.3 — Event logging foundation
- Create `~/.keel/events.jsonl` append logic (shell function or small script)
- Event format: `{"type": "gate_fired|gate_override|status_change", "at": "ISO8601", "by": "email", ...}`
- Used by gates (this phase) and all subsequent phases

**Files:** `templates/hooks/event-log.sh` (shared utility)

#### 2.4 — Pre-push invariant check
- Upgrade `templates/hooks/pre-push` script
- Read all invariants from `{base}/invariants/` or `{base}/architecture/invariants/`
- For each invariant, extract the rule and check staged files against it
- Not a full linter — pattern-based check for obvious violations
- Exit 1 on failure with the violated invariant

**Files:** `templates/hooks/pre-push`

#### 2.5 — `/keel:doctor` decision graph validation
- Extend `commands/doctor.md` with new checks:
  - ADR contradiction detection (two ADRs on same topic with different decisions)
  - Rule-invariant consistency (installed rules don't violate invariants)
  - Plan-ADR dependency (plans referencing superseded ADRs)
  - Invariant enforcement (invariants not referenced by any rule)
  - Orphan artifacts (no references to or from)

**Files:** `commands/doctor.md`

#### 2.6 — Tests
- Test: gate blocks when configured agent returns critical finding
- Test: gate override logged with git identity
- Test: pre-push exits 1 on invariant violation
- Test: doctor detects ADR contradictions
- Test: doctor detects orphan artifacts

**Files:** `test/run.sh`

### Completion promise
After phase 2: security and DBA gates block on critical findings. Pre-push validates against invariants. Doctor catches decision graph inconsistencies.

---

## Phase 3: Spec Layer (v4.2)

**Goal:** The full spec workflow exists — PRD → spec → artifacts — with status workflow enforced across all artifacts.

**Requirements:** R10a, R10b, R11
**Depends on:** Phase 2 (doctor graph validation should exist to validate spec references)

### Tasks

#### 3.1 — Artifact status workflow foundation
- Add `status:` field handling to all artifact-creating commands
- Status lifecycle: `draft → accepted → in-progress → implemented → superseded`
- Update `/keel:prd`, `/keel:adr`, `/keel:invariant` to include status in frontmatter
- Update `/keel:plan` to include status in frontmatter
- Add `created_at`, `status_changed_at`, `references:` to all artifact templates
- Log status changes to `~/.keel/events.jsonl`

**Files:** `commands/prd.md`, `commands/adr.md`, `commands/invariant.md`, `commands/plan.md`

#### 3.2 — Config: specs directory
- Add `specs: { dir: docs/product/specs }` to `.keel/config.yaml` schema
- Default to `{base}/product/specs` if not configured
- Update `commands/init.md` to create specs directory

**Files:** `commands/init.md`, config schema

#### 3.3 — `/keel:spec` command
- Create `commands/spec.md`
- Preprocessing: inject next SPEC number, existing ADR list, invariant list
- Flow:
  1. Read PRD (verify status is `accepted`)
  2. Scan codebase (architecture, hooks, agents, ADRs, invariants)
  3. Interview (2-4 codebase-specific questions)
  4. Show outline — user confirms
  5. Conflict detection against ADRs
  6. Route to `principal-architect` + domain specialists via Agent tool
  7. Create `docs/product/specs/SPEC-NNN-{slug}/spec.md`
- Frontmatter: type, id, source_prd, architecture_source, references, status, created_at

**Files:** `commands/spec.md`

#### 3.4 — Spec template
- Create `templates/spec.md.tmpl`
- Sections: Summary, Source PRD, Existing Architecture, Proposed Architecture, Trade-offs, Security Considerations, Performance Approach, Testing Strategy, Open Questions

**Files:** `templates/spec.md.tmpl`

#### 3.5 — `/keel:spec-artifacts` command
- Create `commands/spec-artifacts.md`
- Preprocessing: read spec, detect relevant artifact types from content
- Flow:
  1. Read spec (verify status is `accepted`)
  2. Scan spec content for artifact triggers (database → data-model, API → contracts, etc.)
  3. Show artifact list — user confirms
  4. Route each artifact to primary + secondary agent
  5. Create artifacts in spec folder, status `draft`
- Guard rail: block if spec is not `accepted`

**Files:** `commands/spec-artifacts.md`

#### 3.6 — Artifact templates
- Create templates for each artifact type:
  - `templates/artifacts/data-model.md.tmpl`
  - `templates/artifacts/api-contract.md.tmpl`
  - `templates/artifacts/proto-contract.md.tmpl`
  - `templates/artifacts/migrations.md.tmpl`
  - `templates/artifacts/events-contract.md.tmpl`
  - `templates/artifacts/test-strategy.md.tmpl`
  - `templates/artifacts/config-spec.md.tmpl`

**Files:** `templates/artifacts/*.md.tmpl`

#### 3.7 — State machine guard rails
- `/keel:spec` blocks if PRD is not `accepted`
- `/keel:spec-artifacts` blocks if spec is not `accepted`
- `/keel:plan` warns if artifacts are still `draft`
- Doctor flags artifacts stuck in `draft` with no recent activity (>7 days)

**Files:** `commands/spec.md`, `commands/spec-artifacts.md`, `commands/plan.md`, `commands/doctor.md`

#### 3.8 — Update install.sh
- Add new commands to install list: `keel:spec`, `keel:spec-artifacts`
- Add artifact templates to install

**Files:** `install.sh`

#### 3.9 — Tests
- Test: `/keel:spec` command file exists with correct structure
- Test: `/keel:spec-artifacts` command file exists
- Test: spec template has required sections
- Test: all artifact templates exist
- Test: preprocessing injects correct next SPEC number

**Files:** `test/run.sh`

### Completion promise
After phase 3: engineers can go from accepted PRD → technical spec → implementable artifacts, with status enforced at each transition. The spec folder contains the full spec package. All existing artifact commands emit timestamps and references.

---

## Phase 4: Drift Detection (v4.3)

**Goal:** `/keel:drift` checks whether implementation matches the full governance chain.

**Requirements:** R12
**Depends on:** Phase 3 (specs and artifacts must exist to drift against)

### Tasks

#### 4.1 — `/keel:drift` command
- Create `commands/drift.md`
- Preprocessing: read spec ID from argument, resolve spec folder path
- Flow:
  1. Read spec + artifacts + source PRD + referenced ADRs + invariants
  2. Get git diff (since plan started or since last drift)
  3. For each layer (PRD criteria, spec requirements, artifact contracts, ADRs, invariants):
     - Route to relevant specialist agents with the artifact + diff as context
     - Agent returns per-requirement compliance assessment with confidence
  4. Aggregate into drift report
  5. Persist report as file: `docs/product/specs/SPEC-NNN-{slug}/drift-YYYY-MM-DD.md`
  6. Log drift event to `~/.keel/events.jsonl`

**Files:** `commands/drift.md`

#### 4.2 — Drift report template
- Create `templates/drift-report.md.tmpl`
- Sections: header (spec, date, scope), summary (counts per severity), then per-layer details
- Severity model: compliant (high), likely compliant (medium), diverged (high), unknown

**Files:** `templates/drift-report.md.tmpl`

#### 4.3 — Scoping support
- Parse `--scope=` argument: prd, spec, artifacts, adrs
- When scoped, only check that layer
- Default: full chain

**Files:** `commands/drift.md`

#### 4.4 — Integration with `/keel:review`
- Update `commands/review.md` to run drift check after specialist review
- Only runs if an active spec exists for the reviewed code
- Drift findings appended to review output

**Files:** `commands/review.md`

#### 4.5 — CI output format
- When `--output=json` is passed, output structured JSON instead of terminal format
- Exit code 1 if any `diverged` findings
- Exit code 0 if all `compliant` or `likely_compliant`

**Files:** `commands/drift.md`

#### 4.6 — Update install.sh
- Add `keel:drift` to install list
- Add drift report template

**Files:** `install.sh`

#### 4.7 — Tests
- Test: drift command file exists with correct structure
- Test: drift report template has required sections
- Test: drift report persisted in spec folder

**Files:** `test/run.sh`

### Completion promise
After phase 4: engineers can run `/keel:drift SPEC-NNN` and get a full-chain compliance report with confidence levels. Reports are persisted. Review includes drift check. CI can gate on drift findings.

---

## Phase 5: Observability (v4.4)

**Goal:** `/keel:status` is a real governance dashboard. Stop hook uses semantic detection.

**Requirements:** R13–R14
**Depends on:** Phase 1 (session-signals.log), Phase 2 (events.jsonl), Phase 3 (chain status), Phase 4 (drift data)

### Tasks

#### 5.1 — `/keel:status` rebuild
- Rewrite `commands/status.md` with new dashboard layout
- Sections (in order):
  1. GOVERNANCE HEALTH — rules count, agents count, decisions count, active plan
  2. ACTIVE SPEC — current spec, artifact status, last drift
  3. CHAIN STATUS — full chain from PRD through plan with statuses
  4. GATE ACTIVITY — findings and overrides this session
  5. AGENT ACTIVITY — which agents ran, how many times, what they found
  6. HOOK ACTIVITY — fire counts per hook type
  7. SIGNALS DETECTED — uncaptured ADR/doc-gap signals
- Data sources: `session-signals.log`, `events.jsonl`, plan progress tables, spec folders, installed rules list

**Files:** `commands/status.md`

#### 5.2 — Stop hook semantic detection
- Replace regex-based `templates/hooks/stop-hook.sh` with `agent` hook type
- The agent:
  1. Reads `last_assistant_message`
  2. Checks for architecture decision signals, doc gap signals, security signals
  3. For each detected signal, checks if it already exists as an ADR (read `{base}/decisions/`)
  4. Only suggests capture for genuinely new signals
  5. Returns `{"systemMessage": "..."}` with findings or `{"continue": true}` if none

**Files:** `templates/hooks/stop-hook.sh` (replaced), `templates/settings.json.tmpl` (hook type change)

#### 5.3 — Update settings.json.tmpl
- Final pass: ensure all 9 hook types are correctly configured
- SessionStart, PreToolUse, PostToolUse, Stop, PreCompact (existing)
- UserPromptSubmit, PostCompact, SubagentStop, InstructionsLoaded (new from phase 1)
- Stop hook type changed from `command` to `agent` (this phase)

**Files:** `templates/settings.json.tmpl`

#### 5.4 — Update install.sh
- Final pass: ensure all new commands, templates, and hooks are in the install list

**Files:** `install.sh`

#### 5.5 — Full test suite
- Run complete test suite
- Verify all new commands exist and have correct structure
- Verify all hooks are referenced in settings.json.tmpl
- Verify all templates exist
- Verify backwards compatibility: existing v3 projects can upgrade

**Files:** `test/run.sh`

#### 5.6 — Version bump and changelog
- Bump VERSION to 4.0
- Update CHANGELOG.md with all v4 features
- Update `.keel/config.yaml` keel_version

**Files:** `VERSION`, `CHANGELOG.md`, `.keel/config.yaml`

### Completion promise
After phase 5: `/keel:status` shows a full governance dashboard. The Stop hook uses semantic detection with no false positives. All v4 features are installed, tested, and documented. The version is 4.0.

---

## Risk Register

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Claude Code changes hook API | Breaks all new hooks | Medium | Hook scripts are defensive (exit 0 on error). Monitor Claude Code releases. |
| `agent` hook type adds too much latency | Stop hook feels slow | Medium | Test latency. Fall back to `command` type if >2s. |
| State machine feels restrictive | Users skip steps | Medium | Warnings, not hard blocks (except gates). Override is always possible. |
| Too many new commands overwhelm users | Adoption friction | Low | Commands are opt-in. `/keel:init` only installs what's relevant. |
| Event log grows unbounded | Disk usage | Low | Monthly rotation built into logging utility. |

---

## Notes

- Each phase ships as an independent release (v4.0, v4.1, v4.2, v4.3, v4.4)
- Phases are sequential — each depends on the previous
- All commands are `.md` files — INV-001 (plain markdown only) is maintained
- archway integration is an extension point, not a v4 deliverable
- Experiments (EXP-001/002/003) are enabled by data requirements but not implemented in v4
