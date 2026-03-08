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

# keel:prd

Write a Product Requirements Document (PRD) for a feature or change.

## Instructions

### 1. Resolve Paths

Read `.keel/config.yaml`. `BASE` = `base:` value (default: `docs`).

- PRDs go in: `{BASE}/product/prds/`

### 2. Load Context

```bash
ls {BASE}/product/prds/*.md 2>/dev/null | sort
```

Read `{BASE}/soul.md` for project identity, users, and stack.
Read `{BASE}/product/spec.md` if it exists — for roadmap context.

Note the highest existing PRD number. Zero-pad to 3 digits (e.g. `003`).

### 3. Clarify Requirements

If `$ARGUMENTS` is vague or missing, ask 2-3 focused questions:
- Who is this for? (which user type)
- What problem does it solve?
- What does success look like?

If `$ARGUMENTS` is clear enough, proceed directly.

### 4. Write the PRD

Create `{BASE}/product/prds/PRD-{NNN}-{slug}.md`:

```markdown
# PRD-{NNN}: {Feature Title}

**Status:** draft
**Date:** {today}

---

## Problem

{What problem this solves. Who has it. How painful it is.}

## Users

{Who this is for — be specific. Reference soul.md user types.}

## Goals

- {What success looks like — measurable where possible}
- {What we're optimizing for}

## Non-Goals

- {What this explicitly does NOT solve}
- {Out of scope for this version}

## Requirements

### Must Have
- {Requirement}

### Should Have
- {Requirement}

### Won't Have (v1)
- {Deferred requirement}

## User Stories

**As a** {user type}, **I want** {action} **so that** {benefit}.

## Acceptance Criteria

- [ ] {Testable criterion}
- [ ] {Testable criterion}

## Technical Notes

{Constraints, dependencies, integration points — or "TBD"}

## Open Questions

- {Question that needs resolution before implementation}

---

*Written by keel:prd — {date}*
```

### 5. Confirm

```
✅ PRD created: {BASE}/product/prds/PRD-{NNN}-{slug}.md

  PRD-{NNN}: {Feature Title}
  Status: draft

  Review and change status to "approved" when ready for planning.
  Run /keel:plan PRD-{NNN} to create an execution plan.
```
