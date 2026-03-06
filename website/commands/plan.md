# /keel:plan

Turns a task or feature into a phased execution plan with dependencies, parallelism, and progress tracking.

## When to use it

Whenever a task is bigger than a single prompt. If it touches multiple files, has multiple steps, or spans more than one session — make a plan first.

## Usage

```
/keel:plan
```

Or describe the task inline:

```
/keel:plan add bulk order creation endpoint
/keel:plan CON-42
```

## What happens

Keel asks 3-6 targeted questions, reads your codebase for relevant context, then writes a phased plan to `docs/product/plans/`.

**Example conversation:**

> **Claude:** What's the scope — just the API endpoint, or does this include the domain model and tests too?
>
> **You:** Everything. Domain model, repo, handler, tests.
>
> **Claude:** Any existing order code to build on, or greenfield?
>
> **You:** We have the Order entity, no bulk operations yet.
>
> **Claude:** Got it. Writing plan...

## What a plan looks like

```markdown
# Plan: Bulk Order Creation

| Phase | Task            | Depends on | Status |
|-------|-----------------|------------|--------|
| 1     | Domain model    | —          | -      |
| 2     | Repository      | 1          | -      |
| 3     | HTTP handler    | 2          | -      |
| 4     | Tests           | 1, 2, 3    | -      |

### Phase 1 — Domain model
Add BulkOrder aggregate and CreateBulkOrder command...

### Phase 2 — Repository
Implement BulkOrderRepository with transaction support...
```

## Why it matters

Plans survive context compaction. The progress table in the plan file is the persistent state. When context gets compacted in a long session, Claude re-reads the plan and knows exactly where things stand — without losing progress.

## Natural language triggers

- "let's plan this"
- "create a plan for X"
- "break this into phases"
