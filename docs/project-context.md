# Keel — Project Context

## What Is This

Keel is the governance layer for agentic engineering. It governs the full engineering cycle — from requirements and specifications through execution to verification — closing the gap between what engineers intend and what agents produce.

Claude handles execution. Keel ensures what was decided is what gets built.

## Problem It Solves

Claude Code has memory — but it's local to each engineer, never shared, never consistent across a team. There's no governance: no enforced standards, no persistent decisions, no feedback loop when Claude drifts from what the team agreed on.

Keel fixes this by:

1. **Governing the engineering cycle** — PRD → spec → artifacts → plan → execute → drift detection, with status enforcement at each transition
2. **Compiling governance directives** — ADRs and invariants compile into short directives Claude follows automatically every session
3. **Enforcing through hooks** — 9 lifecycle hooks: auto-format, plan injection, compaction recovery, signal detection, quality gates
4. **Specialist review** — 16 domain agents (DBA, security, SRE, architect) review plans and implementations
5. **Detecting drift** — Verifies implementation matches the spec, PRD, and ADRs with confidence-based severity

## Who Uses It

Engineers who own the full spec-to-implementation cycle with Claude Code — solo agentic engineers, team leads standardizing AI across their team, and consultancies applying a repeatable methodology across client projects.

## Core Principles

- **Governance over context** — Context makes Claude informed; governance makes Claude consistent
- **Enforcement over suggestion** — Rules in `.claude/rules/` fire automatically; hooks run without being invoked
- **Traceability over trust** — Every decision traced from PRD through implementation to verification
- **Decisions compile into enforcement** — ADRs are the source of truth; compiled directives are the enforcement format
- **Infer, don't interrogate** — User describes, keel figures out the rest
- **Plain markdown, no magic** — No build step, no runtime, no proprietary formats
- **Claude Code native** — Uses the platform's primitives (rules, agents, hooks) instead of reinventing them

## Non-Negotiables

- Commands are `.md` files — no compiled code, no build step
- Installation is copy files — no npm, no dependencies
- The governance chain enforces status transitions — PRD accepted before spec, spec before artifacts
- ADRs are the source of truth — no manual edits to compiled governance directives
- Works without external services (no Linear/Jira required for core features)

## Stack

- Markdown for commands, templates, and governance directives
- YAML for configuration (`.keel/config.yaml`)
- Shell scripts for hooks (bash, no external dependencies)
- No runtime dependencies — pure Claude Code slash commands

## Name

Keel — the structural backbone of a ship. You don't see it, but without it everything drifts.

## Category

Agentic Engineering Governance

## Voice

Precise. Direct. Authoritative. Forward.
