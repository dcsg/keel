---
name: keel:prd
description: "Write a Product Requirements Document for a feature"
argument-hint: "<feature description>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---
!`BASE=$(grep "^base:" .keel/config.yaml 2>/dev/null | awk '{print $2}' | tr -d '"' || echo "docs"); COUNT=$(ls "${BASE}/product/prds/"*.md 2>/dev/null | wc -l | tr -d ' '); NEXT=$(printf "%03d" $((COUNT + 1))); EXISTING=$(ls "${BASE}/product/prds/"*.md 2>/dev/null | xargs -I{} basename {} .md | sort | tr '\n' ', ' | sed 's/,$//'); printf "<!-- keel:live -->\nNext PRD number: PRD-%s\nExisting PRDs: %s\n<!-- /keel:live -->\n" "$NEXT" "${EXISTING:-(none yet)}"`

# keel:prd

Write a Product Requirements Document (PRD) for a feature or change.

## Instructions

### 1. Resolve Paths

Read `.keel/config.yaml`. Resolve paths from the `paths:` section (fall back to defaults if not configured):

- PRDs: `paths.prds` (default: `docs/product/prds`)
- Project Context: `paths.soul` (default: `docs/project-context.md`)
- Template override: check if `.keel/templates/prd.md` exists — if yes, use it as the output template instead of the built-in template below

### 2. Load Context

```bash
ls {prds_path}/*.md 2>/dev/null | sort
```

Read `{project_context_path}` for project identity, users, and stack.
Read `{BASE}/product/spec.md` if it exists — for roadmap context.

The correct next PRD number is provided at the top of this prompt in the `<!-- keel:live -->` block. Use it exactly — do not guess or count files yourself.

### 3. Clarify Requirements

If `$ARGUMENTS` is vague or missing, ask 2-3 focused questions:
- Who is this for? (which user type)
- What problem does it solve?
- What does success look like?

If `$ARGUMENTS` is clear enough, proceed directly.

### 4. Write the PRD

Create `{BASE}/product/prds/PRD-{NNN}-{slug}.md`:

```markdown
---
type: prd
id: PRD-{NNN}
title: {Feature Title}
status: draft
author: {git user.name}
stakeholders: []
created_at: {ISO8601 timestamp}
references:
  adrs: []
  invariants: []
---

# PRD-{NNN}: {Feature Title}

**Status:** draft
**Date:** {today}
**Author:** {git user.name}

---

## Problem

{What problem this solves. Who has it. How painful it is. Include evidence if available.}

## Users

{Who this is for — be specific. Reference project-context.md user types if defined.}

## Goals

- {What success looks like — measurable where possible}
- {What we're optimizing for}

## Non-Goals

- {What this explicitly does NOT solve}
- {Out of scope for this version}

## Requirements

### Must Have
- FR-001: {Requirement} [MUST]
- FR-002: {Requirement} [MUST]

### Should Have
- FR-003: {Requirement} [SHOULD]

### Won't Have (v1)
- FR-004: {Deferred requirement}

## User Stories

**P1** — **As a** {user type}, **I want** {action} **so that** {benefit}.

**P2** — **As a** {user type}, **I want** {action} **so that** {benefit}.

## Acceptance Criteria

- [ ] AC-001: {Testable criterion} — Verify: {how to check — automated test, manual review, or command}
- [ ] AC-002: {Testable criterion} — Verify: {how to check}
- [ ] AC-003: {Testable criterion} — Verify: {how to check}

## Technical Notes

{Constraints, dependencies, integration points — or "TBD".}
{If anything is unclear, mark it:}
- NEEDS CLARIFICATION: {question that must be answered before implementation}

## Open Questions

- {Question that needs resolution before implementation}

---

*Written by keel:prd — {date}*
```

---

REMEMBER: Every requirement needs a numbered ID (FR-NNN) and every acceptance criterion needs a verification method (AC-NNN: criterion — Verify: method). If something is unclear, mark it NEEDS CLARIFICATION — never invent details.

### 5. Confirm

```
✅ PRD created: {BASE}/product/prds/PRD-{NNN}-{slug}.md

  PRD-{NNN}: {Feature Title}
  Status: draft

  Review and change status to "accepted" when ready.
  Then: "write a spec for PRD-{NNN}"

  Want pm to review this? Say "review this PRD"
```
