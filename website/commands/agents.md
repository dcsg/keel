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

Specialist agents are role-based Claude configurations installed in `.claude/agents/`. Each agent has a defined domain, trigger conditions that tell Claude when to delegate to it, and constraints that keep it focused. No agent has a fixed model — the model is assigned per plan phase based on task complexity (see [Model selection](/agents#model-selection)).

When Claude sees a task that matches an agent's domain, it delegates automatically. You can also invoke any agent directly by name.

## Available agents

keel ships 18 specialist agents organized in four tiers.

### Always installed

| Agent | Domain |
|-------|--------|
| `architect` | System design, ADRs, component boundaries, trade-off analysis |
| `docs` | Documentation accuracy, gap detection, runbooks |
| `qa` | Testing strategy, test writing, coverage |

### Common (most projects)

| Agent | Domain |
|-------|--------|
| `sre` | Reliability, observability, deployment, infrastructure |
| `security` | OWASP, auth, secrets, threat modeling |
| `pm` | Requirements, scope, user stories, PRDs |
| `api` | REST/GraphQL/gRPC contracts, versioning, breaking changes |

### Stack-triggered (installed when detected)

| Agent | Triggered by |
|-------|-------------|
| `backend` | Go, TypeScript, Python, PHP, Ruby, Java, Rust |
| `frontend` | TypeScript + React/Vue/Angular/Svelte/Next.js |
| `dba` | Go, Python, Java (database-heavy stacks) |
| `ux` | React, Next.js, Vue, Angular, Svelte, React Native, Flutter |
| `platform` | Docker, Kubernetes, Terraform |
| `mobile` | React Native, Flutter, Swift, Kotlin |
| `seo` | Next.js, web content projects |
| `gtm` | Web content projects |
| `data` | Data pipeline projects |

### Optional (available on request)

| Agent | Domain |
|-------|--------|
| `performance` | Optimization, profiling, caching |
| `compliance` | HIPAA, PCI, SOC2, GDPR |

## Subcommands

### No argument — list agents

```
/keel:agents

Installed agents (11):
  architect   — System design, ADRs, trade-off analysis
  docs        — Documentation accuracy, gap detection
  qa          — Testing strategy, test writing, coverage
  sre         — Reliability, observability, deployment
  security    — OWASP, auth, secrets, threat modeling
  pm          — Requirements, scope, user stories
  api         — REST/GraphQL/gRPC contracts, versioning
  backend     — Backend implementation, business logic
  dba         — Schema, migrations, queries, data modeling
  ...

Available (not installed):
  performance — Performance profiling and optimization
  compliance  — HIPAA, PCI, SOC2, GDPR

/keel:agents add performance
```

### `add {slug}` — install an agent

```
/keel:agents add performance
```

Copies the agent template from `~/.keel/templates/agents/` to `.claude/agents/`. Commit the new file so your whole team gets it.

### `remove {slug}` — uninstall an agent

```
/keel:agents remove pm
```

Deletes `.claude/agents/{slug}.md`.

### `show {slug}` — view agent details

```
/keel:agents show dba
```

Prints the full agent system prompt — domain identity, expertise, constraints.

### `suggest` — get recommendations for your stack

```
/keel:agents suggest

Recommended agents for your stack (go, chi):

  Already installed:
    architect
    backend
    dba
    qa

  Recommended (not installed):
    sre    — Reliability, observability, deployment
    api    — REST/GraphQL/gRPC contracts, versioning
```

## How agents are chosen at init

When you run `/keel:init`, keel reads `~/.keel/templates/agents/_registry.yaml` and selects agents based on your detected stack:

- **Always**: `architect`, `docs`, `qa`
- **Most projects**: + `sre`, `security`, `pm`, `api`
- **Go detected**: + `backend`, `dba`
- **TypeScript detected**: + `frontend`, `backend`
- **React/Vue/Angular/Svelte**: + `frontend`, `ux`
- **Next.js**: + `frontend`, `ux`, `seo`
- **Docker/K8s/Terraform**: + `platform`
- **Security keywords in project-context.md** (payment, auth, HIPAA): + `security`
- **Compliance keywords**: + `compliance`

## Customizing agents

Two mechanisms prevent `/keel:upgrade` from overwriting your changes:

**File marker** — add `<!-- keel:custom -->` anywhere in the agent file:

```yaml
---
name: dba
description: "..."
<!-- keel:custom -->
tools:
  - Read
  - Grep
  - Glob
---
```

**Config** — list agents in `.keel/config.yaml`:

```yaml
agents:
  custom:
    - dba              # don't overwrite on upgrade
    - my-team-reviewer # not from keel templates
```

Both are supported. Config takes precedence. Agents not in the keel registry are always skipped by upgrade — they have no matching template to compare against.

## Creating custom agents

Create a `.md` file in `.claude/agents/`:

```yaml
---
name: my-domain-expert
description: "Reviews X for Y. Use proactively when Z files are modified."
tools:
  - Read
  - Grep
  - Glob
---

You are a {domain} specialist...
```

The `description:` field is what Claude reads to decide when to delegate. Make it specific and include trigger conditions.

## Natural language triggers

- "what agents do we have?" → `/keel:agents`
- "add the performance agent" → `/keel:agents add performance`
- "show me the dba agent" → `/keel:agents show dba`
- "what agents are recommended for my stack?" → `/keel:agents suggest`
