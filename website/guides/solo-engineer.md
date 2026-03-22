---
title: "Keel for Solo Engineers"
description: "The full conversation: from first init to compound governance. Watch keel turn Claude from a stateless tool into a governed engineering partner."
---

# Keel for Solo Engineers

You own the full cycle. Requirements, architecture, implementation, testing, shipping. Every decision is yours. And every decision lives in your head — which means Claude doesn't have it next session.

This guide shows the actual workflow. Not summaries. Not feature lists. The conversation between you and Claude, from first init to the moment governance starts compounding.

---

## 1. First init — describe the project, get governance

You have a Go backend for a payment processing service. Chi router, PostgreSQL, hexagonal architecture. You've been running Claude Code on it for two weeks with a hand-maintained CLAUDE.md that's already out of date.

<Terminal title="Claude Code — payment-service">
<T in>/keel:init</T>
<T>[1/3] Scanning project...</T>
<T dim>  Code: Go project, 89 files. Chi framework, PostgreSQL.</T>
<T dim>  Build: make build | Test: make test</T>
<T dim>  Commits: conventional commits detected</T>
<T>[2/3] Configuring...</T>
<T>Rules (✓ = recommended for your stack):</T>
<T hi>  [x] code-quality     — naming, correctness guardrails</T>
<T hi>  [x] testing          — TDD, tautological test prevention</T>
<T hi>  [x] security         — payment surface detected, timing attacks</T>
<T hi>  [x] error-handling   — typed errors, context wrapping</T>
<T hi>  [x] architecture     — hexagonal layer enforcement</T>
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

That took 30 seconds. The rules are in `.claude/rules/`. The agents are in `.claude/agents/`. The hooks are in `.claude/settings.json`. Everything Claude needs to follow your standards is installed where Claude actually reads it — not in a wiki, not in a doc you'll forget to update.

---

## 2. The moment Claude follows the rules without being told

Next morning. New session. You don't mention your architecture. You don't remind Claude about error handling. You just describe the work.

<Terminal title="Claude Code — payment-service">
<T in>I need a new endpoint to handle Stripe webhook events. POST /webhooks/stripe. It should verify the Stripe signature, parse the event, and route to the right handler based on event type. Start with payment_intent.succeeded and payment_intent.payment_failed.</T>
<T>I'll build the webhook handler following your hexagonal architecture.</T>
<T>Here's my approach:</T>
<T>- Domain: WebhookEvent entity + PaymentEventHandler port</T>
<T>- Application: ProcessWebhookUseCase orchestrates verification → parsing → routing</T>
<T>- Infrastructure: StripeWebhookAdapter (signature verification), Chi handler (HTTP layer only)</T>
<T>The handler won't touch the database directly — it calls through the application layer. Errors will be typed (ErrInvalidSignature, ErrUnknownEventType) with context wrapping per your error-handling rules.</T>
<T>I'll use the raw request body for signature verification, not the parsed JSON — Stripe requires the raw bytes.</T>
<T>Starting with the domain layer.</T>
</Terminal>

Stop and read that again.

Claude separated the layers correctly — domain, application, infrastructure. It kept the HTTP handler thin. It used typed errors with context wrapping. It knew about Stripe's raw body requirement. It planned the work from the domain layer outward.

You didn't ask for any of that. The rules in `.claude/rules/` told Claude how your project works. The `go.md` rules told it how you write Go. The `architecture.md` rules told it about hexagonal layers. The `error-handling.md` rules told it about typed errors.

This is the moment. Claude read your rules before you asked. No reminding. No re-explaining. The overhead stops here.

---

## 3. Writing a PRD through conversation

Two weeks in. You need Stripe webhook delivery with retry logic — not just receiving webhooks, but sending them to your own consumers. Before writing code, you capture the requirements.

<Terminal title="Claude Code — payment-service">
<T in>Write a PRD for webhook delivery to our consumers. We need to send events when payments succeed, fail, or get refunded. Retry logic with backoff. Idempotency so consumers can safely receive the same event twice.</T>
<T>Before I draft this, a few questions to ground the requirements in your project:</T>
<T>1. Delivery target — are consumers external HTTP endpoints (like Stripe's model) or internal services via a message queue?</T>
<T>2. Retry budget — how many attempts before marking delivery failed? And what's the max delay you'd accept between first failure and final attempt?</T>
<T>3. Idempotency scope — should idempotency be per-consumer (same event delivered to consumer A twice is deduplicated) or global (same event ID is never processed twice, period)?</T>
<T>4. Ordering — do consumers need events in order (payment_intent.succeeded always after payment_intent.created) or is out-of-order acceptable with idempotency handling it?</T>
<T>5. I see your existing PaymentEventHandler port in the domain layer. Should webhook delivery extend this port or be a separate bounded context?</T>
</Terminal>

Notice question 5. Claude read your codebase. It found the existing port and asked whether to extend it or create something new. It's not generating from a template — it's grounding the requirements in what already exists.

<Terminal title="Claude Code — payment-service">
<T in>External HTTP endpoints, like Stripe's model. 5 retries max, exponential backoff with jitter, max delay 4 hours. Idempotency per-consumer. Out-of-order is fine. Separate bounded context — delivery is its own domain.</T>
<T>Got it. Drafting now.</T>
<T>PRD-003: Webhook Delivery System</T>
<T dim>Status: draft</T>
<T dim>Domain: Webhook Delivery (new bounded context)</T>
<T>Problem:</T>
<T>  Consumers of our payment platform have no way to receive real-time notifications when payment events occur. They must poll the API, which increases latency and load.</T>
<T>Solution:</T>
<T>  HTTP webhook delivery system. Consumers register endpoints. The platform delivers events with retry logic and idempotency guarantees.</T>
<T>Acceptance Criteria:</T>
<T>  1. Deliver payment_intent.succeeded, payment_intent.payment_failed, charge.refunded events to registered consumer endpoints</T>
<T>  2. Retry failed deliveries: exponential backoff with jitter, 5 attempts max, 4-hour ceiling</T>
<T>  3. Per-consumer idempotency: same event + same consumer = deduplicated (consumer receives it at most once after success)</T>
<T>  4. Delivery status tracking: pending → delivering → delivered / failed</T>
<T>  5. Consumer endpoint registration via API</T>
<T>  6. Signature verification so consumers can authenticate the source</T>
<T>  7. Separate bounded context from payment processing</T>
<T hi>Saved: docs/product/prds/PRD-003-webhook-delivery.md</T>
<T>Review and tell me what to change, or accept it and we'll move to the spec.</T>
<T in>Accept it.</T>
<T>PRD-003 accepted. Ready for spec when you are.</T>
</Terminal>

The requirements survive context compaction. They're in `docs/product/prds/`. Tomorrow's session can reference them without you re-explaining what you're building.

**Command reference:** `/keel:prd`

---

## 4. Spec interview — Claude asks codebase-aware questions

<Terminal title="Claude Code — payment-service">
<T in>Write a spec for PRD-003</T>
<T>Routing to architect for spec generation.</T>
<T>Before I write the spec, I've scanned your codebase and have questions:</T>
<T>1. Your existing migrations use goose with sequential numbering. I'll follow that convention for the delivery tables. Any reason to change?</T>
<T>2. I see you're using pgx for database access in the infrastructure layer. The delivery system will need a transactional outbox to guarantee event delivery — should I use pgx transactions for the outbox pattern, or do you want a separate approach?</T>
<T>3. ADR-001 established typed errors with context wrapping. For delivery failures, I'll create DeliveryError with cause chaining (network timeout, HTTP 5xx, signature mismatch). That consistent with your intent?</T>
<T>4. Your Chi middleware stack includes request ID propagation. Should delivery attempts carry the originating request ID for traceability, or generate their own?</T>
<T>5. Testing: your existing test setup uses testcontainers-go for PostgreSQL integration tests. I'll follow that for delivery tests. Confirm?</T>
</Terminal>

Every question references something real in your codebase. The migration tool. The database driver. An existing ADR. The middleware stack. The test setup. Claude isn't guessing — it read the project before asking.

<Terminal title="Claude Code — payment-service">
<T in>Yes to all. Use pgx transactions for the outbox. Delivery attempts should carry the originating request ID.</T>
<T>Spec generated.</T>
<T>SPEC-003: Webhook Delivery System</T>
<T dim>Source PRD:  PRD-003</T>
<T dim>Status:      draft</T>
<T dim>References:  ADR-001 (error handling), ADR-002 (database conventions)</T>
<T>Architecture:</T>
<T>  New bounded context: delivery/</T>
<T>  Domain:         DeliveryEvent, ConsumerEndpoint, DeliveryAttempt</T>
<T>  Application:    ScheduleDeliveryUseCase, RetryDeliveryUseCase</T>
<T>  Infrastructure: HTTPDeliverer, PostgresOutbox, ConsumerRepository</T>
<T>Key decisions:</T>
<T>  - Transactional outbox pattern via pgx — events written to outbox table in same transaction as domain events</T>
<T>  - Exponential backoff: base 30s, factor 2, jitter ±20%, cap 4h</T>
<T>  - Per-consumer idempotency via (event_id, consumer_id) unique constraint</T>
<T>  - HMAC-SHA256 signatures using per-consumer secrets</T>
<T>Database:</T>
<T>  3 tables: consumer_endpoints, delivery_outbox, delivery_attempts</T>
<T>  Migrations: goose sequential, following existing convention</T>
<T hi>Saved: docs/product/specs/SPEC-003-webhook-delivery/spec.md</T>
<T>Review it. I'll generate artifacts once you accept.</T>
<T in>Accept.</T>
<T>SPEC-003 accepted.</T>
</Terminal>

**Command reference:** `/keel:spec PRD-003`

---

## 5. Pre-flight review — specialist agents catch what you'd miss

<Terminal title="Claude Code — payment-service">
<T in>Create a plan for SPEC-003</T>
<T>Breaking SPEC-003 into implementation phases.</T>
<T>PLAN-003: Webhook Delivery System</T>
<T>  Phase 1: Domain layer — entities, value objects, ports</T>
<T>  Phase 2: Database — migrations, outbox table, repositories</T>
<T>  Phase 3: Application layer — use cases, retry scheduling</T>
<T>  Phase 4: Infrastructure — HTTP deliverer, signature generation</T>
<T>  Phase 5: API — consumer registration endpoints, Chi handlers</T>
<T>  Phase 6: Integration tests</T>
<T>Running pre-flight review with specialist agents...</T>
<T>PRE-FLIGHT REVIEW</T>
<T dim>DBA</T>
<T err>  CRITICAL  Migration 007_create_delivery_outbox has no DOWN migration — add rollback before executing</T>
<T warn>  WARNING   No index on delivery_outbox.status — queried in every retry poll cycle, will degrade at volume</T>
<T warn>  WARNING   delivery_attempts.created_at missing — needed for backoff calculation</T>
<T dim>SECURITY</T>
<T warn>  WARNING   Consumer webhook secrets must be generated server-side with crypto/rand, not accepted as user input</T>
<T ok>  PASS      HMAC-SHA256 signature scheme is sound</T>
<T dim>API</T>
<T ok>  PASS      Consumer registration endpoint contract is stable</T>
<T>  INFO      Consider pagination on GET /consumers/{id}/deliveries — could return thousands of rows</T>
<T dim>QA</T>
<T warn>  WARNING   No test case for jitter bounds — backoff with jitter should be tested for min/max range</T>
<T dim>SRE</T>
<T>  INFO      Consider circuit breaker for consumer endpoints that fail repeatedly — avoid retry storms</T>
<T warn>3 findings require attention before execution.</T>
<T>Fix now, or proceed with known gaps?</T>
</Terminal>

The DBA caught the missing rollback migration. The security agent caught a secret generation issue. The QA agent caught a missing test case. These are the things you'd catch in code review — except they were caught before a single line was written.

<Terminal title="Claude Code — payment-service">
<T in>Fix the migration rollback, add the index, add the created_at column, and generate secrets server-side. The rest I'll address during implementation.</T>
<T>Updated. Plan ready for execution.</T>
<T>Phase 1 is active. Start when ready.</T>
</Terminal>

Five minutes to catch a migration without a rollback. After implementation, that's an hour of work and a risky production deploy.

**Command reference:** `/keel:plan SPEC-003`

---

## 6. The drift check — does the implementation match what was decided?

Three days later. All six phases are complete. The webhook delivery system is built. Before you open a PR, you verify.

<Terminal title="Claude Code — payment-service">
<T in>Does the implementation match the spec for SPEC-003?</T>
<T>Running drift detection against the full governance chain.</T>
<T>Comparing: PRD-003 → SPEC-003 → artifacts → implementation</T>
<T>DRIFT REPORT — SPEC-003</T>
<T dim>SUMMARY</T>
<T ok>  14 compliant          2 likely compliant</T>
<T err>   1 diverged           0 unknown</T>
<T>PRD ACCEPTANCE CRITERIA</T>
<T ok>  [compliant] Deliver payment events to registered endpoints</T>
<T ok>  [compliant] Retry with exponential backoff, 5 attempts, 4h cap</T>
<T ok>  [compliant] Per-consumer idempotency</T>
<T ok>  [compliant] Delivery status tracking</T>
<T ok>  [compliant] Consumer endpoint registration</T>
<T ok>  [compliant] Signature verification</T>
<T>SPEC REQUIREMENTS</T>
<T ok>  [compliant]  Transactional outbox with pgx</T>
<T ok>  [compliant]  HMAC-SHA256 signatures</T>
<T ok>  [compliant]  Goose sequential migrations with rollbacks</T>
<T ok>  [compliant]  Typed errors with context wrapping (per ADR-001)</T>
<T err>  [diverged]   Retry backoff — spec requires jitter</T>
<T>     expected: exponential backoff with jitter, +/-20% (spec 3.2)</T>
<T>     found:    fixed exponential backoff, no jitter</T>
<T hi>     file:     delivery/infrastructure/retry_scheduler.go:47</T>
<T>     action:   Add jitter to calculateBackoff()</T>
<T>ADR COMPLIANCE</T>
<T ok>  [compliant]  ADR-001: typed errors with context wrapping</T>
<T ok>  [compliant]  ADR-002: database conventions followed</T>
<T>INVARIANT COMPLIANCE</T>
<T ok>  [compliant]  All invariants respected</T>
<T warn>1 divergence. 1 action required.</T>
</Terminal>

One divergence. The retry scheduler uses exponential backoff but forgot the jitter. The spec said jitter. The implementation doesn't have it. File path, line number, clear action.

<Terminal title="Claude Code — payment-service">
<T in>Fix the jitter.</T>
<T>Updated delivery/infrastructure/retry_scheduler.go — added +/-20% jitter to calculateBackoff() using crypto/rand for uniform distribution.</T>
<T>Re-running drift check...</T>
<T>DRIFT REPORT — SPEC-003</T>
<T dim>SUMMARY</T>
<T ok>  15 compliant          2 likely compliant</T>
<T ok>   0 diverged           0 unknown</T>
<T ok>Full compliance. Implementation matches the governance chain.</T>
</Terminal>

Zero drift. What was decided is what got built.

**Command reference:** `/keel:drift SPEC-003`

---

## 7. Decision capture — governance that compiles itself

During implementation, you made a choice: transactional outbox over event-driven messaging. Claude's `Stop` hook noticed.

<Terminal title="Claude Code — payment-service">
<T>Decision signal detected:</T>
<T>  You chose transactional outbox pattern over event-driven messaging (Kafka/NATS) for webhook delivery reliability.</T>
<T>Rationale detected:</T>
<T>  - Eliminates message broker dependency</T>
<T>  - Guarantees delivery atomicity with domain writes</T>
<T>  - Simpler operational model for current scale</T>
<T>Save this as an ADR? (y/n)</T>
<T in>Yes.</T>
<T>ADR-003: Transactional Outbox for Webhook Delivery</T>
<T dim>Status: accepted</T>
<T hi>Saved: docs/architecture/decisions/ADR-003-transactional-outbox.md</T>
<T in>Compile governance.</T>
<T>Reading all accepted ADRs and active invariants...</T>
<T hi>Governance compiled: .claude/rules/governance.md</T>
<T>  3 ADRs  ->  4 directives</T>
<T>  1 invariant -> 1 directive</T>
<T>  5 total directives</T>
<T>Directives:</T>
<T>  1. Use typed errors with context wrapping (ADR-001)</T>
<T>  2. Follow goose sequential migration conventions (ADR-002)</T>
<T>  3. Use transactional outbox for async event delivery (ADR-003)</T>
<T>  4. Hexagonal architecture: no domain imports from infrastructure (ADR-001)</T>
<T>  5. All database schema changes require DOWN migrations (INV-001)</T>
<T>Claude will follow these directives automatically in every session.</T>
</Terminal>

The decision you made today is now enforcement tomorrow. Not a doc someone might read. A directive Claude loads automatically, every session, before writing code.

**Command references:** `/keel:adr`, `/keel:compile`

---

## 8. Next session — Claude already knows everything

Thursday morning. New session. You haven't opened this project since Tuesday.

<Terminal title="Claude Code — payment-service">
<T>[SessionStart] Loading project context...</T>
<T>Payment Processing Service — Go + Chi + PostgreSQL</T>
<T dim>Last session: Tue Mar 18 — completed webhook delivery system</T>
<T>Active governance:</T>
<T>  7 rules, 7 agents, 5 compiled directives</T>
<T>  3 ADRs (error handling, DB conventions, transactional outbox)</T>
<T>  1 invariant (migration rollbacks required)</T>
<T>Governance chain:</T>
<T hi>  PRD-003 accepted -> SPEC-003 accepted -> implemented (0 drift)</T>
<T>No active plan. What would you like to work on?</T>
<T in>I need to add a dead letter queue for webhook deliveries that exhaust all retries.</T>
<T>Good addition. A few things I'll account for based on your existing governance:</T>
<T>- ADR-003 established the transactional outbox pattern — the DLQ will be a table in the same database, not a separate message broker</T>
<T>- Per your error-handling rules, failed deliveries will use typed errors (DeliveryExhaustedError) with the full attempt history</T>
<T>- Migration will include a DOWN migration per INV-001</T>
<T>Want me to write a PRD for this, or is it small enough to go straight to implementation?</T>
</Terminal>

Claude referenced ADR-003 (which you captured two days ago), your error handling rules, and your migration invariant. Without being asked. Without being reminded. The governance is working.

This is the compound effect. The first session after `/keel:init` is better. The tenth session is substantially better. Each ADR compounds into enforcement. Each spec becomes a drift detection baseline. Each decision you capture makes the next session smarter.

A hand-maintained CLAUDE.md decays the moment you forget to update it. Keel's governance accumulates. You still make every call. Keel makes sure Claude remembers them.

**Command reference:** `/keel:status`
