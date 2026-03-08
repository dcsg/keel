# ADR-004: Advisor Orchestration Pattern

**Status:** Accepted
**Date:** 2026-03-08
**Deciders:** Daniel Gomes

## Context

Keel v2 introduced 17 specialist agents (principal-architect, principal-dba, staff-sre, staff-security, etc.) but they are entirely passive — users must manually invoke them. This creates the same problem keel was built to solve: you have to *remember* to involve the right expert at the right time.

The vision is "Claude behaves like a senior engineer who's been on the team for months." A senior engineer knows when to pull in the DBA before a migration, knows to flag a security concern before it ships, knows who needs to review what. Passive agents don't deliver this.

Keel v3 introduces **proactive advisor orchestration**: agents are automatically routed to relevant tasks based on domain signal detection, without user invocation.

## Decision

### Advisor orchestration is in scope. Execution orchestration is not.

The distinction is precise and must be maintained:

**Advisors (in scope):**
- Read plans, code, and conversation
- Return findings, warnings, and recommendations
- Never write files, never modify state
- Run in isolated forked subagents (context: fork)
- Invoked automatically by keel based on domain signals

**Executors (out of scope):**
- Write code, modify files, run commands
- Coordinate multi-agent parallel execution
- Manage worktrees or parallel contexts
- That is Claude Code's native responsibility

### Domain Signal Detection

Keel detects domain signals from task descriptions, plan content, and changed files:

| Signal Keywords | Agent Invoked |
|----------------|---------------|
| SQL, query, schema, migration, index, database | principal-dba |
| deploy, docker, kubernetes, terraform, infra, CI, helm | staff-sre |
| auth, JWT, OAuth, payment, PCI, HIPAA, token, secret | staff-security |
| API, endpoint, REST, GraphQL, route, contract | senior-api |
| bounded context, domain, architecture, refactor | principal-architect |
| performance, N+1, cache, latency, throughput | senior-performance |

### Three Advisor Moments

Proactive advisory fires at three moments in the workflow:

1. **Session start** — git-aware summary of what changed since last session, which domains are affected, which agents are relevant
2. **Pre-flight** — after `/keel:plan` creates a plan, relevant specialists review it before execution begins
3. **Post-implementation** — `/keel:review` routes to specialists based on what was actually built

### Severity Model

Advisor findings use a three-level severity model:
- 🔴 **Critical** — must be addressed before shipping (security vulnerability, data loss risk, broken contract)
- 🟡 **Warning** — should be addressed, not blocking (missing index, no rollback, test gap)
- 🟢 **OK** — domain looks healthy, notable positive patterns

## Alternatives Considered

**Full execution orchestration**
Auto-route tasks to agents that write code, not just review it. Rejected: violates keel's "no execution orchestration" principle from ADR-001. Claude Code handles execution natively via worktrees and subagents.

**PostToolUse advisory hooks**
Fire advisor agents after each file write to catch domain issues mid-edit. Rejected: PostToolUse hooks can only run shell commands, not Claude agents. Would require nested `claude -p` calls — messy, slow, breaks session context.

**Manual invocation only (status quo)**
Keep agents passive, require users to invoke them. Rejected: creates the same "you have to remember" problem keel was built to solve.

## Consequences

- Pre-flight review adds latency to `/keel:plan` — acceptable because plan creation is not time-critical
- `/keel:review` requires git diff — only meaningful after commits or with staged changes
- Domain signal detection is heuristic (keyword-based) — false positives possible, false negatives acceptable (better to over-route than miss a critical domain)
- Agent findings are advisory — users always decide whether to act on them
- Two new commands added: `/keel:audit` (security), `/keel:review` (post-implementation)
- Two enhanced workflows: `/keel:plan` (pre-flight), session start hook (git-aware)
- One new command added: `/keel:session` (end-of-session sweep)

## Related

- ADR-001: Keel Architecture (no execution orchestration)
- PLAN-006: Keel v3 — Proactive Intelligence
- PRD: Proactive Advisor System
