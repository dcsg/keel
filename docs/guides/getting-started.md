# Getting Started with Keel

Keel is a governance layer for agentic engineering. It enforces your coding standards, persists your architectural decisions, and makes agent behavior reproducible across every session and every engineer.

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
│   ├── project-context.md   — project identity
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

## Capturing Decisions as You Work

As you build, keel watches the conversation and suggests when something is worth capturing:

```
💡 This looks like an ADR — run `/keel:adr` to capture it.
💡 This is an invariant — run `/keel:invariant` to capture it.
💡 This looks like a PRD — run `/keel:prd` to capture it.
```

You can also run them explicitly at any time:

```
/keel:adr use postgres for persistence     → docs/decisions/001-use-postgres.md
/keel:invariant no floats for money        → docs/invariants/INV-001-no-floats.md
/keel:prd webhook delivery with retries    → docs/product/prds/PRD-001-webhooks.md
```

Or with no argument to extract from the current conversation:

```
/keel:adr         → extracts the last architectural decision discussed
/keel:invariant   → extracts the last hard constraint discussed
/keel:prd         → extracts the last feature requirement discussed
```

## Specialist Agents

Keel installs specialist agent templates in `.claude/agents/` based on your stack. These give Claude a defined "role" when you invoke it as an agent — making its expertise and constraints transparent.

Agents installed by default (based on stack):

| Agent | Role |
|-------|------|
| `principal-architect` | System design, ADRs, trade-off analysis |
| `staff-engineer` | Implementation leadership, code review |
| `senior-backend` | Backend implementation, APIs, data layers |
| `principal-dba` | Database design, query optimization, migrations |
| `staff-security` | Security review, OWASP, threat modeling |
| `staff-sre` | Reliability, observability, deployment |
| `staff-qa` | Testing strategy, test writing, coverage |
| `staff-frontend` | Frontend, React/Next.js, accessibility |
| `principal-ux` | UX/UI review, user flows, design systems |
| `senior-pm` | Product requirements, PRD writing |
| `senior-api` | API design, REST/GraphQL, versioning |

```
/keel:agents              → list installed and available agents
/keel:agents add {slug}   → install an additional agent
/keel:agents show {slug}  → show an agent's full prompt
```

## Memory Persistence

After running `/keel:context`, keel writes a compact snapshot to Claude's auto-memory (`~/.claude/projects/.../memory/MEMORY.md`). This is auto-loaded at the start of every future session — so Claude always knows the project name, stack, active plan, and hard constraints without needing to run `/keel:context` first.

The `SessionStart` hook detects when memory is stale (>7 days old) and reminds you to refresh.

## Connecting to Project Management

Wire keel to your ticket system for native access in Claude:

```
/keel:mcp add linear    → configure Linear (needs LINEAR_API_KEY)
/keel:mcp add github    → configure GitHub (needs GITHUB_TOKEN)
/keel:mcp add jira      → configure Jira (needs JIRA_URL + JIRA_USERNAME + JIRA_API_TOKEN)
/keel:mcp               → show status and required env vars
```

MCP config is committed to git (`.mcp.json`) — your team inherits the server config. Each member adds their own API keys to their local environment.

## Team Setup

Share keel config with your team:

```bash
git add .keel/ .claude/ .mcp.json docs/ CLAUDE.md
git commit -m "chore: initialize keel"
git push
```

New team members:
```
git clone ... && cd project
/keel:team setup    → validates environment and lists missing env vars
```

## Commit to Git

The `.keel/` and `.claude/` directories should be committed. Your team gets the same guardrails automatically.

```bash
git add .keel/ .claude/ docs/ CLAUDE.md
git commit -m "chore: initialize keel"
```

