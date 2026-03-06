# Keel — Soul

## What Is This

Keel is a context engine and guardrail installer for Claude Code. It ensures Claude always has the right architectural context, coding standards, and product knowledge before writing code — producing consistent, production-grade results across any project.

## Problem It Solves

Without structure, Claude in a new session is stateless — it doesn't know your architecture decisions, coding standards, or product context. Every session starts from zero. Keel fixes this by:

1. **Installing guardrails** — `.claude/rules/` files that enforce coding standards, security, testing, and architecture patterns automatically
2. **Loading context** — Soul files, product specs, and PRDs loaded at session start
3. **Intelligent onboarding** — Detects project age, infers architecture from description, audits existing codebases
4. **Execution structure** — Phased plans with dependencies, parallelism awareness, compaction recovery

## Who Uses It

Developers who use Claude Code seriously — solo builders, small teams, anyone who wants Claude to behave like a senior engineer who's been on the team for months, not a stateless code generator.

## Core Principles

- **Context is everything** — Right context in, right code out
- **Guardrails over guidelines** — Rules installed where Claude reads them, not in docs it forgets
- **Infer, don't interrogate** — User describes, keel figures out the rest
- **Opinionated but extensible** — Strong defaults, three levels of customization
- **Plain markdown** — No build step, no runtime dependencies, no proprietary formats
- **Claude-native** — Uses Claude Code's own features (rules, agents, hooks, worktrees) instead of reinventing them

## Non-Negotiables

- Commands are `.md` files — no compiled code, no build step
- Installation is copy files — no npm, no dependencies
- Works without external services (no Linear/Jira required for core features)
- `.claude/rules/` is where enforcement happens — not separate folders Claude might not read
- Three-tier rules (base/lang/framework), single `.md` per topic

## Stack

- Markdown for commands and templates
- YAML for configuration (`.keel/config.yaml`)
- No runtime dependencies — pure Claude Code slash commands

## Name

Keel — the structural backbone of a ship. You don't see it, but without it everything drifts.
