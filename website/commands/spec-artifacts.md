# /keel:spec-artifacts

Generate implementable artifacts from an accepted technical specification.

Artifacts are the engineering outputs that bridge spec and implementation: data model, API contracts, migrations, test strategy, event contracts, config spec, fixtures. Each artifact is reviewed by the appropriate domain specialist before being written.

## Usage

```
/keel:spec-artifacts SPEC-005
/keel:spec-artifacts path/to/spec-folder/
```

Pass a SPEC identifier (e.g., `SPEC-005`) or the path to the spec folder.

## Gate

The spec must have `status: accepted` before artifacts can be generated:

```
BLOCKED  SPEC-005 status is "draft".
         Specs must be accepted before generating artifacts.
         Review the spec and change status to "accepted" first.
```

## What gets generated

The command scans the spec content and detects which artifacts are relevant:

```
Based on SPEC-005, these artifacts are relevant:
  INCLUDED  data-model.md       — schema mentions detected
  INCLUDED  contracts/api.md    — API endpoint references
  INCLUDED  test-strategy.md    — testing strategy section
  SKIPPED   migrations.md       — no schema changes
  SKIPPED   contracts/events.md — no messaging patterns
  SKIPPED   config-spec.md      — no config changes

Generate 3 artifacts? (y/n)
```

Detection is automatic — if the spec mentions databases, models, or schema, `data-model.md` is triggered. If it mentions API endpoints, `contracts/api.md` is triggered. Confirm or adjust before generation begins.

## Artifact types

| Artifact | Triggered by | Reviewed by |
|----------|-------------|-------------|
| `data-model.md` | database, model, schema, entity, table | dba |
| `contracts/api.md` | API, endpoint, route, REST, request, response | api |
| `contracts/proto/` | gRPC, protobuf, service definition | api |
| `migrations.md` | migration, schema change, ALTER, CREATE TABLE | dba |
| `contracts/events.md` | event, queue, Kafka, pub/sub, webhook delivery | architect |
| `test-strategy.md` | test, testing strategy, coverage | qa |
| `config-spec.md` | config, environment variable, feature flag | sre |
| `fixtures.md` | seed, fixture, test data (also auto-triggers with data-model) | qa |

## What each artifact contains

**data-model.md** — entity definitions with fields, types, constraints, relationships, indexes, and migration notes.

**contracts/api.md** — endpoint definitions with method, path, request/response shapes, error codes, and auth requirements.

**migrations.md** — up and down migrations (rollback is required for every up migration), data backfill plan, risk assessment including lock duration.

**test-strategy.md** — unit test coverage by component, integration test scenarios, edge cases from the spec and PRD acceptance criteria, coverage target.

**contracts/events.md** — event schemas, topics/queues, producers, consumers, ordering guarantees, idempotency strategy.

**config-spec.md** — environment variables with types, defaults, and required flags; feature flags with rollout plans.

**fixtures.md** — seed data scenarios with rationale. Database-agnostic — implementation generates the appropriate format (SQL, Prisma, factory definitions, etc.).

## Output location

All artifacts live in the spec's folder:

```
docs/product/specs/SPEC-005-webhook-delivery/
├── spec.md
├── data-model.md
├── contracts/
│   └── api.md
├── test-strategy.md
└── fixtures.md
```

Each artifact gets frontmatter with spec reference, status, and reviewing agent.

## After generating

Review each artifact. Accept them individually by changing `status: draft` to `status: accepted` in the frontmatter. All artifacts must be accepted before running `/keel:plan`.

## What's next

- [/keel:plan](/commands/plan) — generate phased execution plan with pre-flight specialist review
- [/keel:drift](/commands/drift) — verify implementation against these artifacts after building
- [Governance Chain](/governance/chain) — full chain overview
