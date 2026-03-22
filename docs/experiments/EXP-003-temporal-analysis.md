# EXP-003: Temporal Analysis — Governance Health as a Time-Series

**Status:** planned
**Prerequisites:** v4 shipped, 30+ days of governance data, 5+ drift reports
**Created:** 2026-03-20

---

## Hypothesis

Tracking governance events over time reveals whether governance is improving, stagnating, or degrading — and provides evidence-based answers to "is keel actually helping?" that point-in-time snapshots cannot.

## Why This Matters

`/keel:status` shows the current state. It can't answer:
- Are we getting better or worse?
- Did enabling pre-flight review actually reduce drift?
- Is our gate override rate trending up (governance fatigue)?
- How long does it take decisions to go from captured to enforced?
- Which phase of the chain is our bottleneck?

Engineering leads need trend data to justify governance investment. "Drift rate dropped 58% over 30 days" is a better answer than "it feels better."

## What It Would Enable

### Governance trends
```
/keel:trends

GOVERNANCE TRENDS — last 30 days
─────────────────────────────────────────
Drift rate:        12% → 8% → 5%        ↓ improving
Gate findings:     7 → 4 → 2            ↓ improving
Override rate:     43% → 25% → 0%       ↓ improving
Spec velocity:     1 spec/2wk           → stable
Avg spec-to-plan:  4.2 days             → stable
Decision debt:     3 uncaptured signals  ↑ watch

INSIGHT: drift rate dropped after pre-flight review
was enabled on 2026-03-10. Pre-flight catches findings
3.2 days earlier than review on average.
```

### Chain throughput
```
/keel:trends --chain

CHAIN THROUGHPUT — last 90 days
─────────────────────────────────────────
PRD → accepted:       avg 1.5 days
accepted → spec:      avg 2.1 days
spec → artifacts:     avg 0.5 days
artifacts → plan:     avg 1.2 days
plan → execute:       avg 4.8 days   ← bottleneck
execute → drift:      avg 0.3 days

INSIGHT: execution is the bottleneck. Specs and
artifacts flow quickly but implementation stalls.
Consider breaking plans into smaller phases.
```

### Before/after analysis
```
/keel:trends --compare "pre-flight enabled"

BEFORE pre-flight (5 specs):
  Drift rate: 34% avg
  Gate findings at review: 4.2 avg
  Critical findings in prod: 1

AFTER pre-flight (5 specs):
  Drift rate: 8% avg
  Gate findings at review: 0.8 avg
  Critical findings in prod: 0

CONCLUSION: pre-flight review reduces drift by 76%
and catches 81% of findings earlier in the cycle.
```

### Team patterns (ICP 2 — engineering lead)
```
/keel:trends --team

PER-ENGINEER GOVERNANCE — last 30 days
─────────────────────────────────────────
daniel:  8 specs, 5% drift, 0 overrides
marcus:  3 specs, 12% drift, 1 override
elena:   5 specs, 7% drift, 0 overrides

INSIGHT: marcus' higher drift correlates with
skipping artifact acceptance before planning
(2 of 3 specs). Not a performance issue —
a process issue.
```

## Data Requirements

### Events to track (with timestamps)
- Artifact created (type, id, timestamp)
- Status changed (artifact, old status, new status, timestamp, who)
- Gate fired (agent, severity, finding, resolved/overridden, timestamp, who)
- Drift report generated (spec, compliant count, diverged count, timestamp)
- Agent invoked (agent, context, findings count, timestamp)
- Signal detected (type, captured/ignored, timestamp)
- Hook fired (hook type, count per session, timestamp)

### Storage
- `~/.keel/events.jsonl` — append-only event log, one JSON object per line
- Each event: `{"type": "status_change", "artifact": "SPEC-005", "from": "draft", "to": "accepted", "at": "2026-03-20T14:23:00Z", "by": "daniel@dcsg.me"}`
- Rotated monthly (archive to `events-2026-03.jsonl`)

### Querying
- `/keel:trends` reads the event log and computes aggregates
- No database needed — JSONL is sufficient for single-project, single-team scale
- If multi-repo needed later, events could push to a central store

## Experiment Design

### Phase 1: Event logging (during v4)
- Add event emission to every status change, gate firing, and drift report
- Write to `~/.keel/events.jsonl`
- No querying yet — just log

### Phase 2: Basic trends (after 30 days of data)
- Build `/keel:trends` command
- Show drift rate, gate findings, override rate over time
- Simple: count events per week, compute rates

### Phase 3: Insights (after 60 days)
- Add before/after comparison
- Add chain throughput analysis
- Add per-engineer patterns (for team leads)
- Add bottleneck detection

## Success Criteria

- **Proceed:** trends are visible and actionable after 30 days. At least one insight leads to a process change (e.g., "enable pre-flight review" or "break plans into smaller phases").
- **Iterate:** data is there but the visualization or aggregation needs improvement. Refine queries.
- **Kill:** governance events are too sparse to show meaningful trends at single-team scale. Reconsider at larger scale.

## v4 Requirement

For this experiment to be possible later, v4 must:
- Emit structured events for every status change, gate firing, and drift report
- Write events to `~/.keel/events.jsonl` (append-only)
- Include `at` (ISO8601 timestamp) and `by` (git identity) in every event
- `/keel:status` already reads `session-signals.log` — extend to read `events.jsonl`

## Relationship to Other Experiments

- **EXP-001 (Decision Intelligence):** temporal analysis provides the raw data that decision intelligence uses for pattern detection and risk scoring
- **EXP-002 (Ontology Layer):** temporal analysis tracks how relationships change over time (ADR superseded, spec dependency added/removed)

The three experiments form a stack:
```
EXP-001: Decision Intelligence (prediction)
    ↑ consumes patterns from
EXP-003: Temporal Analysis (trends)
    ↑ queries events across
EXP-002: Ontology Layer (relationships)
    ↑ structures
v4: Governance Chain (artifacts + state machine)
```

---

*Experiment designed during v4 design session — 2026-03-20*
