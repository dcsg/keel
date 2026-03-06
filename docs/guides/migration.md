# Migrating from dof to Keel

If your project uses `dof:init` (has a `.dof/` directory), run `/keel:migrate` to upgrade. It maps the old structure to keel's and generates everything that's new.

## What Gets Migrated

| Source | Destination |
|--------|-------------|
| `.dof/soul.md` | `docs/soul.md` |
| `.dof/config.yaml` | `.keel/config.yaml` (rewritten) |
| `.dof/architecture/decisions/*.md` | `docs/decisions/` |
| `.dof/architecture/invariants/*.md` | `docs/invariants/` |
| `.dof/design/components/*.md` | `docs/reference/components/` |
| `.dof/product/prds/*.md` | `docs/product/prds/` |

## What Gets Generated (New in Keel)

| File | Purpose |
|------|---------|
| `.claude/rules/*.md` | Rule packs based on detected stack |
| `CLAUDE.md` (keel block) | Context loading instructions, build commands |
| `.claude/settings.json` | PreCompact and PreToolUse hooks |

## What Gets Left Alone

- `.cursorrules`, `.windsurfrules`, `.github/copilot-instructions.md` — keel is Claude Code only; remove these if you're no longer using other AI tools
- Existing `CLAUDE.md` content — keel appends/merges using sentinels, never overwrites
- Existing `docs/soul.md` — if it already exists, keel skips it

## Config Mapping

Old dof config keys map to keel as follows:

| dof key | keel key | Notes |
|---------|----------|-------|
| `base:` | `base:` | Same |
| `tools:` | _(dropped)_ | Keel is Claude Code only |
| `git:` | `sdlc:` | Renamed section |
| `worktree:` | _(dropped)_ | Use Claude native worktrees |
| `ticketSystem:` | `ticket:` | Renamed |
| `plans.dir:` | `base: docs` | Standardized |

## Run the Migration

```
/keel:migrate
```

Keel will show a migration plan and ask for confirmation before making any changes:

```
Migration: .dof/ → keel

  Files to migrate:
    .dof/soul.md                    → docs/soul.md
    .dof/config.yaml                → .keel/config.yaml (rewritten)
    .dof/architecture/decisions/*   → docs/decisions/
    .dof/architecture/invariants/*  → docs/invariants/

  Files to generate:
    .claude/rules/*.md              — rule packs based on detected stack
    CLAUDE.md                       — keel block (safe merge)
    .claude/settings.json           — hooks

  Legacy files to remove (after verification):
    .dof/                           — entire directory

Proceed? (y/n)
```

## After Migration

1. Verify `docs/soul.md` looks correct
2. Review `.keel/config.yaml` — check the rules section
3. Run `/keel:context` to confirm everything loads
4. When satisfied: `rm -rf .dof/`
5. Commit the migration

```bash
git add .keel/ .claude/ docs/ CLAUDE.md
git commit -m "chore: migrate from dof to keel"
```

## Invariants vs Decisions

One key difference from dof: keel separates **invariants** (hard constraints, non-negotiables) from **decisions** (architectural choices with context and rationale). They live in separate directories:

- `docs/decisions/` — ADRs: what was decided and why
- `docs/invariants/` — hard rules: things that must never be violated

During migration, files from `.dof/architecture/invariants/` go to `docs/invariants/`, not `docs/decisions/`.
