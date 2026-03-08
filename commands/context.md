---
name: keel:context
description: "Load all project context into session"
argument-hint: "[--depth=full|focused|minimal]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# keel:context

Load project context into the current session. Shows what was loaded for transparency.

## Arguments

- `$ARGUMENTS` — Optional depth flag: `--depth=full`, `--depth=focused`, or `--depth=minimal`

## Depth Levels

| Depth | Loads | Best for |
|-------|-------|----------|
| `full` | Everything: soul, all decisions, all invariants, product, PRDs, plans, rules | Small/medium projects, first time on a project |
| `focused` | Soul, current plan phase, relevant decisions, all invariants, rule names | Day-to-day work on large projects |
| `minimal` | Soul, current plan phase title + tasks, all invariants | Quick tasks, tight context windows |

Default is `full`. If no `--depth` flag is provided and the project has more than 15 ADRs or more than 5 PRDs, suggest focused mode before proceeding:

```
Note: This project has {n} ADRs and {m} PRDs (~{est}k tokens).
  Consider --depth=focused to reduce context size.
  Proceeding with --depth=full (default).
```

## Instructions

### 1. Find Config

Look for `.keel/config.yaml`. If not found, check for `.dof/config.yaml` or `.conductor/config.yaml` (legacy). If none exist:

```
No keel config found. Run /keel:init to set up this project.
```

Read the config to determine `base:` directory (default: `docs`).

Parse `$ARGUMENTS` for `--depth=` flag. Default to `full` if not provided.

### 2. Load Soul (all depths)

Read `{base}/soul.md`. If it exists, summarize the key points. If not, note it's missing.

### 3. Load Active Plan

Search for plan files:

```bash
ls -t {base}/product/plans/*.md {base}/plans/*.md 2>/dev/null | head -5
```

**full:** Read the most recent plan. Summarize: plan name, progress table, current phase, what's next.

**focused:** Read the most recent plan. Show only the current in-progress phase (objective + tasks). Skip completed and future phases.

**minimal:** Show only the current phase title and task list. No progress table, no other phases.

### 4. Load Product Context (full only)

Skip this step for `focused` and `minimal` depths.

If `{base}/product/spec.md` exists, read and summarize:
- Product vision
- Current roadmap status
- Active features

If PRDs exist in `{base}/product/prds/`, list them with titles.

### 5. Load Architecture Decisions

```bash
ls {base}/decisions/*.md 2>/dev/null
```

**full:** Read and summarize every decision record (title, status, key decision).

**focused:** Load only relevant decisions. Determine relevance by:
1. Get the current git branch name: `git branch --show-current 2>/dev/null`
2. Get the active plan's current phase title and keywords
3. For each ADR, check if its filename or title contains keywords from the branch name or phase title (e.g., branch `feat/auth` matches ADR `003-authentication-strategy.md`)
4. If no matches found, load the 5 most recently modified ADRs as fallback
5. Note which decisions were loaded and why: `Loaded 3/{total} decisions (matched branch: feat/auth)`

**minimal:** Skip entirely.

### 6. Load Invariants (all depths)

```bash
ls {base}/invariants/*.md 2>/dev/null
```

Invariants are hard architectural constraints — non-negotiables that must never be violated. Read each one and keep them in mind for the session. If none exist, skip silently.

Invariants are always loaded regardless of depth — they are safety constraints.

### 7. Check Rules Status

**full:** List installed rule packs. For each, check for `<!-- keel:generated -->` marker. Flag manually edited ones.

```bash
ls .claude/rules/*.md 2>/dev/null
```

**focused / minimal:** List rule pack names only (no content check — rules are already active via `.claude/rules/`).

### 8. Check Ticket Config (full and focused)

Skip for `minimal`.

Read `.keel/config.yaml` for a `ticket:` section. If configured, note the system and team.

### 9. Output Summary

```
Context loaded for: {project name from soul.md} (depth: {depth})

  Soul:        {one-line summary}
  Plan:        {active plan name and current phase, or "None active"}
  Product:     {spec status, or "No product spec"}
  Decisions:   {count loaded}/{count total} decision records
  Invariants:  {count} invariants
  PRDs:        {count} product requirements
  Rules:       {count} rule packs installed
  Tickets:     {system name, or "Not configured"}
```

Then output each section based on depth:

**full:**
```
  ─────────────────────────────────────────
  SOUL
  ─────────────────────────────────────────
  {soul.md summary — what this project is, stack, architecture}

  ─────────────────────────────────────────
  ACTIVE PLAN
  ─────────────────────────────────────────
  {plan summary with progress, or "No active plan. Run /keel:plan to create one."}

  ─────────────────────────────────────────
  DECISIONS
  ─────────────────────────────────────────
  {list of decisions with status, or "No decisions recorded yet."}

  ─────────────────────────────────────────
  INVARIANTS
  ─────────────────────────────────────────
  {list of invariants — hard constraints to never violate, or "None defined."}

  ─────────────────────────────────────────
  RULES
  ─────────────────────────────────────────
  {list of installed rule packs, flagging any manually edited ones}
```

**focused:**
```
  ─────────────────────────────────────────
  SOUL
  ─────────────────────────────────────────
  {soul.md summary}

  ─────────────────────────────────────────
  CURRENT PHASE
  ─────────────────────────────────────────
  {current phase objective + tasks only}

  ─────────────────────────────────────────
  RELEVANT DECISIONS
  ─────────────────────────────────────────
  {matched decisions with reason, or "No relevant decisions for current branch/phase."}
  (Use --depth=full to load all {n} decisions)

  ─────────────────────────────────────────
  INVARIANTS
  ─────────────────────────────────────────
  {list of invariants}
```

**minimal:**
```
  ─────────────────────────────────────────
  SOUL
  ─────────────────────────────────────────
  {soul.md summary}

  ─────────────────────────────────────────
  CURRENT PHASE
  ─────────────────────────────────────────
  {phase title + task list only}

  ─────────────────────────────────────────
  INVARIANTS
  ─────────────────────────────────────────
  {list of invariants}
```

### 10. Warnings

If anything is missing or stale, note it:

```
  Warnings:
  - No soul.md found — run /keel:init
  - Plan "PLAN-xyz.md" has no progress updates in 7+ days
  - Rule pack "go.md" was manually edited (no keel:generated marker) — customizations preserved
```

### 11. Write Auto-Memory

After printing the full context summary, write a compact snapshot to Claude's auto-memory. This persists context across sessions so the SessionStart hook can surface it.

Compute memory path:
```bash
ENCODED=$(echo "$PWD" | sed 's|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/${ENCODED}/memory"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
mkdir -p "$MEMORY_DIR"
```

Write the following to `$MEMORY_FILE` (keep under 150 lines):

```markdown
# {Project Name from soul.md} — Keel Memory

_Last updated: {YYYY-MM-DD} via /keel:context_

## Soul
{2-3 sentence summary from soul.md}

## Stack
{stack from config.yaml}

## Active Plan
{plan name + current phase title, or "None"}

## Architecture Decisions
{list of ADR titles with status — one line each, e.g. "ADR-001 (Accepted) — Use PostgreSQL for persistence"}

## Invariants
{list of invariants — HARD RULES — one line each}

## Rules Installed
{list of rule pack filenames — e.g. code-quality.md, testing.md, go.md}

## Agents Installed
{list of agent names from .claude/agents/}

## Key Files
- Config: .keel/config.yaml
- Soul: docs/soul.md
- Plans: docs/product/plans/ (or docs/plans/)
- Decisions: docs/decisions/
- Invariants: docs/invariants/
```

After writing, output one line: `  Memory: updated ~/.claude/projects/.../memory/MEMORY.md`
