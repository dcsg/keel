# Natural Language

Keel teaches Claude to respond to how you naturally talk — no need to remember slash commands.

After `/keel:init`, your `CLAUDE.md` includes a trigger table. Claude reads it at session start and knows what to do when you ask everyday questions.

## How it works in practice

You're mid-session, deep in a feature. You want to know where things stand:

> **You:** what's our status?

> **Claude:** *(runs `/keel:status`)*
> ```
> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
>  KEEL STATUS — Orders API
> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
>
>  ACTIVE PLAN
>  ───────────
>  PLAN-bulk-orders  ·  2/4 phases (50%)
>
>  | Phase | Title         | Status      |
>  |-------|---------------|-------------|
>  | 1     | Schema        | done        |
>  | 2     | Domain model  | done        |
>  | 3     | HTTP handler  | in-progress |
>  | 4     | Tests         | -           |
>
>  WHAT'S NEXT
>  ───────────
>  Phase 3 — HTTP handler
>    - Wire up POST /orders/bulk in Chi router
>    - Validate with domain service
>    - Return 207 multi-status response
> ```

You didn't type `/keel:status`. You just asked. Claude knew.

---

You come back after the weekend and want Claude to catch up:

> **You:** remind yourself about this project

> **Claude:** *(runs `/keel:context`)*
> ```
> Loaded context for Orders API:
>
>   Project:   Go REST API, DDD, Chi, PostgreSQL
>   Plan:      PLAN-bulk-orders (Phase 3 in progress)
>   Rules:     code-quality, testing, security, error-handling, go, chi
>   Decisions: 3 ADRs (hexagonal arch, error strategy, auth pattern)
>   Product:   spec + 2 PRDs
>
> Ready. What are we working on?
> ```

---

You want to start planning a new feature:

> **You:** let's plan the export to CSV feature

> **Claude:** *(runs `/keel:plan`)*
> Great, let me ask a few questions to scope this out...

---

## Full trigger list

| You say... | Claude runs |
|------------|-------------|
| "what's our status?" | `/keel:status` |
| "where are we?" | `/keel:status` |
| "what's next?" | `/keel:status` |
| "what should we work on?" | `/keel:status` |
| "remind yourself" | `/keel:context` |
| "load context" | `/keel:context` |
| "what's this project?" | `/keel:context` |
| "let's plan X" | `/keel:plan` |
| "create a plan for X" | `/keel:plan` |
| "save this decision" | `/keel:adr` |
| "record this choice" | `/keel:adr` |
| "capture that" | `/keel:adr` |
| "that's a hard rule" | `/keel:invariant` |
| "never do X" | `/keel:invariant` |
| "write a PRD for X" | `/keel:prd` |
| "document this feature" | `/keel:prd` |
| "what agents do we have?" | `/keel:agents` |
| "add the security agent" | `/keel:agents add security` |
| "setup Linear" | `/keel:mcp add linear` |
| "validate my environment" | `/keel:team setup` |

These are defined in `.claude/CLAUDE.md` — you can add your own triggers by editing that file.

## Adding your own triggers

Open `.claude/CLAUDE.md` and add rows to the trigger table:

```markdown
| "run the tests" | `make test` |
| "deploy to staging" | `make deploy-staging` |
| "what broke?" | `/keel:status` then check recent git log |
```

Any instruction you find yourself repeating to Claude belongs here.
