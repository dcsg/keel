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

Read `.keel/config.yaml`. `BASE` = `base:` value (default: `docs`).

- PRDs go in: `{BASE}/product/prds/`

### 2. Load Context

```bash
ls {BASE}/product/prds/*.md 2>/dev/null | sort
```

Read `{BASE}/soul.md` for project identity, users, and stack.
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
