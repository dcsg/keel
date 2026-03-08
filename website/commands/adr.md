# /keel:adr

Capture an Architecture Decision Record — from scratch or extracted from the current conversation.

## Usage

```
/keel:adr use postgres for persistence
/keel:adr                                  ← extracts from current conversation
```

## What is an ADR?

An Architecture Decision Record captures a significant technical choice with its context, reasoning, alternatives considered, and consequences. Unlike comments in code, ADRs survive refactoring and give future teammates (and Claude) the "why" behind decisions.

## Two modes

### With argument — define from scratch

```
/keel:adr use postgres for persistence
```

Keel opens a structured conversation to work through the decision:
- What problem does this solve?
- What alternatives were considered?
- Why was this chosen?
- What are the consequences?

Creates: `docs/decisions/{NNN}-use-postgres-for-persistence.md`

### No argument — extract from conversation

```
/keel:adr
```

Keel reads the current conversation, extracts the last significant technical decision discussed, and creates an ADR from it. Useful when you've been discussing trade-offs and realize it's worth capturing.

## Proactive suggestions

You don't need to remember to run this. The `Stop` hook installed by `/keel:init` watches every Claude response for significant technical choices with trade-offs. When it detects one, Claude ends its response with:

```
💡 This looks like an ADR — run `/keel:adr` to capture it.
```

## Output

```
docs/decisions/
└── 003-use-postgres-for-persistence.md
```

File format: title, status (Accepted/Proposed/Deprecated), date, context, decision, rationale, alternatives, consequences.

ADRs are loaded by `/keel:context` and available to Claude in every future session.

## Natural language triggers

- "save this decision"
- "record this choice"
- "capture that"
- "let's write an ADR"
