# /keel:prd

Write a Product Requirements Document for a feature.

## Usage

```
/keel:prd webhook delivery with retry logic
/keel:prd                                    ← extracts from current conversation
```

## What is a PRD?

A PRD captures a clearly defined feature need: the problem, who it's for, what success looks like, and the acceptance criteria. It's the handoff from "we want this" to "here's what done means."

Keel reads `docs/project-context.md` and `docs/product/spec.md` before writing the PRD — so it knows your project context and doesn't repeat what's already decided.

## Two modes

### With argument — define from scratch

```
/keel:prd webhook delivery with retry logic
```

If the description is vague, keel asks clarifying questions:
- Who is this for?
- What's the problem it solves?
- What are the edge cases?

Creates: `docs/product/prds/PRD-{NNN}-webhook-delivery-with-retry-logic.md`

### No argument — extract from conversation

```
/keel:prd
```

Extracts the last clearly-defined feature requirement from the current conversation.

## Proactive suggestions

The `Stop` hook watches every Claude response for product requirement signals. When it detects a clearly-defined feature, Claude suggests:

```
💡 This looks like a PRD — run `/keel:prd` to capture it.
```

## Output

```
docs/product/prds/
└── PRD-001-webhook-delivery-with-retry-logic.md
```

File format: problem statement, users affected, success metrics, requirements, user stories, acceptance criteria, out-of-scope.

After creating a PRD, run `/keel:plan PRD-001` to generate an execution plan for it.

## Natural language triggers

- "write a PRD for X"
- "document this feature"
- "requirements for X"
- "let's spec this out"
