# Quality Gates

Quality gates are enforcement checkpoints. When a specialist agent detects a critical finding during a plan phase, review, or audit, it blocks progression until the finding is resolved.

You don't trigger gates. They fire automatically — via the SubagentStop hook when an agent completes work, via pre-flight review when a plan phase begins, or via an explicit audit. When a gate fires, Claude presents it.

## What they catch

Gates fire on findings that shouldn't proceed:

- Hardcoded secrets or credentials
- Migrations without rollback (DOWN migration)
- API breaking changes without version strategy
- Security vulnerabilities identified by OWASP scan
- Missing indexes on high-query columns
- Authentication boundary violations

Not all findings trigger a gate. Findings are classified by severity:

| Severity | Behavior |
|----------|----------|
| `CRITICAL` | Blocks progression. Must be resolved or explicitly overridden. |
| `WARNING` | Surfaces in review output. Does not block. |
| `PASS` | No action required. |

## What you see when a gate fires

```
GATE: security — critical finding
   Hardcoded JWT secret in auth/handler.go:47

   This gate must be resolved before proceeding.
   Override this gate? (y/n)
   Note: override will be logged with your git identity.
```

The agent that raised the finding is named. The file and line are specific. The override prompt requires explicit acknowledgment.

Fix the issue and continue, or respond `y` to log the override. There is no path that skips the gate silently.

## Overrides

Overrides are available — but they are not silent. Every override is logged with the git identity of the engineer who approved it. The log is readable, auditable, and committed to the repo.

This is intentional. Gates are not about blocking work — they're about making enforcement visible. An override says "I know about this finding and I'm proceeding anyway." That's a legitimate decision. The log captures it.

Override log format:

```
GATE OVERRIDE
  Finding:    Hardcoded JWT secret in auth/handler.go:47
  Agent:      security
  Approved:   daniel <hi@dcsg.me>
  Date:       2026-03-20
  Reason:     development environment only — will be removed before merge
```

Override activity is visible in the governance dashboard. Ask Claude "what's our status?" to see gate history.

## Configuring gates

Gates are configured in `.keel/config.yaml` under `gates:`:

```yaml
gates:
  security:
    level: critical      # block on critical findings
    agents:
      - security
  database:
    level: critical
    agents:
      - dba
  api:
    level: warning       # surface but don't block
    agents:
      - api
```

To disable a gate entirely, remove it from the config. To change severity threshold, adjust the `level` field.

## When gates fire

Gates are checked at three points:

1. **Pre-flight review** — before plan execution begins, specialist agents review the plan. Critical findings from pre-flight block the plan from starting.

2. **SubagentStop hook** — after each specialist agent completes work during execution, findings are evaluated. Critical findings pause execution.

3. **Explicit audit** — ask Claude to run a security and quality audit. All relevant agents scan the current implementation.

**Command reference:** `/keel:audit`

## CI integration

For CI pipelines, run `/keel:drift --output=json`. Exit code `1` if any diverged findings exist. This integrates with any CI system that checks exit codes.

Quality gates during development prevent CI failures from being the first signal of a problem. The gate fires while the engineer is still in the session — not after a push.
