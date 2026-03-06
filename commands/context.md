---
name: keel:context
description: "Load all project context into session"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# keel:context

Load all project context into the current session. Shows what was loaded for transparency.

## Instructions

### 1. Find Config

Look for `.keel/config.yaml`. If not found, check for `.dof/config.yaml` or `.conductor/config.yaml` (legacy). If none exist:

```
No keel config found. Run /keel:init to set up this project.
```

Read the config to determine `base:` directory (default: `docs`).

### 2. Load Soul

Read `{base}/soul.md` (or `docs/soul.md`). If it exists, summarize the key points. If not, note it's missing.

### 3. Load Active Plan

Search for plan files in the plans directory:

```bash
ls -t docs/product/plans/*.md docs/plans/*.md 2>/dev/null | head -5
```

If plans exist:
- Read the most recent plan (or the one marked active)
- Look for a progress table — this is the persistent state
- Summarize: plan name, current phase, what's done, what's next

### 4. Load Product Context

If `{base}/product/spec.md` exists, read and summarize:
- Product vision
- Current roadmap status
- Active features

If PRDs exist in `{base}/product/prds/`, list them with titles.

### 5. Load Architecture Decisions

```bash
ls docs/decisions/*.md 2>/dev/null
```

If decision records exist, read and summarize each (title, status, key decision). These inform implementation choices.

### 6. Load Invariants

```bash
ls docs/invariants/*.md 2>/dev/null
```

Invariants are hard architectural constraints — non-negotiables that must never be violated. Read each one and keep them in mind for the session. If none exist, skip silently.

### 7. Check Rules Status

```bash
ls .claude/rules/*.md 2>/dev/null
```

List installed rule packs. For each, check if the file contains `<!-- keel:generated -->` — if that marker is missing, the file was manually edited. Note it as a warning so the user knows their customizations won't be overwritten if they re-run init.

### 8. Check Ticket Config

Read `.keel/config.yaml` for a `ticket:` section. If configured, note the system and team — this context is useful for plan creation and referencing issues.

### 9. Output Summary

```
Context loaded for: {project name from soul.md}

  Soul:        {one-line summary}
  Plan:        {active plan name and current phase, or "None active"}
  Product:     {spec status, or "No product spec"}
  Decisions:   {count} decision records
  Invariants:  {count} invariants
  PRDs:        {count} product requirements
  Rules:       {count} rule packs installed
  Tickets:     {system name, or "Not configured"}

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

### 10. Warnings

If anything is missing or stale, note it:

```
  Warnings:
  - No soul.md found — run /keel:init
  - Plan "PLAN-xyz.md" has no progress updates in 7+ days
  - Rule pack "go.md" was manually edited (no keel:generated marker) — customizations preserved
```
