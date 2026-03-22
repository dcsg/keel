# /keel:status

Your project dashboard. Where are we, what's in progress, what's next.

## You probably won't type this

Just ask:

> "what's our status?"
> "where are we?"
> "what's next?"

Claude runs `/keel:status` automatically.

## What it shows

The dashboard has six sections:

**Governance health** — rules installed, agents, decisions, compiled directives status, active plan phase.

**Active spec** — if a spec is in progress: its status, artifact acceptance counts, and the last drift report summary.

**Chain status** — the full governance chain for the active spec, e.g. `PRD-005 accepted → SPEC-005 accepted → artifacts 3/3 accepted → PLAN-007 in progress`.

**Gate activity** — any quality gate firings from the current session, including what was found and whether it was resolved or overridden.

**Agent activity** — specialist agents that ran this session, how many times, and in what context (plan pre-flight, review, audit).

**Hook activity** — hook fires by type this session (rule loads, agent invocations, signals detected).

**Signals detected** — ADR candidates, doc gaps, and security signals surfaced by the Stop hook during the session.

```
KEEL STATUS — Orders API
═══════════════════════════════════════════════

GOVERNANCE HEALTH
  Rules:        6 active (code-quality  testing  security  error-handling  go  chi)
  Agents:       8 installed
  Decisions:    3 ADRs, 2 invariants
  Compile:      2026-03-20
  Plan:         PLAN-bulk-orders Phase 3/4 — in progress

CHAIN STATUS
  PRD-005 accepted → SPEC-005 accepted → artifacts 3/3 accepted → PLAN-bulk-orders in progress

GATE ACTIVITY (this session)
  ✅ No gate findings this session

AGENT ACTIVITY (this session)
  No agent activity this session

HOOK ACTIVITY (this session)
  No hook activity this session

SIGNALS DETECTED
  No signals detected this session

WHAT'S NEXT
  Phase 3 — HTTP handler
  - Wire up POST /orders/bulk endpoint in Chi router
  - Validate request with domain service
  - Return 207 multi-status response

═══════════════════════════════════════════════
```

**WHAT'S NEXT** is the most important part — it tells you the concrete next tasks, not just a phase name.

## Persisted to disk

After displaying the dashboard, `/keel:status` writes the same output to `docs/STATUS.md`. Commit it so your team can see project health without running the command. Keel uses sentinel markers so re-runs only update the keel block — any notes you add above it are preserved.

## No active plan?

If there's no plan in progress, `/keel:status` still shows your installed rules and governance health, and suggests running `/keel:plan` to start one.

## Natural language triggers

- "what's our status?"
- "where are we?"
- "what's next?"
- "what should we work on?"
- "project status"
