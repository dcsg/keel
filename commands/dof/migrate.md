---
name: dof:migrate
description: "Migrate a project set up with dof:init (has .dof/ directory) to keel — moves soul, config, decisions, and invariants into keel's structure"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# keel:migrate

Migrate a project that was set up with `dof:*` commands to keel.

If you've been using `dof:init` on your projects, they have a `.dof/` directory with soul, config, architecture decisions, and invariants. This command moves all of that into keel's structure and generates the missing pieces (rules, CLAUDE.md, hooks).

## Instructions

### 1. Detect Legacy Setup

Check for legacy directories:

```bash
ls -la .dof/ 2>/dev/null && echo "FOUND: .dof/"
ls -la .conductor/ 2>/dev/null && echo "FOUND: .conductor/"
```

If neither exists:
```
No legacy dof or conductor setup found. Run /keel:init for a fresh setup.
```

If `.keel/config.yaml` already exists:
```
Keel is already set up. Use /keel:init to reconfigure, or /keel:intake to import additional docs.
```

### 2. Read Legacy Config

Read the legacy config (`.dof/config.yaml` or `.conductor/config.yaml`):
- Extract: base directory, tools list, git config, worktree patterns, ticket system, plans directory
- Note what maps to keel and what's deprecated

### 3. Show Migration Plan

```
Migration: {.dof/ or .conductor/} → keel

  Files to migrate:
    {legacy}/soul.md                    → docs/soul.md
    {legacy}/config.yaml                → .keel/config.yaml (rewritten)
    {legacy}/agent-instructions.md      → .claude/rules/ (converted to rule packs)
    {legacy}/architecture/decisions/*   → docs/decisions/
    {legacy}/architecture/invariants/*  → .claude/rules/ (as custom topics)
    {legacy}/design/components/*        → docs/reference/components/
    {legacy}/product/prds/*             → docs/product/prds/

  Files to generate (new in keel):
    .claude/rules/*.md                  — rule packs based on detected stack
    .claude/CLAUDE.md                   — generated context loader
    .claude/settings.json               — hooks

  Legacy files to remove (after verification):
    {legacy}/                           — entire directory

  Files to update (non-destructive):
    CLAUDE.md                           — keel block appended/merged via sentinels
    .claude/settings.json               — hooks merged, existing keys preserved
    .cursorrules                        — left untouched (keel is Claude Code only)
    .github/copilot-instructions.md     — left untouched

Proceed? (y/n)
```

### 4. Execute Migration

#### 4.1 — Create keel structure
```bash
mkdir -p .keel
mkdir -p docs/product/prds
mkdir -p docs/product/plans
mkdir -p docs/decisions
mkdir -p docs/reference
mkdir -p .claude/rules
```

#### 4.2 — Migrate soul
**If `docs/soul.md` does not exist:** copy `{legacy}/soul.md` → `docs/soul.md`, clean up legacy references (remove "dof"/"conductor" mentions, update paths).
**If `docs/soul.md` already exists:** skip — do not overwrite.

#### 4.3 — Migrate config
Read legacy config and generate new `.keel/config.yaml`:
- Map `base:` → `base:`
- Map `tools:` → dropped (keel is Claude Code only)
- Map `git:` → `sdlc:` section
- Map `worktree:` → dropped (Claude native worktrees)
- Map `ticketSystem:` → `ticket:` section
- Map `plans.dir:` → keep or default to `docs/product/plans`
- Add `stack:` based on detected languages
- Add `rules:` section based on codebase detection

#### 4.4 — Migrate decisions
```bash
cp {legacy}/architecture/decisions/*.md docs/decisions/ 2>/dev/null
```

#### 4.5 — Convert invariants to rules
For each invariant file in `{legacy}/architecture/invariants/`:
1. Read the invariant
2. Create a custom rule file in `.claude/rules/` with the invariant content
3. Add it to `.keel/config.yaml` under `rules:` as a custom topic

#### 4.6 — Migrate product docs
```bash
cp {legacy}/product/prds/*.md docs/product/prds/ 2>/dev/null
```

#### 4.7 — Migrate components
```bash
mkdir -p docs/reference/components
cp {legacy}/design/components/*.md docs/reference/components/ 2>/dev/null
```

#### 4.8 — Migrate plans
```bash
cp docs/plans/PLAN-*.md docs/product/plans/ 2>/dev/null
```

#### 4.9 — Generate new files (non-destructive)

**`.claude/rules/*.md`** — generate rule packs based on detected stack. Skip any that already exist.

**`CLAUDE.md`** — use sentinel merge (ADR-002):
- No CLAUDE.md → create with keel block only
- CLAUDE.md exists, no keel block → append keel block at bottom
- CLAUDE.md exists, keel block present → replace only between `<!-- keel:start -->` and `<!-- keel:end -->`
- Never use Write on the whole file — always Read + Edit

**`.claude/settings.json`** — if it exists, merge the PreCompact hook into the existing JSON. If it doesn't exist, create it. Never overwrite existing keys.

#### 4.10 — Leave other tool adapters alone
`.cursorrules`, `.windsurfrules`, `.github/copilot-instructions.md` — do NOT touch these. Note to the user that keel only works in Claude Code and these files can be removed if they no longer use those tools.

### 5. Output Summary

```
Migration complete!

  Migrated:
    Soul:          docs/soul.md
    Config:        .keel/config.yaml
    Decisions:     {count} records → docs/decisions/
    Invariants:    {count} → .claude/rules/ (custom topics)
    PRDs:          {count} → docs/product/prds/
    Components:    {count} → docs/reference/components/

  Generated:
    Rules:         {count} packs in .claude/rules/
    CLAUDE.md:     .claude/CLAUDE.md
    Hooks:         .claude/settings.json

  Legacy directory preserved: {legacy}/
  To remove it (after verifying everything works):
    rm -rf {legacy}/

  Next steps:
  1. Verify docs/soul.md looks correct
  2. Review .keel/config.yaml
  3. Test: /keel:context (should load everything)
  4. When satisfied: rm -rf {legacy}/
  5. Commit the migration
```
