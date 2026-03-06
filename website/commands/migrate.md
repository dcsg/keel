# /keel:migrate

Converts dof or conductor projects to keel.

## Usage

```
/keel:migrate
```

## What Gets Migrated

| Old | New |
|-----|-----|
| `.dof/soul.md` or `.conductor/soul.md` | `docs/soul.md` |
| `.dof/config.yaml` | `.keel/config.yaml` (format updated) |
| `.dof/architecture/decisions/` | `docs/decisions/` |
| `.dof/architecture/invariants/` | converted to `.claude/rules/` custom topics |
| Old `CLAUDE.md` | regenerated from keel template |

After migration, keel runs the init logic to fill gaps — generating rules from your detected stack and creating any missing files.

## After Migration

Run `/keel:context` to verify everything loaded correctly, then `/keel:status` to see the full picture.
