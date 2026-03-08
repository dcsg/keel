# /keel:agents

List, install, and manage specialist agent templates.

## Usage

```
/keel:agents
/keel:agents add {slug}
/keel:agents remove {slug}
/keel:agents show {slug}
/keel:agents suggest
```

## What are specialist agents?

Specialist agents are role-based Claude configurations installed in `.claude/agents/`. Each agent has:
- A defined role (Principal Architect, Staff Security Engineer, etc.)
- Domain expertise specific to that role
- Constraints (what the role never does)
- A prompt to name its role before starting, making its reasoning transparent

When you ask Claude to act as a specialist, it applies that lens explicitly — you can see which role it's taking and why.

## Available agents

| Agent | Role |
|-------|------|
| `principal-architect` | System design, ADRs, trade-off analysis |
| `staff-engineer` | Implementation leadership, code review, refactoring |
| `senior-backend` | Backend implementation, APIs, data layers |
| `principal-dba` | Database design, query optimization, migration safety |
| `staff-security` | Security review, OWASP, threat modeling |
| `staff-sre` | Reliability, observability, deployment |
| `staff-qa` | Testing strategy, test writing, coverage |
| `staff-frontend` | Frontend, React/Next.js, accessibility |
| `principal-ux` | UX/UI review, user flows, design systems |
| `senior-pm` | Product requirements, PRD writing |
| `senior-api` | API design, REST/GraphQL, versioning |
| `senior-performance` | Performance profiling and optimization |
| `principal-data` | Data modeling, analytics, pipelines |

## Subcommands

### No argument — list agents

```
/keel:agents

Installed agents (9):
  principal-architect  — System design, ADRs, trade-off analysis
  staff-engineer       — Implementation leadership, code review
  senior-backend       — Backend implementation, business logic, APIs
  ...

Available (not installed):
  principal-data       — Data modeling, analytics, pipelines
  senior-performance   — Performance profiling and optimization

/keel:agents add principal-data
```

### `add {slug}` — install an agent

```
/keel:agents add staff-security
```

Copies the agent template from `~/.keel/templates/agents/` to `.claude/agents/`. Commit the new file so your whole team gets it.

### `remove {slug}` — uninstall an agent

```
/keel:agents remove senior-pm
```

Deletes `.claude/agents/{slug}.md`.

### `show {slug}` — view agent details

```
/keel:agents show principal-dba
```

Prints the full agent system prompt — role identity, expertise, constraints.

### `suggest` — get recommendations for your stack

```
/keel:agents suggest

Recommended agents for your stack (go, chi):

  Already installed:
    ✅ principal-architect
    ✅ staff-engineer
    ✅ senior-backend

  Recommended (not installed):
    📦 principal-dba    — Database design, query optimization, migration safety
    📦 staff-qa         — Testing strategy, test writing, coverage analysis
```

## How agents are chosen at init

When you run `/keel:init`, keel reads `~/.keel/templates/agents/_registry.yaml` and selects agents based on your detected stack:

- **Always**: `principal-architect`, `staff-engineer`
- **Go detected**: `senior-backend`, `principal-dba`, `staff-qa`
- **React/Next.js detected**: `staff-frontend`, `principal-ux`
- **Security keywords in soul.md** (payment, auth, HIPAA): `staff-security`
- **All projects**: `staff-sre`, `staff-qa`, `senior-pm`, `senior-api`

## Natural language triggers

- "what agents do we have?" → `/keel:agents`
- "add the security agent" → `/keel:agents add staff-security`
- "show me the DBA agent" → `/keel:agents show principal-dba`
