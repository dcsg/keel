# ADR-003: Adopt Remaining Claude Code Feature Surface

**Status:** Accepted
**Date:** 2026-03-08
**Deciders:** Daniel Gomes

## Context

An audit of keel against the full Claude Code feature surface revealed that keel v1 used roughly 15% of what Claude Code offers. Keel v2 addressed the biggest gaps (specialist agents, Stop hook, auto-memory, MCP wiring). Three significant capabilities remain unused:

1. **`PostToolUse` hook** — fires after every tool call; could auto-trigger linting/formatting after edits
2. **`` !`command` `` preprocessing** — shell commands evaluated before a slash command runs; could inject live project state (next ADR number, current plan phase, existing invariant list) into commands
3. **`context: fork`** on commands — runs the command in an isolated subagent, keeping main context clean

Additionally, the linter-aware rule generation (PRD exists, not implemented) requires a new command `keel:sync` to stay in sync after the initial generation.

## Decision

### PostToolUse hook — adopt for auto-format/lint

Add a `PostToolUse` hook that fires after `Write` or `Edit` on source files. If a formatter is detected in the project (gofmt, prettier, black, rustfmt), run it automatically. This closes the feedback loop: Claude writes code → it's immediately formatted → no manual step needed.

**Noise control:** Only fire when the edited file matches a known source extension. Suppress when writing markdown, YAML, JSON config files — formatting those is rarely the right behavior.

**Disable:** `KEEL_FORMAT_SKIP=1` env var, or `hooks: { post-tool-use: false }` in `.keel/config.yaml`.

### `!`command`` preprocessing — adopt for live data injection

Use shell preprocessing in slash commands where live project state matters:

- `/keel:adr` — inject next available ADR number by counting `docs/decisions/*.md`
- `/keel:invariant` — inject next available INV number
- `/keel:prd` — inject next available PRD number
- `/keel:plan` — inject active plan name and current phase from progress table

This eliminates the "Claude guesses the wrong number" problem for sequential artifacts.

### `context: fork` — adopt selectively

Add `context: fork` frontmatter to commands that do read-only analysis and shouldn't affect the main session:

- `/keel:doctor` — validation/audit work, no code changes
- `/keel:status` — dashboard read, no side effects
- `/keel:docs audit` — doc scanning, no writes

Do NOT fork commands that need to write files (`keel:init`, `keel:context`, `keel:adr`, etc.) — forked subagents can't write back to the parent session.

### Linter-aware rules — implement as `keel:sync`

Implement linter config → AI rules translation as a new command `keel:sync`. Runs during `keel:init` for brownfield projects (auto), and manually when linter config changes.

## Alternatives Considered

**PostToolUse: run formatter in Stop hook instead**
The Stop hook fires after Claude's full response, not after each file write. A response may write multiple files — formatting all of them in Stop would require knowing which files were changed. PostToolUse has the file path directly in context.

**Preprocessing: hardcode placeholder numbers**
Claude could start from `NNN` and let the user rename. But this causes friction and breaks automation. Shell preprocessing is zero-friction.

**`context: fork`: apply to all commands**
Some commands (`keel:context`, `keel:init`) need to write to the session's working memory. Forked agents can't do that. Apply only where there's clear benefit.

## Consequences

- `PostToolUse` hook fires on every edit — teams with slow formatters may notice latency; the disable option is essential
- Preprocessing requires files to exist at command invocation time — commands that create their own directories need to handle the case where no files exist yet (count = 0 → start at 001)
- `context: fork` means doctor/status results are returned as agent output, not written to main context — this is fine for read-only commands
- `keel:sync` adds a 12th command — update all command counts in docs

## Related

- PRD: Linter-Aware Rule Generation (`docs/product/prds/PRD-linter-aware-rules.md`)
- PRD: Claude Code Feature Gap Closure (`docs/product/prds/PRD-claude-code-feature-gaps.md`)
