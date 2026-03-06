# What is Keel?

Keel is a context engine and guardrail installer for Claude Code. It ensures Claude always has the right architectural context, coding standards, and product knowledge before writing code — producing consistent, production-grade results across every session.

## The Problem

Without structure, Claude starts every session stateless. It doesn't know your architecture decisions, coding standards, or business rules. Output quality varies wildly between sessions. ADRs get ignored. Invariants get violated. Not because Claude is incapable — because the right context isn't loaded.

```
Session 1:  "Use error wrapping in Go"         ← you remind it
Session 2:  panic("not implemented")           ← forgot
Session 3:  "I said use error wrapping!"       ← you remind again
```

## The Solution

Keel installs your standards where Claude actually reads them.

```
/keel:init
```

One command. Describe your project. Keel infers your architecture, picks the right rules, and generates everything — coding standards as `.claude/rules/` files, project identity in `docs/soul.md`, and a `CLAUDE.md` that loads context automatically.

```
Session 1:  Claude reads .claude/rules/go.md   ← automatic
Session 2:  Claude reads .claude/rules/go.md   ← automatic
Session 3:  Claude reads .claude/rules/go.md   ← always automatic
```

## Two Pillars

### 1. Guardrails

`.claude/rules/` files that Claude reads before writing code. Path-conditional — Go rules only fire on `.go` files, framework rules only fire on their file types.

```
.claude/rules/
├── code-quality.md     ← all files
├── testing.md          ← all files
├── security.md         ← all files
├── error-handling.md   ← all files
├── go.md               ← **/*.go only
└── chi.md              ← **/*.go only
```

### 2. Context

Project memory that loads at session start — who the project is, what decisions were made, what's being built next.

```
docs/
├── soul.md             ← project identity
└── product/
    ├── spec.md         ← what you're building
    ├── prds/           ← feature requirements
    └── plans/          ← execution plans
```

## Why Claude Code Only

Keel targets Claude Code exclusively. Other AI coding tools lack the features keel depends on:

| Feature | Claude Code | Others |
|---------|:-----------:|:------:|
| Path-conditional rules | ✓ | ✗ |
| Hooks (pre-compact) | ✓ | ✗ |
| Slash commands | ✓ | ✗ |
| Subagents (Agent tool) | ✓ | ✗ |

The knowledge base (soul.md, ADRs, product docs) is plain markdown that works anywhere. But the full guardrail loop only works in Claude Code.
