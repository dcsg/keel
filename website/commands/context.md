# /keel:context

Loads all project context into the current session.

## Usage

```
/keel:context
```

## What Gets Loaded

| Source | Content |
|--------|---------|
| `docs/soul.md` | Project identity, stack, non-negotiables |
| `docs/product/spec.md` | Product vision and roadmap |
| `docs/product/prds/` | Active feature requirements |
| `docs/product/plans/` | Active execution plan + progress table |
| `docs/decisions/` | Architecture decisions |
| `.claude/rules/` | Summary of installed guardrails |

## When to Use

- At the start of a new session on an unfamiliar codebase
- After context compaction (Claude will re-read the active plan automatically)
- When onboarding a teammate to use Claude Code on the project

## Natural Language

Just say:
- "load context"
- "remind yourself"
- "what's this project?"

Claude will run `/keel:context` automatically.
