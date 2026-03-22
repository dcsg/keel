---
name: keel:compile
description: "Compile ADRs and invariants into governance directives"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
---

# keel:compile

Compile accepted ADRs, active invariants, and team guidelines into a single governance directives file that Claude reads automatically via `.claude/rules/governance.md`.

The compiled output is the enforcement format — short, actionable directives with source references. The ADRs, invariants, and guidelines remain the source of truth.

CRITICAL: NEVER write a governance.md that contains contradictions — detect and report them before writing, and abort or confirm with the user.

## Arguments

- `--check` — validate only, don't write. Exit with errors if contradictions found. For CI.

## Instructions

1. Read `.keel/config.yaml`. Resolve paths from the `paths:` section using the Path Defaults in the Reference section.

2. Read source documents:
   - **ADRs:** include if `status: accepted`. Skip `draft`, `superseded`, `deprecated`. Fall back to checking `**Status:** accepted` in the body for backwards compatibility.
   - **Invariants:** include if `status: active` or no status (backwards compatibility). Skip `status: revoked`.
   - **Guidelines:** include all `.md` files from the guidelines directory. No status filtering. Each filename (without `.md`) becomes the section label.

3. Detect contradictions between accepted ADRs: direct contradictions ("use X" vs "never use X"), scope conflicts, approach conflicts. Use the Contradiction Detection examples in the Reference section as a guide for how to report them.

4. Also check: superseded ADRs still referenced by active specs or plans; invariants that conflict with accepted ADRs; guidelines that conflict with ADRs or invariants. Conflicts between guidelines and invariants are errors (invariants always win). Conflicts between guidelines and ADRs are warnings.

5. If `--check` flag: report all contradictions and conflicts, then output the Check Output Format from the Reference section and stop (don't write).

6. If contradictions found and not `--check`: report them and ask user to proceed anyway or abort.

7. Extract directives from each source document. Use the Directive Extraction rules in the Reference section.

8. Group directives by category: Architecture, Implementation, Constraints, Process, Guidelines. Detect categories from content.

9. Write to `.claude/rules/governance.md` using the Output Template in the Reference section.

10. If the compiled output exceeds 30 directives, warn:
    ```
    ⚠️  {count} directives compiled. Anthropic recommends keeping context
        minimal for optimal compliance. Consider consolidating related
        directives or moving lower-priority guidelines to docs/guidelines/.
    ```

11. Log the compilation event:
    ```bash
    source "$HOME/.keel/hooks/event-log.sh" 2>/dev/null
    keel_log_event "compile" '{"adrs_compiled":{n},"invariants_compiled":{m},"guidelines_compiled":{g},"directives":{total}}'
    ```

12. Output confirmation:
    ```
    ✅ Governance compiled: .claude/rules/governance.md

      {n} ADRs → {x} directives
      {m} invariants → {y} directives
      {g} guidelines → {z} directives
      {total} total directives

      Skipped: {k} superseded ADRs, {j} draft ADRs
      {If any}: ⚠️ {warnings about superseded ADRs still referenced}
      {If conflicts}: ⚠️ {count} conflicts detected — review above

      Claude will read these directives automatically in every session.
    ```

13. This command should be suggested (not auto-run) after `/keel:adr` or `/keel:invariant` creates or modifies a document. Add to those commands' output: `Run /keel:compile to update governance directives.`

---

REMEMBER: NEVER write governance.md with contradictions. Invariants are listed first AND last (primacy + recency). The ADRs are the source of truth — the compiled output is the enforcement format, never hand-edit it.

## Reference

### Path Defaults

| Key | Default |
|---|---|
| `paths.decisions` | `docs/architecture/decisions` |
| `paths.invariants` | `docs/architecture/invariants` |
| `paths.guidelines` | `docs/guidelines` |

### Directive Extraction Rules

**From ADRs** — read the `## Decision` section. Distill to 1-2 sentences: what to do, phrased as an instruction. Preserve the constraint, drop the rationale. Reference the source.

Example transformation:
```
ADR source (150 lines):
  # ADR-001 — Keel: Context Engine and Guardrail Installer
  ## Decision
  Build keel as a lean context engine targeting Claude Code exclusively.
  Other tools lack path-conditional rules, hooks, slash commands...
  [... 100 more lines of rationale, alternatives, consequences ...]

Compiled directive (1 line):
  - Claude Code is the only supported platform. Do not write code or
    configuration targeting Cursor, Copilot, or other tools. (ref: ADR-001)
```

**From invariants** — directives are already constraint-shaped; use the Rule section directly:
```
Invariant source:
  # INV-001 — Commands are plain markdown, no compiled code
  ## Rule
  Every keel command is a .md file. No TypeScript, no compiled binaries...

Compiled directive:
  - Every command and template must be a .md or .yaml file. No TypeScript,
    no compiled binaries, no build step. This constraint is non-negotiable.
    (ref: INV-001)
```

**From guidelines** — each file becomes a section labeled by filename. Guidelines are freeform; include them as-is under the Team Guidelines category.

Guidelines are the extension point for team-specific knowledge:
- Unit testing philosophy ("always test error paths first")
- API conventions ("camelCase responses, snake_case DB columns")
- Naming patterns ("services end with Service, repos end with Repository")
- Code review expectations ("every PR needs at least one test")

### Contradiction Detection Examples

```
⚠️  Contradiction detected:
    ADR-001: "Claude Code only — no multi-tool support"
    ADR-007: "Support Cursor for rule distribution"

    Resolve before compiling. Supersede one or reconcile both.
```

```
⚠️  Conflict between guideline and ADR:
    guidelines/testing.md: "Always mock the database in all tests"
    ADR-003: "Integration tests must hit a real database, no mocks"

    Source: guidelines/testing.md (line 12) vs ADR-003 (Decision section)
    Action: Scope the guideline to unit tests only, or amend ADR-003.
```

```
⚠️  Conflict between guideline and invariant:
    guidelines/dependencies.md: "Use lodash for utility functions"
    INV-001: "No runtime dependencies"

    Source: guidelines/dependencies.md (line 5) vs INV-001 (Rule section)
    Action: Remove the guideline — invariants are non-negotiable.
```

### Output Template

```markdown
---
paths: "**/*"
version: "{{keel_version}}"
---
<!-- keel:compiled — generated by /keel:compile, do not edit manually -->
<!-- source: {n} ADRs ({m} accepted, {k} superseded), {j} invariants ({l} active), {g} guidelines -->
<!-- compiled: {ISO8601 timestamp} -->
<!-- directives: {count} | tokens: ~{estimate} -->

# Governance Directives

Follow these directives in every file you write or edit.

## Non-Negotiable Constraints

These are invariants. Violation is never acceptable.

- {directive} (ref: INV-NNN)
- {directive} (ref: INV-NNN)

## Architecture Decisions

- {directive} (ref: ADR-NNN)
- {directive} (ref: ADR-NNN)

## Implementation Decisions

- {directive} (ref: ADR-NNN)

## Process Decisions

- {directive} (ref: ADR-NNN)

## Team Guidelines

- {directive} (ref: guidelines/{filename}.md)

## Reminder: Non-Negotiable Constraints

These constraints were listed above and are restated for emphasis.
Do not violate them under any circumstances.

- {repeat invariant directives from the top}
```

### Check Output Format

```
/keel:compile --check

  Sources: {n} ADRs ({m} accepted), {j} invariants ({l} active), {g} guidelines
  Contradictions: {count}
  Conflicts: {count} (guideline vs ADR/invariant)
  Directives: {count} would be generated

  {If contradictions: list them}
  {If clean: "All clear — governance compiles cleanly."}
```
