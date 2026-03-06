# /keel:init

Intelligent onboarding. Detects your project, infers architecture and rules, and installs everything.

## Usage

```
/keel:init
```

No arguments. Keel figures out the rest.

## How It Works

### Step 1 — Detect Project Age

Keel checks git history to determine if this is a greenfield or established project.

- **< 5 commits** → Greenfield flow
- **5+ commits** → Established flow

### Step 2A — Greenfield Flow

Keel asks one question:

> What are you building?

Describe your project in plain language. Keel infers:
- Architecture pattern (simple, layered, DDD)
- Language and framework
- Which rules make sense

Then shows you the inferred selections to confirm or adjust.

### Step 2B — Established Flow

Keel runs a codebase audit using a subagent:
- Languages and versions
- Frameworks and dependencies
- Directory structure pattern
- Test setup
- Existing linting config
- Git history depth

Then recommends rules based on what it finds.

### Step 3 — Rule Selection

Both flows end at the same toggle UI:

```
  Rules:
  1. [x] code-quality     — SOLID, naming, structure
  2. [x] testing          — TDD, mock anti-patterns
  3. [x] security         — API surface detected
  4. [x] error-handling   — typed errors, no silent catches
  5. [ ] frontend         — no UI detected
  6. [x] architecture     — DDD recommended
  7. [x] go               — Go detected
  8. [x] chi              — Chi detected

  Type numbers to toggle (e.g. "5 6"), or press enter to accept:
```

### Step 4 — Generation

Keel generates:

| File | Purpose |
|------|---------|
| `.keel/config.yaml` | Source of truth for rules and config |
| `.claude/rules/*.md` | Installed guardrails |
| `.claude/CLAUDE.md` | Context loader with project summary |
| `.claude/settings.json` | Hooks (PreCompact recovery) |
| `.claude/agents/reviewer.md` | Code review agent |
| `.claude/agents/debugger.md` | Root cause analysis agent |
| `docs/soul.md` | Project identity |
| `.github/pull_request_template.md` | PR template (if opted in) |

## Re-running

Running `/keel:init` again on an existing keel project updates rules from config. It won't overwrite files you've manually edited (tracked via checksum).
