---
name: keel:status
description: "Dashboard — plans, rules, governance health"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# keel:status

Show project dashboard: active plans, rule packs, and governance health.

## Instructions

### 1. Load Config

Read `.keel/config.yaml`. If not found:
```
No keel config found. Run /keel:init to set up this project.
```

### 2. Gather Status

Read `base:` from `.keel/config.yaml` (default: `docs`). Use `{base}` for all paths below.

Collect information in parallel where possible:

**Plans:**
```bash
ls -t {base}/product/plans/PLAN-*.md {base}/plans/PLAN-*.md 2>/dev/null
```
For each plan, read the Progress table to determine status.

**Rules:**
```bash
ls .claude/rules/*.md 2>/dev/null
```
Count installed packs. Optionally check if they match templates (checksum).

**Soul:**
Check if `{base}/soul.md` exists.

**Product:**
Check if `{base}/product/spec.md` exists. Check for PRDs in `{base}/product/prds/`.

**Decisions:**
```bash
ls {base}/decisions/*.md 2>/dev/null | wc -l
```

**Invariants:**
```bash
ls {base}/invariants/*.md 2>/dev/null | wc -l
```

**Team (only if `.keel/config.yaml` exists):**
```bash
# Count rule packs
ls .claude/rules/*.md 2>/dev/null | wc -l
# Count agents
ls .claude/agents/*.md 2>/dev/null | wc -l
# Read MCP config
cat .mcp.json 2>/dev/null
```
- Read `.keel/config.yaml` for `team.name`
- Parse `.mcp.json` to list server names and collect all required env vars across all configured servers:
  - linear → `LINEAR_API_KEY`
  - github → `GITHUB_TOKEN`
  - jira → `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN`

### 3. Determine Plan Status

For each plan file, read the Progress table:
- Count phases with status `done` or `complete`
- Count phases with status `in-progress`
- Count phases with status `-` (not started)
- Calculate percentage complete

### 4. Output Dashboard

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL STATUS — {project name from soul.md}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ACTIVE PLAN
 ───────────
 {plan name}
 Progress: {done}/{total} phases ({percentage}%)

 | Phase | Title              | Status      |
 |-------|--------------------|-------------|
 | 1     | {title}            | done        |
 | 2     | {title}            | in-progress |
 | 3     | {title}            | -           |

 WHAT'S NEXT
 ───────────
 Phase {n} — {title}
   {1-3 bullet points summarising the concrete tasks in that phase}
   Run: /keel:plan to start or /keel:context to load context first

 RULES
 ─────
 {count} packs installed:
   code-quality.md    testing.md    security.md
   error-handling.md  go.md         chi.md

 GOVERNANCE
 ──────────
 Soul:        {exists/missing}
 Decisions:   {count} records
 Invariants:  {count} constraints
 Product:     {spec exists + PRD count, or "No product spec"}
 Tickets:     {system name, or "Not configured"}

 TEAM
 ────
 Shared (committed to git):
   Rules:    {n} packs in .claude/rules/
   Agents:   {n} agents in .claude/agents/
   MCP:      {server names} in .mcp.json (or "not configured")

 Members need:
   {list env vars from .mcp.json, or "No env vars required"}

 Run /keel:team setup to validate your environment.
 Run /keel:team to see full onboarding instructions.

 WARNINGS
 ────────
 {any issues: missing soul, stale plan, manually edited rules, etc.}
 {or: "All clear — governance is healthy."}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If no active plan:
```
 ACTIVE PLAN
 ───────────
 No active plan. Run /keel:plan to create one.
```

If no keel setup at all, show a minimal status with just what exists and suggest init.

### 5. Write STATUS.md

After displaying the dashboard, write the same content to `docs/STATUS.md` so it persists between sessions and can be committed to git. This gives the team a snapshot of project health without needing to run the command.

Use a sentinel block so the file can contain user-written sections above the keel block:

```
<!-- keel:status:start — updated by /keel:status, do not edit manually -->
{dashboard content}
<!-- keel:status:end -->
```

If `docs/STATUS.md` exists: replace only between the sentinels.
If it doesn't exist: create it with the keel block only.
