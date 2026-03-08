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

Read `.keel/config.yaml`. `BASE` = `base:` value (default: `docs`).

- ADRs go in: `{BASE}/decisions/`

### 2. Load Existing ADRs

```bash
ls {BASE}/decisions/*.md 2>/dev/null | sort
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

### 4. Write the ADR

Create `{BASE}/decisions/{NNN}-{slug}.md`:

```markdown
# ADR-{NNN}: {Title}

**Status:** accepted
**Date:** {today}

---

## Context

{Why this decision was needed — the problem it solves}

## Decision

{What was decided — be specific and concrete}

## Rationale

{Why this option over the alternatives}

## Alternatives Considered

### {Alternative 1}
- **Pros:** {benefits}
- **Cons:** {drawbacks}

### {Alternative 2}
- **Pros:** {benefits}
- **Cons:** {drawbacks}

## Consequences

### Positive
- {benefit}

### Negative / Trade-offs
- {accepted trade-off}

---

*Captured by keel:adr — {date}*
```

### 5. Confirm

```
✅ ADR created: {BASE}/decisions/{NNN}-{slug}.md

  {NNN}: {Title}
  Status: accepted

  Review it and change status to "proposed" if it needs team sign-off first.
```
