# Getting Started

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

This copies commands to `~/.claude/commands/keel/` and templates to `~/.keel/templates/`. No dependencies, no build step, no runtime.

## Initialize a Project

Open any project in Claude Code and run:

```
/keel:init
```

### Greenfield Project

If your project has fewer than 5 commits, keel treats it as greenfield. It will ask:

> What are you building?

Describe it in plain language — the stack, the domain, what it does. Keel infers your architecture, languages, and frameworks, then shows you a toggleable rule selection:

```
Based on your description:

  Project:      Go REST API for order management
  Architecture: DDD recommended
  Stack:        Go, Chi framework

  Rules:
  1. [x] code-quality     — SOLID, naming, structure
  2. [x] testing          — TDD, mock anti-patterns
  3. [x] security         — API surface detected
  4. [x] error-handling   — typed errors, no silent catches
  5. [ ] frontend         — no UI detected
  6. [x] architecture     — DDD with bounded contexts
  7. [x] go               — Go language rules
  8. [x] chi              — Chi framework patterns

  Type numbers to toggle (e.g. "5 6"), or press enter to accept:
```

Press enter to accept or type numbers to toggle rules on/off.

### Existing Project

If your project has commit history, keel runs a codebase audit — detecting languages, frameworks, test setup, and existing conventions — then recommends rules based on what it finds.

## What Gets Generated

After init, your project has:

```
your-project/
├── docs/
│   ├── soul.md                  # project identity
│   └── product/
│       ├── plans/               # execution plans
│       └── prds/                # feature requirements
├── .keel/
│   └── config.yaml              # keel configuration
└── .claude/
    ├── rules/                   # installed guardrails
    │   ├── code-quality.md
    │   ├── testing.md
    │   ├── security.md
    │   ├── error-handling.md
    │   └── go.md
    ├── agents/
    │   ├── reviewer.md
    │   └── debugger.md
    ├── settings.json            # hooks
    └── CLAUDE.md                # context loader
```

## Next Steps

- Run `/keel:context` to load all project context into your session
- Run `/keel:plan` when starting a new feature or task
- Say "what's our status?" anytime — Claude will run `/keel:status` automatically
