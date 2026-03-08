# Plan: Keel v3 — Proactive Intelligence

## Overview
**Task:** Make specialist agents proactive — the right expert shows up when needed, not when remembered
**Total Phases:** 5
**Estimated Cost:** ~$8–15
**Created:** 2026-03-08

## Progress

| Phase | Status | Updated |
|-------|--------|---------|
| 1     | -      | -       |
| 2     | -      | -       |
| 3     | -      | -       |
| 4     | -      | -       |
| 5     | -      | -       |

**IMPORTANT:** Update this table as phases complete. This table is the persistent state that survives context compaction.

## Context

### Why this plan exists

Keel v1–v2 solved context and guardrails. Keel v3 solves proactive intelligence.

Today's problem: 17 specialist agents sit idle unless manually invoked. The DBA doesn't show up for migrations. Security is only checked if you remember to ask. End-of-session decisions slip through the Stop hook.

The vision: "Claude behaves like a senior engineer who's been on the team for months." A senior engineer knows when to pull in the DBA. Knows to flag security before pushing. Knows what changed while they were away. Keel v3 delivers this.

### Design constraint (ADR-004)

**Advisor orchestration is in scope. Execution orchestration is not.**

Advisors: read plans and code, return findings, never write files, run in forked subagents.
Executors: out of scope — Claude Code handles that natively.

### Domain signal detection (used across phases 1, 2, 3)

| Signal Keywords | Agent Routed |
|----------------|--------------|
| SQL, query, schema, migration, index, database, db | principal-dba |
| deploy, docker, kubernetes, terraform, infra, CI, helm, container | staff-sre |
| auth, JWT, OAuth, payment, PCI, HIPAA, token, secret, encrypt, credential | staff-security |
| API, endpoint, REST, GraphQL, route, contract, webhook | senior-api |
| bounded context, domain, architecture, refactor, pattern, layer | principal-architect |
| performance, N+1, cache, latency, throughput, slow, optimize | senior-performance |

### Five features in this plan

1. **Git-aware session start** — SessionStart hook detects what changed since last session, surfaces relevant agents
2. **Pre-flight specialist review** — `/keel:plan` automatically routes plan to relevant advisors before execution
3. **Post-implementation review** — new `/keel:review` command, domain-routed specialist review of what was built
4. **Security audit + pre-push scan** — new `/keel:audit` command + lightweight security grep in pre-push hook
5. **Session sweep** — new `/keel:session` command + PreCompact enhancement for end-of-session capture

### Execution strategy

Phases 1, 2, 4, 5 are independent — can run in parallel.
Phase 3 depends on Phase 2 (reuses domain routing logic).

## Model Assignment

| Phase | Task | Model | Reasoning | Est. Cost |
|-------|------|-------|-----------|-----------|
| 1 | Git-aware session start | Haiku | Hook/bash modification only | ~$0.25 |
| 2 | Pre-flight specialist review in /keel:plan | Sonnet | New routing logic + plan integration | ~$3.00 |
| 3 | /keel:review command | Sonnet | New command with agent orchestration | ~$3.00 |
| 4 | /keel:audit + security pre-push | Sonnet | New command + hook changes | ~$2.00 |
| 5 | /keel:session + PreCompact enhancement | Sonnet | New command + conversation analysis | ~$2.00 |

## Execution Strategy

| Phase | Depends On | Parallel With |
|-------|-----------|---------------|
| 1     | None      | 2, 4, 5       |
| 2     | None      | 1, 4, 5       |
| 3     | 2         | -             |
| 4     | None      | 1, 2, 5       |
| 5     | None      | 1, 2, 4       |

Wave 1: Phases 1, 2, 4, 5 (parallel)
Wave 2: Phase 3

---

## Phase 1: Git-Aware Session Start

**Objective:** Replace the generic "memory is stale" SessionStart message with a specific summary of what changed since the last session and which specialist agents are relevant.
**Model:** `claude-haiku-4-5-20251001`
**Max Iterations:** 3
**Completion Promise:** `PHASE 1 COMPLETE`
**Dependencies:** None

**Prompt:**

Enhance the `SessionStart` hook in `templates/settings.json.tmpl`. Read the file first to understand the current hook structure.

### Current behavior
The SessionStart hook checks memory age and outputs either "memory loaded (Nd old)" or "memory is stale." It is purely age-based with no awareness of what actually changed.

### New behavior

The new hook command must:

1. **Keep existing memory age check** — don't remove it, but integrate it
2. **Get last session timestamp** from the memory file mtime
3. **Get git changes since last session:**
   ```bash
   git log --since="$(date -r $MEMORY +%Y-%m-%dT%H:%M:%S 2>/dev/null || stat -f %Sm -t %Y-%m-%dT%H:%M:%S $MEMORY 2>/dev/null)" --name-only --pretty=format: 2>/dev/null | grep -v '^$' | sort -u
   ```
4. **Classify changed files by domain signal:**
   - Contains `migration`, `schema`, `.sql` → DBA
   - Contains `docker`, `compose`, `.tf`, `helm`, `k8s`, `Dockerfile` → SRE
   - Contains `auth`, `jwt`, `oauth`, `payment`, `token`, `secret` (case-insensitive) → Security
   - Contains `route`, `handler`, `controller`, `api`, `endpoint` → senior-api
5. **Output a specific, useful message** (not just "memory loaded"):

   If changes detected:
   ```
   📋 Keel — since your last session (3d ago):
      2 migrations, 3 API routes, 1 Dockerfile changed
      Relevant agents: principal-dba, senior-api, staff-sre
      Run /keel:context to load full project context.
   ```

   If no git changes detected (or not a git repo):
   ```
   📋 Keel project — memory 3d old. Run /keel:context to load context.
   ```

   If memory stale (>7 days):
   ```
   ⚠️  Keel memory is 14d old. Run /keel:context to refresh.
   ```

6. **Respect disable flag:** Check `hooks: { session-start-git: false }` in `.keel/config.yaml` — if set, skip git analysis and use the simple age check.

### Implementation notes

The command must be a single bash line (escape inner quotes). It's OK to be verbose for readability if needed — but it must be a valid JSON string value.

Variables available in SessionStart hook context: `$PWD` for project path.

The memory path pattern: `$HOME/.claude/projects/$(echo "$PWD" | sed 's|/|-|g')/memory/MEMORY.md`

Use `2>/dev/null` on all git commands — fail silently if not a git repo.

### Also update

- `commands/doctor.md` — add check: does SessionStart hook contain git diff logic? If using old version: `[!!] SessionStart hook is outdated — run /keel:init to reinstall`
- `test/test-hooks.sh` — add assertions: SessionStart hook contains `git log`, contains domain signal keywords (migration, docker, auth)
- `commands/init.md` — update SessionStart hook description in section 5.5 to describe git-aware behavior

When complete, output: PHASE 1 COMPLETE

---

## Phase 2: Pre-Flight Specialist Review in /keel:plan

**Objective:** After `/keel:plan` generates a plan, automatically detect which specialist domains are involved and invoke relevant advisor agents to review the plan before execution begins.
**Model:** `claude-sonnet-4-6`
**Max Iterations:** 5
**Completion Promise:** `PHASE 2 COMPLETE`
**Dependencies:** None

**Prompt:**

Read `commands/plan.md` fully before making any changes. Understand the full existing flow.

### What to add

At the end of the `/keel:plan` flow — after the plan file is written and the "Next steps" output is shown — add a **Pre-Flight Review** step.

### Step: Pre-Flight Specialist Review

After saving the plan file, scan the plan content for domain signals:

```
DOMAIN SIGNAL DETECTION:
Scan the full plan text (all phase prompts, objectives, titles) for these keyword groups:

Database signals: SQL, query, schema, migration, index, database, db, table, foreign key, join, transaction, ORM, Postgres, MySQL, SQLite, MongoDB
→ Route to: principal-dba

Infrastructure signals: deploy, docker, kubernetes, k8s, terraform, helm, CI, CD, infra, container, Dockerfile, compose, nginx, AWS, GCP, Azure, cloud
→ Route to: staff-sre

Security signals: auth, JWT, OAuth, payment, PCI, HIPAA, token, secret, encrypt, credential, password, permission, role, RBAC, CORS, XSS, injection
→ Route to: staff-security

API signals: API, endpoint, REST, GraphQL, route, webhook, contract, openapi, swagger, versioning, breaking change
→ Route to: senior-api

Architecture signals: bounded context, domain, architecture, refactor, pattern, layer, dependency, coupling, abstraction, interface, hexagonal, clean arch
→ Route to: principal-architect

Performance signals: performance, N+1, cache, latency, throughput, slow, optimize, index, query optimization, benchmark
→ Route to: senior-performance
```

For each domain with signals detected, invoke that agent as a subagent (using Agent tool with appropriate subagent_type or by using the agent's persona directly). Each advisor:
1. Reads the plan content
2. Reviews from their domain lens ONLY (DBA reviews DB aspects, SRE reviews infra aspects)
3. Returns findings using the severity model:
   - 🔴 Critical: must address before execution (data loss, security breach, broken contract)
   - 🟡 Warning: should address, not blocking
   - 🟢 OK: domain looks healthy

### Output format

```
PRE-FLIGHT REVIEW
─────────────────────────────────────────────────────
Domains detected: database, security (2 of 6 checked)

PRINCIPAL DBA
  🔴  Phase 3 migration missing rollback — add DOWN migration before executing
  🟡  No index on users.email — queried in phase 2, add to phase 3 migration
  🟢  Transaction boundaries correctly scoped

STAFF SECURITY
  🟡  JWT secret storage not specified in phase 2 — clarify storage mechanism
  🟢  Auth middleware scoping looks correct

─────────────────────────────────────────────────────
2 warnings, 1 critical. Address in plan before executing?
Type your updates now, or press enter to proceed with known risks noted.
```

If the user provides updates, incorporate them into the plan file.
If the user skips, add a `## Known Risks` section to the plan file with the outstanding findings.

### Skip option

If the user ran `/keel:plan --no-review`, skip the pre-flight review entirely.
Detect `--no-review` in `$ARGUMENTS`.

### If no domains detected

If no domain signals found (e.g., simple documentation task):
```
Pre-flight: no specialist domains detected — plan looks self-contained.
```
Do not invoke any agents.

### Also update

- `commands/init.md` — no changes needed
- `install.sh` — no changes needed (plan command already installed)
- `test/test-structure.sh` — add: `assert_file_contains "$PROJECT_ROOT/commands/plan.md" "PRE-FLIGHT" "plan.md has pre-flight review"`
- `test/test-structure.sh` — add: `assert_file_contains "$PROJECT_ROOT/commands/plan.md" "no-review" "plan.md supports --no-review flag"`

When complete, output: PHASE 2 COMPLETE

---

## Phase 3: /keel:review — Post-Implementation Review

**Objective:** New command that analyzes what was built (git diff), routes to relevant specialist advisors based on changed file domains, and produces a consolidated review report.
**Model:** `claude-sonnet-4-6`
**Max Iterations:** 5
**Completion Promise:** `PHASE 3 COMPLETE`
**Dependencies:** Phase 2 (domain signal detection logic)

**Prompt:**

Read Phase 2's completed `commands/plan.md` to understand the domain signal detection and advisor invocation pattern. Then create `commands/review.md` using the same patterns.

### Create commands/review.md

Frontmatter:
```yaml
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
```

### Scope detection

The command supports these scope arguments (from `$ARGUMENTS`):
- No argument: `git diff HEAD~1` — review last commit
- `--staged`: `git diff --staged` — review staged changes
- `--branch`: `git diff main...HEAD` (or `master...HEAD`) — review full branch
- A file path: review just that file or directory

If no git available or no changes: output "No changes detected to review."

### Domain detection from changed files

After getting the diff, classify changed files by path/name patterns:

```
File classification rules:
- *.sql, *migration*, *schema* → database
- docker-compose*, Dockerfile*, *.tf, k8s/*, helm/* → infrastructure
- *auth*, *jwt*, *oauth*, *payment*, *token*, *security* → security
- *route*, *handler*, *controller*, *api*, *endpoint*, *webhook* → api
- *architect*, *domain*, *bounded* → architecture (rare — only for explicit restructuring)
- *perf*, *benchmark*, *cache*, *optimize* → performance
```

### Advisor invocation

For each detected domain, invoke the corresponding specialist agent to review the diff from their lens. Use the same domain → agent mapping as Phase 2.

Each advisor reviews ONLY their domain:
- DBA: schema correctness, query efficiency, migration safety, missing indexes, N+1 risks, transaction boundaries
- SRE: deployment readiness, health checks, rollback capability, observability (logging/metrics), resource limits
- Security: OWASP top 10 scan of changed code, hardcoded secrets, input validation, auth gaps, exposed endpoints
- senior-api: contract stability, breaking changes, missing documentation, versioning, response schema
- principal-architect: bounded context violations, dependency direction, pattern consistency, technical debt introduced

### Output format

```
IMPLEMENTATION REVIEW — {date}
─────────────────────────────────────────────────────
Scope: {n} files changed
Domains: {detected domains}

{For each domain with findings:}
{AGENT NAME}              {severity summary}
  {severity icon}  {finding — specific, actionable}
  ...

─────────────────────────────────────────────────────
{summary: N critical, N warnings}
{If critical: "Address before shipping?"}
{If clean: "✅ All domains clear — looks good to ship."}
```

### If no specialist agents installed

If `.claude/agents/` is empty or the relevant agent isn't installed, skip that domain with a note:
```
PRINCIPAL DBA — not installed (run /keel:agents add principal-dba)
```

### Also update

- `install.sh` — add `review` to KEEL_COMMANDS array
- `test/test-structure.sh` — add `review` to commands existence loop
- Create `website/commands/review.md` — full command documentation page (same style as other website command pages)

When complete, output: PHASE 3 COMPLETE

---

## Phase 4: /keel:audit + Security Pre-Push Hook

**Objective:** New `/keel:audit` command for deliberate security passes; lightweight security grep added to pre-push hook; Stop hook enhanced to suggest audit for security-sensitive domains.
**Model:** `claude-sonnet-4-6`
**Max Iterations:** 4
**Completion Promise:** `PHASE 4 COMPLETE`
**Dependencies:** None

**Prompt:**

### Task A: Create commands/audit.md

Frontmatter:
```yaml
---
name: keel:audit
description: "Security audit — OWASP scan, secret detection, auth coverage, vulnerability patterns"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Agent
---
```

The command invokes `staff-security` as the advisor agent with the following process:

**Scope options** (from `$ARGUMENTS`):
- No arg: full codebase scan
- `api`: scan routes and handlers only
- `auth`: scan authentication and authorization code only
- `data`: scan data access and storage code only
- A file path: scan that specific file or directory

**What the security agent checks:**

1. **OWASP Top 10 scan:**
   - A01 Broken Access Control: auth checks on all routes, privilege escalation paths
   - A02 Cryptographic Failures: hardcoded secrets, weak crypto, unencrypted PII storage
   - A03 Injection: SQL concat, command injection, template injection, XSS
   - A04 Insecure Design: missing rate limiting, no input validation, trust boundaries
   - A05 Security Misconfiguration: debug mode, default credentials, verbose errors in prod
   - A07 Auth Failures: session management, token expiry, password policies
   - A09 Logging Failures: sensitive data in logs, insufficient audit trail

2. **Secret detection patterns:**
   - `api_key\s*=\s*["'][^"']+["']`
   - `password\s*=\s*["'][^"']+["']` (in code, not config templates)
   - `token\s*=\s*["'][^"']+["']`
   - Hardcoded IPs or URLs that look like internal endpoints

3. **Input validation coverage:**
   - Routes that accept user input — do they validate?
   - File uploads — are they sanitized?
   - SQL queries — parameterized or concatenated?

**Output format:**
```
SECURITY AUDIT — {date}
─────────────────────────────────────────────────────
Scope: {scope description}

🔴 CRITICAL (must fix before shipping)
  • {file:line} — {finding} — {why it matters}

🟡 WARNINGS (should fix)
  • {file:line} — {finding}

🟢 CLEAN
  • Input validation: present on all public routes
  • No hardcoded secrets detected

OWASP Checklist:
  A01 Access Control    ✅/⚠️/❌
  A02 Cryptography      ✅/⚠️/❌
  A03 Injection         ✅/⚠️/❌
  ...

─────────────────────────────────────────────────────
Run /keel:audit {scope} to narrow focus.
```

### Task B: Enhance templates/hooks/pre-push

Read `templates/hooks/pre-push`. Add a lightweight security section AFTER the existing doc gap checks, BEFORE the final exit 0.

The security section:
1. Check disable flag: `if [ "${KEEL_SECURITY_SKIP:-0}" = "1" ]; then` skip
2. Check config: `grep -q "pre-push-security: false" .keel/config.yaml` skip
3. Run these grep patterns against staged/pushed files (use the git diff from the push):
   ```bash
   # Hardcoded secrets
   git diff "$BASE" "$LOCAL_REF" -- . | grep "^+" | grep -iE '(api_key|password|secret|token)\s*=\s*["'"'"'][^"'"'"']{8,}' | grep -v "^+++"

   # SQL string concatenation
   git diff "$BASE" "$LOCAL_REF" -- . | grep "^+" | grep -E '(query|sql)\s*\+?=.*\+\s*(req\.|params\.|input\.|user\.)' | grep -v "^+++"

   # TODO security comments
   git diff "$BASE" "$LOCAL_REF" -- . | grep "^+" | grep -iE 'TODO.*(auth|security|validate|sanitize)' | grep -v "^+++"
   ```
4. If any found, output:
   ```
   🔒 keel: security patterns detected ({n}):
      • {pattern found} — {file}

      Run /keel:audit to review. Pushing anyway.
      To skip security check: KEEL_SECURITY_SKIP=1 git push
      To disable permanently: add 'pre-push-security: false' under 'hooks:' in .keel/config.yaml
   ```
5. Always exit 0 — never block

### Task C: Enhance Stop hook in templates/settings.json.tmpl

Read the current Stop hook prompt. Add a security signal detector to the existing prompt.

Add to the Stop hook prompt (after the existing doc gap signal section):

```
(3) SECURITY SIGNALS — did your response involve: authentication, authorization, payment processing, PII handling, cryptography, token management, or access control? If yes, add to your next response: '🔒 Security-sensitive domain — run `/keel:audit` before shipping this feature.'
```

### Task D: Update install.sh and tests

- Add `audit` to KEEL_COMMANDS in `install.sh`
- Add `review` to KEEL_COMMANDS in `install.sh` (for Phase 3 — add it here to avoid a separate install.sh edit)
- Add `session` to KEEL_COMMANDS in `install.sh` (for Phase 5 — add it here)
- `test/test-structure.sh`: add `audit` to the commands existence loop
- `test/test-hooks.sh`: add assertion that Stop hook contains "Security-sensitive domain" and "/keel:audit"
- `test/test-structure.sh`: add assertion that `pre-push` hook contains `KEEL_SECURITY_SKIP`

When complete, output: PHASE 4 COMPLETE

---

## Phase 5: /keel:session — End-of-Session Sweep

**Objective:** New command for deliberate end-of-session review that summarizes what happened, cross-references against captured artifacts, and prompts for missed captures in one batch. Enhanced PreCompact hook suggests running it before compaction.
**Model:** `claude-sonnet-4-6`
**Max Iterations:** 4
**Completion Promise:** `PHASE 5 COMPLETE`
**Dependencies:** None

**Prompt:**

### Task A: Create commands/session.md

Frontmatter:
```yaml
---
name: keel:session
description: "End-of-session sweep — summarize what happened, surface missed captures before context is lost"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---
```

### What the command does

**Step 1: What changed (git)**
```bash
git diff HEAD --name-only 2>/dev/null  # unstaged
git diff --staged --name-only 2>/dev/null  # staged
git log --since="3 hours ago" --oneline 2>/dev/null  # recent commits
```
Summarize: "Built: {list of files/areas changed}"

**Step 2: Plan progress**
Find the most recently modified plan file. Check if any phases moved to done/in-progress recently.
Report: "Updated: PLAN-{x} phase {n} → {status}"

**Step 3: Scan for uncaptured decisions**
Look for decision language patterns in the conversation context that aren't reflected in existing ADR files:
- "we decided to...", "going with...", "chose X over Y", "trade-off is...", "because of..."
- Cross-reference against `docs/decisions/*.md` — if the topic isn't covered there, flag it
- Only flag STRONG signals (clear decision + reason + alternative considered)

**Step 4: Scan for uncaptured constraints**
Look for constraint language that isn't in existing invariant files:
- "never...", "always must...", "required on all...", "violating this would..."
- Cross-reference against `docs/invariants/*.md`

**Step 5: Scan for doc gaps**
Check git diff for new routes, env vars, new services not yet in docs (same logic as keel:docs, but scoped to this session).

**Step 6: Cross-reference to avoid noise**
Before surfacing a suggestion, verify it's not already captured:
- Check docs/decisions/ for matching ADR
- Check docs/invariants/ for matching invariant
- Check docs/product/prds/ for matching PRD
Only surface genuinely missing captures.

**Output format:**
```
SESSION SUMMARY — {date} {time}
─────────────────────────────────────────────────────
Built:    {changed areas — e.g., "webhook delivery (3 files), DB migration"}
Commits:  {recent commit messages, or "none yet"}
Updated:  {plan progress changes, or "no plans updated"}

Possible captures:
  💡 ADR: {decision description} — {why it seems like an ADR}
     → Run /keel:adr to capture

  💡 Invariant: {constraint description}
     → Run /keel:invariant to capture

  📄 Doc gap: {new public surface} — not in {doc file}
     → Run /keel:docs to review

─────────────────────────────────────────────────────
{If nothing to capture: "✅ Session looks complete — nothing missed."}
{count} possible captures. Context compaction coming — capture now or later.
```

**If nothing changed (git has no diff and no recent commits):**
```
Nothing built in this session — no captures needed.
```

### Task B: Enhance PreCompact hook in templates/settings.json.tmpl

Read the current PreCompact hook. Currently it says:
`"⚠️ Context compacting. If a plan is active, update its progress table NOW before context is lost."`

Update to:
`"⚠️ Context compacting. (1) Update your active plan's progress table NOW. (2) Run /keel:session to capture any decisions, constraints, or doc gaps before context is lost."`

### Task C: Update install.sh

The `session` command should already be added to KEEL_COMMANDS by Phase 4. Verify it's there. If Phase 4 hasn't run yet, add it now.

### Task D: Tests

- `test/test-structure.sh`: add `session` to the commands existence loop (if not already added by Phase 4)
- `test/test-hooks.sh`: add assertion that PreCompact hook contains `/keel:session`
- Create a basic structure check: `assert_file_contains "$PROJECT_ROOT/commands/session.md" "context: fork"`
- `assert_file_contains "$PROJECT_ROOT/commands/session.md" "SESSION SUMMARY"`

When complete, output: PHASE 5 COMPLETE

---

## After All Phases Complete

1. Run `./test/run.sh` — all suites must pass
2. Update PLAN-006 progress table
3. Update `website/commands/index.md` — add review, audit, session to command table (count goes from 15 to 17)
4. Create `website/commands/review.md`, `website/commands/audit.md`, `website/commands/session.md`
5. Update `website/what-is-keel.md` — mention proactive intelligence as a third evolution
6. Update `docs/architecture/decisions/ADR-001-keel-architecture.md` — update command count to 17
7. Commit: `feat(v3): proactive intelligence — advisor routing, pre-flight review, session sweep`

## Open Questions (resolved before execution)

**Pre-flight review timing:** Accepted — pre-flight runs after plan is saved. For large plans with many domains, it may take 30-60 seconds. This is acceptable because plan creation is not time-critical. User can skip with `--no-review`.

**Session sweep trigger:** Both — `/keel:session` as explicit command AND PreCompact hook suggests it.

**`/keel:review` scope default:** Last commit (`git diff HEAD~1`) as the no-argument default. User can specify `--staged`, `--branch`, or a path.
