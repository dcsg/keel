# Migration from dof / conductor

Coming from dof or conductor? Run one command:

```
/keel:migrate
```

Keel detects your existing `.dof/` or `.conductor/` directory and handles the conversion automatically.

## What Gets Mapped

| Source | Destination |
|--------|-------------|
| `.dof/soul.md` | `docs/soul.md` |
| `.conductor/soul.md` | `docs/soul.md` |
| `.dof/config.yaml` | `.keel/config.yaml` |
| `.dof/architecture/decisions/` | `docs/decisions/` |
| `.dof/architecture/invariants/` | `.claude/rules/` (custom topics) |
| Old `CLAUDE.md` | regenerated from keel template |

After migration, keel fills in any gaps — generating rules from your detected stack and creating missing files.

## Manual Steps

Some things don't migrate automatically:

- **Design/component contracts** — review `.dof/design/components/` and move anything relevant to `docs/`
- **Custom commands** — old conductor commands won't work; use keel's 6 commands instead
- **Worktree config** — keel doesn't have worktree management; use git worktrees directly
