# Specialist Agents

keel ships 18 specialist agent templates covering domain review and implementation. This guide explains what agents are, how routing works, how they interact with rule packs, and how model selection works per phase.

## What agents are

Specialist agents are Claude subagents with a defined domain focus. Each agent has:

- A `description:` field that tells Claude when to activate it
- Domain expertise scoped to one area (database, security, frontend, etc.)
- Constraints that keep it from straying outside its domain

Agents don't replace Claude — they add specialist focus. Claude is the engineer running the session. Agents are the specialists who review plans and code, and implement self-contained tasks in their domain.

## Two types of agents

**Advisory agents** (read-only) — review plans and code, return findings with severity levels. They never write files. This keeps invocations fast and non-destructive.

**Implementation agents** (read and write) — both review AND implement. Claude delegates self-contained implementation tasks to them.

| Type | Agents |
|------|--------|
| Advisory | `architect`, `dba`, `security`, `api`, `sre`, `platform`, `docs`, `pm`, `ux`, `data`, `performance`, `compliance`, `seo`, `gtm` |
| Implementation | `backend`, `frontend`, `qa`, `mobile` |

## The 18 agents

### Always installed

| Agent | Domain |
|-------|--------|
| `architect` | System design, ADRs, component boundaries, architectural trade-offs |
| `docs` | Documentation accuracy, gap detection, runbooks |
| `qa` | Testing strategy, test writing, coverage |

### Common (most projects)

| Agent | Domain |
|-------|--------|
| `sre` | Reliability, observability, deployment, infrastructure |
| `security` | OWASP, auth patterns, secret management, threat modeling |
| `pm` | Product requirements, prioritization, user stories |
| `api` | API contracts, versioning, breaking changes, documentation |

### Stack-triggered

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

### Optional (add with `/keel:agents add {slug}`)

| Agent | Domain |
|-------|--------|
| `performance` | Performance bottlenecks, profiling, optimization |
| `compliance` | HIPAA, PCI, SOC2, GDPR |

## How routing works

Claude routes to agents using their `description:` field. Each description includes trigger conditions:

```yaml
# dba agent description
description: "Reviews and implements database schema, migrations,
  queries, and data modeling. Use proactively when migration or
  schema files are modified."
```

When Claude sees you working on a migration file, it reads this description and delegates to the dba agent.

Three routing paths:

**Auto-routing** — Claude reads file context and the agent descriptions, delegates when there's a match.

**Command routing** — keel's commands route to the right specialists automatically:

| You say | What happens |
|---------|-------------|
| "review this" | `/keel:review` detects changed file domains, routes to matching agents |
| "audit the codebase" | `/keel:audit` routes to `security` and `sre` agents |
| "create a plan" | `/keel:plan` assigns reviewers to each phase based on domain |
| "generate spec artifacts" | `/keel:spec-artifacts` routes each artifact to its domain specialist |

**Direct delegation** — ask by name: "have the dba review this migration"

### Plan pre-flight review

When you run `/keel:plan`, keel scans the plan content for domain signals and invokes the relevant advisors before execution begins:

| Plan mentions... | Agent invoked |
|-----------------|--------------|
| SQL, migration, schema, index | `dba` |
| docker, terraform, helm, k8s | `platform`, `sre` |
| auth, JWT, payment, token, RBAC | `security` |
| API, endpoint, REST, webhook | `api` |
| bounded context, hexagonal, layer | `architect` |
| performance, cache, latency | `performance` |

Each advisor reviews only their domain and returns findings before you start building.

### Post-implementation review

`/keel:review` classifies changed files by domain and routes the diff to the relevant agents:

| Changed files | Agent invoked |
|---------------|--------------|
| `*.sql`, `migration*`, `schema*` | `dba` |
| `Dockerfile*`, `docker-compose*`, `*.tf`, `helm/*` | `sre` |
| `*auth*`, `*jwt*`, `*payment*`, `*token*` | `security` |
| `*route*`, `*handler*`, `*controller*`, `*api*` | `api` |
| `*cache*`, `*perf*`, `*optimize*` | `performance` |

## How agents work with rule packs

Agents and rule packs serve different purposes and work at different levels:

| | Rule packs | Agents |
|--|------------|--------|
| **When** | Every file, every session | When the task matches their domain |
| **How** | Loaded into context automatically | Spawned as subagents with isolated context |
| **What** | Static coding standards | Dynamic specialist review |
| **Language** | Language-specific (go.md, typescript.md) | Language-agnostic (dba reviews any SQL) |

They work together: the Go rule pack teaches Claude Go patterns. The backend agent reviews whether those patterns were applied correctly. The rule pack prevents violations. The agent catches what the rules missed.

**Example:** Your Go rule pack says "always wrap errors with context." Your backend agent reviews a PR and catches a bare `return err` — even though the rule told Claude not to do this, the agent catches it in review.

## Severity model

All advisory agents use the same three-level model:

| Level | Meaning |
|-------|---------|
| Critical | Must address before shipping — data loss, security breach, broken contract |
| Warning | Should fix, not blocking |
| OK | Domain looks healthy |

Critical findings trigger quality gates that block progression. See [Quality Gates](/governance/gates).

## Model selection — per phase, not per agent

Agents don't have a fixed model. No `model:` field exists in any agent template. The model is determined by what's being done and how complex it is — assigned at the plan phase level.

When you create a plan, each phase includes a complexity assessment and suggested model:

```
Phase 1: Multi-tenant schema design
  Complexity: High — architecture decision with security implications
  Suggested model: opus
  Reviewers: architect, dba, security

Phase 3: CRUD handler implementation
  Complexity: Medium
  Suggested model: sonnet
  Reviewers: backend, api
```

Complexity-to-model mapping:

| Task | Complexity | Suggested model |
|------|-----------|----------------|
| Architecture/design decisions | High | opus |
| Complex implementation (domain logic, state machines) | High | opus or sonnet |
| Standard implementation (CRUD, handlers, tests) | Medium | sonnet |
| Mechanical tasks (formatting, docs, simple tests) | Low | haiku or sonnet |
| Critical review (security, schema, API contracts) | High | opus |
| Routine review (formatting, naming, small fixes) | Low | sonnet or haiku |

When agents run outside a plan (ad-hoc review, direct delegation), Claude uses its default model from the main conversation.

## Managing agents

**Full agent roster:** [/agents](/agents)

**List installed agents:**
```
/keel:agents
```

**Add an optional agent:**
```
/keel:agents add performance
/keel:agents add compliance
```

**Get recommendations for your stack:**
```
/keel:agents suggest
```

**Command reference:** [/keel:agents](/commands/agents)

## Adding custom agents

Create a file in `.claude/agents/my-agent.md`:

```yaml
---
name: my-domain-expert
description: "Reviews X for Y. Use proactively when Z files are modified."
tools:
  - Read
  - Grep
  - Glob
---

You are a {domain} specialist with deep knowledge of...
```

Add `<!-- keel:custom -->` to the file or list it in `.keel/config.yaml` under `agents.custom` to prevent `/keel:upgrade` from overwriting it.

## Agent memory

Two agents have persistent memory across sessions:

- `dba` — accumulates schema knowledge, migration history, query patterns
- `security` — accumulates threat model context, past findings, auth decisions

Memory stores at `.claude/agent-memory/{agent-name}/` and loads automatically. The dba agent remembers your schema decisions from last week.

To add memory to any agent, add `memory: project` to its frontmatter.
