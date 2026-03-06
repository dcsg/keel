# Getting Started with Keel

Keel is a context engine and guardrail installer for Claude Code. It gives Claude the right context and coding standards before it writes a single line — producing consistent, production-grade results.

## Watch the Workflow in Action

![Keel workflow demo](../demo/keel-workflow.gif)

The demo walks through the real user experience:
- `/keel:init` — project detection, rule selection, file generation
- `/keel:plan` — feature planning with phased execution
- Code generation with rules enforced (named constants, structured errors, error wrapping)
- `/keel:status` — project dashboard with progress tracking

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/danielgomes/keel/main/install.sh | bash
```

This installs keel's commands to `~/.claude/commands/` and templates to `~/.keel/templates/`.

## Initialize a Project

Open a terminal in your project root and run:

```
/keel:init
```

Keel will:

1. Detect whether your project is greenfield or established
2. Ask what you're building (greenfield) or audit the codebase (established)
3. Show recommended rule packs with a toggle UI
4. Generate everything

**Greenfield example:**

```
What are you building? Describe it in a few sentences.
> A SaaS invoicing tool for freelancers. Go backend, Next.js frontend, Postgres.

Based on your description:

  Project:      SaaS invoicing tool for freelancers
  Architecture: DDD recommended (billing, users, invoices detected)
  Stack:        Go, Next.js, Postgres

  Rules:
  1. [x] code-quality     — SOLID, naming, structure
  2. [x] testing          — TDD, mock anti-patterns
  3. [x] security         — payment handling detected
  4. [x] error-handling   — typed errors, no silent catches
  5. [x] frontend         — Next.js detected
  6. [x] architecture     — DDD recommended
  7. [x] go               — Go detected
  8. [x] nextjs           — Next.js detected

  Type numbers to toggle (e.g. "5 6"), or press enter to accept:
```

Press enter → keel generates everything.

## What Gets Generated

```
your-project/
├── .keel/
│   └── config.yaml          — your project config
├── .claude/
│   ├── rules/
│   │   ├── code-quality.md  — SOLID, naming, size limits
│   │   ├── testing.md       — TDD, mock anti-patterns
│   │   ├── security.md      — input validation, auth checks
│   │   ├── error-handling.md — typed errors, no silent catches
│   │   ├── go.md            — Go idioms, error patterns
│   │   └── nextjs.md        — App Router, RSC, performance
│   └── settings.json        — PreCompact + PreToolUse hooks
├── docs/
│   ├── soul.md              — project identity
│   ├── decisions/           — architecture decision records
│   ├── invariants/          — hard constraints
│   └── product/
│       ├── spec.md          — product vision and roadmap
│       └── plans/           — execution plans
└── CLAUDE.md                — keel block injected (safe merge)
```

## First Workflow

After init, your typical workflow:

```
/keel:context   → load project context into session
/keel:plan      → create a phased plan for a task
/keel:status    → check plan progress and governance health
```

## Commit to Git

The `.keel/` and `.claude/` directories should be committed. Your team gets the same guardrails automatically.

```bash
git add .keel/ .claude/ docs/ CLAUDE.md
git commit -m "chore: initialize keel"
```

## Coming from dof?

If your project has a `.dof/` directory, run `/keel:migrate` instead of `/keel:init`. It will move everything over and fill the gaps.
