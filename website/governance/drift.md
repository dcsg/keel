# Drift Detection

Drift detection is the verification step that closes the governance chain. Ask Claude whether the implementation matches the spec, and it compares what you decided to build against what you actually built.

## How to run it

After implementing a feature, ask Claude:

> "Does the implementation match the spec for SPEC-005?"

Or to narrow the scope:

> "Check if the implementation matches the PRD acceptance criteria for PRD-005"

> "Run a drift check on the artifact contracts for SPEC-005"

Claude runs the check and returns a structured report.

**Command reference:** `/keel:drift SPEC-005`

## What it checks

A full drift check runs five layers in sequence:

| Layer | What it checks | Agent |
|-------|---------------|-------|
| PRD acceptance criteria | Is each acceptance criterion satisfied by the implementation? | architect |
| Spec requirements | Was each requirement implemented as specified? | architect + backend |
| Artifact contracts | Does the implementation match data models, API contracts, test strategy? | dba, api, qa |
| ADR compliance | Does the implementation follow the referenced architectural decisions? | architect |
| Invariant compliance | Does the implementation violate any active invariant? | architect |

## Scoping

Not every drift check needs to run all five layers. Narrow the scope when you need a faster check during implementation:

```bash
/keel:drift SPEC-005                   # full chain (default)
/keel:drift SPEC-005 --scope=prd       # PRD acceptance criteria only
/keel:drift SPEC-005 --scope=spec      # spec requirements only
/keel:drift SPEC-005 --scope=artifacts # artifact contracts only
/keel:drift SPEC-005 --scope=adrs      # ADR compliance only
```

Run `--scope=spec` frequently during implementation. Run the full chain before marking a feature complete.

## Severity model

Each finding gets a confidence-based severity:

| Level | Meaning |
|-------|---------|
| Compliant (high confidence) | Verified by reading code — the thing exists and works as specified |
| Likely compliant (medium) | Appears to match but can't be verified deterministically |
| Diverged (high confidence) | Implementation clearly differs from the decision |
| Unknown | Not enough signal to determine |

"Likely compliant" is honest engineering. Some compliance can't be determined statically. The drift report says so rather than pretending certainty.

## What you see

```
DRIFT REPORT — SPEC-005
─────────────────────────────────────────────────
Source: SPEC-005 + 3 artifacts + 2 ADRs + 1 invariant
Scope:  full chain
Date:   2026-03-20

SUMMARY
  14 compliant (high)    3 likely compliant
   2 diverged             1 unknown

PRD ACCEPTANCE CRITERIA (PRD-005)
  COMPLIANT  "Webhook delivery retries on 5xx responses"
             verified: internal/webhook/retry.go:47 — exponential backoff implemented

  DIVERGED   "Failed deliveries visible in admin dashboard"
             expected: admin endpoint shows failed webhook status
             found: no admin endpoint for webhook status exists
             action: implement GET /admin/webhooks?status=failed

SPEC REQUIREMENTS
  COMPLIANT  Hexagonal architecture — domain logic in domain/webhook/
  DIVERGED   No index on webhooks.status
             contract: index required (spec section 3.2)
             actual: migration exists but index not in schema

ARTIFACT CONTRACTS
  COMPLIANT  data-model.md: WebhookDelivery entity — matches schema
  DIVERGED   contracts/api.md: POST /webhooks/retry — response shape differs
             contract: { "queued": number, "delivery_ids": string[] }
             actual: returns 204 No Content

ADR COMPLIANCE
  COMPLIANT  ADR-003: hexagonal architecture — followed
  LIKELY     ADR-002: error wrapping — appears followed (full coverage unverifiable)

INVARIANT COMPLIANCE
  COMPLIANT  INV-001: commands are plain markdown — not violated
─────────────────────────────────────────────────

Report saved: docs/reports/drift-SPEC-005-2026-03-20.md

2 diverged finding(s) need attention.
Fix the divergences and run /keel:drift again.
```

## Persisted reports

Drift reports are saved to `docs/reports/` automatically:

```
docs/reports/
└── drift-SPEC-005-2026-03-20.md      ← saved automatically
```

The filename format is `drift-{SPEC-NNN}-{YYYY-MM-DD}.md`. The report is version-controlled. You can track how drift resolves over time by comparing reports.

## CI integration

Run with `--output=json` for machine-readable output:

```bash
/keel:drift SPEC-005 --output=json
```

Exit code:
- `0` — no diverged findings
- `1` — one or more diverged findings

Wire this into CI to catch regressions. A spec-passing implementation that regresses should fail the drift check.

## Integration with review

When `/keel:review` runs and an active spec exists, it automatically runs a scoped drift check (`--scope=spec`) and appends the findings under a "DRIFT CHECK" section. You don't need to run both separately during a review cycle.

See [/keel:drift](/commands/drift) for full command reference.
