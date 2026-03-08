# Specialist Agents

Keel ships 16 specialist agent templates that act as domain experts inside your Claude Code sessions. This guide explains how they work, when they show up, and how to extend them.

## How proactive routing works

In keel v3, specialist agents don't wait to be summoned. Keel routes to them automatically at three moments:

### 1. Session start

The `SessionStart` hook inspects what changed in git since your last session and surfaces relevant agents:

```
📋 Keel — since your last session (2d ago):
   3 migration/schema files changed, 2 API files changed
   Relevant agents: principal-dba, senior-api
   Run /keel:context to load full project context.
```

This means when you open a project after working on authentication, the security agent is already top of mind before you write a line of code.

### 2. Pre-flight plan review

When you run `/keel:plan`, keel scans the plan content for domain signals and invokes the right advisors before execution begins:

| Plan mentions... | Agent invoked |
|-----------------|--------------|
| SQL, migration, schema, index | `principal-dba` |
| docker, terraform, helm, k8s | `staff-sre` |
| auth, JWT, payment, token, RBAC | `staff-security` |
| API, endpoint, REST, webhook | `senior-api` |
| bounded context, hexagonal, layer | `principal-architect` |
| N+1, cache, latency, benchmark | `senior-performance` |

Each advisor reviews only their domain and returns findings before you start building.

### 3. Post-implementation review

`/keel:review` classifies changed files and routes the diff to the relevant agents. A migration file triggers the DBA. Auth changes trigger the security agent. You get targeted expert review without having to know which agents to ask.

---

## The 16 agents

### Always installed

| Agent | Role |
|-------|------|
| `principal-architect` | System design, bounded contexts, architectural trade-offs |
| `staff-engineer` | Code quality, technical leadership, cross-cutting concerns |

### Stack-matched (installed based on your detected stack)

| Agent | Role |
|-------|------|
| `senior-backend` | Backend patterns, service design, API implementation |
| `principal-dba` | Schema design, query optimization, migration safety |
| `staff-security` | OWASP, auth patterns, secret management, threat modeling |
| `staff-sre` | Deployment, observability, reliability, infrastructure |
| `staff-qa` | Test strategy, coverage gaps, test quality |
| `staff-frontend` | UI components, accessibility, state management |
| `principal-ux` | User experience, interaction design, information architecture |
| `senior-pm` | Product requirements, prioritization, user stories |
| `senior-api` | API contracts, versioning, breaking changes, documentation |
| `senior-performance` | Performance bottlenecks, profiling, optimization |
| `principal-data` | Data modeling, pipelines, analytics architecture |
| `staff-docs` | Documentation gaps, API docs, runbooks |

### Legacy (always present for backward compatibility)

| Agent | Role |
|-------|------|
| `reviewer` | General code review |
| `debugger` | Systematic root cause analysis |

---

## Advisor vs executor

All specialist agents in keel are **advisors** — they read and comment, never write files. This is intentional (see ADR-004).

- **Advisors**: read plans/code, return findings with severity levels, run in forked subagents
- **Executors**: out of scope — Claude Code handles worktrees, agents, and parallelism natively

This boundary keeps advisor invocations fast and non-destructive. An advisor can't accidentally break your code.

---

## Severity levels

All advisors use the same three-level model:

| Level | Meaning |
|-------|---------|
| 🔴 Critical | Must address before shipping — data loss, security breach, broken contract |
| 🟡 Warning | Should fix, not blocking |
| 🟢 OK | Domain looks healthy |

---

## Managing agents

**List installed agents:**
```
/keel:agents
```

**Add an optional agent:**
```
/keel:agents add staff-docs
/keel:agents add senior-performance
```

**View available agents not yet installed:**
```
/keel:agents available
```

---

## Adding custom agents

Create a file in `.claude/agents/my-agent.md` with a frontmatter and persona:

```markdown
---
name: my-domain-expert
description: "Expert in our internal billing system"
---

You are a billing system expert with deep knowledge of our payment flows...
```

Custom agents are never overwritten by `/keel:upgrade` — keel only manages files that match its registry.

---

## Disabling proactive routing

Pre-flight review can be skipped for a single plan:
```
/keel:plan --no-review
```

Session-start git analysis can be disabled permanently in `.keel/config.yaml`:
```yaml
hooks:
  session-start-git: false
```
