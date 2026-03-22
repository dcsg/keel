# PRD-005: Keel v4 — Agentic Engineering Control Plane

**Status:** draft
**Date:** 2026-03-16
**Updated:** 2026-03-20 (design session complete)
**Design Session:** [[v4 Design Session — 2026-03-20]]

---

## Problem

Keel v3 is architecturally complete but operationally incomplete. The governance loop exists in pieces but doesn't close automatically. Everything is advisory — rules load, agents opine, signals fire, but nothing blocks, enforces, or gates. And there's no traceability: a decision made in an ADR has no verified connection to what Claude actually built.

The deeper problem: keel tells Claude what to do but never verifies it happened. A control plane that can only declare desired state without observing or enforcing it is a configuration file, not a control plane.

Concretely:
- 5 of 24 available Claude Code hook events are used — 19 automation opportunities unused
- Plan context is lost to compaction; recovery is manual
- Specialist agents are templates; pre-flight review, `/keel:review`, and `/keel:audit` route to agents most users never have deployed
- No mechanism to detect whether implementation drifted from what was specified in PRDs and ADRs
- No structured pre-implementation artifacts — keel has PRDs but not technical specifications, data models, or API contracts
- `/keel:status` is a text dump, not a live governance dashboard

## Users

All keel users — solo developers and teams using Claude Code for serious engineering work. Particularly:

- **Solo agentic engineers** (beachhead ICP) who own the full spec-to-implementation cycle
- **Developers running long sessions** where plan context gets lost to compaction
- **Engineering leads** who want visibility into what their agents are deciding and flagging

## Goals

- The governance chain runs as a state machine — each artifact must be accepted before the next step begins
- The governance loop runs automatically — plan context is always present, compaction recovery is zero-touch
- At least one genuine enforcement gate exists (advisory → blocking on critical findings)
- A developer can trace a decision from PRD → spec → artifacts → plan → implementation → validation
- `/keel:status` shows live governance health, not a static file dump
- Drift detection exists as a command — did we build what we decided to build?

## Non-Goals

- Multi-tool support (Claude Code only — ADR-001 stands)
- Agent teams (experimental, too early)
- Full CI integration pipeline (design for CI output, defer CI setup to v5)
- Replacing spec-kit — keel should be self-sufficient for teams that want one tool
- Decision intelligence, ontology layer, temporal analysis (designed as experiments EXP-001/002/003, not v4 scope)

## The Governance Chain State Machine

Every document in the chain has a status. You can only move forward when the previous artifact is accepted:

```
PRD (draft → accepted)
  → SPEC (draft → accepted)
    → ARTIFACTS (draft → accepted)
      → PLAN (draft → accepted)
        → execute
          → DRIFT (validates against all of the above)
```

`/keel:doctor` flags when someone tries to skip a step. Gates can enforce.

## Requirements

### Phase 1 — Close the Automation Loop (PRD-004 superseded by this)

**R1: `UserPromptSubmit` hook**
Inject the active plan phase into every prompt automatically. If no plan is active, exit silently. This is the highest-impact single change — plan tracking becomes automatic rather than something the developer has to remember to restore.

**R2: `PostCompact` hook**
Fire immediately after compaction completes. Re-inject active plan phase + all invariants as `systemMessage`. Zero-touch compaction recovery — no manual `/keel:context` required.

**R3: `SubagentStop` hook**
Log specialist agent activity (agent name, outcome summary, severity) to `~/.keel/session-signals.log` after each agent run. Surface in `/keel:status` under AGENT ACTIVITY.

**R4: `InstructionsLoaded` hook**
Log which rule packs loaded each session to `~/.keel/session-signals.log`. Surface in `/keel:status` as "Rules active this session."

**R5: Skills frontmatter on read-only commands**
Add `context: fork` + `allowed-tools` to `/keel:doctor`, `/keel:status`, `/keel:docs`. Diagnostic commands should not pollute main context and should not be able to write files.

**R6: Agent `memory: project`**
Add `memory: project` to `principal-dba` and `staff-security` templates. These agents benefit most from accumulated project-specific knowledge (schema history, auth decisions). Memory at `.claude/agent-memory/<name>/`.

### Phase 2 — Enforcement

**R7: `SubagentStop` quality gate**
Use the `agent` hook type on `SubagentStop` to gate on specialist agent output. If a specialist returns a critical finding and the project has configured that agent as a gate (`gates: [staff-security]` in `.keel/config.yaml`), block progression with the finding surfaced.

Gate UX: acknowledged block — keel asks for explicit override. Override is logged with git identity to `~/.keel/events.jsonl`. Engineers cannot disable gates — they're team-level config committed to the repo. Engineers can override individual findings with logged accountability.

```
⛔ GATE: staff-security — critical finding
   Hardcoded JWT secret in auth/handler.go:47

   This gate must be resolved before proceeding.
   Override this gate? (y/n)
   Note: override will be logged with your git identity.
```

**R8: Pre-push invariant check**
Upgrade the pre-push hook from a grep-for-secrets check to validate staged files against installed invariants. Not a full linter — a basic check that obvious invariants haven't been violated. Exit 1 on failure.

**R9: `/keel:doctor` decision graph validation**
Extend doctor's check suite to validate the decision graph:
- Do any two ADRs make contradictory decisions on the same topic?
- Do installed rules violate any invariants?
- Are there plans that depend on a superseded ADR?
- Are there invariants never referenced by any rule?
- Are there orphan artifacts (no references to or from other artifacts)?

### Phase 3 — The Spec Layer

**R10a: `/keel:spec` command**
New command. Takes an accepted PRD as input, produces a technical specification.

Config:
```yaml
specs:
  dir: docs/product/specs   # configurable, default
```

Flow:
1. Verify PRD status is `accepted` — block if draft
2. Read the PRD
3. Scan codebase — find existing architecture, hooks, agents, ADRs, invariants
4. Interview — 2-4 questions specific to what was found in the codebase (not generic). Questions prove keel understood the codebase, not just the PRD.
5. Show outline of what the spec will cover — user confirms before agents run
6. Conflict detection — flag if the spec contradicts any existing ADR
7. Route to `principal-architect` + relevant domain specialists
8. Output: `docs/product/specs/SPEC-NNN-{slug}/spec.md`

Spec frontmatter:
```yaml
---
type: spec
id: SPEC-NNN
source_prd: PRD-NNN
architecture_source: archway.yaml  # optional, for future archway integration
references:
  adrs: [ADR-001, ADR-003]
  invariants: [INV-001]
status: draft
created_at: 2026-03-20T00:00:00Z
---
```

Codebase-aware: includes an "Existing Architecture" section describing what's there before proposing changes. Not greenfield-only.

**R10b: `/keel:spec-artifacts` command**
New command. Takes an accepted spec as input, generates implementable artifacts.

Artifacts are contextual — keel scans the spec + codebase and determines which are relevant:

| If the spec mentions... | Generate |
|---|---|
| Database, models, schema, entities | `data-model.md` |
| API endpoints, routes, REST/GraphQL | `contracts/api.md` |
| gRPC, protobuf | `contracts/proto/` |
| Migrations, schema changes | `migrations.md` |
| Events, messaging, queues | `contracts/events.md` |
| Testing strategy, coverage | `test-strategy.md` |
| Config, env vars, feature flags | `config-spec.md` |

Artifacts live in the spec's folder:
```
docs/product/specs/
└── SPEC-005-v4-automation-layer/
    ├── spec.md
    ├── data-model.md
    ├── contracts/
    │   ├── api.md
    │   └── events.md
    ├── migrations.md
    └── test-strategy.md
```

Agent routing per artifact:

| Artifact | Primary agent | Secondary |
|---|---|---|
| data-model.md | principal-dba | principal-architect |
| contracts/api.md | senior-api | principal-architect |
| contracts/proto/ | senior-api | staff-engineer |
| migrations.md | principal-dba | staff-sre |
| test-strategy.md | staff-qa | staff-engineer |
| contracts/events.md | principal-architect | staff-sre |
| config-spec.md | staff-sre | staff-engineer |

Flow: show artifact list → user confirms → route each to agents → output in spec folder as `draft`.

**R11: Artifact status workflow**
All artifacts (PRDs, specs, spec-artifacts, plans) get formal status lifecycle: `draft → accepted → in-progress → implemented → superseded`.

Guard rails:
- `/keel:spec` requires PRD to be `accepted`
- `/keel:spec-artifacts` requires spec to be `accepted`
- `/keel:plan` warns if any artifacts are still `draft`
- `/keel:doctor` flags artifacts stuck in `draft` with no recent activity
- `/keel:drift` validates against `accepted` or `implemented` artifacts

### Phase 4 — Drift Detection

**R12: `/keel:drift` command**
New command. Compares desired state against current implementation across the full governance chain.

Three triggers:
- Manual: `/keel:drift SPEC-NNN`
- Automatic: part of `/keel:review`
- CI: JSON output with exit code 1 on diverged findings

Default: full chain (checks PRD acceptance criteria, spec requirements, artifact contracts, ADR compliance, invariant compliance).

Scoping:
```
/keel:drift SPEC-005                    # full chain (default)
/keel:drift SPEC-005 --scope=prd        # PRD acceptance criteria only
/keel:drift SPEC-005 --scope=spec       # spec requirements only
/keel:drift SPEC-005 --scope=artifacts  # artifact contracts only
/keel:drift SPEC-005 --scope=adrs       # ADR compliance only
```

Severity model (with confidence):
- ✅ Compliant (high confidence) — exact match verified
- 🟡 Likely compliant (medium) — can't verify deterministically
- ⚠️ Diverged (high confidence) — clear mismatch
- ❓ Unknown — not enough signal to determine

Drift reports are persisted as files for temporal analysis (EXP-003).

Routes through `principal-architect` + relevant domain specialists with git diff and spec artifacts as context.

### Phase 5 — Observability

**R13: `/keel:status` rebuilt**
Replace the current text dump with a live governance dashboard:

```
KEEL STATUS — project-name
═══════════════════════════════════════════════

GOVERNANCE HEALTH
  Rules:        4 active (code-quality, testing, security, go)
  Agents:       7 installed
  Decisions:    12 ADRs, 1 invariant
  Plan:         PLAN-007 Phase 2/4 — in progress

ACTIVE SPEC
  SPEC-005: v4.0 Automation Layer (accepted)
  Artifacts: 3/3 accepted
  Drift: not run yet — run /keel:drift SPEC-005

CHAIN STATUS
  PRD-005 accepted → SPEC-005 accepted → artifacts accepted → PLAN-007 in progress

GATE ACTIVITY (this session)
  ⛔ staff-security: 1 critical finding (resolved)
  ✅ principal-dba: no findings

AGENT ACTIVITY (this session)
  principal-architect  — ran 2x (plan pre-flight, review)
  staff-security       — ran 1x (plan pre-flight)
  senior-api           — ran 1x (review)

HOOK ACTIVITY (this session)
  UserPromptSubmit     — 14 fires (plan phase injected)
  PostToolUse          — 23 fires (auto-formatted)
  Stop                 — 8 fires (2 signals detected)
  PostCompact          — 1 fire (phase re-injected)

SIGNALS DETECTED
  💡 ADR candidate: "chose exponential backoff over fixed retry"
  📄 Doc gap: POST /webhooks/retry — new endpoint
```

**R14: Stop hook upgraded to `agent` type**
Replace regex signal detection with semantic detection via Haiku agent. The agent checks whether a detected decision already exists as an ADR before suggesting capture — eliminates false positives.

## The Traceability Chain

v4's north star: a complete artifact chain where each step feeds and validates the next.

```
/keel:prd  →  /keel:spec  →  /keel:spec-artifacts  →  /keel:plan  →  execute  →  /keel:drift
  PRD           tech spec       data model, contracts     phases        Claude       did we build
  what/why      how             implementable artifacts   + review      + hooks      what we decided?
```

Each step requires the previous to be `accepted`. Each can be validated against the next. This chain does not exist anywhere else in the agentic engineering tooling space.

## Data Requirements (for future experiments)

These are low-cost additions during v4 implementation that enable EXP-001/002/003 later:

- All artifacts get `created_at` and `status_changed_at` timestamps in frontmatter
- All artifacts get a `references:` field in frontmatter (ADRs, invariants, other artifacts)
- Consistent ID format: PRD-NNN, SPEC-NNN, ADR-NNN, INV-NNN, PLAN-NNN
- Structured event logging to `~/.keel/events.jsonl` (append-only) for every status change, gate firing, and drift report
- Each event includes `at` (ISO8601) and `by` (git identity)
- Drift reports persisted as files, not just terminal output

## User Stories

**As a developer**, I want to write a technical specification from my PRD, with keel asking me codebase-aware questions and flagging conflicts with existing ADRs before I start.

**As a developer**, I want implementable artifacts (data model, contracts, test strategy) generated from my accepted spec, reviewed by the right specialist agent for each artifact type.

**As a developer in a long session**, I want the active plan phase present in every prompt so I never lose track of where I am even after compaction.

**As a developer**, after compaction I want keel to automatically restore my plan context without me having to manually run `/keel:context`.

**As an engineering lead**, I want to see the full governance chain status (PRD → spec → artifacts → plan) at a glance, with gate activity and agent findings visible.

**As a developer**, after implementing a feature I want a drift report showing whether the implementation matches the spec, PRD, and ADRs — with confidence levels and actionable items.

**As a team using security gates**, I want staff-security critical findings to block progression until addressed, with override requiring explicit acknowledgment logged to my git identity.

## Acceptance Criteria

- [ ] Governance chain state machine enforced: PRD accepted before spec, spec accepted before artifacts, artifacts accepted before plan
- [ ] `/keel:spec` interviews with codebase-aware questions, shows outline before generating, flags ADR conflicts
- [ ] `/keel:spec-artifacts` generates contextual artifacts with per-artifact agent routing
- [ ] `UserPromptSubmit` injects active phase; silent when no plan active
- [ ] `PostCompact` re-injects phase + invariants automatically
- [ ] `SubagentStop` logs agent activity; visible in `/keel:status`
- [ ] Quality gates block with acknowledged override; overrides logged with git identity
- [ ] `/keel:drift` checks full chain by default with scoping options; severity includes confidence levels
- [ ] `/keel:status` shows chain status, gate activity, agent activity, hook activity, signals
- [ ] All artifacts have `created_at`, `references:`, and consistent ID format
- [ ] Events logged to `~/.keel/events.jsonl`
- [ ] `bash test/run.sh` passes on all phases

## Release Phasing

| Release | Theme | Scope |
|---|---|---|
| v4.0 | Automation Layer | R1–R6 (hooks + agent memory + skills frontmatter) |
| v4.1 | Enforcement | R7–R9 (quality gate + pre-push + doctor graph) |
| v4.2 | Spec Layer | R10a, R10b, R11 (/keel:spec + /keel:spec-artifacts + status workflow) |
| v4.3 | Drift Detection | R12 (/keel:drift — full chain, scoped, CI output) |
| v4.4 | Observability | R13–R14 (status rebuild + semantic Stop hook) |

## Open Questions (resolved in design session)

- ~~Should `/keel:spec` be a subcommand of `/keel:prd` or a standalone command?~~ → Standalone.
- ~~Quality gate UX?~~ → Acknowledged block with logged override (Option B).
- ~~`/keel:drift` without spec?~~ → Falls back to PRD-only comparison, warns about limited coverage.
- ~~Additional agents with `memory: project`?~~ → Start with principal-dba and staff-security, expand based on usage.

## Extension Points (designed, not implemented in v4)

- **archway integration:** `architecture_source:` field in spec frontmatter. When `archway.yaml` exists, `/keel:spec` reads component boundaries. `/keel:drift` feeds `archway check` for deterministic validation.
- **CI integration:** `/keel:drift` outputs JSON with exit codes. Design the format, defer CI pipeline setup to v5.
- **Custom artifact types:** teams may need types beyond defaults (runbook.md, rollout-plan.md). Allow custom definitions in config.
- **Experiments:** EXP-001 (decision intelligence), EXP-002 (ontology layer), EXP-003 (temporal analysis) — all enabled by the data requirements above.

## Related Documents

- Design Session: `v4 Design Session — 2026-03-20.md`
- Brand Positioning: `Brand Positioning — Locked.md`
- Experiments: `docs/experiments/EXP-001`, `EXP-002`, `EXP-003`
- Supersedes: PRD-004 (Claude Code Surface Expansion)

---

*Written by keel:prd — 2026-03-16. Updated 2026-03-20 after design session.*
