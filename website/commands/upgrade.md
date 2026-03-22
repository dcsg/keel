# /keel:upgrade

Upgrade keel in this project — hooks, agents, and rule packs — to match the currently installed keel version.

## Usage

```
/keel:upgrade
```

## The problem it solves

When you install a new version of keel (`curl ... | bash`), your global templates are updated but existing projects are not. Each project has its own `.claude/settings.json` (hooks) and `.claude/agents/` (agent templates) that were generated at init time and don't update automatically.

`/keel:upgrade` bridges that gap. It compares what's installed in your project against the current templates and shows you exactly what would change — before touching anything.

## What it upgrades

**Hooks** (`.claude/settings.json`)
- SessionStart: add git-awareness — surfaces relevant agents based on what changed since last session
- PostToolUse: add auto-format hook (gofmt, prettier, black, rubocop, rustfmt)
- Stop: add doc gap and security signal detection
- PreCompact: add `/keel:session` reminder

**Agent templates** (`.claude/agents/`)
- Updates keel-managed agents to latest template versions
- Never touches agents marked with `<!-- keel:custom -->` in the file
- Never touches agents listed under `agents.custom` in `.keel/config.yaml`
- Never touches user-created agents (no matching keel template)

**Rule packs** (`.claude/rules/`)
- Updates outdated rule packs (same logic as `/keel:rules-update`)
- Never touches manually edited files (no `<!-- keel:generated -->` marker)
- Never touches custom rules not in the keel registry

## Safe by design

- **Shows a diff summary before applying** — you see exactly what changes
- **Asks for confirmation** — apply all, cancel, or select sections individually
- **Never overwrites customizations** — manually edited agents and rules are skipped
- **Never removes user-added hooks** — only updates keel-managed hook entries
- **Additive for missing hooks** — if PostToolUse is missing, it's added without touching the rest

## Protecting customized agents

Two mechanisms tell upgrade to skip an agent:

**File marker** — add `<!-- keel:custom -->` anywhere in the agent file:

```yaml
---
name: dba
description: "..."
<!-- keel:custom -->
tools:
  - Read
  - Grep
---
```

**Config** — list agents in `.keel/config.yaml`:

```yaml
agents:
  custom:
    - dba              # skip on upgrade
    - my-team-reviewer # not from keel templates
```

Config takes precedence over the file marker. Both protect the agent from upgrade.

## Output

```
KEEL UPGRADE
─────────────────────────────────────────────────────
Hooks (.claude/settings.json)
  ⬆  SessionStart   — add git-awareness
  ⬆  PostToolUse    — missing, will add auto-format hook
  ✓  PreToolUse     — up to date

Agents (.claude/agents/)
  ⬆  dba.md        — template updated
  ✓  architect.md  — up to date
  —  security.md   — custom, skipped

Rule packs (.claude/rules/)
  ⬆  go.md          1.0 → 1.2
  —  my-custom.md   — custom, skipped

─────────────────────────────────────────────────────
Apply these upgrades? (y/n/select)
```

## What's new

After every upgrade, keel shows the release notes for the new version — the relevant section from the changelog — so you know what changed without having to look it up:

```
WHAT'S NEW in 0.2.0
─────────────────────────────────────────────────────
{changelog content for this release}
─────────────────────────────────────────────────────
```

This appears whether or not actual changes were applied — if the project was already up to date, you still see the notes for the current version.

## Sharing upgrades with your team

After upgrading, commit the changes:

```bash
git add .claude/ && git commit -m "chore: upgrade keel to latest"
```

Your team gets the upgrade on next pull — no manual steps needed.

## Natural language triggers

- "upgrade keel"
- "update keel hooks"
- "my keel hooks are outdated"
- "update to latest keel"
