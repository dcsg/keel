# /keel:spec

Generate a technical specification from an accepted PRD.

The spec is the engineering response to a product requirement — it defines HOW to build what the PRD says to build. Architecture decisions, trade-offs, components, data access, security considerations, testing strategy.

## Usage

```
/keel:spec PRD-005
/keel:spec path/to/prd-file.md
```

Pass a PRD identifier (e.g., `PRD-005`) or the path to the PRD file directly.

## Gate

The PRD must have `status: accepted` before a spec can be generated:

```
BLOCKED  PRD-005 status is "draft".
         PRDs must be accepted before generating a spec.
         Review the PRD and change status to "accepted" first.
```

This gate exists because drafting a technical specification against unresolved requirements produces wasted work. Accept the PRD first.

## What the command does

**1. Scans the codebase** — reads rules, agents, ADRs, invariants, and `docs/project-context.md` to understand what exists before asking any questions.

**2. Interviews with context** — asks 2–4 questions that prove it understood the codebase, not just the PRD. Questions reference what it found:

```
The codebase has ADR-003 for error handling (wrapped errors with context).
Should this spec follow that pattern or propose a different approach?

I see a hexagonal architecture with domain/, port/, adapter/ layers.
Should this feature follow the same pattern?
```

**3. Shows an outline** — before routing to specialist agents, confirms what the spec will cover:

```
Based on the PRD and your answers, the spec will cover:
  - Architecture: hexagonal, same pattern as existing code
  - Key components: WebhookService, WebhookRepository, delivery adapter
  - Data: new webhooks table + delivery_attempts table
  - APIs: POST /webhooks, POST /webhooks/retry, GET /webhooks/:id
  - Breaking changes: none
  - Open questions: 2 carried from PRD

Proceed? (y/n)
```

**4. Checks for ADR conflicts** — surfaces any contradictions between the proposed approach and existing decisions.

**5. Generates the spec** — routes to `architect` and relevant domain specialists. Produces a spec file at:

```
docs/product/specs/SPEC-{NNN}-{slug}/spec.md
```

## Output format

```yaml
---
type: spec
id: SPEC-005
source_prd: PRD-005
references:
  adrs: [ADR-001, ADR-003]
  invariants: [INV-001]
status: draft
created_at: 2026-03-20T14:30:00Z
---
```

Sections:
- Summary
- Existing Architecture (what the spec builds on)
- Proposed Architecture
- Components (what gets built, where it lives, how it integrates)
- Trade-offs (alternatives considered)
- Security Considerations
- Performance Approach
- Testing Strategy
- Open Questions

## After generating

Review the spec. Change `status: draft` to `status: accepted` when ready to proceed.

Then run `/keel:spec-artifacts` to generate the implementable artifacts.

```
Run /keel:spec-artifacts SPEC-005 to generate implementable artifacts.
```

## What's next

- [/keel:spec-artifacts](/commands/spec-artifacts) — generate data model, API contracts, migrations, test strategy
- [/keel:plan](/commands/plan) — phased execution with pre-flight review
- [Governance Chain](/governance/chain) — full chain overview
