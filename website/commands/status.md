# /keel:status

Your project dashboard. Where are we, what's in progress, what's next.

## You probably won't type this

Just ask:

> "what's our status?"
> "where are we?"
> "what's next?"

Claude runs `/keel:status` automatically.

## What it shows

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL STATUS — Orders API
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ACTIVE PLAN
 ───────────
 PLAN-bulk-orders  ·  2/4 phases (50%)

 | Phase | Title          | Status      |
 |-------|----------------|-------------|
 | 1     | Schema         | done        |
 | 2     | Domain model   | done        |
 | 3     | HTTP handler   | in-progress |
 | 4     | Tests          | -           |

 WHAT'S NEXT
 ───────────
 Phase 3 — HTTP handler
   - Wire up POST /orders/bulk endpoint in Chi router
   - Validate request with domain service
   - Return 207 multi-status response

 RULES
 ─────
 6 packs installed:
   code-quality  testing  security  error-handling  go  chi

 GOVERNANCE
 ──────────
 Soul:        present
 Decisions:   3 records
 Invariants:  2 constraints
 Product:     spec + 2 PRDs
 Tickets:     Linear (team: eng)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
