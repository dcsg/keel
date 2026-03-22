# Plan: Context Engineering Refinement + Template Quality + Extensibility

## Overview
**Task:** Apply context engineering research, improve template quality, add extensibility model, configurable paths, reports folder, and fix init bugs.
**Source:** Context Injection research, template design session (2026-03-20), ADR-006, init bug report
**Total Phases:** 6
**Created:** 2026-03-20

## Progress

| Phase | Theme | Status | Updated |
|-------|-------|--------|---------|
| 1 | Template quality (PRD, ADR, invariant, spec, compile) | not started | — |
| 2 | Configurable paths + reports folder | not started | — |
| 3 | Extensibility model (ADR-006) | not started | — |
| 4 | Command instruction reduction | not started | — |
| 5 | Primacy + recency systematization | not started | — |
| 6 | Init bug fixes + polish | not started | — |

**IMPORTANT:** Update this table as phases complete.

## Context

### Research findings that apply

From `30 - Resources/Context Injection/`:

1. **Instruction compliance decay** (Science of Context Injection, lines 124-152):
   - 15-25 instructions: ~80-90% compliance
   - 50+ instructions: ~60-70% compliance
   - Agentic scenarios: <30% perfect compliance
   - keel commands are 50-70 instructions each — 3-4x the sweet spot

2. **Phrasing consistency matters more than task complexity** (lines 82-88):
   - IFEval++: 18-31% compliance swing with rephrasing alone
   - Consistent phrasing across commands is not implemented

3. **Primacy + recency bias** (lines 148-152):
   - First and last instructions get highest attention
   - Middle instructions ignored 20-30% of the time
   - keel buries critical logic in the middle of commands

4. **Token budget for governance** (IDL Deep Dive, lines 159-169):
   - IDL targets <14K tokens total for governance context
   - keel's compiled governance has no size limit

5. **Three-tier knowledge infrastructure** (Compilers research, lines 249-265):
   - Hot memory (always loaded), warm memory (session-loaded), cold memory (on-demand)
   - keel loads all invariants always — should be selective

6. **ADR/invariant discovery not designed** (keel-shared-infrastructure.md, lines 62-69):
   - "Which ADRs are relevant to what I'm editing?" — unsolved
   - Path-scoped loading (like archway's globs) should apply to governance docs

### Current template gaps

**PRD template:**
- No structured frontmatter in the generated output section
- Acceptance criteria not structured for drift detection consumption
- No "what makes a good PRD" guardrail (like invariant has "what makes a good invariant")

**Spec template:**
- Outline confirmation step is good but comes late (step 5 of 8)
- "Existing Architecture" section is good but needs guidance on depth
- No constraint on spec length

**ADR template:**
- "With/Without arguments" branching adds cognitive load
- The distinction between ADR and rule is critical but buried
- No guidance on ADR scope (too broad = useless, too narrow = noise)

**Invariant template:**
- "What Makes a Good Invariant" (lines 23-31) is excellent but not reinforced at the end
- No examples of BAD invariants (what NOT to capture)
- Status field uses "active" but the research shows invariants should have enforcement level

**Compiled governance output:**
- No instruction count limit
- No primacy/recency structure in the compiled output
- No token budget enforcement

---

## Phase 4: Command Instruction Clarity (reframed from "reduction")

**Goal:** Bring every command within the 15-25 instruction sweet spot, or split into focused sub-commands.

### Tasks

#### 1.1 — Audit and count instructions per command
For each command file in `commands/`, count:
- Total instruction blocks (### sections + bullet points with "do X" directives)
- Branching points (if/then logic)
- Template sections (inline templates that could be externalized)
Document the count and identify reduction targets.

#### 1.2 — Externalize artifact templates from spec-artifacts
The `commands/spec-artifacts.md` has 8 inline artifact templates (~400 tokens of repetition). Move them to `templates/artifacts/` as separate files. The command references them instead of inlining.

Reduces spec-artifacts from ~58 instructions to ~20.

**Files:** `commands/spec-artifacts.md`, `templates/artifacts/*.md.tmpl`

#### 1.3 — Restructure /keel:plan for compliance
Plan is the longest command (70+ instructions) and the most critical. Options:
- **Option A:** Split into `/keel:plan-interview` + `/keel:plan-generate`
- **Option B:** Externalize the pre-flight review logic into a reusable template
- **Option C:** Reduce inline instructions by removing procedural steps that Claude already knows

Decide which approach, then implement.

**Files:** `commands/plan.md` (and possibly new command files)

#### 1.4 — Reduce /keel:compile, /keel:drift, /keel:spec
Apply the same reduction pattern:
- Move procedural steps to comments (Claude doesn't need "read the file" instructions)
- Consolidate branching (with/without arguments) into simpler patterns
- Externalize output format templates

**Files:** `commands/compile.md`, `commands/drift.md`, `commands/spec.md`

#### 1.5 — Add instruction count to /keel:doctor
Doctor should warn when a command or rule pack exceeds the sweet spot:
```
[!!] commands/plan.md has 70 instruction blocks (recommendation: <25)
```

**Files:** `commands/doctor.md`

### Completion promise
After phase 1: every command is within or close to the 15-25 instruction sweet spot. Doctor warns on bloat.

---

## Phase 1: Template Quality (Design Session Locked)

**Goal:** Improve the quality of all generated artifacts based on template design session (2026-03-20) and research findings.

### Tasks

#### 1.1 — PRD template improvements
Based on design session decisions:
- Add numbered requirements: `FR-001: {requirement} [MUST]` with RFC 2119 language
- Add structured acceptance criteria: `AC-001: {criterion} — Verify: {method}`
- Add `author:` and `stakeholders:` to frontmatter
- Add priority levels on user stories (P1/P2/P3)
- Add NEEDS CLARIFICATION markers for gaps instead of inventing details
- Add "what makes a good PRD" guardrail at the start

**Files:** `commands/prd.md`

#### 1.2 — ADR template improvements
Based on design session decisions (adopting MADR structure):
- Add **Confirmation** section — how to verify the decision was followed (feeds `/keel:drift`)
- Add **Decision Drivers** — prioritized list of concerns before the decision
- Reframe Context as a question: "How should we {the decision question}?"
- Add `decision-makers:` and `supersedes:` to frontmatter
- Add ADR scope guidance: one decision, max 2 pages, if longer it's a spec
- Move "ADR vs rule" distinction to start AND end (primacy + recency)
- Add bad examples of what is NOT an ADR

**Files:** `commands/adr.md`

#### 1.3 — Invariant template improvements
Based on design session decisions:
- Add `severity: critical | high` to frontmatter
- Add `scope: "**/*"` (path glob) to frontmatter for future selective loading
- Add **Violation Consequences** — concrete blast radius, not just rationale
- Add **Verification** — automated check + manual review method (feeds drift + pre-push)
- Add **Exceptions** — zero-tolerance or overridable with approval
- Add **Related** — ADRs, specs, incidents that established this
- Reinforce "What Makes a Good Invariant" at end (recency)
- Add bad examples: "This is NOT an invariant" (preferences belong in guidelines)

**Files:** `commands/invariant.md`

#### 1.4 — Spec template improvements
Based on design session decisions:
- Add **Non-Goals** section — explicit scope exclusions
- Add **Context** section — why this spec exists now (engineering context beyond PRD)
- Restructure Trade-offs as **Alternatives Considered** with pros/cons/rejection reason
- Add **Risks & Mitigations** with rollback plans
- Add spec-level **Acceptance Criteria** (AC-001 format with verification methods)
- Add NEEDS CLARIFICATION markers for unknowns
- Add `author:` and `implements:` (replaces `source_prd:`) to frontmatter
- Move outline confirmation earlier (step 3, not step 5)
- Add spec length guidance: 200-400 lines, split if longer

**Files:** `commands/spec.md`

#### 1.5 — Compiled governance improvements
Based on design session decisions:
- **Invariants first AND last** — primacy + recency for non-negotiable constraints
- Severity hierarchy: invariants labeled "non-negotiable", guidelines clearly softer
- Directive and token count in compiled output header
- **Warn (not block) if >30 directives** — "⚠️ 42 directives compiled. Anthropic recommends keeping context minimal for optimal compliance."
- Token budget awareness in header

**Files:** `commands/compile.md`

### Completion promise
After phase 1: all generated artifacts follow research-validated patterns, are structured for downstream consumption (drift detection, compile), and include verification methods.

---

## Phase 2: Configurable Paths + Reports Folder

**Goal:** All folder paths configurable via `.keel/config.yaml`. New `docs/reports/` for keel-generated outputs.

### Tasks

#### 2.1 — Unified paths config
Replace scattered path configs with a single `paths:` section:

```yaml
paths:
  decisions: docs/architecture/decisions
  invariants: docs/architecture/invariants
  plans: docs/plans
  specs: docs/product/specs
  prds: docs/product/prds
  guidelines: docs/guidelines
  reports: docs/reports
  soul: docs/soul.md
```

All with sensible defaults derived from `base:`. All commands read from this config.

**Files:** all commands that read paths, `commands/init.md`

#### 2.2 — Reports folder
Create `docs/reports/` for keel-generated outputs:
- Drift reports (currently in spec folder — move here)
- Audit reports (currently not saved — start saving)
- Review reports (currently not saved — start saving)
- Session summaries (currently not saved — start saving)

Update commands that generate reports: drift, audit, review, session.
Update init to create the reports directory.

**Files:** `commands/drift.md`, `commands/audit.md`, `commands/review.md`, `commands/session.md`, `commands/init.md`

#### 2.3 — Update all commands to use paths config
Every command that reads a path should resolve it from `paths:` config with fallback to defaults. No hardcoded paths.

**Files:** all `commands/*.md`

### Completion promise
After phase 2: all paths are configurable, reports have a dedicated folder, no hardcoded paths in any command.

---

## Phase 3: Extensibility Model (ADR-006)

**Goal:** Teams can customize templates, agents, and rules without forking keel.

### Tasks

#### 3.1 — Template override (lookup-order)
Commands check `.keel/templates/{name}.md` before falling back to keel defaults.

Add to init:
```yaml
templates:
  dir: .keel/templates
```

Update all artifact-generating commands (prd, adr, invariant, spec, spec-artifacts, compile) to check the override path first.

**Files:** all artifact-generating commands, `commands/init.md`

#### 3.2 — Agent customization (marker-based)
Add `<!-- keel:custom -->` marker support. Upgrade skips files with this marker.

Add to config:
```yaml
agents:
  custom:
    - principal-dba
    - my-team-reviewer
```

Update `/keel:upgrade` to check both marker and config before overwriting.
Update `/keel:doctor` to report custom vs default agents.

**Files:** `commands/upgrade.md`, `commands/doctor.md`

#### 3.3 — Rule extension (override or extend)
Override: `.keel/rules/{name}.md` replaces the built-in pack.
Extend: `extend:` config appends to the built-in pack.

```yaml
rules:
  go:
    include: all
    extend: .keel/rules/go-extensions.md
```

Update rule installation logic in init and rules-update.
Update `/keel:doctor` to report overridden, extended, and default rules.

**Files:** `commands/init.md`, `commands/rules-update.md`, `commands/doctor.md`

### Completion promise
After phase 3: teams can override templates, customize agents (surviving upgrades), and extend rule packs — all via config and git-committed files.

---

## Phase 5: Primacy + Recency Systematization

**Goal:** Every command and template follows the research-validated placement pattern: critical rules at start + end, procedural steps in the middle.

### Tasks

#### 3.1 — Define the command structure pattern
Document the standard pattern for all keel commands:

```
# Command Name

CRITICAL: {the one thing that must not go wrong}
{1-2 sentences defining the key distinction or guardrail}

## Instructions
{procedural steps}

---
REMEMBER: {restate the critical guardrail from the top}
```

**Files:** documentation / convention

#### 3.2 — Apply pattern to all commands
Go through each command and restructure:
- Move critical logic to the top (before step 1)
- Add recency reinforcement at the bottom (after confirmation)
- Keep procedural steps in the middle

**Files:** all `commands/*.md`

#### 3.3 — Apply pattern to rule packs
Audit each rule pack for primacy/recency:
- Most critical rules at start and end
- Moderate rules in the middle
- Consistent phrasing across all packs (IFEval++ finding)

**Files:** `templates/rules/**/*.md`

#### 3.4 — Phrasing consistency audit
Ensure all commands use consistent phrasing:
- "Read X" not sometimes "Check X" and sometimes "Load X"
- "Output Y" not sometimes "Generate Y" and sometimes "Create Y"
- "If Z is missing" not sometimes "When Z doesn't exist"

Document the canonical phrasing in a style guide.

**Files:** all `commands/*.md`, all `templates/rules/**/*.md`

### Completion promise
After phase 3: every command and template follows the primacy + recency pattern with consistent phrasing.

---

## Phase 6: Init Bug Fixes + Polish

**Goal:** Fix known bugs in `/keel:init` and polish the first-run experience.

### Tasks

#### 4.1 — Document init bugs
Open a fresh project and run `/keel:init`. Document every issue:
- Interview flow: does it ask the right questions?
- Rule selection: does it infer correctly from the description?
- File generation: are all files created correctly?
- Hooks: are all 9 hooks installed?
- Edge cases: what happens with an empty description? A one-word description?

#### 4.2 — Fix interview bugs
Based on 4.1 findings, fix the interview flow. Known issue: "the interview is buggy" — investigate and fix.

**Files:** `commands/init.md`

#### 4.3 — Polish first-run experience
The init should feel magical:
- Description → inferred architecture → rules selected → everything installed → "what do you want to build?"
- No friction, no confusion, no errors
- The "aha moment" from the solo engineer guide should be reproducible

**Files:** `commands/init.md`

#### 4.4 — Run full test suite + e2e
- `bash test/run.sh` — all suites pass
- E2e test on a fresh project (like the tmp/keystone experiment)
- Manual test: open archway or another real project, run init, verify

### Completion promise
After phase 4: init works reliably, the first-run experience is polished, all tests pass.

---

## Notes

- Phase 1 and 2 can run in parallel — instruction reduction is independent from template quality
- Phase 3 depends on phases 1 and 2 (restructured commands need the pattern applied)
- Phase 4 can start anytime — init bugs are independent
- All changes must pass `bash test/run.sh`
- Reference the research documents in Obsidian for specific data points
