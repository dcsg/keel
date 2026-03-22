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
!`BASE=$(grep "^base:" .keel/config.yaml 2>/dev/null | awk '{print $2}' | tr -d '"' || echo "docs"); COUNT=$(ls "${BASE}/invariants/"*.md 2>/dev/null | wc -l | tr -d ' '); NEXT=$(printf "%03d" $((COUNT + 1))); EXISTING=$(ls "${BASE}/invariants/"*.md 2>/dev/null | xargs -I{} basename {} .md | sort | tr '\n' ', ' | sed 's/,$//'); printf "<!-- keel:live -->\nNext INV number: INV-%s\nExisting invariants: %s\n<!-- /keel:live -->\n" "$NEXT" "${EXISTING:-(none yet)}"`

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

Read `.keel/config.yaml`. Resolve paths from the `paths:` section:

- Invariants: `paths.invariants` (default: `docs/architecture/invariants`)
- Template override: check if `.keel/templates/invariant.md` exists — if yes, use it as the output template instead of the built-in template below

### 2. Load Existing Invariants

```bash
ls {BASE}/invariants/*.md 2>/dev/null | sort
```

The correct next INV number is provided at the top of this prompt in the `<!-- keel:live -->` block. Use it exactly — do not guess or count files yourself.

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

### 4. Draft with Enforcement-Grade Language

Before writing, ensure the invariant's Rule statement and Rationale meet enforcement quality. Invariants compile directly into non-negotiable governance directives — vague language here means vague enforcement.

Rules for writing invariants:

1. **The Rule statement uses MUST or NEVER** (uppercase). Example: "Every command MUST be a plain `.md` file — NEVER compiled code, NEVER a build step."
2. **Name specific things** — file types, namespaces, tools, patterns. "Code should be well-structured" is not an invariant. "Domain layer classes MUST NOT import from infrastructure packages" is.
3. **State the consequence in the Rationale** — not "it's important" but "violations cause X specific harm."
4. **Verification must be concrete** — a command to run, a grep pattern, or explicit review criteria. Not "review the code."

Do NOT write invariants with soft language ("should", "prefer", "try to"). If it's not a hard constraint, it belongs in `docs/guidelines/`.

### 5. Write the Invariant

Create `{BASE}/invariants/INV-{NNN}-{slug}.md`:

```markdown
---
type: invariant
id: INV-{NNN}
title: {Title}
status: active
severity: critical       # critical | high
scope: "**/*"            # path glob — what code this applies to
created_at: {ISO8601 timestamp}
references:
  adrs: []
  specs: []
  established_by: ""     # ADR, PRD, or incident that created this
---

# INV-{NNN}: {Title}

{One sentence. State the constraint as "X must always be true."}

## Rationale

{Why this is non-negotiable — the specific harm that occurs without it, not just "it's important."}

## Scope

{What parts of the system this applies to. Be specific: all code, only Go files, only the domain layer, only API handlers.}

## Violation Consequences

{What breaks if this is violated. Be concrete: data loss, security breach, CI failure, architectural drift.}

## Verification

How to check compliance:
- Automated: {command, test, hook, or CI check that verifies this}
- Manual: {what a reviewer should look for}

## Exceptions

{Can this ever be overridden? If yes, what approval is needed. If no: "No exceptions."}

## Related

{ADRs, specs, or incidents that established this invariant.}

---

*Captured by keel:invariant — {date}*
```

An invariant is a HARD CONSTRAINT that can never be violated. If there are exceptions, it might be a guideline (put it in `docs/guidelines/` instead). If it describes a preference, it's not an invariant.

---

REMEMBER: An invariant is a HARD CONSTRAINT where violation causes real harm. If it starts with "prefer" or "try to" — it belongs in docs/guidelines/, not in invariants. Every invariant needs a Verification section describing how to check compliance.

### 6. Confirm

```
✅ Invariant captured: {BASE}/invariants/INV-{NNN}-{slug}.md

  INV-{NNN}: {Title}
  Severity: {critical | high}

  Run /keel:compile to update governance directives.

  Want architect or security to review this? Say "review this invariant"
```
