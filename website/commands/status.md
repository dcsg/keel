# /keel:status

Project dashboard — plan progress, installed rules, and governance health.

## Usage

```
/keel:status
```

Or just say **"what's our status?"** or **"what's next?"** — Claude runs it automatically.

## Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL STATUS — Orders API
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ACTIVE PLAN
 ───────────
 PLAN-bulk-orders
 Progress: 2/4 phases (50%)

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
 Soul:       present
 Decisions:  3 records
 Product:    spec + 2 PRDs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
