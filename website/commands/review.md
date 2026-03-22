# /keel:review

Post-implementation specialist review — routes to relevant domain agents based on what was built.

## Usage

```
/keel:review                    ← review last commit
/keel:review --staged           ← review staged changes
/keel:review --branch           ← review all changes on this branch
/keel:review src/payments/      ← review a specific directory
```

## Arguments

| Argument | Description |
|----------|-------------|
| (none) | Review last commit |
| `--staged` | Review staged changes |
| `--branch` | Review all changes on this branch |
| A file path | Review a specific file or directory |
| `--no-keel` | Run all domain reviews inline without spawning specialist agents |

## What it does

After implementing a feature, `keel:review` inspects what changed and automatically routes to the specialist agents whose domain was touched — without you having to know which agents exist or which to ask.

A migration file triggers the DBA. Auth changes trigger the security agent. A Dockerfile triggers the SRE. You get expert eyes on the right parts, automatically.

## Domain routing

| Changed files contain... | Agent invoked |
|--------------------------|--------------|
| `*.sql`, `migration*`, `schema*` | `dba` |
| `Dockerfile*`, `docker-compose*`, `*.tf`, `helm/*` | `sre` |
| `*auth*`, `*jwt*`, `*payment*`, `*token*` | `security` |
| `*route*`, `*handler*`, `*controller*`, `*api*` | `api` |
| `*cache*`, `*perf*`, `*optimize*`, `*benchmark*` | `performance` |

## Output

```
IMPLEMENTATION REVIEW — 2026-03-08
─────────────────────────────────────────────────────
Scope: 4 files changed
Domains: database, security

DBA
  🔴  Missing index on users.created_at — queried in new reports endpoint
  🟡  Migration has no DOWN — rollback impossible if deploy fails
  🟢  Transaction boundaries correctly scoped

SECURITY
  🟢  No hardcoded secrets detected
  🟢  Auth middleware applied on new routes

─────────────────────────────────────────────────────
2 findings (1 critical). Address before shipping?
```

## Severity model

- **🔴 Critical** — must fix before shipping (data loss, security breach, broken contract)
- **🟡 Warning** — should fix, not blocking
- **🟢 OK** — domain looks healthy

## Natural language triggers

- "review what I built"
- "review this implementation"
- "check my changes"
- "get a second opinion on this"
