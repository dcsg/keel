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

## Auto-memory

After running `/keel:context`, keel writes a compact snapshot to Claude's auto-memory (`~/.claude/projects/.../memory/MEMORY.md`). This file is automatically loaded at the start of every future session — so Claude knows the project name, stack, active plan, and hard invariants without you running `/keel:context` first.

The `SessionStart` hook checks if memory is stale (>7 days old) and prompts you to refresh. The memory file is local to your machine, not committed to git.

## You usually don't need to run this manually

The `SessionStart` hook installed by `/keel:init` fires when you open the project. If auto-memory exists and is fresh, it confirms context is loaded. If memory is missing or stale, it prompts you to run `/keel:context`. Running it explicitly gives you the full visible output — useful when onboarding a teammate or starting a complex session.

## Natural language triggers

- "remind yourself"
- "load context"
- "what's this project?"
- "catch me up"
