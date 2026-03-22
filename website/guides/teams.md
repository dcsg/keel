---
title: "Keel for Teams"
description: "The full conversation: from one engineer's init to team-wide governance. Watch code review shift from catching basics to evaluating design."
---

# Keel for Teams

Every engineer on your team uses Claude Code. Every engineer prompts it differently. The output looks like it came from five different organizations. You know this because you're the one reviewing the PRs — catching the naming inconsistencies, the business logic in HTTP handlers, the error handling that doesn't match what the team agreed on last sprint.

Code review has become standards enforcement. That's not your job. That's a governance problem.

This guide shows the full workflow. One engineer sets up keel, commits it, and every engineer on the team gets governed Claude sessions from that point forward.

---

## 1. One engineer sets up, commits — the whole team gets governance

Elena is the engineering lead. The team builds an order management API — Go, Chi, PostgreSQL. She opens the project in Claude Code.

<Terminal title="Claude Code — orders-api">
<T in>/keel:init</T>
<T>[1/3] Scanning project...</T>
<T dim>  Code: Go project, 234 files. Chi framework, PostgreSQL.</T>
<T dim>  Build: make build | Test: make test | Lint: golangci-lint</T>
<T dim>  Commits: conventional commits detected</T>
<T>[2/3] Configuring...</T>
<T>Rules (✓ = recommended for your stack):</T>
<T hi>  [x] code-quality     — naming, correctness guardrails</T>
<T hi>  [x] testing          — TDD, tautological test prevention</T>
<T hi>  [x] security         — e-commerce surface detected, timing attacks</T>
<T hi>  [x] error-handling   — typed errors, context wrapping</T>
<T hi>  [x] go               — error handling, data races, interfaces</T>
<T hi>  [x] chi              — thin handlers, middleware</T>
<T dim>  [ ] architecture, api, database, frontend, observability, seo...</T>
<T>Agents: architect, backend, dba, qa, security, docs, api, sre</T>
<T>SDLC: conventional commits, PR template</T>
<T>Toggle items by name, or say "looks good" to proceed.</T>
<T in>add architecture — we want the service layer pattern enforced</T>
<T hi>  [x] architecture     — layer boundaries, import discipline</T>
<T>Toggle more, or say "looks good" to proceed.</T>
<T in>looks good</T>
<T>[3/3] Installing...</T>
<T ok>  ✓ Config, project context, 7 rules, 8 agents, 9 behaviors, CLAUDE.md</T>
<T>Start building — describe what you want. Rules and agents are active.</T>
</Terminal>

Elena commits:

```bash
git add .claude/ .keel/ docs/
git commit -m "chore: add keel governance"
git push
```

That commit is the only setup step. Every engineer who pulls this branch gets the full governance — rules, agents, hooks, project identity. No Slack message saying "hey, update your CLAUDE.md." No wiki page nobody reads. One commit, done.

---

## 2. New engineer opens the project — governance is already there

Next morning. Tomasz pulls the latest changes and opens the project in Claude Code. He's never heard of keel. He doesn't need to.

<Terminal title="Claude Code — orders-api">
<T>[SessionStart] Loading project context...</T>
<T>Order Management API — Go + Chi + PostgreSQL</T>
<T>Active governance:</T>
<T>  7 rules, 7 agents, 0 compiled directives</T>
<T>  0 ADRs, 0 invariants (new project)</T>
<T>Recent changes since your last session:</T>
<T hi>  - chore: add keel governance (Elena, 14h ago)</T>
<T hi>  - New files: .claude/rules/, .claude/agents/, docs/project-context.md</T>
<T>What would you like to work on?</T>
<T in>I need to add a search endpoint for orders. GET /orders with filters for status, date range, and customer ID.</T>
<T>I'll build the search endpoint following your service layer pattern.</T>
<T>Approach:</T>
<T>- Handler:    Parse query params, validate, call service. No business logic.</T>
<T>- Service:    OrderSearchService.Search(ctx, filters) — builds query criteria, calls repository</T>
<T>- Repository: OrderRepository.Search(ctx, criteria) — PostgreSQL query with parameterized filters</T>
<T>I'll use typed errors: ErrInvalidDateRange, ErrInvalidStatus.</T>
<T>Pagination via cursor-based approach (not offset) for consistency at scale.</T>
<T>Starting with the service layer.</T>
</Terminal>

Tomasz didn't mention the service layer pattern. He didn't mention typed errors. He didn't mention keeping business logic out of handlers. Claude read `.claude/rules/architecture.md`, `.claude/rules/error-handling.md`, and `.claude/rules/chi.md` — automatically, before writing anything.

This is the moment for teams. Every engineer's Claude session produces the same architecture, the same patterns, the same error handling. Not because they prompt the same way. Because the governance is in the repo.

---

## 3. The code review shift — standards are already followed

Tomasz opens his PR. Elena reviews it.

The handler parses query parameters, validates them, and calls the service. No database queries. No business logic. The service builds filter criteria and calls the repository. The repository runs parameterized SQL — no string interpolation. The errors are typed with context wrapping.

Elena's review comments:

```
Elena: "Nice cursor-based pagination choice. One thought — should we
       add a max page size to prevent someone requesting 10,000 orders?
       Maybe cap at 100 with a default of 20."

Elena: "The OrderSearchCriteria value object is clean. Consider adding
       a Validate() method so the service doesn't need to check each
       field individually."
```

Two comments. Both about design decisions. Neither about standards violations.

Before keel, Elena's review of a similar PR would have looked like this:

```
Elena: "Move the SQL query out of the handler — it should go through
       the service layer."

Elena: "Don't use fmt.Errorf here — we use typed errors. See how
       the payment handler does it."

Elena: "This string interpolation in the WHERE clause is a SQL injection
       risk. Use parameterized queries."

Elena: "The handler is doing too much — parsing, validation, querying,
       formatting. Split it up."

Elena: "We discussed using cursor-based pagination in standup last week.
       This is offset-based."
```

Five comments. All standards enforcement. All things Claude should have gotten right on its own.

The shift isn't incremental. The category of review comment changes. Elena stops catching basics and starts evaluating design. The team's code review actually improves the codebase instead of policing it.

---

## 4. Quality gate fires — Claude blocks a security issue

Two weeks in. The team has captured 5 ADRs and compiled them into governance directives. Priya is building the order cancellation endpoint.

<Terminal title="Claude Code — orders-api">
<T in>Build the order cancellation endpoint. POST /orders/{id}/cancel. Should check that the order is in a cancellable state and update the status.</T>
</Terminal>

Claude builds the endpoint. Handler, service, repository — following the pattern. Then:

<Terminal title="Claude Code — orders-api">
<T err>GATE: security — critical finding</T>
<T err>  SQL injection risk in order/infrastructure/repository.go:89</T>
<T err>  — order ID from URL path used in raw SQL string</T>
<T>  query := "UPDATE orders SET status = 'cancelled' WHERE id = '" + orderID + "'"</T>
<T warn>This gate must be resolved before proceeding.</T>
<T>Override this gate? (y/n)</T>
<T dim>Note: override will be logged with your git identity.</T>
<T in>No, fix it.</T>
<T ok>Fixed. Using parameterized query:</T>
<T>  query := "UPDATE orders SET status = $1 WHERE id = $2"</T>
<T>  _, err := r.db.Exec(ctx, query, StatusCancelled, orderID)</T>
<T ok>Gate cleared. Continuing.</T>
</Terminal>

The security agent caught raw string interpolation in a SQL query. It didn't just warn — it blocked. Priya couldn't proceed until the issue was resolved or she logged an override with her identity.

This is what quality gates do for teams. The security standard isn't a suggestion someone reads in a wiki. It's enforcement that runs on every session, for every engineer.

If Priya had overridden:

<Terminal title="Claude Code — orders-api">
<T warn>Override logged.</T>
<T dim>Gate:       security — SQL injection risk</T>
<T dim>Engineer:   Priya Sharma (priya@company.com)</T>
<T dim>Timestamp:  2026-03-18T14:32:00Z</T>
<T hi>File:       order/infrastructure/repository.go:89</T>
<T>Proceeding. This override is visible in the governance dashboard.</T>
</Terminal>

The override is recorded. Elena sees it when she checks governance status. It's not surveillance — it's a record that a trade-off was made consciously, not accidentally.

---

## 5. Status dashboard — governance health at a glance

End of sprint. Elena checks the state of governance.

<Terminal title="Claude Code — orders-api">
<T in>What's our status?</T>
<T>KEEL STATUS — orders-api</T>
<T>GOVERNANCE HEALTH</T>
<T>  Rules:        7 active</T>
<T dim>                code-quality, testing, security, error-handling,</T>
<T dim>                architecture, go, chi</T>
<T>  Agents:       7 installed</T>
<T>  Decisions:    5 ADRs, 1 invariant</T>
<T>  Directives:   7 compiled (from 5 ADRs + 1 invariant)</T>
<T>GOVERNANCE CHAIN</T>
<T ok>  PRD-001 accepted -> SPEC-001 accepted -> implemented (0 drift)</T>
<T>  PRD-002 accepted -> SPEC-002 accepted -> PLAN-002 Phase 4/5</T>
<T>GATE ACTIVITY (last 14 days)</T>
<T ok>  security:  1 critical finding (resolved — Priya, Mar 18)</T>
<T ok>  dba:   2 warnings (both resolved)</T>
<T ok>  qa:        0 findings</T>
<T>  api:      1 advisory (acknowledged — Tomasz, Mar 20)</T>
<T>ADR SUMMARY</T>
<T hi>  ADR-001: Cursor-based pagination for all list endpoints</T>
<T hi>  ADR-002: Typed domain errors, no sentinel errors</T>
<T hi>  ADR-003: Event-driven order state transitions</T>
<T hi>  ADR-004: Soft delete for orders, hard delete for drafts</T>
<T hi>  ADR-005: UTC timestamps everywhere, convert at API boundary</T>
<T ok>All governance is current. Last compiled: Mar 19.</T>
</Terminal>

Seven rules active. Five ADRs compiled into directives. One security gate fired and was resolved. One plan in progress. Elena can see exactly what's enforced, what decisions the team has made, and whether any gates were overridden.

She shares this in the sprint review. Not as a report she had to write — as a command she ran in 2 seconds.

**Command reference:** `/keel:status`

---

## 6. New hire onboarding — zero setup, same governance from minute one

Week 6. A new engineer joins — James, straight out of a bootcamp. His first day, he clones the repo, opens it in Claude Code.

<Terminal title="Claude Code — orders-api">
<T>[SessionStart] Loading project context...</T>
<T>Order Management API — Go + Chi + PostgreSQL</T>
<T>Active governance:</T>
<T>  7 rules, 7 agents, 7 compiled directives</T>
<T>  5 ADRs, 1 invariant</T>
<T dim>Architecture: Service layer (handler -> service -> repository)</T>
<T>Key decisions:</T>
<T hi>  - Cursor-based pagination on all list endpoints (ADR-001)</T>
<T hi>  - Typed domain errors, no sentinel errors (ADR-002)</T>
<T hi>  - Event-driven order state transitions (ADR-003)</T>
<T hi>  - Soft delete for orders (ADR-004)</T>
<T hi>  - UTC timestamps, convert at API boundary (ADR-005)</T>
<T warn>Invariant: All database migrations require DOWN migrations.</T>
<T>What would you like to work on?</T>
<T in>I need to add a field to the order model for tracking delivery estimates. A nullable timestamp.</T>
<T>I'll add the delivery_estimate field. Here's my approach:</T>
<T>Domain:</T>
<T>  - Add DeliveryEstimate *time.Time to the Order entity</T>
<T>  - Per ADR-005, this will be stored and returned in UTC. Frontend converts to local time at the API boundary.</T>
<T>Database:</T>
<T>  - Migration 012: ALTER TABLE orders ADD COLUMN delivery_estimate TIMESTAMPTZ</T>
<T>  - DOWN migration: ALTER TABLE orders DROP COLUMN delivery_estimate (per your migration rollback invariant)</T>
<T>Repository:</T>
<T>  - Update OrderRepository.Save and .Find to include the new column</T>
<T>  - Soft delete (ADR-004) is unaffected — field is nullable</T>
<T>Shall I proceed?</T>
</Terminal>

Claude referenced three ADRs and one invariant. It knew about UTC timestamps, migration rollbacks, and soft deletes — not because James told it, but because the team's governance was committed to the repo six weeks ago.

James's first PR arrives with the right patterns. Elena's review is about the feature, not the formatting. The onboarding checklist just got shorter.

Before keel, James would have spent his first week learning patterns by getting them wrong in code review. "We don't do it that way — check the wiki." Except the wiki is six pages and half of it is outdated.

With keel, the governance is the wiki. It's enforced, not referenced. It's current, not aspirational. And it works from minute one.

---

## What changes

The dynamic shifts in three places.

**Code review** stops being standards enforcement. When every engineer's Claude reads the same rules and follows the same ADRs, the baseline is handled before the PR opens. What's left is the work that actually matters: evaluating design decisions, questioning trade-offs, catching logic errors.

**Onboarding** stops being knowledge transfer. The new engineer's Claude session is as governed as the senior engineer's. The patterns are enforced, the decisions are documented, the invariants are active. Tribal knowledge becomes committed governance.

**Consistency** stops being a function of who's prompting. The engineer who writes great prompts and the engineer who writes "add a search endpoint" both get architecture-compliant output. The rules don't care how you ask. They fire every time.

One commit to set up. Zero per-engineer configuration. The governance accumulates as the team makes decisions and compiles them. Every ADR makes the next session smarter. Every invariant prevents the same mistake from happening twice.

**Command reference:** `/keel:init`, `/keel:status`, `/keel:adr`, `/keel:compile`
