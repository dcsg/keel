# CLAUDE.md

## What This Project Is

Keel is a context engine and guardrail installer for Claude Code. It ensures Claude always has the right context and coding standards before writing code — producing consistent, production-grade results across any project.

This project dogfoods itself: `.keel/` governs keel's own development.

## Architecture

All commands are `.md` files — no build step, no compiled code, no runtime dependencies. Rule templates live in `templates/rules/`. Configuration lives in `.keel/config.yaml`.

**Repo structure:**
```
keel/
├── commands/                 # 5 keel slash commands
├── templates/
│   ├── rules/
│   │   ├── _registry.yaml   # maps rules to templates + metadata
│   │   ├── base/             # language-agnostic rules
│   │   ├── lang/             # language-specific rules
│   │   └── framework/        # framework-specific rules
│   ├── agents/               # agent templates
│   ├── sdlc/                 # PR templates, commit conventions
│   ├── CLAUDE.md.tmpl
│   ├── settings.json.tmpl
│   └── soul.md.tmpl
├── test/                     # bash test harness
├── docs/
│   ├── architecture/
│   │   ├── decisions/        # ADRs
│   │   └── invariants/       # hard rules
│   ├── plans/
│   └── guides/
├── install.sh
└── README.md
```

## Key Invariants

- Commands are `.md` files — no compiled code, no build step
- Installation is copy files — no npm, no dependencies
- Rule templates are single `.md` per topic (not folders with individual rules)
- Three-tier rules: base (language-agnostic), lang, framework
- Claude Code only for execution reliability

## Before Implementing

1. Read ADR-001 in `docs/architecture/decisions/`
2. Read INV-001 in `docs/architecture/invariants/`
3. Read the implementation plan in `docs/plans/PLAN-keel-v1.md`
4. Read `.keel/soul.md` for project identity

## Testing

Run `./test/run.sh` to validate templates, registry, and install.

## Commit Convention

```
{type}({scope}): {description}
```

Types: feat | fix | refactor | test | docs | chore

<!-- keel:start — managed by keel, do not edit manually -->
## Keel

### Project
Keel enforces coding standards and remembers architectural decisions so Claude behaves consistently — every session, every engineer.

### Before Writing Code
1. Read `docs/soul.md` for project context
2. Rules are enforced automatically via `.claude/rules/`
3. If a plan is active, read it in `docs/plans/` — check progress table for current state

### Build & Test Commands
```
# Test
./test/run.sh

# Install (global)
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

### Keel Commands
When the user asks any of the following, run the corresponding command automatically:

| If the user asks... | Run |
|---------------------|-----|
| "what's our status?", "where are we?", "project status" | `/keel:status` |
| "load context", "remind yourself", "what's this project?" | `/keel:context` |
| "create a plan", "let's plan this", "plan for X" | `/keel:plan` |
| "save this decision", "record this", "capture that" | `/keel:adr` |
| "add an invariant", "that's a hard rule", "never do X" | `/keel:invariant` |

### After Compaction
If context was compacted, re-read the active plan file in `docs/plans/`. The progress table is the persistent state — it tells you what's done and what's next.
<!-- keel:end -->
