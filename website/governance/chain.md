# Governance Chain

The governance chain is the full sequence from intent to implementation to verification. A traceable, state-machine path where every step references the one before it.

<div class="chain-diagram">
<div class="chain-col chain-gov">
<div class="chain-heading">Governance</div>
<div class="chain-item chain-adr">ADRs</div>
<div class="chain-item chain-inv">Invariants</div>
<div class="chain-item chain-guide">Guidelines</div>
<div class="chain-flow">↓ compile</div>
<div class="chain-item chain-compiled">governance.md</div>
</div>
<div class="chain-col chain-connect">
<div class="chain-bridge">constrains →</div>
<div class="chain-bridge-low">directives →</div>
<div class="chain-bridge-drift">← verifies</div>
</div>
<div class="chain-col chain-eng">
<div class="chain-heading">Engineering Chain</div>
<div class="chain-item">PRD</div>
<div class="chain-flow">↓</div>
<div class="chain-item">Spec</div>
<div class="chain-flow">↓</div>
<div class="chain-item">Artifacts</div>
<div class="chain-flow chain-flow-merge">↓ spec + artifacts</div>
<div class="chain-item">Plan</div>
<div class="chain-flow">↓</div>
<div class="chain-item chain-exec">Execute</div>
<div class="chain-flow">↓</div>
<div class="chain-item chain-drift">Drift</div>
</div>
</div>

<style>
.chain-diagram {
  display: flex;
  gap: 0;
  margin: 24px 0 32px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 13px;
}
.chain-col {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}
.chain-gov {
  flex: 0 0 140px;
  padding-top: 32px;
}
.chain-connect {
  flex: 0 0 100px;
  justify-content: center;
  padding-top: 60px;
  gap: 60px;
}
.chain-eng {
  flex: 0 0 140px;
}
.chain-heading {
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: #64748B;
  margin-bottom: 8px;
}
.chain-item {
  padding: 6px 16px;
  border: 1px solid #334155;
  border-radius: 3px;
  color: #CBD5E1;
  background: #1E293B;
  text-align: center;
  width: 100%;
}
.chain-adr { border-color: #A0936D; color: #D4C5A9; }
.chain-inv { border-color: #DC2626; color: #F87171; }
.chain-guide { border-color: #A0936D; color: #D4C5A9; }
.chain-compiled { border-color: #0D9488; color: #5EEAD4; }
.chain-exec { border-color: #0D9488; color: #2DD4BF; }
.chain-drift { border-color: #059669; color: #34D399; }
.chain-flow {
  color: #475569;
  font-size: 12px;
  padding: 2px 0;
}
.chain-flow-merge { color: #64748B; font-size: 11px; }
.chain-bridge {
  color: #A0936D;
  font-size: 11px;
  white-space: nowrap;
}
.chain-bridge-low {
  color: #0D9488;
  font-size: 11px;
  white-space: nowrap;
}
.chain-bridge-drift {
  color: #059669;
  font-size: 11px;
  white-space: nowrap;
}

/* Light mode */
@media (prefers-color-scheme: light) {
  .chain-item { background: #F8FAFC; border-color: #E2E8F0; color: #334155; }
  .chain-adr { border-color: #A0936D; color: #6B5F47; }
  .chain-inv { border-color: #DC2626; color: #991B1B; }
  .chain-guide { border-color: #A0936D; color: #6B5F47; }
  .chain-compiled { border-color: #0D9488; color: #115E59; }
  .chain-exec { border-color: #0D9488; color: #0F766E; }
  .chain-drift { border-color: #059669; color: #047857; }
}

:not(.dark) .chain-item { background: #F8FAFC; border-color: #E2E8F0; color: #334155; }
:not(.dark) .chain-adr { border-color: #A0936D; color: #6B5F47; }
:not(.dark) .chain-inv { border-color: #DC2626; color: #991B1B; }
:not(.dark) .chain-guide { border-color: #A0936D; color: #6B5F47; }
:not(.dark) .chain-compiled { border-color: #0D9488; color: #115E59; }
:not(.dark) .chain-exec { border-color: #0D9488; color: #0F766E; }
:not(.dark) .chain-drift { border-color: #059669; color: #047857; }
:not(.dark) .chain-flow { color: #94A3B8; }

@media (max-width: 500px) {
  .chain-diagram { flex-direction: column; align-items: center; }
  .chain-connect { flex-direction: row; padding: 8px 0; gap: 16px; }
  .chain-bridge, .chain-bridge-low, .chain-bridge-drift { transform: rotate(90deg); }
}
</style>

Two systems working together:

**Governance** — ADRs, invariants, and guidelines are your current decisions and constraints. They compile into `governance.md` — short directives Claude reads every session.

**Engineering Chain** — PRD → Spec → Artifacts → Plan → Execute → Drift. Each step feeds the next. Each must be accepted before the next begins. The plan consumes both the spec and its artifacts.

They connect at three points:
- Governance **constrains** the spec — existing ADRs and invariants inform the technical design
- Compiled **directives are active** during plan and execution — Claude follows them automatically
- Drift **verifies** the implementation against governance — did we build what we decided?

The details of each mechanism have their own pages:
- [Quality Gates](/governance/gates) — block on critical findings during plan and execution
- [Compiled Directives](/governance/compile) — how ADRs become enforcement
- [Drift Detection](/governance/drift) — the verification step
- [Agents](/agents) — specialist review at each phase
- [Rule Packs](/rules/) — coding standards that fire automatically

## The conversation that drives it

You don't type commands in sequence — you tell Claude what you need, and Claude runs the right step.

> "Write a PRD for Stripe webhook delivery with retry logic and idempotency"

Claude generates structured requirements with acceptance criteria grounded in your project context. Review it, mark it accepted.

> "Write a spec for PRD-005"

Claude checks that PRD-005 is accepted, then routes to `architect`, scans your codebase and ADRs, and generates a technical specification. The spec references the PRD and any relevant ADRs.

> "Generate spec artifacts for SPEC-005"

Claude produces the implementable outputs: data model, API contracts, migrations, test strategy. Each artifact references the spec it came from.

> "Create a plan for SPEC-005"

Claude breaks the spec into phases, routes each to specialist agents for pre-flight review, and returns findings before any code is written.

Then you execute. Claude builds with enforced standards, the active plan phase injected on every prompt.

> "Does the implementation match the spec?"

Claude runs drift detection — comparing what got built against the PRD acceptance criteria, spec requirements, artifact contracts, and ADR compliance.

The full sequence:

```
PRD → spec → artifacts → plan → execute → drift detection
```

**Command references:** `/keel:prd`, `/keel:spec`, `/keel:spec-artifacts`, `/keel:plan`, `/keel:drift`

## State machine

Each step in the chain has a status. The chain enforces a strict progression: each artifact must be accepted before the next step can begin.

| Step | Status values | Gate |
|------|--------------|------|
| PRD | `draft` → `accepted` | spec requires `accepted` PRD |
| Spec | `draft` → `accepted` | spec-artifacts requires `accepted` spec |
| Artifacts | `draft` → `accepted` (per artifact) | plan requires `accepted` artifacts |
| Plan | `draft` → `in-progress` → `complete` | Execution proceeds phase by phase |
| Drift report | generated on demand | Closes the loop — accepted vs. built |

Attempting to write a spec on a draft PRD produces a hard block:

```
BLOCKED  PRD-005 status is "draft".
         PRDs must be accepted before generating a spec.
         Review the PRD and change status to "accepted" first.
```

This isn't a suggestion. The gate exists because a draft PRD represents unresolved requirements — building a technical specification on top of unresolved requirements produces wasted work.

## What gets captured at each step

**PRD** — functional requirements, non-functional requirements, acceptance criteria, open questions. The product intent, in structured form.

**Spec** — architecture approach, components, trade-offs, alternatives considered, references to ADRs and invariants. The engineering response to the PRD.

**Artifacts** — the implementable outputs of the spec:
- `data-model.md` — entities, relationships, indexes
- `contracts/api.md` — endpoint definitions, request/response shapes, error codes
- `migrations.md` — schema changes with up and down migrations
- `test-strategy.md` — unit, integration, and edge case coverage
- `contracts/events.md` — event schemas, producers, consumers
- `config-spec.md` — environment variables, feature flags

**Plan** — phased execution with pre-flight specialist review. Each phase is reviewed by the domain agents before any code is written.

**Drift report** — comparison of implementation against spec, PRD acceptance criteria, artifact contracts, ADR decisions, and invariants. Saved to the spec folder.

## Traceability

Every artifact in the chain carries references to what it came from:

```yaml
# spec frontmatter
type: spec
id: SPEC-005
source_prd: PRD-005
references:
  adrs: [ADR-001, ADR-003]
  invariants: [INV-001]
status: accepted
```

```yaml
# artifact frontmatter
type: artifact
artifact_type: data-model
spec: SPEC-005
status: draft
reviewed_by: dba
```

When drift detection runs, it follows these references backward through the chain — checking implementation against artifacts, artifacts against spec, spec against PRD acceptance criteria.

## Why this matters

Without the chain, the engineering cycle is scattered: requirements in Notion, decisions in Slack, specs in someone's head, verification by hope. The chain creates a single, version-controlled, machine-readable path from "what we decided to build" to "what we actually built."

The drift check closes the loop. It's not optional ceremony — it's the mechanism that makes the governance chain a governance chain rather than a documentation exercise.

## When to use it

You don't have to use the full chain for every piece of work. For ad hoc tasks, keel's rules and hooks govern the session without PRD or spec. The chain is for features where traceability matters — where you need to verify that implementation matches intent.

For new features, the chain is the right default. Tell Claude what you want to build, let it generate acceptance criteria, review and accept it, then proceed.

See [/keel:prd](/commands/prd), [/keel:spec](/commands/spec), [/keel:spec-artifacts](/commands/spec-artifacts), [/keel:plan](/commands/plan), [/keel:drift](/commands/drift).
