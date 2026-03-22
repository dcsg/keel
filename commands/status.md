---
name: keel:status
description: "Governance dashboard — chain status, gates, agents, hooks"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# keel:status

Show the governance dashboard: chain status, gate activity, agent activity, hook activity, and signals.

## Instructions

### 1. Load Config

Read `.keel/config.yaml`. If not found:
```
No keel config found. Run /keel:init to set up this project.
```

Read `base:` from config (default: `docs`).
Read `specs: { dir: }` from config (default: `{base}/product/specs`).
Read `plans: { dir: }` from config (default: `{base}/plans`).

### 2. Gather Data

Collect all information in parallel:

**Rules:**
```bash
ls .claude/rules/*.md 2>/dev/null | wc -l
ls .claude/rules/*.md 2>/dev/null | xargs -I{} basename {} .md | paste -sd', ' -
```

**Agents:**
```bash
ls .claude/agents/*.md 2>/dev/null | wc -l
```

**Decisions:**
```bash
ls {base}/decisions/*.md {base}/architecture/decisions/*.md 2>/dev/null | wc -l
```

**Invariants:**
```bash
ls {base}/invariants/*.md {base}/architecture/invariants/*.md 2>/dev/null | wc -l
```

**Active plan:**
```bash
ls -t {plans_dir}/PLAN-*.md 2>/dev/null | head -1
```
Read the progress table to find the current in-progress phase.

**Active spec:**
```bash
ls -t {specs_dir}/SPEC-*/spec.md 2>/dev/null | head -1
```
Read the spec frontmatter for status and source_prd.

**Spec artifacts:**
```bash
ls {spec_folder}/*.md {spec_folder}/contracts/*.md 2>/dev/null | grep -v spec.md
```
Check each artifact's `status:` frontmatter.

**Last drift report:**
```bash
ls -t {spec_folder}/drift-*.md 2>/dev/null | head -1
```
If found, read the frontmatter `summary:` for compliant/diverged counts.

**Compile status:**
```bash
# Check if governance.md exists and when it was last compiled
ls -l .claude/rules/governance.md 2>/dev/null
# Check for ADRs/invariants modified after the last compile
COMPILE_DATE=$(grep 'compiled:' .claude/rules/governance.md 2>/dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
```
Compare the compile date against ADR/invariant modification dates. If any ADR or invariant was modified after the last compile, the directives are stale.

**Gate activity:**
```bash
grep 'GATE\|gate_fired\|gate_override' ~/.keel/session-signals.log ~/.keel/events.jsonl 2>/dev/null
```

**Agent activity:**
```bash
grep 'AGENT' ~/.keel/session-signals.log 2>/dev/null
```

**Hook activity:**
```bash
# Count hook fires by type from session-signals.log
grep 'RULE_LOADED' ~/.keel/session-signals.log 2>/dev/null | wc -l
grep 'AGENT' ~/.keel/session-signals.log 2>/dev/null | wc -l
```

**Signals detected:**
```bash
grep -E 'ADR|Doc gap|Security' ~/.keel/session-signals.log 2>/dev/null | grep -v 'AGENT\|RULE_LOADED'
```

### 3. Build Chain Status

If an active spec exists, trace the governance chain:
1. Read the spec's `source_prd:` → find the PRD → get its status
2. Read the spec's status
3. Count artifacts and their statuses
4. Find the associated plan and its status

Build the chain string:
```
PRD-005 accepted → SPEC-005 accepted → artifacts 3/3 accepted → PLAN-007 in progress
```

If no spec exists, show a simpler chain from PRD → plan (or just the plan).

### 4. Output Dashboard

```
KEEL STATUS — {project name from project-context.md}
═══════════════════════════════════════════════

GOVERNANCE HEALTH
  Rules:        {n} active ({rule names})
  Agents:       {n} installed
  Decisions:    {n} ADRs, {n} invariants
  Compile:      {last compile date, or "not compiled — run /keel:compile"}
                {If stale: "⚠️ stale — {n} ADRs modified since last compile"}
  Plan:         {plan name} Phase {n}/{total} — {status}

{If active spec exists:}
ACTIVE SPEC
  {SPEC-NNN}: {title} ({status})
  Artifacts: {accepted}/{total} accepted
  Drift: {last drift date and summary, or "not run yet — run /keel:drift {SPEC-NNN}"}
         {If last drift had divergences: "⚠️ {n} diverged — run /keel:drift to recheck"}

CHAIN STATUS
  {chain string from step 3}

{If gate events exist:}
GATE ACTIVITY (this session)
  {For each gate event:}
  ⛔ {agent}: {finding summary} ({resolved/overridden})
  {If no gate events:}
  ✅ No gate findings this session

{If agent events exist:}
AGENT ACTIVITY (this session)
  {agent name}  — ran {n}x ({contexts: plan pre-flight, review, etc.})
  {If no agent events:}
  No agent activity this session

HOOK ACTIVITY (this session)
  {For each hook type with activity:}
  {HookName}         — {n} fires ({description})
  {If no hook activity:}
  No hook activity this session

{If signal events exist:}
SIGNALS DETECTED
  💡 {ADR candidate signals}
  📄 {Doc gap signals}
  🔒 {Security signals}
  {If no signals:}
  No signals detected this session

WHAT'S NEXT
  Phase {n} — {title}
  {1-3 bullet points summarising tasks}

WARNINGS
  {Any issues: missing project context, stale plan, draft artifacts, etc.}
  {Or: "All clear — governance is healthy."}

═══════════════════════════════════════════════
```

### 5. Write STATUS.md

After displaying the dashboard, write the same content to `docs/STATUS.md` using sentinel comments:

```
<!-- keel:status:start — updated by /keel:status, do not edit manually -->
{dashboard content}
<!-- keel:status:end -->
```

If `docs/STATUS.md` exists: replace only between the sentinels.
If it doesn't exist: create it with the keel block only.
