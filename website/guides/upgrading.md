# Keeping Keel Up to Date

Keel has two layers that need updating separately: the **global templates** (installed on your machine) and the **project configuration** (committed in each repo).

## How versioning works

Every keel install writes its version to `~/.keel/VERSION`. Every project records its keel version in `.keel/config.yaml`:

```yaml
keel_version: "3.1"
```

`/keel:doctor` compares the two and warns when they differ:
```
[!!] project on keel 3.0, installed is 3.1 — run /keel:upgrade
```

`/keel:upgrade` reads both, shows a diff, applies changes, and bumps `keel_version` in your config when done.

## Update flow

### Step 1 — Update global templates

```bash
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

This takes ~10 seconds. Your commands, templates, and `~/.keel/VERSION` are now current.

### Step 2 — Upgrade each project

Open the project in Claude Code and run:

```
/keel:upgrade
```

Keel shows release notes first, then a diff of what will change:

```
WHAT'S NEW
─────────────────────────────────────────────────────
v3.1 — Stop hook JSON fix, hooks migrated to ~/.keel/hooks/ scripts
─────────────────────────────────────────────────────

Installed keel: 3.1
Project keel:   3.0

KEEL UPGRADE
─────────────────────────────────────────────────────
Hooks (.claude/settings.json)
  ⬆  SessionStart   — inline bash → script reference
  ⬆  Stop           — fix JSON validation error
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

You can apply everything, cancel, or choose sections. After applying, `keel_version` in `.keel/config.yaml` is bumped to match the installed version.

### Step 3 — Share with your team

```bash
git add .claude/ .keel/config.yaml && git commit -m "chore: upgrade keel to 3.1"
git push
```

Your team gets the upgrade on next pull. No manual steps needed on their end.

---

## What gets upgraded

**Hooks** — The most common reason to upgrade. New keel versions add hook capabilities or fix bugs (like the v3.1 Stop hook JSON fix). Old inline bash hooks get migrated to readable `~/.keel/hooks/*.sh` script references.

**Agent templates** — Specialist agents are periodically improved. Upgrades bring better prompts, new domain coverage, and more precise advice.

**Rule packs** — Rule packs are versioned. `/keel:upgrade` updates outdated ones (same as `/keel:rules-update`). Manually edited rule files are always skipped.

---

## What never gets overwritten

- Rule files without the `<!-- keel:generated -->` marker — you've customized these
- Agent files with no matching keel template — you created these
- Hooks you added yourself — keel only updates its own hook entries, never removes yours
- `.keel/config.yaml` — only `keel_version` is updated, everything else is preserved

---

## Checking if a project needs upgrading

```
/keel:doctor
```

Doctor now shows version status as the first check:
```
[!!] project on keel 3.0, installed is 3.1 — run /keel:upgrade
[!!] Stop hook outdated (JSON validation error) — run /keel:upgrade
[!!] go.md outdated (installed: 1.0, available: 1.2) — run /keel:upgrade
```

---

## Managing multiple projects

For teams with many repos, the upgrade pattern is:

1. One person runs the installer and upgrades each project
2. Commits `.claude/` and `.keel/config.yaml` changes to each repo
3. Team gets upgrades via normal git pull

Or document it in your team's runbook:
```
After keel installer updates: run /keel:upgrade in each active project.
```

There's no central push mechanism — keel stays offline-first and git-native.
