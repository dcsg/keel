# /keel:context

Loads your project's memory into the current session.

## When to use it

**New session, existing project.** Claude starts with no memory. Run `/keel:context` (or just say "remind yourself") and it knows everything — your stack, your standards, your current plan, your decisions.

**After context compaction.** Long sessions hit Claude's context limit and get compacted. Run context to reload what matters.

**Onboarding a teammate.** They open the project, run `/keel:context`, and Claude is immediately useful — no hand-holding, no re-explaining the architecture.

## What it loads

| Source | What Claude learns |
|--------|--------------------|
| `docs/soul.md` | Project identity, stack, non-negotiables |
| `docs/product/spec.md` | What you're building and why |
| `docs/product/prds/` | Active feature requirements |
| `docs/product/plans/` | Current plan + phase progress |
| `docs/decisions/` | Architecture decisions and their reasoning |
| `docs/invariants/` | Hard constraints — non-negotiables Claude must never violate |
| `.keel/config.yaml` | Ticket system config (Linear/Jira/GitHub) |
| `.claude/rules/` | Which packs are active; flags manually edited files |

## What it looks like

> **You:** remind yourself about this project
>
> **Claude:** *(runs `/keel:context`)*
>
> ```
> Loaded context for Orders API:
>
>   Soul:      Go REST API for order management
>              DDD with bounded contexts (orders, inventory, billing)
>              Chi router · PostgreSQL · Hexagonal architecture
>
>   Active plan: PLAN-bulk-orders
>   Progress:    Phase 3 of 4 in progress (HTTP handler)
>
>   Rules:     code-quality · testing · security
>              error-handling · go · chi
>
>   Decisions: 3 ADRs on file
>              — hexagonal architecture
>              — error wrapping strategy
>              — JWT auth pattern
>
>   Product:   spec + 2 active PRDs
>
> Ready. What are we working on?
> ```

## You usually don't need to run this manually

The `PreToolUse` hook installed by `/keel:init` fires before Claude's first Write or Edit in a session. If context hasn't been loaded yet, it reminds Claude to load it before writing any code. Running `/keel:context` explicitly gives you the full visible output — useful when onboarding a teammate or starting a complex session.

## Natural language triggers

- "remind yourself"
- "load context"
- "what's this project?"
- "catch me up"
