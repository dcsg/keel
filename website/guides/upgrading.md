# Keeping Keel Up to Date

Keel has two layers that need updating separately: the **global templates** (installed on your machine) and the **project configuration** (committed in each repo).

## How updates work

When you run the keel installer, it updates your global templates at `~/.keel/templates/` and your commands at `~/.claude/commands/keel/`. But existing projects keep their own `.claude/settings.json` and `.claude/agents/` — those don't update automatically.

This is intentional: your project config is committed to git and shared with your team. An auto-update would surprise people.

## Update flow

### Step 1 — Update global templates

```bash
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

This takes ~10 seconds. Your commands and templates are now current.

### Step 2 — Upgrade each project

Open the project in Claude Code and run:

```
/keel:upgrade
```

Keel compares what's in the project against the current templates and shows you a diff before touching anything:

```
KEEL UPGRADE
─────────────────────────────────────────────────────
Hooks (.claude/settings.json)
  ⬆  SessionStart   — add git-awareness
  ⬆  PostToolUse    — missing, will add auto-format hook
  ⬆  Stop           — add doc gap + security signals
  ✓  PreToolUse     — up to date

Agents (.claude/agents/)
  ⬆  principal-dba.md   — template updated
  ✓  principal-architect.md — up to date

Rule packs (.claude/rules/)
  ⬆  go.md          1.0 → 1.2
  —  my-custom.md   — custom, skipped

─────────────────────────────────────────────────────
Apply these upgrades? (y/n/select)
```

You can apply everything, cancel, or choose sections. Customizations are never overwritten.

### Step 3 — Share with your team

```bash
git add .claude/ && git commit -m "chore: upgrade keel to latest"
git push
```

Your team gets the upgrade on next pull. No manual steps needed on their end.

---

## What gets upgraded

**Hooks** — The most common reason to upgrade. New keel versions add hook capabilities (git-aware session start, PostToolUse auto-format, security signals) that older projects don't have.

**Agent templates** — Specialist agents are periodically improved. Upgrades bring better prompts, new domain coverage, and more precise advice.

**Rule packs** — Rule packs are versioned. `/keel:upgrade` updates outdated ones (same as `/keel:rules-update`). Manually edited rule files are always skipped.

---

## What never gets overwritten

- Rule files without the `<!-- keel:generated -->` marker — you've customized these
- Agent files with no matching keel template — you created these
- Hooks you added yourself — keel only updates its own hook entries, never removes yours
- `.keel/config.yaml` — your project configuration is always preserved

---

## Checking if a project needs upgrading

```
/keel:doctor
```

Doctor flags outdated hooks:
```
[!!] SessionStart hook outdated — run /keel:upgrade to update hooks
[!!] go.md outdated (installed: 1.0, available: 1.2) — run /keel:upgrade
```

---

## Managing multiple projects

For teams with many repos, the upgrade pattern is:

1. One person runs the installer and upgrades each project
2. Commits the `.claude/` changes to each repo
3. Team gets upgrades via normal git pull

Or document it in your team's runbook:
```
After keel installer updates: run /keel:upgrade in each active project.
```

There's no central push mechanism — keel stays offline-first and git-native.
