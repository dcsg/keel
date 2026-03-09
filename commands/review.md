---
name: keel:review
description: "Post-implementation specialist review — routes to relevant domain agents based on what was built"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Agent
---

You are performing a post-implementation specialist review. Your job is to analyze what was built, detect which specialist domains are involved, and produce a consolidated review report.

## Scope Detection

Determine the scope from `$ARGUMENTS`:
- No argument: `git diff HEAD~1` — review last commit
- `--staged`: `git diff --staged` — review staged changes
- `--branch`: `git diff main...HEAD` (or `master...HEAD`) — review full branch
- A file path: review just that file or directory

Run the appropriate git diff command:

```bash
# Default: last commit
git diff HEAD~1 --name-only 2>/dev/null

# Get the actual diff for analysis
git diff HEAD~1 2>/dev/null
```

If no git is available or no changes detected, output: `No changes detected to review.`

## Domain Detection from Changed Files

Classify changed files by path and name patterns:

```
File classification rules:
- *.sql, *migration*, *schema*             → database (principal-dba)
- docker-compose*, Dockerfile*, *.tf,
  k8s/*, helm/*                            → infrastructure (staff-sre)
- *auth*, *jwt*, *oauth*, *payment*,
  *token*, *security*                      → security (staff-security)
- *route*, *handler*, *controller*,
  *api*, *endpoint*, *webhook*             → api (senior-api)
- *architect*, *domain*, *bounded*         → architecture (principal-architect)
- *perf*, *benchmark*, *cache*, *optimize* → performance (senior-performance)
```

## Advisor Review

For each detected domain, use the Agent tool to spawn the corresponding specialist subagent in parallel. Pass the diff and scope as context in the prompt.

Domain → subagent_type mapping:
- database → `principal-dba`
- infrastructure → `staff-sre`
- security → `staff-security`
- api → `senior-api`
- architecture → `principal-architect`
- performance → `senior-performance`

Each agent prompt should include:
1. The git diff (or relevant file contents)
2. The specific review lens for that domain (see below)
3. The output format expected (findings with severity)

Spawn all applicable agents concurrently using multiple Agent tool calls in a single message.

**Principal DBA** review lens:
- Schema correctness and migration safety
- Query efficiency and N+1 risks
- Missing indexes on queried columns
- Transaction boundaries
- Missing rollback migrations

**Staff SRE** review lens:
- Deployment readiness and health checks
- Rollback capability
- Observability: logging and metrics coverage
- Resource limits defined

**Staff Security** review lens:
- OWASP Top 10 scan of changed code
- Hardcoded secrets or credentials
- Input validation gaps
- Auth gaps on new endpoints
- Exposed sensitive data

**Senior API** review lens:
- Contract stability and breaking changes
- Missing or outdated documentation
- Versioning strategy
- Response schema consistency

**Principal Architect** review lens:
- Bounded context violations
- Dependency direction correctness
- Pattern consistency with existing codebase
- Technical debt introduced

**Senior Performance** review lens:
- N+1 query patterns introduced
- Missing caching opportunities
- Algorithmic complexity concerns
- Benchmark-worthy hot paths

## Severity Model

Each finding uses:
- 🔴 Critical: must address before shipping (data loss, security breach, broken contract)
- 🟡 Warning: should address, not blocking
- 🟢 OK: domain looks healthy

## Output Format

```
IMPLEMENTATION REVIEW — {date}
─────────────────────────────────────────────────────
Scope: {n} files changed ({scope description})
Domains: {detected domains}

{AGENT NAME}              {severity summary}
  🔴  {finding — specific, actionable, with file reference}
  🟡  {finding}
  🟢  {area that looks good}

─────────────────────────────────────────────────────
{N critical, N warnings}
{If critical: "Address before shipping?"}
{If all clean: "✅ All domains clear — looks good to ship."}
```

If a relevant agent is not installed, note:
```
PRINCIPAL DBA — not installed (run /keel:agents add principal-dba)
```
