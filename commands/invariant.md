---
name: keel:invariant
description: "Capture a hard architectural constraint that must never be violated"
argument-hint: "[constraint description] — omit to extract from conversation"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---

# keel:invariant

Capture an invariant — a hard constraint that must never be violated, regardless of context.

Invariants are always loaded by `/keel:context` (all depth levels) because they are non-negotiables.

Two modes:
- **With argument** — `/keel:invariant no floats for money` — define from scratch
- **No argument** — `/keel:invariant` — extract from current conversation

## What Makes a Good Invariant

An invariant is NOT a preference or a guideline. It is a rule where violation causes real harm:
- "All monetary amounts stored as integer cents. Never use float64 for money."
- "Domain package imports only stdlib. No HTTP, no SQL, no framework types."
- "All payment operations require an idempotency key."
- "Never log PII — mask emails, phone numbers, and card data before logging."

If it starts with "prefer" or "try to" — it's a rule, not an invariant. Put it in `.claude/rules/`.

## Instructions

### 1. Resolve Paths

Read `.keel/config.yaml`. `BASE` = `base:` value (default: `docs`).

- Invariants go in: `{BASE}/invariants/`

### 2. Load Existing Invariants

```bash
ls {BASE}/invariants/*.md 2>/dev/null | sort
```

Note the highest existing number. Zero-pad to 3 digits (e.g. `003`).

### 3. Determine Mode

**With `$ARGUMENTS`** — clarify and define:

Ask one focused question if needed: "What's the consequence of violating this?"

If the user's description is already precise, skip asking — just write it.

**Without `$ARGUMENTS`** — extract from conversation:

Look for statements of the form "we must always / never", "under no circumstances", "this is a hard rule", or explicit non-negotiables discussed.

If no clear constraint is found:
```
I couldn't identify a hard constraint in our conversation.

An invariant is something that must NEVER be violated — not a preference.
Describe it: /keel:invariant <constraint>
```

### 4. Write the Invariant

Create `{BASE}/invariants/INV-{NNN}-{slug}.md`:

```markdown
# INV-{NNN}: {Title}

{One or two sentences. State the rule clearly. Lead with the constraint, end with the consequence or reason.}

## What This Means

- {Concrete example of compliance}
- {Concrete example of a violation to avoid}

## Why

{Brief rationale — what goes wrong if this is violated}

---

*Captured by keel:invariant — {date}*
```

### 5. Confirm

```
✅ Invariant captured: {BASE}/invariants/INV-{NNN}-{slug}.md

  INV-{NNN}: {Title}

  This will be loaded in every /keel:context call — Claude will always see it.
```
