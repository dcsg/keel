---
name: keel:spec-artifacts
description: "Generate implementable artifacts from an accepted spec"
---

# keel:spec-artifacts

Generate implementable artifacts (data model, API contracts, migrations, test strategy) from an accepted technical specification. Each artifact is reviewed by the appropriate domain specialist.

## Arguments

- `$ARGUMENTS` — SPEC identifier (e.g., `SPEC-005`) or path to the spec folder

## Instructions

### 1. Resolve Paths

Read `.keel/config.yaml`. Specs directory from `specs: { dir: }` (default: `docs/product/specs/`).

### 2. Find and Validate the Spec

If `$ARGUMENTS` is a SPEC identifier (e.g., `SPEC-005`):
```bash
find {specs_dir}/ -name "SPEC-005*" -type d
```

Read `{spec_folder}/spec.md`. Check the frontmatter `status:` field:
- If `status: accepted` → proceed
- If `status: draft` → block:
  ```
  ⛔ SPEC-005 status is "draft".
     Specs must be accepted before generating artifacts.
     Review the spec and change status to "accepted" first.
  ```
- If no frontmatter status → treat as accepted (backwards compatibility)

### 3. Detect Relevant Artifacts

Scan the spec content for artifact triggers. Show the user what will be generated:

```
Based on SPEC-005, these artifacts are relevant:
```

Apply these detection rules:

| If the spec mentions... | Artifact | Primary agent | Secondary |
|---|---|---|---|
| database, model, schema, entity, table, column, field, relationship | `data-model.md` | dba | architect |
| API, endpoint, route, REST, GraphQL, request, response, contract | `contracts/api.md` | api | architect |
| gRPC, protobuf, proto, service definition | `contracts/proto/` | api | engineer |
| migration, schema change, ALTER, CREATE TABLE | `migrations.md` | dba | sre |
| event, message, queue, Kafka, RabbitMQ, pub/sub, webhook delivery | `contracts/events.md` | architect | sre |
| test, testing strategy, coverage, unit test, integration test | `test-strategy.md` | qa | engineer |
| config, environment variable, feature flag, configuration | `config-spec.md` | sre | engineer |
| seed, fixture, test data, sample data, development data (also auto-triggers when data-model.md is generated) | `fixtures.md` | qa | dba |

Show the list with checkmarks:
```
  ✓ data-model.md — schema mentions detected
  ✓ contracts/api.md — API endpoint references
  ✓ test-strategy.md — testing strategy section
  ✗ migrations.md — no schema changes
  ✗ contracts/events.md — no messaging patterns
  ✗ config-spec.md — no config changes

Generate 3 artifacts? (y/n)
```

Wait for confirmation.

### 4. Generate Artifacts

For each confirmed artifact, route to the primary + secondary agent via the Agent tool.

Each agent receives:
- The spec content
- The source PRD content (read from `source_prd:` in spec frontmatter)
- The project-context.md for project context
- Any referenced ADRs
- Instruction to produce the specific artifact type

Show routing as it happens:
```
🪝 keel: routing data-model.md to dba...
🪝 keel: routing contracts/api.md to api...
🪝 keel: routing test-strategy.md to qa...
```

### 5. Artifact Templates

Each artifact gets frontmatter and lives in the spec's folder:

**data-model.md:**
```markdown
---
type: artifact
artifact_type: data-model
spec: SPEC-{NNN}
status: draft
created_at: {ISO8601 timestamp}
reviewed_by: dba
---

# Data Model — {feature name}

## Entities

### {EntityName}

| Field | Type | Constraints | Notes |
|---|---|---|---|
| id | UUID | PK | |
| {field} | {type} | {constraints} | {notes} |

## Relationships

{Entity relationship descriptions or diagram}

## Indexes

{Recommended indexes with rationale}

## Migration Notes

{What needs to change from current schema, if applicable}
```

**contracts/api.md:**
```markdown
---
type: artifact
artifact_type: api-contract
spec: SPEC-{NNN}
status: draft
created_at: {ISO8601 timestamp}
reviewed_by: api
---

# API Contracts — {feature name}

## Endpoints

### {METHOD} {path}

**Purpose:** {what this endpoint does}

**Request:**
```json
{request shape}
```

**Response (200):**
```json
{response shape}
```

**Errors:**
| Code | Condition | Response |
|---|---|---|
| 400 | {condition} | {error shape} |
| 404 | {condition} | {error shape} |

**Auth:** {auth requirements}
```

**test-strategy.md:**
```markdown
---
type: artifact
artifact_type: test-strategy
spec: SPEC-{NNN}
status: draft
created_at: {ISO8601 timestamp}
reviewed_by: qa
---

# Test Strategy — {feature name}

## Unit Tests

| Component | What to test | Priority |
|---|---|---|
| {component} | {behavior} | {high/medium/low} |

## Integration Tests

| Scenario | Components involved | Priority |
|---|---|---|
| {scenario} | {components} | {high/medium/low} |

## Edge Cases

{Edge cases identified from the spec and PRD acceptance criteria}

## Coverage Target

{What coverage looks like for this feature}
```

**migrations.md:**
```markdown
---
type: artifact
artifact_type: migrations
spec: SPEC-{NNN}
status: draft
created_at: {ISO8601 timestamp}
reviewed_by: dba
---

# Migration Plan — {feature name}

## Changes

{What schema changes are needed}

## Up Migration

{SQL or migration framework commands}

## Down Migration (rollback)

{Rollback commands — required for every up migration}

## Data Backfill

{If existing data needs transformation — or "None"}

## Risk Assessment

{Lock duration, data volume impact, deployment considerations}
```

**contracts/events.md:**
```markdown
---
type: artifact
artifact_type: event-contract
spec: SPEC-{NNN}
status: draft
created_at: {ISO8601 timestamp}
reviewed_by: architect
---

# Event Contracts — {feature name}

## Events

### {EventName}

**Topic/Queue:** {topic}
**Schema:**
```json
{event shape}
```
**Producer:** {service/component}
**Consumers:** {services/components}
**Ordering:** {ordering guarantees}
**Idempotency:** {idempotency strategy}
```

**config-spec.md:**
```markdown
---
type: artifact
artifact_type: config-spec
spec: SPEC-{NNN}
status: draft
created_at: {ISO8601 timestamp}
reviewed_by: sre
---

# Configuration Spec — {feature name}

## Environment Variables

| Variable | Type | Default | Required | Description |
|---|---|---|---|---|
| {VAR_NAME} | {type} | {default} | {yes/no} | {description} |

## Feature Flags

| Flag | Default | Description | Rollout plan |
|---|---|---|---|
| {flag_name} | {default} | {description} | {plan} |
```

**fixtures.md:**
```markdown
---
type: artifact
artifact_type: fixtures
spec: SPEC-{NNN}
status: draft
created_at: {ISO8601 timestamp}
reviewed_by: qa
---

# Fixtures & Seed Data — {feature name}

## Purpose

{What this seed data enables: development environment, integration tests, demo, or all}

## Seed Scenarios

### Scenario: {name} — {what it tests or enables}

| Entity | Key fields | Why this data matters |
|---|---|---|
| {Entity} | {field: value, field: value} | {what behavior this enables or edge case it covers} |

### Scenario: {name}

| Entity | Key fields | Why this data matters |
|---|---|---|
| {Entity} | {field: value} | {reason} |

## Relationships

{How seed entities relate to each other. Order of creation matters for foreign keys.}

## Edge Cases

{Seed data specifically designed to cover edge cases:
- Expired subscriptions for renewal testing
- Users with no permissions for auth boundary testing
- Empty collections for nil-handling
- Maximum-length strings for validation testing}

## Implementation Notes

{Database-agnostic. During implementation, generate the appropriate format
for the project's stack: SQL seeds, factory definitions, JSON fixtures,
Prisma seed.ts, etc. The data model artifact defines the schema — this
artifact defines what data to populate and why.}
```

---

REMEMBER: Every artifact must be reviewed by the appropriate specialist agent. NEVER generate an artifact without routing it to the agent listed in the detection table. The spec must be accepted before artifacts are generated.

### 6. Confirm

```
✅ Artifacts created in {spec_folder}/

  data-model.md         — reviewed by dba
  contracts/api.md      — reviewed by api
  test-strategy.md      — reviewed by qa

  Status: draft
  Review and accept each artifact before planning.
  Run /keel:plan to create an execution plan.
```
