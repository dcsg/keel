---
name: keel:spec
description: "Technical specification from an accepted PRD"
---

(eval):1: no matches found: docs/product/specs/SPEC-*.md
(eval):1: no matches found: docs/product/specs/SPEC-*/spec.md
<!-- keel:live -->
Next SPEC number: SPEC-001
Existing specs: (none yet)
<!-- /keel:live -->

# keel:spec

Write a technical specification from an accepted PRD. The spec is the engineering response to a product requirement — it defines HOW to build what the PRD says to build.

## Arguments

- `$ARGUMENTS` — PRD identifier (e.g., `PRD-005`) or path to the PRD file

## Instructions

### 1. Resolve Paths

Read `.keel/config.yaml`. Resolve paths from the `paths:` section:

- Specs: `paths.specs` (default: `docs/product/specs`)
- PRDs: `paths.prds` (default: `docs/product/prds`)
- Decisions: `paths.decisions` (default: `docs/architecture/decisions`)
- Invariants: `paths.invariants` (default: `docs/architecture/invariants`)
- Template override: check if `.keel/templates/spec.md` exists — if yes, use it as the output template instead of the built-in template below

The correct next SPEC number is provided at the top of this prompt in the `<!-- keel:live -->` block. Use it exactly.

### 2. Find and Validate the PRD

If `$ARGUMENTS` is a PRD identifier (e.g., `PRD-005`):
```bash
find {BASE}/product/prds/ -name "PRD-005*" -type f
```

If `$ARGUMENTS` is a path, read it directly.

Read the PRD file. Check the frontmatter `status:` field:
- If `status: accepted` → proceed
- If `status: draft` → block:
  ```
  ⛔ PRD-005 status is "draft".
     PRDs must be accepted before generating a spec.
     Review the PRD and change status to "accepted" first.
  ```
- If no frontmatter status → treat as accepted (backwards compatibility with pre-v4 PRDs)

### 3. Scan Codebase

Before asking questions, understand what exists. Run these in parallel:

```bash
# Architecture signals
ls .claude/rules/*.md 2>/dev/null
ls .claude/agents/*.md 2>/dev/null
ls {BASE}/decisions/*.md {BASE}/architecture/decisions/*.md 2>/dev/null
ls {BASE}/invariants/*.md {BASE}/architecture/invariants/*.md 2>/dev/null
```

Read the project-context.md for project identity and stack.

Read any relevant ADRs that might constrain the spec (match ADR titles against the PRD's topic).

### 4. Interview

Ask 2-4 questions specific to what you found in the codebase. These questions should prove you understood the project, not just the PRD.

Good questions reference what you found:
- "The codebase has 3 ADRs about error handling. Should this spec follow ADR-002 (wrapped errors) or propose a different approach?"
- "I see a hexagonal architecture with `domain/`, `port/`, `adapter/` layers. Should this feature follow the same pattern?"
- "There's no existing test infrastructure for integration tests. Should the spec include setting that up?"

Bad questions are generic:
- "What language should we use?" (you can see the stack)
- "What's the project about?" (you read project-context.md)

Wait for the user's answers before proceeding.

### 5. Show Outline

Before routing to agents, show what the spec will cover:

```
Based on the PRD and your answers, the spec will cover:
  - Architecture: {what architectural approach}
  - Key components: {what gets built or modified}
  - Data: {schema changes, models, or "no data changes"}
  - APIs: {new endpoints, contracts, or "no API changes"}
  - Breaking changes: {any, or "none"}
  - Open questions: {count carried from PRD}

Proceed? (y/n)
```

If the user says no, ask what to change and revise the outline.

### 6. Conflict Detection

Before generating, check if the spec would contradict any existing ADR:

```
⚠️  This spec proposes {X}.
    ADR-{NNN} states: "{relevant decision}".
    {Assessment: consistent / extends / contradicts}
    {If contradicts: Consider capturing a new ADR.}
```

Surface conflicts as warnings, not blockers. The user decides whether to proceed.

### 7. Generate the Spec

**Write with enforcement-grade language.** Requirements and acceptance criteria are checked by `/keel:drift` — vague requirements produce unverifiable drift reports.

Rules for spec requirements:
1. **Requirements use MUST/MUST NOT** — not "should" or "could."
2. **Each requirement is independently testable** — it can be verified by reading code, running a test, or checking a specific condition.
3. **Acceptance criteria use Given/When/Then or a verifiable command** — not "system works correctly."
4. **Name specific types, endpoints, fields, or patterns** — not "the API should handle errors."

Route to `architect` + relevant domain specialists via the Agent tool.

Create `{specs_dir}/SPEC-{NNN}-{slug}/spec.md`:

```markdown
---
type: spec
id: SPEC-{NNN}
title: {Title}
status: draft
author: {git user.name}
implements: {PRD identifier}
architecture_source:   # optional: archway.yaml if present
created_at: {ISO8601 timestamp}
references:
  adrs: [{list of referenced ADR IDs}]
  invariants: [{list of referenced invariant IDs}]
---

# SPEC-{NNN}: {Title}

**Implements:** {PRD identifier}
**Date:** {today}
**Author:** {git user.name}

---

## Summary

{One paragraph: what this spec proposes, why, and the high-level approach.}

## Context

{Why this spec exists now. What engineering context matters beyond the PRD.
Prior art, failed approaches, constraints discovered during investigation.}

## Existing Architecture

{What exists in the codebase that this spec builds on or modifies.
Reference specific files, patterns, and conventions. 3-5 sentences max.
Skip for greenfield projects.}

## Proposed Design

{The engineering design. How components interact. What layers are involved.}

## Components

{What gets built or modified. For each:
- What it does
- Where it lives (file paths)
- How it integrates with existing code}

## Non-Goals

{What this spec explicitly does NOT address.
Features deferred, approaches rejected, scope boundaries.}

## Alternatives Considered

### {Alternative 1}
- **Pros:** {benefits}
- **Cons:** {drawbacks}
- **Rejected because:** {specific reason}

### {Alternative 2}
- **Pros:** {benefits}
- **Cons:** {drawbacks}
- **Rejected because:** {specific reason}

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation | Rollback |
|---|---|---|---|---|
| {risk} | {impact} | {likelihood} | {mitigation} | {rollback plan} |

## Security Considerations

{Auth, data access, encryption, input validation — or "None identified."}

## Performance Approach

{Expected load, caching, optimization — or "Standard patterns sufficient."}

## Acceptance Criteria

- AC-001: {Criterion} — Verify: {automated test, command, or review method}
- AC-002: {Criterion} — Verify: {method}

## Testing Strategy

{What to test, at which layer. What's hard to test and why.}

## Dependencies

{External systems, other specs, ADRs that constrain this design.}

## Open Questions

{Unresolved items. Flag gaps explicitly:}
- NEEDS CLARIFICATION: {question that must be resolved before implementation}

---

*Generated by keel:spec — {date}*
```

A spec should be 200-400 lines. If longer, the feature should be split. The spec is the engineering response to a PRD — it defines HOW, not WHAT.

---

REMEMBER: The spec must include Non-Goals (explicit scope exclusions), Alternatives Considered (with rejection reasons), and Acceptance Criteria (AC-NNN with verification methods). If anything is unclear, mark it NEEDS CLARIFICATION — never invent architectural decisions.

### 8. Confirm

```
✅ Spec created: {specs_dir}/SPEC-{NNN}-{slug}/spec.md

  SPEC-{NNN}: {Title}
  Implements: {PRD identifier}
  Status: draft
  References: {count} ADRs, {count} invariants

  Review and change status to "accepted" when ready.
  Then: "generate artifacts for SPEC-{NNN}"
```
