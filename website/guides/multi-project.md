---
title: "Keel Across Projects"
description: "The full conversation: from first client init to engineer rotation. Watch the same methodology produce governed output on every engagement, every stack."
---

# Keel Across Projects

Every new client project starts from zero. No governance, no methodology in place, no way to ensure your engineers follow the same standards they used on the last engagement. The senior engineer who built the patterns on project A rotates off, and the engineer who replaces them starts from scratch.

You have a methodology. Your consultancy knows how to build software. But Claude doesn't know any of it — and there's no mechanism for that knowledge to persist from one engagement to the next.

This guide shows the full workflow. Same methodology across every client project. Different stacks, different decisions, same governed output.

---

## 1. Setting up client project A — Go backend for a logistics platform

Ravi is the technical director. His consultancy just signed a new client — a logistics company that needs a shipment tracking API. Go, Chi, PostgreSQL. Ravi opens the project.

<Terminal title="Claude Code — logistics-tracking-api">
<T in>/keel:init</T>
<T>[1/3] Scanning project...</T>
<T dim>  Code: no source files detected</T>
<T>What are you building?</T>
<T dim>  Example: "A multi-tenant SaaS for restaurant inventory.</T>
<T dim>  Go + Chi, PostgreSQL, DDD with bounded contexts."</T>
<T in>Shipment tracking API for a logistics client. Go with Chi, PostgreSQL. DDD with bounded contexts — tracking, routing, and notifications. Multi-tenant: the client has sub-clients (shippers) who each see only their own shipments.</T>
<T>[2/3] Configuring...</T>
<T>Rules (✓ = recommended for your stack):</T>
<T hi>  [x] code-quality     — naming, correctness guardrails</T>
<T hi>  [x] testing          — TDD, tautological test prevention</T>
<T hi>  [x] security         — multi-tenant surface, timing attacks</T>
<T hi>  [x] error-handling   — typed errors, context wrapping</T>
<T hi>  [x] architecture     — DDD, layer boundaries</T>
<T hi>  [x] go               — error handling, data races, interfaces</T>
<T hi>  [x] chi              — thin handlers, middleware</T>
<T dim>  [ ] api, database, frontend, observability, seo...</T>
<T>Agents: architect, backend, dba, qa, security, docs, api, sre</T>
<T>SDLC: conventional commits, PR template</T>
<T>Toggle items by name, or say "looks good" to proceed.</T>
<T in>looks good</T>
<T>[3/3] Installing...</T>
<T ok>  ✓ Config, project context, 7 rules, 8 agents, 9 behaviors, CLAUDE.md</T>
<T>Start building — describe what you want. Rules and agents are active.</T>
</Terminal>

Ravi captures the client-specific constraints immediately:

<Terminal title="Claude Code — logistics-tracking-api">
<T in>That's a hard rule — all data must stay in the EU region. The client's compliance requirement.</T>
<T>Invariant recorded.</T>
<T>INV-001: EU Data Residency</T>
<T>All data storage, processing, and backups must remain within EU regions. No cross-region replication or CDN edge caching of shipment data outside EU.</T>
<T hi>Saved: docs/architecture/invariants/INV-001-eu-data-residency.md</T>
<T warn>This invariant will block progression if violated.</T>
<T in>Save this decision — we're using event sourcing for the tracking bounded context. Shipment state changes must be auditable, and the client needs full history reconstruction.</T>
<T>ADR-001: Event Sourcing for Tracking Context</T>
<T dim>Status: accepted</T>
<T>Context:</T>
<T>  Client requires full audit trail of shipment state changes with history reconstruction capability.</T>
<T>Decision:</T>
<T>  Use event sourcing in the tracking bounded context. ShipmentCreated, ShipmentPickedUp, ShipmentInTransit, ShipmentDelivered as domain events. Event store in PostgreSQL. CQRS with read projections for query performance.</T>
<T>Consequences:</T>
<T ok>  + Full audit trail by design</T>
<T ok>  + History reconstruction at any point in time</T>
<T>  - Higher complexity in the tracking context</T>
<T>  - Eventual consistency between write and read models</T>
<T hi>Saved: docs/architecture/decisions/ADR-001-event-sourcing-tracking.md</T>
<T in>Compile governance.</T>
<T hi>Governance compiled: .claude/rules/governance.md</T>
<T>  1 ADR   ->  2 directives</T>
<T>  1 invariant -> 1 directive</T>
<T>  3 total directives</T>
<T>Directives:</T>
<T>  1. Use event sourcing in the tracking bounded context (ADR-001)</T>
<T>  2. CQRS with read projections for tracking queries (ADR-001)</T>
<T>  3. All data must remain in EU regions — no exceptions (INV-001)</T>
<T>Claude will follow these directives automatically in every session.</T>
</Terminal>

Ravi commits and pushes. Every engineer assigned to this project gets the full governance from their first session.

**Command references:** `/keel:init`, `/keel:adr`, `/keel:invariant`, `/keel:compile`

---

## 2. Setting up client project B — TypeScript frontend for a fintech dashboard

Same week. A different client — a fintech company building a real-time trading dashboard. TypeScript, Next.js, React. Ravi opens the project.

<Terminal title="Claude Code — trading-dashboard">
<T in>/keel:init</T>
<T>What are you building? Describe your project in plain language — stack, architecture, anything relevant.</T>
<T in>Real-time trading dashboard for a fintech client. TypeScript with Next.js and React. WebSocket connections for live market data. Server components where possible, client components for interactive charts. Authentication via the client's existing OAuth provider.</T>
<T>[2/3] Configuring...</T>
<T>Rules (✓ = recommended for your stack):</T>
<T hi>  [x] code-quality     — naming, correctness guardrails</T>
<T hi>  [x] testing          — TDD, tautological test prevention</T>
<T hi>  [x] security         — auth surface detected, timing attacks</T>
<T hi>  [x] error-handling   — typed errors, error boundaries</T>
<T hi>  [x] typescript       — strict mode, no any, data races</T>
<T hi>  [x] frontend         — components, state management</T>
<T hi>  [x] nextjs           — App Router, Server Components</T>
<T dim>  [ ] architecture, api, database, observability, seo...</T>
<T>Agents: architect, frontend, qa, security, docs, ux, api</T>
<T>SDLC: conventional commits, PR template</T>
<T>Toggle items by name, or say "looks good" to proceed.</T>
<T in>looks good</T>
<T>[3/3] Installing...</T>
<T ok>  ✓ Config, project context, 7 rules, 7 agents, 9 behaviors, CLAUDE.md</T>
</Terminal>

Different stack, different rules. Same methodology. The governance chain (PRD, spec, artifacts, plan, execute, drift) is identical. The quality gates work the same way. The decision capture process is the same. What changed is the stack-specific rules: `typescript.md`, `frontend.md`, and `nextjs.md` instead of `go.md` and `chi.md`.

Ravi captures the client-specific decisions:

<Terminal title="Claude Code — trading-dashboard">
<T in>That's a hard rule — no client-side storage of financial data. Not localStorage, not sessionStorage, not IndexedDB. All financial data lives on the server and streams via WebSocket.</T>
<T>Invariant recorded.</T>
<T>INV-001: No Client-Side Financial Data Storage</T>
<T>Financial data (positions, balances, trade history) must never be persisted in client-side storage mechanisms. Data streams via WebSocket and exists only in component state during the active session.</T>
<T hi>Saved: docs/architecture/invariants/INV-001-no-client-storage.md</T>
<T in>Save this decision — we're using Zustand for client-side state management, scoped per feature. No global store.</T>
<T>ADR-001: Zustand for Feature-Scoped Client State</T>
<T dim>Status: accepted</T>
<T hi>Saved: docs/architecture/decisions/ADR-001-zustand-feature-state.md</T>
<T in>Compile governance.</T>
<T hi>Governance compiled: .claude/rules/governance.md</T>
<T>  1 ADR   ->  1 directive</T>
<T>  1 invariant -> 1 directive</T>
<T>  2 total directives</T>
<T>Claude will follow these directives automatically in every session.</T>
</Terminal>

Commit, push. Project B is governed. The methodology is Ravi's consultancy's methodology. The rules are fintech-specific. The invariants are this client's compliance requirements. Each project has its own governance — nothing leaks between them.

---

## 3. Engineer rotating from project A to project B

Anya has been working on the logistics API (project A) for three weeks. She's built the tracking context, captured two more ADRs, and is comfortable with the Go codebase. Today she rotates to the trading dashboard (project B) because the frontend needs an engineer who understands real-time data.

Anya opens project B in Claude Code. She's never seen this codebase.

<Terminal title="Claude Code — trading-dashboard">
<T>[SessionStart] Loading project context...</T>
<T>Trading Dashboard — TypeScript + Next.js + React</T>
<T>Active governance:</T>
<T>  7 rules, 7 agents, 4 compiled directives</T>
<T>  3 ADRs, 1 invariant</T>
<T dim>Architecture: Next.js App Router (server/client component split)</T>
<T>Key decisions:</T>
<T hi>  - Zustand for feature-scoped client state, no global store (ADR-001)</T>
<T hi>  - WebSocket connection manager as singleton service (ADR-002)</T>
<T hi>  - Server components by default, client components only for interactivity (ADR-003)</T>
<T warn>Invariant: No client-side storage of financial data. Data exists only in component state during active sessions.</T>
<T>Recent activity:</T>
<T dim>  - feat: add position monitoring widget (Kai, 2 days ago)</T>
<T dim>  - feat: WebSocket reconnection with exponential backoff (Kai, 4 days ago)</T>
<T>What would you like to work on?</T>
<T in>I need to build the trade history view. A table showing recent trades with real-time updates when new trades execute. Should use the existing WebSocket connection.</T>
<T>I'll build the trade history view following your project conventions.</T>
<T>Approach:</T>
<T>- Server component: TradeHistoryPage — fetches initial trade data via server action (per ADR-003, server components by default)</T>
<T>- Client component: TradeHistoryTable — subscribes to WebSocket for real-time updates (needs interactivity)</T>
<T>- State: Zustand store scoped to trade-history feature (per ADR-001) — no global store, feature-local</T>
<T>- WebSocket: Use the existing connection manager singleton (ADR-002) — subscribe to trade.executed channel</T>
<T>- Data handling: Trade data exists only in Zustand store during the session. No localStorage, no IndexedDB (per INV-001).</T>
<T>Starting with the server component.</T>
</Terminal>

Anya went from Go with DDD and event sourcing to TypeScript with Next.js and Zustand. Different language. Different framework. Different architecture. But the governance loaded instantly — she knows the decisions, the constraints, the invariants. She didn't ask Kai how the project works. She didn't read a wiki. Claude told her.

Every decision Anya's predecessors made on this project is reflected in Claude's approach. The server-first component strategy. The scoped Zustand store. The existing WebSocket manager. The financial data invariant. Claude referenced three ADRs and one invariant — without Anya asking about any of them.

This is the moment for consultancies. An engineer rotates onto a project they've never touched, and their first session produces code that follows every decision the team made before they arrived. No ramp-up week. No "ask Kai how this works." The governance is in the repo.

---

## 4. Capturing a client-specific decision — the governance grows

Anya is mid-implementation. She needs to decide how to handle WebSocket disconnections in the trade history view.

<Terminal title="Claude Code — trading-dashboard">
<T in>The WebSocket might disconnect while the user is viewing trade history. I think we should show a stale data banner and auto-reconnect, rather than clearing the table. Clearing would be disorienting for traders — they need to see the last known state while we reconnect.</T>
<T>Decision signal detected:</T>
<T>  Stale data UX pattern — show banner on disconnection, preserve last known state, auto-reconnect in background.</T>
<T>Rationale:</T>
<T>  - Clearing data during disconnection is disorienting for traders</T>
<T>  - Last known state is better than no state</T>
<T>  - Auto-reconnect handles transient failures without user action</T>
<T>This applies beyond trade history — any real-time component on this dashboard will face the same disconnection scenario.</T>
<T>Save this as an ADR? (y/n)</T>
<T in>Yes. Make it project-wide — all real-time components should follow this pattern.</T>
<T>ADR-004: Stale Data UX Pattern for WebSocket Disconnections</T>
<T dim>Status: accepted</T>
<T dim>Scope: All real-time components</T>
<T>When a WebSocket connection drops:</T>
<T>  1. Display a stale data banner with timestamp of last update</T>
<T>  2. Preserve last known data in the UI — do not clear</T>
<T>  3. Auto-reconnect with exponential backoff (per ADR-002 manager)</T>
<T>  4. On reconnect, reconcile state silently and remove banner</T>
<T hi>Saved: docs/architecture/decisions/ADR-004-stale-data-ux.md</T>
<T in>Compile governance.</T>
<T hi>Governance compiled: .claude/rules/governance.md</T>
<T>  4 ADRs  ->  5 directives</T>
<T>  1 invariant -> 1 directive</T>
<T>  6 total directives</T>
<T>New directive added:</T>
<T>  5. On WebSocket disconnection, show stale data banner and preserve last known state — never clear real-time data (ADR-004)</T>
<T>Claude will follow these directives automatically in every session.</T>
</Terminal>

Anya commits. Tomorrow, when Kai opens the project, his Claude session knows about the stale data pattern. When the next engineer builds the portfolio positions widget, Claude will implement the same disconnection handling without being told. The decision Anya made today is enforcement for every engineer from this point forward.

**Command references:** `/keel:adr`, `/keel:compile`

---

## 5. Status across projects — governance health per engagement

End of the week. Ravi checks the health of both client projects.

He opens the logistics project:

<Terminal title="Claude Code — logistics-tracking-api">
<T in>What's our status?</T>
<T>KEEL STATUS — logistics-tracking-api</T>
<T>GOVERNANCE HEALTH</T>
<T>  Rules:        7 active</T>
<T dim>                code-quality, testing, security, error-handling,</T>
<T dim>                architecture, go, chi</T>
<T>  Agents:       7 installed</T>
<T>  Decisions:    4 ADRs, 1 invariant</T>
<T>  Directives:   6 compiled</T>
<T>GOVERNANCE CHAIN</T>
<T ok>  PRD-001 accepted -> SPEC-001 accepted -> implemented (0 drift)</T>
<T>  PRD-002 accepted -> SPEC-002 accepted -> PLAN-002 Phase 3/4</T>
<T>GATE ACTIVITY (last 14 days)</T>
<T ok>  security:  0 findings</T>
<T ok>  dba:   1 warning (resolved — Anya, Mar 15)</T>
<T ok>  qa:        0 findings</T>
<T>INVARIANT STATUS</T>
<T ok>  INV-001 (EU Data Residency): active, 0 violations</T>
<T ok>Governance is current. Last compiled: Mar 17.</T>
</Terminal>

He opens the trading dashboard project:

<Terminal title="Claude Code — trading-dashboard">
<T in>What's our status?</T>
<T>KEEL STATUS — trading-dashboard</T>
<T>GOVERNANCE HEALTH</T>
<T>  Rules:        7 active</T>
<T dim>                code-quality, testing, security, error-handling,</T>
<T dim>                typescript, react, next</T>
<T>  Agents:       7 installed</T>
<T>  Decisions:    4 ADRs, 1 invariant</T>
<T>  Directives:   6 compiled</T>
<T>GOVERNANCE CHAIN</T>
<T ok>  PRD-001 accepted -> SPEC-001 accepted -> implemented (0 drift)</T>
<T>  PRD-002 accepted -> SPEC-002 in progress</T>
<T>GATE ACTIVITY (last 14 days)</T>
<T ok>  security:  1 critical finding (resolved — Kai, Mar 19)</T>
<T>  frontend:  2 advisory (acknowledged)</T>
<T ok>  qa:        0 findings</T>
<T>INVARIANT STATUS</T>
<T ok>  INV-001 (No Client-Side Financial Data): active, 0 violations</T>
<T ok>Governance is current. Last compiled: Mar 20.</T>
</Terminal>

Two different projects. Different stacks. Different clients. Different decisions. Same methodology. Same governance chain. Same quality gate structure. Same status format.

Ravi can see at a glance: the logistics API has zero security findings and one DBA warning that was resolved. The trading dashboard had a security gate fire and was resolved. Both projects have their client-specific invariants active with no violations.

He pulls this up in the client review meeting. Not a report he spent an hour writing — a command he ran in 2 seconds per project.

**Command reference:** `/keel:status`

---

## What stays the same, what varies

The methodology is the constant:
- The governance chain: PRD, spec, artifacts, plan, execute, drift detection
- The quality gates: blocking and advisory, with override logging
- The specialist agents: architect, security, DBA, API, QA, SRE
- The decision capture: ADRs compiled into enforcement directives
- The lifecycle hooks: session start, plan injection, compaction recovery, signal detection

What varies is what should vary:
- The stack rules: Go rules on the logistics project, TypeScript rules on the dashboard
- The ADRs: event sourcing for logistics tracking, Zustand for dashboard state
- The invariants: EU data residency for one client, no client-side storage for the other
- The compiled governance: each project's directives reflect that project's decisions only

Nothing leaks between clients. The logistics client's data residency invariant doesn't appear in the trading dashboard project. The dashboard's Zustand decision doesn't show up in the Go codebase. Per-project governance, shared methodology.

When an engineer rotates, they carry the methodology — not the client-specific knowledge. The knowledge is in the repo, loaded automatically. The methodology is in the muscle memory of running `/keel:init`, capturing decisions, compiling governance.

One command per project. The framework is immediate. The specifics accumulate as the engagement progresses. The next engineer who joins gets everything the last one built.

**Command reference:** `/keel:init`, `/keel:status`, `/keel:adr`, `/keel:invariant`, `/keel:compile`
