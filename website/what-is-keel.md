---
title: "What is Keel? — Governance Layer for Agentic Engineering"
description: "keel governs the full agentic engineering cycle — from requirements through execution to verification. Enforced standards, quality gates, drift detection."
---

# What is Keel?

**The governance layer for agentic engineering.**

Claude Code has memory. It doesn't have governance. Auto memory is local — never shared, never reviewed, never consistent across a team. Architectural decisions made last month live in Slack threads or nowhere. Standards exist in a CLAUDE.md file that drifts the moment someone forgets to update it.

The result: every engineer's Claude works differently. Same team, same codebase, different output. Decisions contradicted. Patterns ignored. Technical debt generated at machine speed.

keel governs the full agentic engineering cycle — from requirements and specifications through execution to verification. It doesn't tell you what to build. It ensures that what you decided to build is what actually gets built.

## The problem

You've told Claude your patterns. You've explained your architecture. You've corrected the same mistakes ten times. And then a new session starts, and you do it all over again.

This isn't a Claude problem. It's a governance problem. Claude is stateless by default. Without enforcement, every session starts from zero.

<Terminal title="Claude Code — without keel">
<T in>build the payment handler</T>
<T>func HandlePayment(w http.ResponseWriter, r *http.Request) {</T>
<T>    db.Query("INSERT INTO payments...")  // business logic in handler</T>
<T>    panic("stripe not configured")       // told you a hundred times</T>
<T>}</T>
<T in>I said — no DB calls in handlers, return errors don't panic, use the service layer. We have an ADR for this.</T>
<T>"You're right, let me fix that..."</T>
<T dim>// Tomorrow. New session. Same mistakes.</T>
</Terminal>

Not because Claude is incapable. Because there's no governance — no enforcement, no persistent decisions, no feedback loop.

And on a team, the problem multiplies. Five engineers, five different Claude sessions, five different interpretations of "follow the coding standards." The output looks like it came from five different organizations. Code review becomes standards enforcement — catching what Claude should have known, every PR, every day.

## The fix is structural, not conversational

You can't fix a stateless tool by talking to it more. You fix it by installing governance.

```
/keel:init
```

Describe your project once. keel installs your standards where Claude reads them automatically — before writing a single line of code.

<Terminal title="Claude Code — with keel">
<T in>build the payment handler</T>
<T dim>// Thin handler — delegates to PaymentService</T>
<T dim>// Returns error — no panics</T>
<T dim>// No DB calls — service layer handles persistence</T>
<T dim>// Named constants — no magic strings</T>
<T dim>// Because it read .claude/rules/go.md, architecture.md,</T>
<T dim>// error-handling.md before touching your code</T>
</Terminal>

The reminders disappear. The standards stick.

A CLAUDE.md is a suggestion Claude reads once. `.claude/rules/` is enforcement Claude follows on every file, every session — without being reminded.

Ready to try it? [Get Started — 5 minutes](/getting-started)

## The full cycle

Without keel, the engineering cycle is scattered — requirements in Notion, decisions in Slack, specs in someone's head, and no way to verify the implementation matches any of them.

keel governs the full agentic engineering cycle. You drive it through natural language:

> "Write a PRD for Stripe webhook delivery with retry logic"

Claude generates structured requirements with acceptance criteria grounded in your project context. You review and accept it.

> "Write a spec for PRD-005"

Claude routes to `architect`, scans your codebase, reads your existing ADRs, and generates a technical specification — architecture decisions, trade-offs, alternatives considered. Each step references the one before it.

> "Create a plan for SPEC-005"

Claude breaks the spec into phases, routes each to specialist agents for pre-flight review, and returns findings before a single line of code is written.

> "Does the implementation match the spec?"

Claude runs drift detection — comparing what got built against the PRD acceptance criteria, spec requirements, artifact contracts, and ADR compliance.

The full sequence:

```
PRD → spec → artifacts → plan → execute → drift detection
```

Each step feeds the next. Each must be accepted before the next begins.

**Command references:** `/keel:prd`, `/keel:spec`, `/keel:spec-artifacts`, `/keel:plan`, `/keel:drift`

## The governance loop

While Claude works, keel governs — automatically, every session:

- Claude writes a file → auto-formatted via PostToolUse hook
- Claude makes a decision → signal detected, ADR capture suggested → compile updates directives
- Context compaction hits → plan phase and invariants re-injected automatically
- Plan phase starts → specialist agents review before the first line is written
- Security gate fires → critical finding blocks progression until resolved
- Feature shipped → drift detection verifies it matches the spec and ADRs
- New engineer joins → same standards, same agents, same decisions, day one

This is not a checklist. These are lifecycle hooks that run without being told.

These aren't prompts. They're Claude Code platform primitives — lifecycle hooks that fire automatically, path-conditional rules that gate on file type, and quality gates that block progression. keel uses Claude Code's enforcement surface, not its conversation surface.

## What keel installs

### Guardrails — `.claude/rules/`

One `.md` file per standard. Path-conditional — each rule only fires on the files it's relevant to.

```
.claude/rules/code-quality.md       ← every file
.claude/rules/testing.md            ← every file
.claude/rules/security.md           ← every file
.claude/rules/error-handling.md     ← every file
.claude/rules/go.md                 ← **/*.go only
.claude/rules/chi.md                ← **/*.go only
```

What gets enforced without being told:
- No `panic` — return errors with context
- No business logic in HTTP handlers
- No raw SQL string concatenation — parameterized queries only
- No `any` in TypeScript — typed all the way down
- Test behavior, not implementation

Base rules (code-quality, testing, security, error-handling) apply to every language. Language and framework rules layer on top — Go, TypeScript, Python, React, Next.js, Chi, and more. keel detects your stack and picks the right combination.

keel works upstream of your linter. Rules tell Claude the standards before it writes code — so the linter rarely fires. Your CI pipeline still runs. Your linters still catch what they catch. keel's job is to prevent the violations from being written in the first place.

### Compiled governance directives

Tell Claude to compile your governance directives after capturing decisions:

> "Compile governance"

keel reads your accepted ADRs and active invariants, produces `.claude/rules/governance.md` — short, actionable directives Claude follows automatically. The ADRs are the source of truth. The compiled output is the enforcement format.

```
ADRs (accepted) + Invariants (active)
        ↓ /keel:compile
.claude/rules/governance.md (auto-loaded every session)
```

Update an ADR, recompile. One source of truth, one enforcement point.

**Command reference:** `/keel:compile`

### Specialist agents — `.claude/agents/`

18 domain agents matched to your stack. Each applies a specific domain lens.

```
architect    ← system design, ADRs, bounded contexts
security         ← OWASP, threat modeling, auth patterns
dba          ← schema design, migration safety, N+1 queries
api             ← API contracts, versioning, breaking changes
qa               ← testing strategy, coverage, flaky tests
```

Used in plan pre-flight review, review, and audit — or called directly.

### Project memory — `docs/`

Claude knows your project identity, not just your file structure.

```
docs/project-context.md  ← what the project is, stack, non-negotiables
docs/decisions/       ← why you chose PostgreSQL, why you went DDD
docs/invariants/      ← constraints that must NEVER be violated
```

Loaded automatically at session start via git-aware hooks.

### Lifecycle hooks

Nine hooks govern the session lifecycle:

| Hook | What it does |
|------|-------------|
| SessionStart | Surfaces what changed since last session, relevant agents |
| PreToolUse | Validates governance setup before Claude writes code |
| PostToolUse | Auto-formats code after every edit |
| Stop | Detects uncaptured decisions, suggests ADR capture |
| PreCompact | Preserves plan state before context compaction |
| PostCompact | Recovers context after compaction |
| UserPromptSubmit | Injects active plan phase on every prompt |
| SubagentStop | Logs agent activity and enforces quality gates |

## What changes day-to-day

**Defining requirements:**

> "Write a PRD for Stripe webhook delivery with retry logic and idempotency"

Structured requirements with acceptance criteria, generated from your description and project context. Lives in `docs/product/prds/` — referenced by everything that follows.

**Writing the spec:**

> "Write a spec for PRD-005"

Technical specification from the accepted PRD — architecture decisions, trade-offs, alternatives considered. Checked against your existing ADRs before generating.

**Planning execution:**

> "Create a plan for SPEC-005"

Phased execution with specialist pre-flight review:

<Terminal title="Pre-flight review">
<T>PRE-FLIGHT REVIEW</T>
<T>DBA</T>
<T err>  CRITICAL  Migration has no rollback — add DOWN migration before executing</T>
<T warn>  WARNING   No index on webhooks.status — queried in retry loop</T>
<T>API</T>
<T ok>  PASS      Endpoint contract looks stable</T>
</Terminal>

Fix the migration gap now. Takes 5 minutes. Would have taken an hour after.

**Quality gates:**

These fire automatically — you don't trigger them. When a specialist agent detects a critical finding during execution, Claude presents the gate:

<Terminal title="Quality gate">
<T err>GATE: security — critical finding</T>
<T>   Hardcoded JWT secret in auth/handler.go:47</T>
<T>   This gate must be resolved before proceeding.</T>
<T>   Override this gate? (y/n)</T>
<T dim>   Note: override will be logged with your git identity.</T>
</Terminal>

**After implementation:**

> "Does the implementation match the spec?"

<Terminal title="Drift report — SPEC-005">
<T>SUMMARY</T>
<T ok>  14 compliant (high confidence)</T>
<T hi>  2 likely compliant (medium)</T>
<T warn>  1 diverged</T>
<T>SPEC REQUIREMENTS</T>
<T warn>  Retry backoff — spec requires exponential with jitter</T>
<T dim>     expected: exponential backoff with jitter (ref: spec section 3.2)</T>
<T dim>     found: fixed 5-second retry interval</T>
<T hi>     action: Update RetryJob to use exponential backoff</T>
</Terminal>

**Governance dashboard:**

> "What's our status?"

<Terminal title="keel status — my-project">
<T>GOVERNANCE HEALTH</T>
<T>  Rules:        4 active (code-quality, testing, security, go)</T>
<T>  Agents:       7 installed</T>
<T>  Decisions:    12 ADRs, 1 invariant</T>
<T>  Plan:         PLAN-007 Phase 2/4 — in progress</T>
<T>CHAIN STATUS</T>
<T hi>  PRD-005 accepted → SPEC-005 accepted → artifacts accepted → PLAN-007 in progress</T>
<T>GATE ACTIVITY</T>
<T ok>  security: 1 critical finding (resolved)</T>
<T ok>  dba: no findings</T>
</Terminal>

## For teams

Commit `.claude/` and `docs/` to your repo. Every engineer using Claude Code gets identical governance from the first session — no setup, no per-developer configuration.

What this means for code review: the standards violations stop arriving. When every engineer's Claude follows the same rules, the same architecture decisions, and the same quality gates, code review shifts from catching formatting and pattern violations to evaluating design decisions. The baseline is handled.

What this means for onboarding: a new engineer opens the project, runs Claude Code, and gets the same governance as the engineer who set it up six months ago. The standards, the decisions, the agents — all there. No tribal knowledge. No "ask Marcus how we do error handling here."

What this means for consistency: the same coding standards enforced automatically. The same specialist agents installed. The same governance chain from PRD through drift detection. The same quality gates — critical findings block, overrides are logged with git identity.

No drift between teammates. The junior engineer follows the architecture from day one.

On a team, a shared CLAUDE.md requires every engineer to read it, remember it, and follow it. keel's rules fire automatically — no per-engineer discipline required.

[Set up keel for your team — Getting Started](/getting-started)

## Across projects

If you run multiple projects — client work, internal products, microservices — keel's governance installs per-project. Each project gets its own rules, its own decisions, its own agents matched to its stack.

The methodology stays constant: governance chain, quality gates, specialist review. The specifics vary: this project uses Go and PostgreSQL, that one uses TypeScript and MongoDB. Run `/keel:init` on each. The framework is immediate.

When engineers rotate between projects, they don't start from scratch. The governance is already there. Same discipline, different codebase. That's the difference between a methodology and a habit.

Maintenance is low by design. Rules update when you run the install script again. Decisions update when you compile. The overhead per project is a config file and the decisions you'd be making anyway — keel just makes sure they persist.

[See how it works on your first project — Getting Started](/getting-started)

## Why Claude Code only

keel is built on Claude Code's platform primitives. Other tools don't have them.

| Feature | Claude Code | Cursor | Copilot | Windsurf |
|---------|:-----------:|:------:|:-------:|:--------:|
| Path-conditional rules | Yes | No | No | No |
| Lifecycle hooks (9 types) | Yes | No | No | No |
| Pre-compact recovery | Yes | No | No | No |
| Slash commands | Yes | No | No | No |
| Specialist agents | Yes | No | No | No |
| Quality gates | Yes | No | No | No |

The knowledge base (project-context.md, ADRs, specs, docs) is plain markdown that works anywhere. The governance loop only works in Claude Code.

---

[Get Started — 5 minutes](/getting-started) · [View on GitHub](https://github.com/dcsg/keel)
