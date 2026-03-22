# CLAUDE.md

## What This Project Is

Keel is a governance layer for agentic engineering. It enforces your coding standards, persists your architectural decisions, and makes agent behavior reproducible across every session and every engineer.

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
│   └── project-context.md.tmpl
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
4. Read `.keel/project-context.md` for project identity

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
Keel is the governance layer for agentic engineering. It enforces coding standards, persists architectural decisions, and makes agent behavior reproducible across every session and every engineer.

### Before Writing Code
1. Read `docs/project-context.md` for project context
2. Rules are enforced automatically via `.claude/rules/`
3. If a plan is active, read it in `docs/plans/` — check progress table for current state
4. If a spec exists, read it in `docs/product/specs/` — the spec and its artifacts are the engineering blueprint

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
| "write a PRD", "document this feature" | `/keel:prd` |
| "write a spec", "technical spec for X" | `/keel:spec` |
| "generate artifacts", "create the data model" | `/keel:spec-artifacts` |
| "check drift", "did we build what we decided?" | `/keel:drift` |
| "compile governance", "update directives" | `/keel:compile` |
| "review governance", "are our ADRs well written?", "check governance quality" | `/keel:review-governance` |

### After Compaction
If context was compacted, the PostCompact hook will re-inject the active plan phase and invariants automatically. If you need full context, run `/keel:context`.
<!-- keel:end -->
