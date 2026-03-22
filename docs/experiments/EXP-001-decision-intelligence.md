# EXP-001: Decision Intelligence — Do Governance Patterns Predict Drift?

**Status:** planned
**Prerequisites:** v4 shipped, 10+ specs through the full governance chain
**Created:** 2026-03-20

---

## Hypothesis

Projects that follow the full governance chain (PRD → spec → artifacts → plan) with all statuses accepted before proceeding have measurably lower drift rates than projects that skip steps.

Secondary hypothesis: specific patterns in the governance data (open questions at acceptance, gate override frequency, pre-flight vs. review timing) are reliable predictors of drift.

## Why This Matters

If governance patterns predict drift, keel can surface risk before it materializes — not as a generic warning but as a data-backed signal from your own project's history. This turns keel from reactive governance (enforce + detect) into predictive governance (warn before it happens).

## Prerequisites

- v4 state machine shipped and in use
- At least 10 specs have gone through the full chain (PRD → spec → artifacts → plan → execute → drift)
- Drift reports are persisted as files, not just terminal output
- Gate overrides are structured in logs (not just text)
- All artifacts have `created_at` and `status_changed_at` timestamps

## What to Measure

### Per-spec metrics
- Drift rate: % of requirements that diverge at `/keel:drift`
- Open questions at spec acceptance: count
- Artifacts accepted before planning: yes/no
- Pre-flight review run: yes/no
- Gate findings count and severity
- Number of contributing engineers
- Spec complexity: requirement count, artifact count

### Correlation analysis
- Drift rate vs. open questions at acceptance
- Drift rate vs. artifacts-accepted-before-planning
- Drift rate vs. pre-flight-included
- Time to resolve gate findings: pre-flight vs. review vs. drift
- Override frequency per engineer vs. downstream drift

### Agent effectiveness
- Which agent findings predict drift vs. which are noise
- False positive rate per agent
- Time savings: pre-flight catch vs. review catch vs. drift catch

### Organizational patterns (if multi-project)
- ADR capture method (session sweep vs. ad hoc) vs. ADR longevity
- Decision quality by capture context

## Experiment Design

### Phase 1: Data collection (passive)
- Add timestamps to all artifact frontmatter in v4
- Persist drift reports as files
- Structure gate override logs
- No analysis, just collect

### Phase 2: Pattern detection (after 10 specs)
- Run correlation analysis on collected data
- Identify top 3 strongest predictors of drift
- Calculate statistical significance

### Phase 3: Surface patterns (if significant)
- Add a `/keel:insights` command that queries governance history
- Surface patterns as signals in `/keel:status`
- Risk score on new specs based on historical patterns

## Success Criteria

- **Proceed to product:** patterns are detectable and actionable from 10 specs of data. At least 2 predictors have >0.5 correlation with drift rate.
- **Iterate:** patterns exist but are weak. Collect more data, revisit at 25 specs.
- **Kill:** data is too noisy, no meaningful correlation. Governance chain value is in enforcement, not prediction.

## What This Could Become

If the experiment succeeds:

```
SPEC-008 RISK ASSESSMENT
  Drift risk: HIGH (73%)

  Factors:
    ⚠️ 4 open questions unresolved (historical: 80% drift rate)
    ⚠️ No principal-dba in pre-flight (historical: 60% drift on DB specs)
    ✅ All artifacts accepted (historical: 20% drift rate)

  Recommendation: resolve open questions, add DBA pre-flight.
  Projected risk after: 31%.
```

## Related Concepts

- **Ontology layer:** typed objects (PRD, spec, ADR, plan) with computed relationships and properties — prerequisite for efficient querying
- **Temporal analysis:** governance health as a time-series, not a point-in-time snapshot — enables trend detection

---

*Experiment designed during v4 design session — 2026-03-20*
