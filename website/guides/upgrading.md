# Keeping Keel Up to Date

Keel has two layers that need updating separately: the **global templates** (installed on your machine) and the **project configuration** (committed in each repo).

## How versioning works

Every keel install writes its version to `~/.keel/VERSION`. Every project records its keel version in `.keel/config.yaml`:

```yaml
keel_version: "0.1.0"
```

`/keel:doctor` compares the two and warns when they differ:
```
[!!] project on keel 0.1.0, installed is 0.2.0 — run /keel:upgrade
```

`/keel:upgrade` reads both, shows a diff, applies changes, and bumps `keel_version` in your config when done.

## Update flow

### Step 1 — Update global templates

```bash
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

This takes ~10 seconds. Your commands, templates, and `~/.keel/VERSION` are now current.

### Step 2 — Upgrade each project

Open the project in Claude Code and say:

> "Upgrade keel"

Keel shows release notes first, then a diff of what will change:

```
WHAT'S NEW
─────────────────────────────────────────────────────
v0.2.0 — New agents, rule pack updates, hook improvements
─────────────────────────────────────────────────────

Installed keel: 0.2.0
Project keel:   0.1.0

KEEL UPGRADE
─────────────────────────────────────────────────────
Hooks (.claude/settings.json)
  ⬆  SessionStart   — updated
  ✓  PostToolUse    — up to date

Agents (.claude/agents/)
  ⬆  dba.md         — template updated
  ✓  architect.md   — up to date
  —  my-reviewer.md — custom, skipped

Rule packs (.claude/rules/)
  ⬆  go.md          1.0.0 → 0.1.0
  ✓  testing.md     — up to date
  —  my-custom.md   — custom, skipped

─────────────────────────────────────────────────────
Apply these upgrades? (y/n/select)
```

You can apply everything, cancel, or choose sections. After applying, `keel_version` in `.keel/config.yaml` is bumped to match.

### Step 3 — Share with your team

```bash
git add .claude/ .keel/config.yaml && git commit -m "chore: upgrade keel to 0.2.0"
git push
```

Your team gets the upgrade on next pull.

---

## Protecting customizations

**Agents** — Add `<!-- keel:custom -->` to any agent file to skip it during upgrade. Or list custom agents in config:

```yaml
agents:
  custom:
    - dba              # team has customized
    - my-team-reviewer # not from keel templates
```

**Rules** — Files without the `<!-- keel:generated -->` marker are always skipped. Files with an `extend:` config keep the extension untouched while the base pack updates.

**Hooks** — keel only updates its own hook entries. Hooks you added yourself are never removed.

**Config** — Only `keel_version` is updated. Everything else is preserved.

---

## What gets upgraded

**Hooks** — New keel versions add hook capabilities or fix bugs. Old inline bash hooks get migrated to `~/.keel/hooks/*.sh` script references.

**Agent templates** — Specialist agents are periodically improved with better prompts and domain coverage.

**Rule packs** — Rule packs are versioned. Outdated packs are updated. Manually edited files are always skipped.

---

## Checking if a project needs upgrading

> "What's our status?"

Or directly:

> "Run doctor"

Doctor shows version status:
```
[!!] project on keel 0.1.0, installed is 0.2.0 — run /keel:upgrade
[!!] go.md outdated (installed: 1.0.0, available: 0.1.0) — run /keel:upgrade
```

---

## Managing multiple projects

For teams with many repos:

1. One person runs the installer
2. Upgrades each project: "upgrade keel"
3. Commits and pushes

There's no central push mechanism — keel stays offline-first and git-native.
