# Teams

Keel is designed to be committed — the whole team benefits automatically.

## Commit Everything

```bash
git add .claude/ .keel/ docs/soul.md docs/product/
git commit -m "chore: add keel context and guardrails"
```

Every teammate who opens the project in Claude Code now has:
- The same coding standards enforced automatically
- The same project context loaded at session start
- The same agents available (reviewer, debugger)

No per-developer setup. No drift between teammates.

## Onboarding New Teammates

New team member opens the project → Claude Code reads `.claude/CLAUDE.md` → context loads automatically. They're productive from the first session.

## Keeping Rules in Sync

When you update `.keel/config.yaml` (add a rule, change config), re-run `/keel:init` and commit the updated `.claude/rules/` files. The PR diff shows exactly what changed.

## Shared Plans

Plans in `docs/product/plans/` are committed and shared. Any teammate can run `/keel:status` and see exactly where things stand — what's done, what's in progress, what's next.
