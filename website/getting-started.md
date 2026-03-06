# Getting Started

You'll be set up in under 5 minutes.

## 1. Install

```bash
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

Copies commands to `~/.claude/commands/keel/` and templates to `~/.keel/templates/`. No dependencies, no build step, no runtime — just files.

## 2. Open a project in Claude Code

Keel works on any project. New or existing.

## 3. Run `/keel:init`

```
/keel:init
```

Keel detects whether this is a new project or an existing one and takes the right path.

---

### New project (< 5 commits)

Keel asks one question:

> What are you building?

Answer in plain language. Be as specific or as vague as you like — keel infers the rest.

**Example:**

> A multi-tenant SaaS for restaurant inventory. Go backend with Chi, PostgreSQL, DDD with bounded contexts for inventory, orders, and suppliers. No frontend yet.

Keel infers your architecture, stack, and rules, then shows you what it picked:

```
Based on your description:

  Project:      Restaurant inventory SaaS — Go + Chi + DDD
  Architecture: DDD recommended (3 bounded contexts detected)
  Stack:        Go, Chi

  Rules:
  1. [x] code-quality     — SOLID, naming, structure
  2. [x] testing          — TDD, mock anti-patterns
  3. [x] security         — multi-tenant surface detected
  4. [x] error-handling   — typed errors, no silent catches
  5. [ ] frontend         — no UI detected
  6. [x] architecture     — DDD with bounded contexts
  7. [x] go               — Go language rules
  8. [x] chi              — Chi framework patterns

  Type numbers to toggle (e.g. "5 6"), or press enter to accept:
```

Press enter. Done.

---

### Existing project

Keel runs a codebase audit — reads your files, detects languages, frameworks, test setup, and existing linting config — then recommends rules based on what it actually finds. Same toggle UI, same one keypress to confirm.

---

## 4. Start working

That's it. From this point, every Claude session in this project:

- Reads your rules before writing any code
- Knows your project identity from `docs/soul.md`
- Responds to natural language — just say "what's our status?" or "what's next?"

**What just got generated:**

```
your-project/
├── docs/
│   ├── soul.md                  # project identity
│   └── product/
│       ├── plans/               # execution plans
│       └── prds/                # feature requirements
├── .keel/
│   └── config.yaml              # your configuration
└── .claude/
    ├── rules/                   # guardrails Claude reads automatically
    │   ├── code-quality.md
    │   ├── testing.md
    │   ├── security.md
    │   ├── error-handling.md
    │   ├── go.md
    │   └── chi.md
    ├── agents/
    │   ├── reviewer.md          # run: "review this PR"
    │   └── debugger.md          # run: "debug this issue"
    ├── settings.json            # compaction recovery hook
    └── CLAUDE.md                # loads context automatically
```

## What to do next

**Start a feature:** just describe what you want, or run `/keel:plan` for a structured approach with phases and dependencies.

**Check progress:** say "what's our status?" — Claude runs `/keel:status` and shows exactly where things stand.

**Commit everything:** `.claude/`, `.keel/`, `docs/soul.md` — all of it. Your teammates get the same context the moment they open the project.
