---
type: adr
id: ADR-007
title: Model selection belongs to the plan phase, not the agent
status: accepted
decision-makers: [Daniel Gomes]
created_at: 2026-03-21T00:00:00Z
references:
  adrs: [ADR-004]
  invariants: []
---

# ADR-007: Model Selection Belongs to the Plan Phase, Not the Agent

**Status:** accepted
**Date:** 2026-03-21
**Decision-makers:** Daniel Gomes

---

## Context and Problem Statement

keel's specialist agents need to run on the right model for the task. A DBA reviewing a simple index addition doesn't need Opus. The same DBA designing a multi-tenant schema does. The model should scale with task complexity, not be fixed per agent.

How should model selection work for specialist agents?

## Decision Drivers

- Same agent, different complexity levels — model should adapt
- Plan phases already define the task context and complexity
- Claude Code supports per-subagent model override
- Cost efficiency — Haiku for mechanical tasks, Opus for complex reasoning

## Considered Options

### 1. Model fixed per agent (e.g., `model: opus` in architect.md)
- Pros: simple, predictable
- Cons: architect runs Opus for trivial tasks, wastes cost; DBA runs Sonnet for complex schema design, misses quality
- Rejected because: the model should match the task, not the agent

### 2. Model assigned per plan phase (chosen)
- Pros: complexity-aware, cost-efficient, adapts to context
- Cons: requires plan to assess complexity; without a plan, falls back to defaults

### 3. Claude decides model automatically
- Pros: zero configuration
- Cons: Claude doesn't have cost context; no transparency into why a model was chosen

## Decision

Agent templates have NO `model:` field. The model is determined by the conjunction of:

1. **Task type** — design/architecture, implementation, review, mechanical
2. **Complexity** — how many trade-offs, how much reasoning required
3. **Agent type** — advisory agents can use lighter models for routine checks

The plan phase includes a complexity assessment and model suggestion:

```markdown
## Phase 1: Multi-tenant schema design

**Objective:** Design tenant isolation at the database level
**Complexity:** High — architecture decision with security implications
**Suggested model:** opus
**Agents:** architect, dba, security
```

### Complexity-to-model mapping

| Task type | Complexity | Suggested model |
|---|---|---|
| Architecture/design decisions | High | opus |
| Complex implementation (domain logic, state machines) | High | opus or sonnet |
| Standard implementation (CRUD, handlers, tests) | Medium | sonnet |
| Mechanical tasks (formatting, doc updates, simple tests) | Low | haiku or sonnet |
| Review of critical changes (security, schema, API contracts) | High | opus |
| Review of routine changes (formatting, naming, small fixes) | Low | sonnet or haiku |

### Without a plan

When agents are invoked outside a plan (ad-hoc `/keel:review`, direct agent delegation), Claude uses its default model (inherited from the main conversation). This is acceptable — the user already chose their model.

## Consequences

### Good
- Cost-efficient: mechanical tasks don't burn Opus tokens
- Quality-aware: complex decisions get the reasoning power they need
- Transparent: the plan shows why a model was suggested
- Flexible: Claude makes the final call, plan suggestion is guidance

### Bad
- Requires plan to get optimal model selection — ad-hoc usage inherits the default
- Complexity assessment is subjective — Claude's judgment on "high vs medium" may vary

### Neutral
- Agent templates become simpler (no model field)
- `/keel:plan` becomes responsible for complexity assessment

## Confirmation

How to verify this decision is being followed:
- Agent templates in `templates/agents/` should NOT have a `model:` field
- Plan phases should include `Complexity:` and `Suggested model:` fields
- `/keel:status` shows which model was used per agent run (via SubagentStop hook)
