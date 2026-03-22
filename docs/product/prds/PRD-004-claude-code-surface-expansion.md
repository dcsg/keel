# PRD-004: Claude Code Surface Expansion

**Status:** draft
**Date:** 2026-03-16

---

## Problem

Claude Code has expanded significantly since keel v3. The hooks system now has 24 events (keel uses 5). Skills have new frontmatter capabilities. Subagent templates support new fields. Keel is leaving substantial platform leverage on the table — the same kind of gap that ADR-003 addressed, but for the current feature surface.

The consequence is the same as before: keel users don't get the full feedback loop, and keel's commands run with less isolation and precision than the platform supports.

## Users

All keel users. Particularly teams who run specialist agents frequently and developers on large codebases where context pollution from diagnostic commands is expensive.

## Goals

- Close the gap between what Claude Code's hook system supports and what keel uses
- Give keel commands the right execution model (forked, isolated, scoped) for their intent
- Give subagent templates access to new fields that improve their reliability
- Produce a prioritised backlog of platform capabilities to adopt in keel v4

## Non-Goals

- Agent teams support (experimental, too early)
- AGENTS.md generation (decided against — no hooks in other tools)
- Implementing all 24 hook events — only adopt what delivers clear user value

## Requirements

### Must Have

**R1: `UserPromptSubmit` hook — inject active plan phase**

A new hook that fires before each prompt is processed. Keel uses this to inject the current active plan phase into every prompt automatically — no more "re-read the plan" instructions. If no plan is active, hook exits silently.

Implementation: reads `.keel/config.yaml` for `base:`, finds the most recent plan file, extracts the current in-progress phase from the progress table, injects as `systemMessage`.

**R2: `PostCompact` hook — re-inject plan context after compaction**

The current `PreCompact` hook tells Claude to save state before compaction. But the session after compaction starts cold — the plan context isn't re-injected until the user explicitly runs `/keel:context`. A `PostCompact` hook fires immediately after compaction and re-injects the active plan phase and invariants as `systemMessage`.

This makes compaction recovery automatic instead of manual.

**R3: `SubagentStop` hook — log specialist agent activity**

Fires when any subagent finishes. Keel logs which agent ran, duration, and a one-line outcome to `~/.keel/session-signals.log`. `/keel:status` already reads this log — subagent activity becomes visible in the dashboard without any extra steps.

**R4: Skills frontmatter on read-only commands**

Add `context: fork` to `/keel:doctor`, `/keel:status`, `/keel:docs`. These commands do diagnostic work and should not pollute main context. Already identified in ADR-003 but not yet implemented for all three.

Add `allowed-tools` to scope tools per command — `/keel:doctor` only needs Read, Grep, Glob, Bash. Scoping prevents accidental writes during diagnostic runs.

### Should Have

**R5: `InstructionsLoaded` hook — rules observability**

Fires every time a `.claude/rules/*.md` file loads. Keel logs which rule packs are active in a given session to `~/.keel/session-signals.log`. Surface in `/keel:status` as "Rules active this session". This closes a visibility gap: users currently can't tell which rules are actually being applied.

**R6: Subagent `memory: project` field**

Specialist agents that run repeatedly (principal-dba on migrations, staff-security on auth changes) can accumulate project-specific knowledge over time. Add `memory: project` to agent templates where persistent learning makes sense. Memory stored at `.claude/agent-memory/<name>/`.

**R7: `PreToolUse` input modification**

The hook can now return `updatedInput` to modify a tool's input before execution. Keel could use this to normalise file paths, enforce path conventions, or inject project-scoped context into tool calls. Evaluate specific use cases during implementation.

### Won't Have (v1)

- `PermissionRequest` hook auto-management — too project-specific to template well
- `agent` hook type for quality gates — powerful but adds significant latency; evaluate in v5
- `TeammateIdle` / `TaskCompleted` hooks — agent teams feature is experimental
- `WorktreeCreate` override — too niche
- `Elicitation` hooks — MCP-specific, not core keel workflow

## User Stories

**As a developer**, I want the active plan phase injected into every prompt so I don't have to re-read the plan after context compaction or a long session.

**As a developer**, after a compaction event I want keel to automatically re-surface my current phase without me having to run `/keel:context` manually.

**As a team lead**, I want `/keel:status` to show which specialist agents ran this session and what they flagged, so I have visibility into the advisory layer without reading every agent output.

**As a developer running `/keel:doctor`**, I want the diagnostic output isolated so it doesn't consume main context tokens.

## Acceptance Criteria

- [ ] `UserPromptSubmit` hook injects current phase when a plan is active; silent otherwise
- [ ] `PostCompact` hook re-injects active plan phase and invariants after compaction
- [ ] `SubagentStop` hook logs agent activity; `/keel:status` shows it under HOOK ACTIVITY
- [ ] `/keel:doctor`, `/keel:status`, `/keel:docs` have `context: fork` in frontmatter
- [ ] `InstructionsLoaded` hook logs active rule packs; visible in `/keel:status`
- [ ] At least 2 agent templates updated with `memory: project`
- [ ] All changes reflected in `templates/settings.json.tmpl` and relevant agent templates
- [ ] `bash test/run.sh` passes

## Technical Notes

- `UserPromptSubmit` and `PostCompact` are new hook events — update `templates/settings.json.tmpl`
- `SubagentStop` matcher should be broad (`.*`) to catch all specialist agents
- `InstructionsLoaded` is observability-only — no decision output needed, exit 0 always
- `SessionEnd` has a 1.5s timeout by default — do not use for anything time-sensitive
- `context: fork` on commands means they cannot write to session state — verify no read-only commands currently write

## Open Questions

- Which specific agent templates benefit most from `memory: project`? (principal-dba, staff-security are obvious candidates — others?)
- Should `UserPromptSubmit` inject the full phase task list or just the phase title + objective?
- Is `PostCompact` reliable enough to replace manual `/keel:context` after compaction, or should it complement it?

---

*Written by keel:prd — 2026-03-16*
