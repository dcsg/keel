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
!`PLAN=$(ls -t docs/product/plans/*.md docs/plans/*.md 2>/dev/null | head -1); if [ -n "$PLAN" ]; then NAME=$(basename "$PLAN"); PHASE=$(grep -E "in.progress|In Progress" "$PLAN" 2>/dev/null | head -1 | tr -d '|' | xargs); printf "<!-- keel:live -->\nActive plan: %s\nCurrent phase status: %s\n<!-- /keel:live -->\n" "$NAME" "${PHASE:-(none in progress)}"; fi`

# keel:plan

Create an optimized execution plan through interview and codebase analysis.

CRITICAL: NEVER write a plan without running the pre-flight specialist review — skip it only if `--no-review` is explicitly passed.

## Arguments

- `$ARGUMENTS` — Optional ticket ID or task description

## Instructions

1. Run `/keel:context` logic to load project context, decisions, product context, and active rules.

2. Determine the task from `$ARGUMENTS`:
   - Looks like a ticket ID (e.g., `GLO-35`): note it for reference
   - Is a SPEC identifier (e.g., `SPEC-005`): find the spec folder and use it as primary context
   - Is a description: use it as the task
   - Empty: ask "What are you planning? Describe the task or feature."

3. If a SPEC identifier was provided or detected, check the governance chain:
   - Read spec frontmatter for `status:`. If not `accepted`, warn the user.
   - Check for spec-artifacts in the spec folder. If any have `status: draft`, warn and ask to proceed.
   - If artifacts exist and are accepted, read them as planning context.

4. Interview: ask 3-6 targeted questions to clarify requirements. Adapt to task type using the Interview Guidance in the Reference section. Present options where applicable.

5. Analyze the codebase using an Agent:
   ```
   Agent(
     subagent_type: "Explore",
     prompt: "Find files and patterns relevant to: {task description}. Look for existing implementations, related tests, config files, and dependencies that will be affected.",
     description: "Scan codebase for plan"
   )
   ```

6. Generate phases. For each phase, assign a model, write a detailed prompt, set a completion promise, max iterations, and dependencies. Use the Phase Structure and Model Assignment guide in the Reference section.

7. Build the dependency graph. Identify phases with no inter-dependencies and group them into execution waves (Wave 1: no dependencies, Wave 2: depends only on Wave 1, etc.).

8. Write the plan file to `docs/product/plans/PLAN-{slug}.md` (or `docs/plans/` if product dir doesn't exist). Use the Plan File Template in the Reference section.

9. Output next steps:
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

10. Run pre-flight specialist review (skip if `--no-review` in arguments):
    - Scan the full plan text for domain signals using the Domain Signal table in the Reference section.
    - If no domains detected, output: `Pre-flight: no specialist domains detected — plan looks self-contained.` and stop.
    - Spawn all applicable specialist agents concurrently (single message, multiple Agent tool calls) using the domain-to-subagent mapping in the Reference section.
    - Each agent reads the plan, reviews from their domain lens only, and returns findings with severity.
    - Output the consolidated pre-flight review using the Pre-Flight Output Format in the Reference section.
    - If user provides updates, incorporate them into the plan file. If user skips, add a `## Known Risks` section listing outstanding findings.

## Reference

### Interview Guidance

- Feature work: "Should this be behind a feature flag?", "What's the data model?"
- Refactoring: "What's the migration strategy?", "Can we do it incrementally?"
- Bug fix: "Can you reproduce it?", "What's the impact?"

### Model Assignment

| Model | Cost/phase | Best for |
|---|---|---|
| Haiku | ~$0.01 | Database migrations, config files, simple CRUD, documentation, scripts |
| Sonnet | ~$0.08 | Business logic, UI components, API integrations, refactoring, complex tests |
| Opus | ~$0.80 | Security, algorithms, architecture, complex debugging, novel problems |

### Phase Structure

Each phase requires:
- Number (e.g., 1, 2, 3)
- Title
- Objective (one sentence)
- Model recommendation with reasoning
- Detailed prompt (full implementation instructions — be specific and self-contained)
- Completion promise (shell-safe: uppercase, numbers, spaces, dots ONLY)
- Max iterations (based on complexity)
- Dependencies (which phases must complete first)

### Completion Promise Rules

Promises are used in automation, so they MUST be shell-safe:
- ONLY: uppercase letters, numbers, spaces, dots
- NO: `>`, `<`, `|`, `&`, `$`, backticks, `!`, `'`, `"`, arrows
- Keep SHORT: 2-4 words max
- Good: `PHASE 1 COMPLETE`, `MIGRATION DONE`, `API READY`, `TESTS PASSING`
- Bad: anything with special characters or lowercase

### Domain Signal Detection

| Domain | Signals | Agent |
|---|---|---|
| Database | SQL, query, schema, migration, index, database, db, table, foreign key, join, transaction, ORM, Postgres, MySQL, SQLite, MongoDB | `dba` |
| Infrastructure | deploy, docker, kubernetes, k8s, terraform, helm, CI, CD, infra, container, Dockerfile, compose, nginx, AWS, GCP, Azure, cloud | `sre` |
| Security | auth, JWT, OAuth, payment, PCI, HIPAA, token, secret, encrypt, credential, password, permission, role, RBAC, CORS, XSS, injection | `security` |
| API | API, endpoint, REST, GraphQL, route, webhook, contract, openapi, swagger, versioning, breaking change | `api` |
| Architecture | bounded context, domain, architecture, refactor, pattern, layer, dependency, coupling, abstraction, interface, hexagonal, clean arch | `architect` |
| Performance | performance, N+1, cache, latency, throughput, slow, optimize, index, query optimization, benchmark | `performance` |

### Pre-Flight Severity

- 🔴 Critical: must address before execution (data loss, security breach, broken contract)
- 🟡 Warning: should address, not blocking
- 🟢 OK: domain looks healthy

### Pre-Flight Output Format

```
PRE-FLIGHT REVIEW
─────────────────────────────────────────────────────
Domains detected: {list} ({n} of 6 checked)

{AGENT NAME}
  🔴  {finding}
  🟡  {finding}
  🟢  {positive finding}

─────────────────────────────────────────────────────
{N critical, N warnings}. Address in plan before executing?
Type your updates now, or press enter to proceed with known risks noted.
```

### Plan File Template

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
