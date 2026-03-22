---
title: "Getting Started with Keel — Install in 5 Minutes"
description: "Install keel, run /keel:init, and govern your Claude Code sessions in under 5 minutes. Automatic standards, specialist agents, lifecycle hooks."
---

# Getting Started

## What you'll have in 5 minutes

After running `/keel:init`, your project gets:

- **Rules** that Claude reads before writing any code — matched to your stack
- **Specialist agents** (architect, QA, security, DBA) you can invoke by name
- **Automatic behaviors** — code auto-formatted on edit, context refreshed each session, decisions captured when you make them
- **A governance chain** — PRD → Spec → Plan → Code, with drift detection

All committed to your repo. Your whole team gets identical governance.

## 1. Install

```bash
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

Copies commands to `~/.claude/commands/keel/` and templates to `~/.keel/templates/`. No dependencies, no build step, no runtime — just files.

## 2. Open a project in Claude Code

keel works on any project. New or existing.

## 3. Run `/keel:init`

```
/keel:init
```

Init runs in three steps. You talk to Claude naturally throughout — no CLI flags, no config files to edit.

---

### [1/3] Scan

keel scans your codebase automatically — languages, frameworks, linters, existing docs, commit conventions:

**Existing project:**
```
[1/3] Scanning project...

  Code:       Go project, 142 files
              Chi framework, PostgreSQL
  Build:      make build
  Test:       make test
  Lint:       golangci-lint (.golangci-lint.yaml)
  AI config:  CLAUDE.md (34 lines)
  Docs:       3 ADRs in docs/decisions/
  Commits:    conventional commits detected
  Governance: archway.yaml detected — architecture pack skipped
```

**New project (no code yet):**

keel shows the same scan format (with "no source files detected"), then asks:

> What are you building?
>
> Example: "A multi-tenant SaaS for restaurant inventory. Go + Chi, PostgreSQL, DDD with bounded contexts."

Describe your project in a few sentences. keel infers the stack and architecture from your description.

---

### [2/3] Configure

keel shows all available rules and agents in one view. Recommended items are checked based on what was detected or described. Everything else is available to toggle on:

```
Rules (✓ = recommended for your stack):

  Base:
    [x] code-quality       — naming, structure, size limits
    [x] testing            — TDD, mock boundaries
    [x] security           — input validation, no hardcoded secrets
    [x] error-handling     — typed errors, context wrapping
    [ ] api                — REST conventions, pagination, versioning
    [x] architecture       — layer boundaries, DDD, bounded contexts
    [ ] database           — migrations, indexes, N+1 prevention
    ...

  Language:
    [x] go                 — error handling, interfaces, goroutines
    ...

  Framework:
    [x] chi                — thin handlers, middleware chains
    ...

Agents (✓ = matched to your stack):

    [x] architect          — architecture review
    [x] backend            — Go patterns
    [x] dba                — PostgreSQL
    [x] qa                 — test strategy
    [x] docs               — documentation
    [ ] security           — OWASP, auth, secrets
    ...

SDLC:
  Commits:    conventional commits (detected from git log)
  PR template: yes (GitHub repo detected)

Toggle items by name (e.g. "add api", "add security"),
or say "looks good" to proceed.
```

One screen. Say "looks good" when you're happy with the selection.

---

### [3/3] Install

keel generates everything and shows progress:

```
[3/3] Installing...

  ✓ Config          .keel/config.yaml
  ✓ Project context docs/project-context.md
  ✓ Rules           6 packs → .claude/rules/
  ✓ Agents          5 specialists → .claude/agents/
  ✓ Hooks           .claude/settings.json (9 behaviors)
  ✓ CLAUDE.md       updated
  ✓ Directories     docs/architecture/, docs/plans/, docs/product/
```

---

### Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL INITIALIZED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Rules:   6 packs — code-quality, testing, security,
           error-handling, go, chi
  Agents:  5 specialists — architect, qa, backend, dba, docs
  Hooks:   auto-format on edit, context on session start,
           plan injection on every prompt, compaction recovery,
           decision detection on session end

What just changed:

  Before keel, Claude writes code with no project standards,
  no architecture awareness, and forgets everything between sessions.

  Now Claude reads your 6 rule packs before writing any code.
  Try it — ask Claude to write a function and watch it follow
  your project's error handling and testing patterns.

  Commit .keel/, .claude/, and docs/ to git — your team gets
  identical governance automatically.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 4. Start working

From this point, every Claude session in this project reads your rules before writing code, knows your project identity, and enforces standards automatically.

Just describe what you want to build. keel governs in the background.

**Start the governance chain:**

> "Write a PRD for [feature name]"

Claude generates structured requirements with acceptance criteria. Accept it, then continue: "Write a spec for PRD-001", "Create a plan for SPEC-001". Each step feeds the next.

**Capture decisions as you go:**

> "Save this decision"

Claude persists it as an ADR with enforcement-grade language. Then say "Compile governance" to update the directives Claude follows automatically.

**Check governance health:**

> "What's our status?"

Claude shows the governance dashboard — rules, agents, chain status, gate activity, signals.

### For teams

One engineer runs `/keel:init` and commits the generated files. Every teammate using Claude Code gets the same governance automatically — no additional setup. The rules, agents, hooks, and decisions are in the repo.

### Across projects

Run `/keel:init` in each project. Each gets its own rules matched to its stack, its own decisions, its own agents. The methodology is the same everywhere.

---

## What got generated

```
your-project/
├── docs/
│   ├── project-context.md       # project identity
│   ├── architecture/
│   │   ├── decisions/           # ADRs (with README)
│   │   └── invariants/          # hard constraints (with README)
│   └── product/
│       ├── plans/               # execution plans (with README)
│       ├── prds/                # requirements (with README)
│       └── specs/               # specifications (with README)
├── .keel/
│   └── config.yaml              # governance configuration
└── .claude/
    ├── rules/                   # guardrails Claude reads automatically
    ├── agents/                  # specialist agents (stack-matched)
    ├── settings.json            # 9 automatic behaviors
    └── CLAUDE.md                # project block + natural language triggers
```

**Automatic behaviors (9 lifecycle hooks):**

| Behavior | What happens |
|----------|-------------|
| Session refresh | Surfaces what changed since last session |
| Governance check | Validates setup before Claude writes code |
| Auto-format | Formats code after every edit |
| Decision detection | Suggests ADR capture when decisions are made |
| Plan injection | Injects active plan phase on every prompt |
| Context preservation | Preserves plan state before compaction |
| Context recovery | Recovers plan + invariants after compaction |
| Agent logging | Logs agent activity, enforces quality gates |
| Rule tracking | Logs which rule packs load each session |

All behaviors are [configurable](/governance/features) — set any to `false` in `.keel/config.yaml`.

---

**Questions?** See the [FAQ](/faq) or [open an issue on GitHub](https://github.com/dcsg/keel/issues).
