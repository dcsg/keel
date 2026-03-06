# Plan: Governance Hardening

## Overview
**Total Phases:** 4
**Approach:** Sequential — each phase unlocks correctness for the next

Fix real bugs found during dogfooding: invariant misplacement, hardcoded paths,
missing plan consolidation, and no health-check command. Defer nice-to-haves
(rule versioning, context depth) to a future plan.

## Phase Summary

| Phase | Task | Status | Effort |
|-------|------|--------|--------|
| 1 | Fix invariant placement in intake | Done | Low |
| 2 | Config-aware paths in status + context | Done | Low |
| 3 | Intake improvements — PLAN consolidation + archive | Done | Medium |
| 4 | keel:doctor command | Done | Medium |

---

## Phase 1: Fix Invariant Placement in Intake

**Objective:** Invariants go to `docs/invariants/`, not `.claude/rules/`.

**Problem:** `commands/intake.md` line 118 directs invariants into `.claude/rules/`
as custom topics. Invariants are business constraints (what must never happen),
not coding rules (how to write code). Different audience, different lifecycle.

**Tasks:**
1. In `commands/intake.md`, change the invariants handling (around line 118):
   - **Before:** "Invariants: offer to convert into `.claude/rules/` custom topics"
   - **After:** "Invariants: copy to `docs/invariants/` (or `{base}/invariants/`
     from config). Add a one-line reference in the relevant `.claude/rules/` file
     if the invariant constrains code behavior."
2. Update the output summary section to list `docs/invariants/` as a target
3. Verify `commands/context.md` already reads from `docs/invariants/` (it does)

**Completion promise:** `commands/intake.md` places invariants in `docs/invariants/`,
never in `.claude/rules/`.

**Tests:** Run `./test/run.sh` — structure tests still pass.

---

## Phase 2: Config-Aware Paths in Status + Context

**Objective:** Commands read directory paths from `.keel/config.yaml` instead of
hardcoding them.

**Problem:** `commands/status.md` and `commands/context.md` hardcode
`docs/decisions/`, `docs/invariants/`, `docs/product/`. If a project sets
`base: documentation` in config, these commands silently find nothing.

**Tasks:**
1. In `commands/status.md`:
   - Read `base:` from `.keel/config.yaml` (default: `docs`)
   - Replace hardcoded `docs/decisions/` with `{base}/decisions/`
   - Replace hardcoded `docs/invariants/` with `{base}/invariants/`
   - Replace hardcoded `docs/product/` with `{base}/product/`
2. In `commands/context.md`:
   - Same substitutions — read `base:` and derive paths
3. In `commands/intake.md`:
   - Use `{base}/` prefix for all output directories

**Completion promise:** All 3 commands resolve paths from config. Hardcoded `docs/`
only appears as the default fallback.

**Tests:** Run `./test/run.sh`.

---

## Phase 3: Intake Improvements — PLAN Consolidation + Archive

**Objective:** Intake detects plan-like documents and offers to consolidate them
into `PLAN-*.md` format. After all moves, offer to archive originals.

**Problem:** Intake scatters execution plans across multiple files without
consolidating. After intake, originals are duplicated with no cleanup path.

**Tasks:**

### 3a: PLAN consolidation
1. After the categorization step in `commands/intake.md`, add plan detection:
   - Identify files that contain phases, milestones, roadmaps, checklists, or
     progress tracking
   - Present a consolidation prompt:
     ```
     Found {N} plan-related docs that could consolidate into PLAN-001-{slug}.md.
     Proceed? (consolidate / keep-separate / skip)
     ```
   - If consolidating: generate a PLAN file with phases table derived from the
     source files, place in `{base}/plans/`

### 3b: Archive step
2. After all file operations, add a cleanup prompt:
   ```
   Original files preserved. Options:
     [a] Archive originals to {base}/archive/
     [d] Delete originals (confirm twice)
     [k] Keep both (default)
   ```
3. If archiving: `mkdir -p {base}/archive/` and move originals there

**Completion promise:** Intake offers PLAN consolidation for plan-like docs and
archive/cleanup for all originals.

**Tests:** Run `./test/run.sh`.

---

## Phase 4: keel:doctor Command

**Objective:** Single command to validate the entire governance setup.

**Problem:** After init, migrate, or intake, users have no way to verify everything
is wired correctly. Issues (missing files, broken hooks, stale rules) are discovered
only when something fails.

**Tasks:**
1. Create `commands/doctor.md` with these checks:
   - `.keel/config.yaml` exists and is valid YAML
   - `{base}/soul.md` exists
   - `{base}/decisions/` — count ADRs
   - `{base}/invariants/` — count INVs
   - `.claude/rules/` — count installed packs
   - `CLAUDE.md` has keel sentinel block
   - `.claude/settings.json` has PreToolUse + PreCompact hooks
   - Active `PLAN-*.md` exists (warning if missing)
   - `{base}/product/spec.md` exists (warning if missing)
2. Output format:
   ```
   keel:doctor
     [ok] .keel/config.yaml valid
     [ok] docs/soul.md exists
     [ok] docs/decisions/ — 3 ADRs
     [ok] .claude/rules/ — 5 packs installed
     [!!] No active PLAN-*.md found
     [!!] docs/product/spec.md missing

   2 warnings — run /keel:intake to onboard missing docs
   ```
3. All path checks must use config-aware paths (depends on Phase 2)
4. Register in test suite — add doctor to structure tests

**Completion promise:** `/keel:doctor` validates governance setup and reports
actionable warnings.

**Tests:** Run `./test/run.sh` — new doctor command passes structure checks.

---

## Deferred (Future Plan)

| Item | Reason to defer |
|------|----------------|
| Rule pack versioning (P5) | High effort, needs registry schema change + update command |
| Context depth control (P6) | Medium effort, needs task-relevance heuristics |

These are genuine improvements but don't block correctness. Ship governance
hardening first, revisit in PLAN-003.
