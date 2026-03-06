# /keel:plan

Interview + phased execution plan with dependency tracking.

## Usage

```
/keel:plan
```

Optionally pass a ticket ID or description:

```
/keel:plan CON-42
/keel:plan "add bulk order creation endpoint"
```

## How It Works

1. **Interview** — Keel asks 3-6 targeted questions about the task
2. **Context load** — Reads soul, active plan, relevant ADRs
3. **Codebase analysis** — Identifies affected files and patterns
4. **Plan generation** — Phased plan with dependencies and parallelism

## Plan Output

```markdown
## Plan: Add Bulk Order Creation

| Phase | Task | Model | Status |
|-------|------|-------|--------|
| 1 | Schema + migration | Sonnet | - |
| 2 | Domain model | Opus | - |
| 3 | HTTP handler | Sonnet | - |
| 4 | Tests | Sonnet | - |

### Phase 1 — Schema + migration
...
```

## Features

- **Dependency graph** — phases declare what they depend on
- **Parallelism** — independent phases flagged as runnable concurrently
- **Model assignment** — Opus for architecture, Sonnet for implementation
- **Compaction recovery** — progress table in the plan file survives context resets

Plans are saved to `docs/product/plans/PLAN-{slug}.md`.
