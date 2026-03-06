---
name: keel:plan
description: "Create execution plan with interview and codebase analysis"
argument-hint: "[ticket-id or task description]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - Agent
  - AskUserQuestion
---

# keel:plan

Create an optimized execution plan through interview and codebase analysis.

## Arguments

- `$ARGUMENTS` — Optional ticket ID or task description

## Instructions

### 1. Load Context

Run `/keel:context` logic to load soul, decisions, product context, and active rules. This ensures the plan respects existing architecture.

### 2. Determine Task

- If `$ARGUMENTS` looks like a ticket ID (e.g., `GLO-35`, `PROJ-123`): note it for reference
- If `$ARGUMENTS` is a description: use it as the task
- If empty: ask "What are you planning? Describe the task or feature."

### 3. Interview

Ask 3-6 targeted questions to clarify requirements. Adapt based on the task type:

```
Let me ask a few questions to create an optimal plan:

1. {Contextual question based on task type}
   - Option A (Recommended — reason)
   - Option B
   - Other: ___

2. {Technical decision question}

3. {Scope/boundary question}

4. Anything else I should know?
```

For example:
- Feature work: "Should this be behind a feature flag?", "What's the data model?"
- Refactoring: "What's the migration strategy?", "Can we do it incrementally?"
- Bug fix: "Can you reproduce it?", "What's the impact?"

### 4. Analyze Codebase

Use an Agent to scan for relevant code:

```
Agent(
  subagent_type: "Explore",
  prompt: "Find files and patterns relevant to: {task description}. Look for existing implementations, related tests, config files, and dependencies that will be affected.",
  description: "Scan codebase for plan"
)
```

### 5. Generate Phases

Break the task into phases. For each phase, assign:

**Model assignment:**
- **Haiku** (~$0.01/phase): Database migrations, config files, simple CRUD, documentation, scripts
- **Sonnet** (~$0.08/phase): Business logic, UI components, API integrations, refactoring, complex tests
- **Opus** (~$0.80/phase): Security, algorithms, architecture, complex debugging, novel problems

**Phase structure:**
- Number (e.g., 1, 2, 3)
- Title
- Objective (one sentence)
- Model recommendation with reasoning
- Detailed prompt (full implementation instructions — be specific)
- Completion promise (shell-safe: uppercase, numbers, spaces, dots ONLY)
- Max iterations (based on complexity)
- Dependencies (which phases must complete first)

### 6. Parallelism Analysis

After building the dependency graph, identify phases that can run simultaneously:

- Phases with no inter-dependencies can run in parallel
- Group into execution waves:
  - Wave 1: all phases with no dependencies
  - Wave 2: phases whose dependencies are all in Wave 1
  - etc.

### 7. Write Plan File

Save to `docs/product/plans/PLAN-{slug}.md` (or `docs/plans/` if product dir doesn't exist):

```markdown
# Plan: {Title}

## Overview
**Task:** {description or ticket ID}
**Total Phases:** {n}
**Estimated Cost:** ${cost}
**Created:** {date}

## Progress

| Phase | Status | Updated |
|-------|--------|---------|
| 1     | -      | -       |
| 2     | -      | -       |

**IMPORTANT:** Update this table as phases complete. This table is the persistent state that survives context compaction.

## Model Assignment
| Phase | Task | Model | Reasoning | Est. Cost |
|-------|------|-------|-----------|-----------|
| 1 | {task} | haiku | {why} | $0.01 |

## Execution Strategy
| Phase | Depends On | Parallel With |
|-------|-----------|---------------|
| 1     | None      | 2             |
| 2     | None      | 1             |
| 3     | 1, 2      | -             |

## Phase 1: {Title}

**Objective:** {brief description}
**Model:** `{model}`
**Max Iterations:** {n}
**Completion Promise:** `{SHELL SAFE PROMISE}`
**Dependencies:** {None or phase numbers}

**Prompt:**
```
{Full detailed implementation instructions.
Reference specific file paths, patterns to follow, tests to write.
This is where all the detail goes — be thorough.
The prompt should be self-contained: someone reading only this section
should be able to implement the phase without other context.

When complete, output: {COMPLETION PROMISE}
}
```

---

{repeat for each phase}
```

### 8. Completion Promise Rules

Promises are used in automation, so they MUST be shell-safe:
- ONLY: uppercase letters, numbers, spaces, dots
- NO: `>`, `<`, `|`, `&`, `$`, backticks, `!`, `'`, `"`, arrows
- Keep SHORT: 2-4 words max
- Good: `PHASE 1 COMPLETE`, `MIGRATION DONE`, `API READY`, `TESTS PASSING`
- Bad: anything with special characters or lowercase

### 9. Output Next Steps

```
Plan saved: {path}

Execution Strategy:
  Wave 1: Phase {n}, {m} (parallel)
  Wave 2: Phase {x}
  Wave 3: Phase {y}

Estimated cost: ${total}

Next steps:
1. Review the plan: {path}
2. Start Phase 1:
   - /model {model}
   - Execute the phase prompt

To check progress: /keel:status
```
