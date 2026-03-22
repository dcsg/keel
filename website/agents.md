---
title: "Agents — Specialist Review and Implementation"
description: "18 domain agents that review plans, audit code, and implement features. How they work with rule packs, how routing works, how to customize."
---

# Agents

keel ships 18 specialist agents. Each covers one domain — architecture, database, security, API design, and more. Claude routes to them automatically based on what you're working on.

Agents don't replace Claude — they add domain-specific focus. Claude is the engineer. Agents are the specialists who review before you ship.

## How the system works

Three layers govern what Claude produces:

```
Rule packs (.claude/rules/)     → static standards, always loaded
Agents (.claude/agents/)        → specialist review and implementation
Plan phases                     → assign agents + model to each phase
```

**Rule packs** fire automatically on every file. Go rules fire on `.go` files. Security rules fire on every file. Claude follows them without being told.

**Agents** activate in three ways:
1. **Auto-routing** — Claude reads the agent's description and delegates when the task matches
2. **Command routing** — `/keel:review`, `/keel:audit`, `/keel:plan` route to the right specialists
3. **You ask** — "have the dba review this migration"

**Plan phases** assign specific agents as reviewers and suggest a model based on complexity:

```
Phase 2: Database layer
  Complexity: Medium
  Suggested model: sonnet
  Reviewers: dba, security
```

## The roster

### Advisory agents (read-only)

These review and advise. They never write code.

| Agent | Domain | When it activates |
|---|---|---|
| `architect` | System design, ADRs, component boundaries | Architecture decisions, design trade-offs |
| `dba` | Schema, migrations, queries, data modeling | Migration files, schema changes |
| `security` | OWASP, auth, secrets, threat modeling | Auth code, payment handling, secrets |
| `api` | REST/GraphQL/gRPC contracts, versioning | API handlers, route definitions |
| `sre` | Reliability, observability, deployment | Infra configs, health checks |
| `platform` | CI/CD, containers, IaC, build systems | Dockerfile, CI configs, Terraform |
| `docs` | Documentation accuracy, gap detection | Doc files, README changes |
| `pm` | Requirements, scope, user stories | PRDs, specs, product decisions |
| `ux` | Accessibility, design patterns, WCAG | Frontend components, forms |
| `data` | Data pipelines, analytics, ETL | Data processing code |
| `performance` | Optimization, profiling, caching | Performance-sensitive code |
| `compliance` | HIPAA, PCI, SOC2, GDPR (optional) | Regulated data handling |
| `seo` | Technical SEO, structured data, Core Web Vitals (optional) | Web pages, meta tags |
| `gtm` | Analytics, tracking events, attribution (optional) | Tracking code, events |

### Implementation agents (write code)

These both review AND implement. Claude delegates self-contained implementation tasks to them.

| Agent | Domain | When it activates |
|---|---|---|
| `backend` | Server-side implementation, error handling | Backend source files |
| `frontend` | Components, state, accessibility, performance | Frontend source files |
| `qa` | Testing strategy, test writing, coverage | Test files, coverage gaps |
| `mobile` | iOS/Android/React Native/Flutter (optional) | Mobile source files |

## How routing works

Claude picks agents based on their `description:` field. Each agent's description includes a trigger condition:

```yaml
# dba agent description
description: "Reviews and implements database schema, migrations,
  queries, and data modeling. Use proactively when migration or
  schema files are modified."
```

When Claude sees you working on a migration file, it reads this description and knows to involve the dba agent.

For explicit routing, keel's commands handle it:

| You say | What happens |
|---|---|
| "review this" | `/keel:review` detects changed file domains, routes to matching agents |
| "audit the codebase" | `/keel:audit` routes to security + sre agents |
| "create a plan" | `/keel:plan` assigns reviewers to each phase based on domain |
| "have dba review this" | Claude routes directly to the dba agent |

## Model selection — per phase, not per agent

Agents don't have a fixed model. The model is chosen based on what's being done and how complex it is.

```
Architecture design decisions  → opus (complex reasoning)
Complex implementation         → sonnet (balanced)
Standard implementation        → sonnet
Mechanical tasks (docs, tests) → haiku or sonnet
Critical review (security)     → opus
Routine review                 → sonnet
```

When you create a plan, each phase includes a complexity assessment and suggested model:

```
Phase 1: Multi-tenant schema design
  Complexity: High — architecture decision with security implications
  Suggested model: opus
  Reviewers: architect, dba, security
```

Claude follows the suggestion. No model is hardcoded in agent templates.

## Which agents get installed

keel detects your stack and installs the right agents:

| Detection | Agents installed |
|---|---|
| Every project | architect, docs, qa |
| Most projects | + sre, security, pm, api |
| Go detected | + backend, dba |
| TypeScript detected | + frontend, backend |
| React/Vue/Angular | + frontend, ux |
| Next.js | + frontend, ux, seo |
| Docker/K8s/Terraform | + platform |
| Payment/auth keywords | + security |
| Compliance keywords | + compliance |

Optional agents (performance, data, compliance, mobile, seo, gtm) are available via:

> "Add the performance agent"

## Agents + rule packs

Agents and rule packs serve different purposes:

| | Rule packs | Agents |
|---|---|---|
| **When** | Every file, every session | When the task matches their domain |
| **How** | Loaded into context automatically | Spawned as subagents with isolated context |
| **What** | Static coding standards | Dynamic specialist review |
| **Language** | Language-specific (go.md, typescript.md) | Language-agnostic (dba reviews any SQL) |

They work together: the Go rule pack teaches Claude Go patterns. The backend agent reviews whether those patterns were applied correctly. The rule pack prevents violations. The agent catches what the rules missed.

**Example:** Your Go rule pack says "always wrap errors with context." Your backend agent reviews a PR and catches `return err` without wrapping — even though the rule pack told Claude not to do this, the agent catches it in review.

## Customizing agents

Three levels of customization:

### 1. Edit an installed agent

Agents install to `.claude/agents/`. Edit them directly:

```bash
# Open the dba agent
vim .claude/agents/dba.md
```

Add `<!-- keel:custom -->` to prevent `/keel:upgrade` from overwriting your changes:

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

### 2. Add to config

List custom agents in `.keel/config.yaml` to protect them from upgrades:

```yaml
agents:
  custom:
    - dba              # don't overwrite on upgrade
    - my-team-reviewer # not from keel templates
```

### 3. Create a new agent

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

You are a {domain} specialist. {What you do and why it matters.}

## Domain Expertise

- {area 1}
- {area 2}

## How You Work

1. {step 1}
2. {step 2}

## Constraints

- {constraint} — {why}

## Outputs

- {what you produce}

---

REMEMBER: {the one thing that matters most}
```

The `description:` field is what Claude reads to decide when to delegate. Make it specific and include trigger conditions.

## Agent memory

Two agents have persistent memory across sessions:

- `dba` — accumulates schema knowledge, migration history, query patterns
- `security` — accumulates threat model context, past findings, auth decisions

Memory is stored at `.claude/agent-memory/{agent-name}/` and loads automatically. This means the dba agent remembers your schema decisions from last week.

To add memory to any agent, add `memory: project` to its frontmatter.
