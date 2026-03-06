# Keel

**Stop hoping Claude remembers your standards. Install them.**

Keel is a context engine for Claude Code. It installs coding standards as `.claude/rules/` files, loads project memory at session start, and keeps every session consistent — whether it's you, a teammate, or a fresh conversation.

```
/keel:init
```

Describe your project once. Keel figures out the rest.

---

**If you've ever:**
- Spent the first 5 minutes of a Claude session re-explaining your architecture
- Seen Claude write `panic("not implemented")` after you've told it a hundred times to return errors
- Had Claude ignore your ADRs because it didn't know they existed
- Wished your whole team got consistent output from Claude, not just you

Keel is for you.

---

## Before Keel vs After Keel

**Before:** Every Claude session starts from zero. You re-explain your architecture. You remind it about error handling patterns. It writes Go code with `panic` instead of returning errors. It ignores your ADRs. Quality varies wildly between sessions.

**After:** Claude reads your rules automatically. It knows your project identity, your architecture decisions, your coding standards. Every session. Every time. Without you saying a word.

```
Before                              After
────────────────────────            ────────────────────────
"Use error wrapping"        →       .claude/rules/go.md
"Follow clean arch"         →       .claude/rules/architecture.md
"No any types in TS"        →       .claude/rules/typescript.md
"Check auth before access"  →       .claude/rules/security.md
"Read the ADRs first"       →       .claude/rules/code-quality.md
```

Rules are path-conditional. Go rules only fire on `*.go` files. Framework rules only fire on their file types. No noise.

---

## Quick Start

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

This copies commands to `~/.claude/commands/` and templates to `~/.keel/templates/`. No dependencies, no build step, no runtime.

### Initialize a Project

Open any project in Claude Code and run:

```
/keel:init
```

Keel detects whether your project is greenfield or established:

- **Greenfield** (< 5 commits): Describe what you're building in natural language. Keel infers your architecture, languages, frameworks, and recommends rules.
- **Established**: Keel audits your codebase, identifies languages and frameworks, and suggests rules based on what it finds.

You get a toggleable selection of rules. Turn on what you want, turn off what you don't. Then keel generates everything:

```
.claude/rules/code-quality.md
.claude/rules/testing.md
.claude/rules/security.md
.claude/rules/error-handling.md
.claude/rules/go.md
.claude/rules/chi.md
.claude/settings.json        ← PreToolUse + PreCompact hooks
.keel/config.yaml
docs/soul.md
docs/product/spec.md
docs/decisions/
docs/invariants/
CLAUDE.md
```

---

## Commands

| Command | What it does |
|---------|-------------|
| `/keel:init` | Detect project, infer architecture, install rules and context |
| `/keel:context` | Load soul, plans, ADRs, and product docs into current session |
| `/keel:plan` | Interview + phased execution plan with dependency tracking |
| `/keel:status` | Dashboard — plan progress, installed rules, governance health |
| `/keel:intake` | Scan for scattered docs and organize into keel structure |
| `/dof:migrate` | Convert `.dof/` projects to keel (global skill) |

## You don't need to remember commands

After init, just talk to Claude naturally:

| Say this... | Claude runs |
|-------------|-------------|
| "what's our status?" | `/keel:status` |
| "what's next?" | `/keel:status` |
| "remind yourself" | `/keel:context` |
| "let's plan the X feature" | `/keel:plan` |

---

## Rule Packs

Three tiers. One `.md` file per topic. Each installed as a `.claude/rules/` file with `paths:` frontmatter so it only activates on relevant files.

### Base (enabled by default)

| Rule | What it enforces |
|------|-----------------|
| **code-quality** | SOLID, naming, size limits, early returns, no dead code |
| **testing** | TDD, behavior-focused tests, mock boundaries, coverage |
| **security** | Input validation, parameterized queries, no secrets in code |
| **error-handling** | Typed errors, context enrichment, no silent catches |

### Base (opt-in)

| Rule | What it enforces |
|------|-----------------|
| **frontend** | Component patterns, a11y, state management, performance |
| **architecture** | DDD, clean architecture, bounded contexts, layer boundaries |

### Language

| Rule | Scope |
|------|-------|
| **go** | Error wrapping, interfaces, goroutine safety, project layout |
| **typescript** | Strict types, no `any`, async/await, Zod validation |
| **python** | Type hints, PEP 8, dataclasses, pytest patterns |
| **php** | strict_types, PHP 8+, PSR-12, Composer autoloading |

### Framework

| Rule | Scope |
|------|-------|
| **chi** | Route groups, middleware chains, thin handlers |
| **nextjs** | App Router, Server Components, Server Actions |
| **laravel** | Eloquent, Form Requests, Jobs, Events |
| **symfony** | DI, Doctrine, Messenger, Security voters |
| **rails** | ActiveRecord, service objects, jobs, RSpec |
| **django** | Models, views, ORM optimization, Celery tasks |

---

## What Gets Generated

After `/keel:init`, your project looks like this:

```
your-project/
├── docs/
│   ├── soul.md                  # project identity and non-negotiables
│   ├── decisions/               # architecture decision records
│   ├── invariants/              # hard constraints — never violate these
│   └── product/
│       ├── spec.md              # product spec / roadmap
│       ├── prds/                # feature requirements
│       └── plans/               # execution plans
├── .keel/
│   └── config.yaml              # keel configuration
└── .claude/
    ├── rules/                   # installed guardrails
    │   ├── code-quality.md
    │   ├── testing.md
    │   ├── security.md
    │   ├── error-handling.md
    │   └── go.md                # language-specific
    ├── agents/
    │   ├── reviewer.md          # code review agent
    │   └── debugger.md          # root cause analysis agent
    ├── settings.json            # PreToolUse context gate + PreCompact recovery
    └── CLAUDE.md                # project context block (safe merge)
```

---

## Extensibility

### Toggle rules on/off

Edit `.keel/config.yaml`:

```yaml
rules:
  base:
    - code-quality
    - testing
    - security
    - error-handling
  lang:
    - go
  framework:
    - chi
```

Remove a line to disable a rule. Add one to enable it. Run `/keel:init` again to regenerate.

### Extend existing rules

Add custom sections to any generated `.claude/rules/*.md` file. Keel tracks checksums — it won't overwrite your additions.

### Create new rule topics

Drop any `.md` file into `.claude/rules/` with `paths:` frontmatter:

```markdown
---
paths:
  - "internal/billing/**/*.go"
description: "Billing domain rules"
---

# Billing Rules

- All monetary amounts use `decimal.Decimal`, never `float64`
- Every charge mutation requires an idempotency key
```

---

## Context Loading

`/keel:context` loads your project's memory into the current session:

- **Soul** — project identity, non-negotiables, tech stack
- **Active plan** — current phase, progress, what's next
- **Product docs** — specs, PRDs, feature requirements
- **Architecture decisions** — ADRs that inform code choices
- **Invariants** — hard constraints Claude must never violate
- **Installed rules** — which packs are active, which were manually edited
- **Ticket system** — Linear/Jira config for referencing issues in plans

You don't need to run it manually at session start. The `PreToolUse` hook fires before Claude's first code write and reminds it to load context if it hasn't already.

---

## Planning

`/keel:plan` interviews you about a task, then produces a phased execution plan:

- Dependency graph between phases
- Parallelism annotations (which phases can run concurrently)
- Progress table that survives context compaction
- Model assignment suggestions (Opus for architecture, Sonnet for implementation)

Plans live in `docs/product/plans/` as plain markdown.

---

## Claude Code Only

Keel targets Claude Code exclusively. Other AI coding tools lack the features keel depends on:

| Feature | Claude Code | Cursor | Copilot | Windsurf |
|---------|:-----------:|:------:|:-------:|:--------:|
| Path-conditional rules | Yes | No | No | No |
| Hooks (pre-compact) | Yes | No | No | No |
| Slash commands | Yes | No | No | No |
| Agent tool (subagents) | Yes | No | No | No |

The knowledge base (soul.md, ADRs, product docs) is plain markdown that works anywhere. But the full guardrail loop — rules that fire on the right files, hooks that protect context, commands that orchestrate workflows — only works in Claude Code.

---

## Philosophy

**Context is everything.** The difference between good and bad AI output is almost always context. Keel's job is making sure Claude has the right context before it writes a single line.

**Guardrails over guidelines.** Documentation that Claude has to be told to read is documentation it will forget. Rules installed in `.claude/rules/` are enforced automatically.

**Infer, don't interrogate.** You describe your project in plain language. Keel figures out the architecture, picks the rules, and generates everything. You confirm and adjust.

**Plain markdown, no magic.** No build step. No runtime. No proprietary formats. Every file is a `.md` or `.yaml` you can read, edit, and version control.

**Minimal surface area.** Six commands. That's the entire interface. Each one does exactly one thing well.
