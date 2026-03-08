# ADR-001 — Keel: Context Engine and Guardrail Installer for Claude Code

**Status:** Accepted
**Date:** 2026-03-06
**Deciders:** Daniel Gomes

## Context

AI coding tools (Claude Code, Cursor, Copilot) produce inconsistent output because they start every session stateless. Architecture decisions get ignored, coding standards drift, and business rules are violated — not because the AI is incapable, but because the right context isn't loaded.

Existing solutions either try to orchestrate AI execution (too complex) or dump documentation into a single file (too blunt). Claude Code now has native features — path-conditional rules, custom agents, hooks, worktree isolation — that make a lighter approach possible.

## Decision

Build **keel** as a lean context engine and guardrail installer with two pillars:

### Pillar 1 — Architecture & Design Governance

Install coding standards, security rules, and architecture patterns as `.claude/rules/` files where Claude automatically reads and enforces them. Three-tier rule system:

- **Base** (language-agnostic): code-quality, testing, security, error-handling
- **Language**: go, typescript, python, php (one .md per language)
- **Framework**: chi, nextjs, laravel, etc. (one .md per framework)

Rules are templates shipped with keel, generated into `.claude/rules/` based on project config. Three levels of extensibility: toggle (config only), extend (append custom rules to a topic), create new topics.

### Pillar 2 — Product Management & Execution

Provide a framework to capture product context (soul.md, product specs, PRDs) and create phased execution plans. Plans are the persistent state — progress tracked directly in the plan file, surviving context compaction.

### Core Commands (5 total)

| Command | Purpose |
|---------|---------|
| `/keel:init` | Intelligent onboarding: detect project age, interview or audit, infer architecture, scaffold everything |
| `/keel:context` | Load all context into session, show what's being pulled |
| `/keel:plan` | Interview + phased execution plan with parallelism analysis |
| `/keel:status` | Dashboard: roadmap progress, active plans, governance health |
| `/keel:intake` | Onboard scattered existing docs into keel's standard structure |
| `/keel:adr` | Capture an architectural decision — from scratch or from conversation |
| `/keel:invariant` | Define a hard constraint that must never be violated |
| `/keel:prd` | Write a product requirement document for a feature |

### Proactive Capture Loop

Keel's `CLAUDE.md` block instructs Claude to watch each response for signals worth capturing:

- **Architectural decisions** (technical choice with trade-offs) → suggest `/keel:adr`
- **Hard constraints** (must-never-violate rules) → suggest `/keel:invariant`
- **Product requirements** (clearly defined feature need) → suggest `/keel:prd`

This is transparent — Claude tells you what it detected and you decide whether to capture it. No silent background writes. The suggestion fires only on strong signals; preferences and implementation details are ignored.

### Intelligent Init

Init detects whether a project is greenfield or established:

- **Greenfield**: User describes what they're building in natural language. Keel infers architecture complexity, bounded contexts, which rule packs to enable, and seeds soul.md from the description. User confirms or toggles selections.
- **Established**: Keel runs a codebase audit (stack, directory structure, test patterns, CI/CD, git history) and recommends rule packs based on findings. Offers intake for existing docs.

### What Keel Does NOT Do

- **No execution orchestration** — Claude Code handles worktrees, agents, parallelism natively
- **No 25-command surface** — 8 commands, each with a single outcome
- **No proprietary formats** — Everything is plain markdown and YAML
- **No runtime dependencies** — Copy .md files, done
- **No backward compatibility with dof** — Clean break, migration path provided

## Project Structure (after init)

```
docs/
├── soul.md
├── product/
│   ├── spec.md
│   ├── prds/
│   └── plans/
└── reference/

.keel/
├── config.yaml

.claude/
├── rules/              # generated from keel templates
│   ├── code-quality.md
│   ├── testing.md
│   ├── security.md
│   ├── error-handling.md
│   └── {lang/framework}.md
├── agents/
├── settings.json       # hooks
└── CLAUDE.md
```

## Config

```yaml
# .keel/config.yaml
base: docs
stack: [go, react]

rules:
  code-quality: { include: all }
  testing: { include: all }
  security: { include: all }
  error-handling: { include: all }
  go: { include: all }
  chi: { include: all }
  # architecture: { include: all }  # opt-in DDD/clean arch

sdlc:
  commit-convention: conventional
  pr-template: true
```

## Distribution

Single-line installer:
```bash
curl -fsSL https://raw.githubusercontent.com/you/keel/main/install.sh | bash
```

Copies commands to `~/.claude/commands/` and templates to `~/.keel/templates/`. No npm, no dependencies.

## Rationale

- **Rules in `.claude/rules/`** — Where Claude actually reads them, not a separate folder it might skip
- **Templates, not runtime** — Keel generates files and gets out of the way
- **Infer, don't interrogate** — Fewer questions, smarter defaults
- **5 commands** — Minimal surface area, maximum impact
- **Plain markdown** — Zero installation friction, survives API changes

## Claude Code Only (For Now)

Keel targets Claude Code exclusively for execution reliability. Other AI coding tools (Cursor, Copilot, Windsurf, Gemini CLI) lack the features keel depends on:

- **Path-conditional rules** — Cursor/Copilot get one flat file; can't scope Go rules to `.go` files only
- **Hooks** — No way to enforce "load context before writing code" as a gate
- **Slash commands** — `/keel:init`, `/keel:plan` don't exist outside Claude Code
- **Custom agents** — Can't spawn reviewers or parallelize plan phases
- **Worktree isolation** — Phase-based execution with isolation is Claude Code native

The knowledge base (docs/, soul.md, config) is plain markdown and works anywhere. If a team uses Cursor alongside Claude Code, init can optionally generate a `.cursorrules` file as a best-effort summary — but the full loop (init, rules, context, plan, execute with guardrails) only works in Claude Code.

Building for the lowest common denominator would mean losing everything that makes keel effective. Better to be excellent on one platform than mediocre on five. If other tools add path-conditional rules and hooks later, support is trivial to add since the templates are already universal markdown.

## Consequences

- Existing dof/conductor projects need migration (rename + restructure)
- Rule templates must be maintained and kept current with language/framework evolution
- Init intelligence requires good inference logic (can improve over time)
- ADRs, invariants, and PRDs are first-class artifacts captured via `/keel:adr`, `/keel:invariant`, `/keel:prd`
