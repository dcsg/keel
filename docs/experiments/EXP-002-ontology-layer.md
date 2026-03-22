# EXP-002: Ontology Layer — Typed Artifacts with Queryable Relationships

**Status:** planned
**Prerequisites:** v4 shipped, 10+ specs and 15+ ADRs in the system
**Created:** 2026-03-20

---

## Hypothesis

If every keel artifact (PRD, spec, ADR, invariant, plan, drift report) is a typed object with explicit relationships to other artifacts, engineers can perform impact analysis before making decisions — and keel can prevent downstream breakage automatically.

## Why This Matters

Right now keel's artifacts are files with implicit relationships. A spec references a PRD via `source_prd:` in frontmatter. An ADR is referenced in a spec's prose, not in structured data. The relationships exist in the engineer's head.

This breaks in two ways:
1. **Superseding an ADR** — you don't know what specs, plans, or rules depend on it until something breaks
2. **Understanding a spec's full context** — you have to manually read every ADR to know which ones are relevant

An ontology layer makes every relationship explicit and queryable.

## What It Would Enable

### Impact analysis
```
/keel:impact ADR-004

ADR-004 is referenced by:
  SPEC-005 (extends: opt-in gates)
  PLAN-007 (phase 2: enforcement)
  3 agent templates (advisor constraint)
  /keel:review routing logic

Impact: high — superseding ADR-004 requires
updating 1 spec, 1 plan, 3 templates, 1 command.
```

### Dependency queries
```
/keel:depends SPEC-005

SPEC-005 depends on:
  PRD-005 (source)
  ADR-001, ADR-003, ADR-004, ADR-005 (architectural constraints)
  INV-001 (invariant: plain markdown only)

SPEC-005 is depended on by:
  PLAN-007 (execution plan)
  3 artifacts (hooks.md, agent-memory.md, test-strategy.md)
  DRIFT-005 (validation report)
```

### Orphan detection
```
/keel:doctor

  ⚠️ ADR-002 (sentinel comments) is not referenced by any
     active spec or plan. Consider: still relevant or superseded?
  ⚠️ INV-001 is not enforced by any rule pack.
     No .claude/rules/ file checks for compiled code.
```

### Conflict detection
```
/keel:spec PRD-009

  ⚠️ This spec proposes event-driven architecture.
     ADR-001 specifies "no runtime dependencies."
     An event bus (Kafka, RabbitMQ) is a runtime dependency.
     Resolve this conflict before proceeding.
```

## Data Model

Each artifact gets a `references:` block in frontmatter:

```yaml
---
type: spec
id: SPEC-005
source_prd: PRD-005
references:
  adrs: [ADR-001, ADR-003, ADR-004, ADR-005]
  invariants: [INV-001]
status: accepted
created_at: 2026-03-20
---
```

The ontology is built by:
1. Parsing frontmatter `references:` fields (explicit)
2. Scanning prose for `ADR-NNN`, `PRD-NNN`, `INV-NNN` mentions (implicit)
3. Following the chain: PRD → spec → artifacts → plan → drift

Relationships are typed:
- `source` — this artifact was created from that one (PRD → spec)
- `depends_on` — this artifact assumes that decision holds (spec → ADR)
- `extends` — this artifact modifies that decision (spec extends ADR-004)
- `validates` — this artifact checks that one (drift → spec)
- `enforces` — this rule implements that constraint (rule → invariant)

## Experiment Design

### Phase 1: Manual annotation (during v4)
- Add `references:` to all new artifacts created via v4 commands
- Retroactively add `references:` to existing ADRs and PRDs
- No querying yet — just data capture

### Phase 2: Query prototype (after 15+ artifacts)
- Build `/keel:impact` as a command that reads frontmatter and builds the graph
- Build `/keel:depends` for dependency queries
- Add orphan detection to `/keel:doctor`

### Phase 3: Automated relationship detection
- When `/keel:spec` generates a spec, automatically populate `references:` by scanning which ADRs and invariants are relevant
- When `/keel:drift` runs, automatically check referenced ADRs for compliance

## Success Criteria

- **Proceed:** impact analysis catches at least 1 real downstream breakage that would have been missed. Engineers use `/keel:impact` before superseding decisions.
- **Iterate:** relationships are correct but queries aren't useful enough. Improve query UX.
- **Kill:** the graph is too sparse or too noisy to provide value. Relationships are better tracked informally.

## v4 Requirement

For this experiment to be possible later, v4 artifacts must include:
- `references:` field in frontmatter (can be empty initially)
- Consistent ID format across all artifact types (PRD-NNN, SPEC-NNN, ADR-NNN, INV-NNN, PLAN-NNN)

---

*Experiment designed during v4 design session — 2026-03-20*
