---
status: accepted
priority: critical
---

# PRD: Proactive Advisor System (Keel v3)

## Problem

Keel installs 17 specialist agents but they are entirely passive. Users must remember to invoke the DBA before a schema change, the SRE before infra work, the security agent before shipping. This is the same "you have to remember" problem keel was built to solve for rules and context.

Three specific failures today:

1. **The DBA doesn't show up for migrations** — unless you invoke them manually
2. **Security is a late-stage concern** — there's a `staff-security` agent but no workflow that ensures security thinking happens throughout
3. **Capture still slips** — the Stop hook catches strong signals mid-response, but end-of-session decisions, constraints, and gaps often go unrecorded

## Vision

> The right expert shows up when they're needed — not when you remember to summon them.

Keel v3 makes specialist agents proactive. The system detects domain signals from tasks, plans, and code changes — and automatically routes to the relevant advisor at the right moment.

## Users Affected

All keel users, but especially:
- Solo developers who can't hold "remember to ask the DBA" in their head while coding
- Teams where consistency of quality (not just code style) matters
- Anyone shipping features that touch security-sensitive domains

## Success Metrics

- DBA agent reviews every plan that mentions database changes — without user prompting
- Security findings surface before push, not after deploy
- End-of-session: zero decisions/constraints/gaps lost that the user would have wanted captured
- Pre-flight review catches at least one issue per plan for plans that touch multiple domains

## Features

### F1: Git-Aware Session Start

**What:** SessionStart hook enhanced to detect what changed since the last session and surface relevant advisors.

**Current behavior:** "Memory is 7 days old. Run /keel:context."
**New behavior:** "Since your last session (3 days ago): 2 migrations, 3 new API routes, 1 new docker service. Relevant: principal-dba (migrations), senior-api (routes), staff-sre (docker)."

**Implementation:**
- Get last memory modification time
- Run `git log --since={last_session}` to find changed files
- Classify by domain signals (migration → DBA, docker → SRE, auth → security)
- Output summary + relevant agent suggestions
- If no changes detected: keep existing staleness check behavior

**Disable:** `hooks: { session-start-git: false }` in `.keel/config.yaml`

### F2: Pre-Flight Specialist Review (in /keel:plan)

**What:** After `/keel:plan` creates a plan, automatically detect which specialists should review it and invoke them as forked advisors. Findings are reported before execution begins.

**Trigger:** Automatic, runs at end of every `/keel:plan` invocation.

**Domain detection:** Scan plan content for keyword signals.

**Output:**
```
PRE-FLIGHT REVIEW
─────────────────────────────────────────
Domains detected: database, security

PRINCIPAL DBA
  ⚠️  Phase 3 migration has no rollback step — add DOWN migration
  ⚠️  No index defined for users.email (queried in phase 2)

STAFF SECURITY
  ⚠️  JWT secret storage not specified — clarify in phase 2
  ✅  Auth middleware correctly scoped

Address before executing? Updates can be made to the plan now.
─────────────────────────────────────────
```

**User control:** User can update the plan, accept risks, or skip. Findings that aren't addressed are noted in the plan as known risks.

**Skip:** `/keel:plan --no-review` for when you want the plan without advisor delay.

### F3: /keel:review — Post-Implementation Review

**What:** New command. After building a feature, routes to relevant specialists based on what was actually changed (git diff).

**Scope options:**
- No arg: `git diff HEAD~1` (last commit)
- `/keel:review --staged`: staged changes
- `/keel:review --branch`: diff from main/master
- `/keel:review {path}`: specific file or directory

**Domain detection:** Classify changed files by extension and name patterns.

**Output:**
```
IMPLEMENTATION REVIEW
─────────────────────────────────────────
Scope: 8 files changed — domains: database, security, api

PRINCIPAL DBA               🔴 1 critical  🟡 1 warning
  🔴  N+1 query in UserRepository.findWithOrders() — use eager loading
  🟡  Missing index on orders.user_id

STAFF SECURITY              🟢 Clean
  ✅  Input validation present on all handlers
  ✅  No hardcoded secrets detected

SENIOR API                  🟡 1 warning
  🟡  POST /webhooks not documented in docs/api.md
─────────────────────────────────────────
1 critical issue. Address before shipping?
```

**Context: fork** — results returned without polluting main session.

### F4: /keel:audit — Security Audit

**What:** New command. Dedicated security scan invoking `staff-security` against current codebase. For deliberate security passes before shipping.

**Scope options:**
- No arg: full codebase
- `/keel:audit api`: routes and handlers only
- `/keel:audit auth`: authentication and authorization
- `/keel:audit data`: data access and storage

**Pre-push hook enhancement:** Lightweight grep-based security scan added to `.git/hooks/pre-push`:
- Hardcoded secrets patterns (api_key=, password=, token= in code)
- SQL string concatenation patterns
- Debug endpoints left enabled
- TODO/FIXME containing auth, security, validate
- Always warns, never blocks
- Disable: `KEEL_SECURITY_SKIP=1` or `hooks: { pre-push-security: false }`

**Stop hook enhancement:** When response involves auth, payment, PII, or cryptography → add to suggestions: "Security-sensitive domain — run `/keel:audit` before shipping."

### F5: /keel:session — End-of-Session Sweep

**What:** New command for deliberate end-of-session review. Summarizes what happened, cross-references against captured artifacts, prompts for any missed captures in one batch.

**Trigger options:**
- Manual: `/keel:session`
- Automatic: PreCompact hook suggests it when context compaction begins

**Process:**
1. What changed (git status/diff)
2. What plans were updated
3. Scan conversation for decision signals not yet captured as ADRs
4. Scan for constraint language not captured as invariants
5. Scan for new public surface (routes, env vars) not documented
6. Cross-reference with existing docs/decisions/invariants to avoid duplicates

**Output:**
```
SESSION SUMMARY — 2026-03-08
─────────────────────────────────────────
Built:    webhook delivery (3 files, 1 migration)
Updated:  PLAN-003 phase 2 → done

Possible captures (review and confirm):
  💡 ADR: chose Redis over DB for job queue (strong signal — trade-offs discussed)
  💡 Invariant: all webhook deliveries require idempotency key
  💡 Doc gap: POST /webhooks → not in docs/api.md

Run /keel:adr, /keel:invariant, or /keel:docs to capture.
Nothing expires — but context compaction is coming.
─────────────────────────────────────────
```

**Context: fork** — analysis runs isolated, doesn't pollute session.

## Out of Scope

- Agents that write or modify code (advisors only — ADR-004)
- Blocking workflows (warnings only, user always decides)
- Integration with external review tools (GitHub PR reviews, etc.)
- Real-time mid-edit advisories via PostToolUse (technically infeasible — ADR-004)

## Open Questions

- Pre-flight review timing: for large plans with many domains, review could take 30-60 seconds. Is that acceptable? Or should it be opt-in with `--review` flag?
- Session sweep: manual command vs. automatic on PreCompact vs. both?
- `/keel:review` scope default: last commit vs. staged vs. branch diff?

## Related

- ADR-004: Advisor Orchestration Pattern
- PLAN-006: Keel v3 — Proactive Intelligence
