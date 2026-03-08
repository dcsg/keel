---
status: accepted
priority: high
---

# PRD: Claude Code Feature Gap Closure

## Problem

After shipping keel v2, three significant Claude Code capabilities remain unused:

1. **PostToolUse hook** — Claude writes code, but formatted output requires a separate manual step (or waiting for the linter to reject). The hook exists to close this loop automatically.

2. **Shell preprocessing (`` !`command` ``)** — Slash commands like `/keel:adr` guess artifact numbers. Claude frequently assigns wrong numbers (duplicates, gaps) because it doesn't know what already exists. Preprocessing can inject the correct next number before the command runs.

3. **`context: fork`** — Read-only commands like `/keel:doctor` and `/keel:status` pollute the main session context with diagnostic output. Forking isolates them.

Together these represent the difference between keel working *well* and keel working *seamlessly*.

## Users Affected

All keel users — greenfield and brownfield, solo and team.

## Success Metrics

- `/keel:adr` never assigns a duplicate or out-of-sequence number
- Formatted code is immediately formatted after every Claude edit (no manual step)
- `/keel:doctor` and `/keel:status` don't bloat main context

## Requirements

### R1: PostToolUse auto-format hook

- Fires after `Write` or `Edit` on source files
- Detects installed formatter from project (gofmt, prettier, black, rustfmt, php-cs-fixer)
- Runs formatter on the modified file path
- Suppresses for non-source files (`.md`, `.yaml`, `.json`, `.toml` config)
- Disable: `KEEL_FORMAT_SKIP=1` or `hooks: { post-tool-use: false }` in `.keel/config.yaml`
- Added to `templates/settings.json.tmpl`

### R2: Live data injection via preprocessing

- `/keel:adr` — inject next ADR number: `!``ls docs/decisions/*.md 2>/dev/null | wc -l``
- `/keel:invariant` — inject next INV number
- `/keel:prd` — inject next PRD number
- `/keel:plan` — inject active plan name + current phase from progress table
- Format: prepend a `<!-- keel:live -->` comment block at top of command with the injected data

### R3: `context: fork` on read-only commands

- Add `context: fork` to frontmatter of: `keel:doctor`, `keel:status`, `keel:docs`
- Do NOT add to commands that write files or session state

## User Stories

1. As a developer, after Claude edits a Go file, I want it immediately formatted by gofmt so I don't have a save-and-format step.

2. As a developer running `/keel:adr`, I want the correct next number pre-filled so I never create `ADR-003` when `ADR-003` already exists.

3. As a developer running `/keel:doctor`, I want the diagnostic output contained so my main working context isn't cluttered with health check data.

## Out of Scope

- Running linters (not formatters) automatically — linters reject code, which should remain a deliberate step
- Formatting on `Read` — only on `Write`/`Edit`
- Formatting non-keel projects — hook is gated on `.keel/config.yaml` presence
