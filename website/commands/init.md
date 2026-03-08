# /keel:init

Intelligent onboarding. Detects your project, infers architecture and rules, and installs everything.

## Usage

```
/keel:init
```

No arguments. Keel figures out the rest.

## How It Works

### Step 1 — Detect Project Age

Keel checks git history to determine if this is a greenfield or established project.

- **< 5 commits** → Greenfield flow
- **5+ commits** → Established flow

### Step 2A — Greenfield Flow

Keel asks one question:

> What are you building?

Describe your project in plain language. Keel infers:
- Architecture pattern (simple, layered, DDD)
- Language and framework
- Which rules make sense

Then shows you the inferred selections to confirm or adjust.

### Step 2B — Established Flow

Keel runs a codebase audit using a subagent:
- Languages and versions
- Frameworks and dependencies
- Directory structure pattern
- Test setup
- Existing linting config
- Git history depth

Then recommends rules based on what it finds.

### Step 3 — Rule Selection

Both flows end at the same toggle UI:

```
  Rules:
  1. [x] code-quality     — SOLID, naming, structure
  2. [x] testing          — TDD, mock anti-patterns
  3. [x] security         — API surface detected
  4. [x] error-handling   — typed errors, no silent catches
  5. [ ] frontend         — no UI detected
  6. [x] architecture     — DDD recommended
  7. [x] go               — Go detected
  8. [x] chi              — Chi detected

  Type numbers to toggle (e.g. "5 6"), or press enter to accept:
```

### Step 4 — Generation

Keel generates:

| File | Purpose |
|------|---------|
| `.keel/config.yaml` | Source of truth for rules and config |
| `.claude/rules/*.md` | Installed guardrails (tagged `<!-- keel:generated -->`) |
| `.claude/agents/*.md` | Specialist agents matched to your stack |
| `.claude/settings.json` | Four lifecycle hooks |
| `CLAUDE.md` | Project summary block (safe merge — never overwrites existing content) |
| `docs/soul.md` | Project identity |
| `docs/product/spec.md` | Product spec stub |
| `docs/decisions/` | Architecture decisions directory |
| `docs/invariants/` | Hard constraints directory |
| `.github/pull_request_template.md` | PR template (if opted in) |

### Specialist agents installed

Keel installs role-based agents in `.claude/agents/` based on your detected stack. Each agent has a defined role, domain expertise, and constraints. When invoked, it names its role before starting so you know exactly what lens is applied.

Agents always installed: `principal-architect`, `staff-engineer`, `staff-sre`, `staff-qa`, `senior-pm`, `senior-api`

Stack-matched examples: Go → `senior-backend`, `principal-dba` · React/Next.js → `staff-frontend`, `principal-ux` · security keywords detected → `staff-security`

Manage agents with `/keel:agents`.

### Hooks installed

Four hooks protect every session:

**SessionStart** — fires when the project opens. Checks if keel auto-memory is stale (>7 days) and prompts to run `/keel:context` to refresh.

**PreToolUse (Write/Edit)** — warns if `docs/soul.md` is missing, indicating init is incomplete.

**Stop** — after every Claude response, scans for artifact signals and prompts Claude to suggest `/keel:adr`, `/keel:invariant`, or `/keel:prd` when appropriate. More reliable than asking Claude to self-audit in CLAUDE.md.

**PreCompact** — before context compaction, Claude is reminded to update the active plan's progress table so nothing is lost.

## Re-running

Running `/keel:init` again on an existing keel project updates rules from config. Rule files tagged `<!-- keel:generated -->` are updated from templates. Files where that tag is missing were manually edited — keel leaves them untouched and warns you.
