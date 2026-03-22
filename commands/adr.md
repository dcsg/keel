---
name: keel:adr
description: "Capture an architecture decision record — from scratch or from the current conversation"
argument-hint: "[decision topic] — omit to extract from conversation"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---
!`BASE=$(grep "^base:" .keel/config.yaml 2>/dev/null | awk '{print $2}' | tr -d '"' || echo "docs"); COUNT=$(ls "${BASE}/decisions/"*.md 2>/dev/null | wc -l | tr -d ' '); NEXT=$(printf "%03d" $((COUNT + 1))); EXISTING=$(ls "${BASE}/decisions/"*.md 2>/dev/null | xargs -I{} basename {} .md | sort | tr '\n' ', ' | sed 's/,$//'); printf "<!-- keel:live -->\nNext ADR number: ADR-%s\nExisting ADRs: %s\n<!-- /keel:live -->\n" "$NEXT" "${EXISTING:-(none yet)}"`

# keel:adr

Create an Architecture Decision Record (ADR). Two modes:

- **With argument** — `/keel:adr use postgres for persistence` — works through the decision from scratch
- **No argument** — `/keel:adr` — extracts the decision from the current conversation

## Instructions

### 1. Resolve Paths

Read `.keel/config.yaml`. Resolve paths from the `paths:` section:

- Decisions: `paths.decisions` (default: `docs/architecture/decisions`)
- Template override: check if `.keel/templates/adr.md` exists — if yes, use it as the output template instead of the built-in template below

### 2. Load Existing ADRs

```bash
ls {decisions_path}/*.md 2>/dev/null | sort
```

The correct next ADR number is provided at the top of this prompt in the `<!-- keel:live -->` block. Use it exactly — do not guess or count files yourself.

### 3. Determine Mode

**With `$ARGUMENTS`** — work through the decision:

Ask 2-3 focused questions to understand the decision:
- What problem does this solve?
- What alternatives were considered?
- What trade-offs are being accepted?

**Without `$ARGUMENTS`** — extract from conversation:

Scan the conversation for a significant technical or architectural choice that was made. Look for:
- A choice between two or more approaches
- Reasoning about trade-offs
- A conclusion that was reached

If no clear decision is found:
```
I couldn't identify a clear architectural decision in our conversation.

An ADR captures a significant technical choice — not implementation details.
Describe the decision to capture: /keel:adr <decision topic>
```

### 4. Draft and Validate the Decision Section

Before writing the file, draft the Decision section and validate each directive against these quality criteria. Every statement in the Decision section becomes a compiled governance directive — weak language here means weak enforcement later.

**Write with enforcement-grade language from the start.** Every statement in the Decision section becomes a compiled governance directive. Write them as if they're rules Claude will follow literally — because they are.

Rules for writing the Decision section:

1. **Hard constraints use MUST or NEVER** (uppercase) with a one-clause reason after the dash. Example: "Domain classes MUST NOT import from infrastructure namespaces — dependency inversion keeps the domain testable without framework coupling."
2. **Name specific things** — namespaces, tools, patterns, file paths. "Use hexagonal architecture" is vague. "Domain and application layers MUST NOT import from `Symfony\*`, `Doctrine\*`, or any infrastructure namespace" is enforceable.
3. **One directive per sentence.** Don't combine "use CQRS and event sourcing" — split them.
4. **Every directive must be verifiable.** If you can't grep for it, test for it, or check it in code review with specific criteria, rewrite it until you can.

Do NOT write soft language ("should", "try to", "consider", "prefer") for decisions that are meant to be enforced. If it's a preference, it belongs in `docs/guidelines/`, not in an ADR Decision section.

### 5. Write the ADR

Create `{BASE}/decisions/{NNN}-{slug}.md`:

```markdown
---
type: adr
id: ADR-{NNN}
title: {Title}
status: accepted
decision-makers: [{git user.name}]
created_at: {ISO8601 timestamp}
supersedes:        # optional — ADR-NNN if replacing a previous decision
references:
  adrs: []
  invariants: []
  prds: []
  specs: []
---

# ADR-{NNN}: {Title}

**Status:** accepted
**Date:** {today}
**Decision-makers:** {git user.name}

---

## Context and Problem Statement

{Background and forces at play. End with the question this ADR answers:}

How should we {the specific decision question}?

## Decision Drivers

- {Most important quality or concern}
- {Second priority}
- {Third priority}

## Considered Options

1. {Option A} — {one-line description}
2. {Option B} — {one-line description}
3. {Option C} — {one-line description}

## Decision

We will {active voice — what was decided, specifically and concretely}.

## Alternatives Considered

### {Option A}
- **Pros:** {benefits}
- **Cons:** {drawbacks}
- **Rejected because:** {specific reason}

### {Option B}
- **Pros:** {benefits}
- **Cons:** {drawbacks}
- **Rejected because:** {specific reason}

## Consequences

- **Good:** {benefit}
- **Bad:** {accepted trade-off}
- **Neutral:** {side effect that is neither good nor bad}

## Confirmation

How to verify this decision is being followed:
- {Automated: command, test, or hook that checks compliance}
- {Manual: what a reviewer should look for in code review}

---

*Captured by keel:adr — {date}*
```

An ADR should cover ONE decision, not a design document. If it exceeds 2 pages, it's probably a spec. Keep it focused: one question, one decision, one set of consequences.

---

REMEMBER: An ADR captures a DECISION with trade-offs, not a preference. It must include a Confirmation section describing how to verify the decision is being followed. If it exceeds 2 pages, it's a spec, not an ADR.

### 6. Confirm

```
✅ ADR created: {BASE}/decisions/{NNN}-{slug}.md

  ADR-{NNN}: {Title}
  Status: accepted

  Review it and change status to "proposed" if it needs team sign-off first.
  Run /keel:compile to update governance directives.

  Want architect to review this? Say "review this ADR"
```
