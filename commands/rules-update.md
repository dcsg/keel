---
name: keel:rules-update
description: "Check for outdated rule packs and update them"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# keel:rules-update

Compare installed rule packs against keel's templates and offer to update stale ones.

## Instructions

### 1. Load Config

Read `.keel/config.yaml`. If not found:
```
No keel config found. Run /keel:init to set up this project.
```

### 2. Find Keel Templates

Locate keel's rule templates (either `~/.keel/templates/rules/` for global install, or the keel repo location). Also read `_registry.yaml` from the same directory.

If templates are not found:
```
Keel templates not found. Install keel globally or provide the path.
```

### 3. Compare Versions

If `.claude/rules/` does not exist or contains no `.md` files:
```
No rule packs installed. Run /keel:init to set up rules for this project.
```
Stop.

For each `.claude/rules/*.md` file:

1. Read the installed file's YAML frontmatter to get `version:`
2. Check for `<!-- keel:generated -->` marker
3. Check if a project override exists at `.keel/rules/{name}.md` — if yes, this pack is overridden (skip)
4. Check if the config has an `extend:` for this pack under `rules.{name}.extend` — note for later
5. Look up the pack name (filename without `.md`) in the registry
6. Categorize:
   - **Overridden:** `.keel/rules/{name}.md` exists (project owns this pack — skip)
   - **Outdated:** installed version < registry version
   - **Up to date:** installed version == registry version
   - **Manually edited:** no `keel:generated` marker (skip by default)
   - **No version:** file has no `version:` frontmatter (predates versioning)
   - **Custom:** pack name not in registry (user-created, skip)
   - **Extended:** config has `extend:` — base pack updates normally, extension file is untouched

### 4. Display Summary

```
Rule Pack Status
────────────────
  code-quality.md   1.0.0 → 1.1.0   (outdated)
  testing.md        1.0.0 = 1.0.0   (up to date)
  go.md             1.0.0 → 1.2.0   (outdated)
  chi.md            —     → 1.0.0   (no version — predates versioning)
  security.md       [manually edited — skipped]
  my-custom.md      [custom rule — skipped]

2 outdated, 1 unversioned, 1 up to date, 2 skipped
```

If everything is up to date:
```
All rule packs are up to date.
```

### 5. Offer Update

If there are outdated or unversioned packs:

```
Update options:
  [a] Update all outdated packs (2 files)
  [s] Select which packs to update
  [k] Skip — no changes
```

**If updating:**

For each pack to update:
1. Read the current installed file
2. Read the new template
3. Show a brief diff summary: what sections changed (added/removed/modified headings)
4. Replace the installed file with the new template content

**Manually edited files** (no `keel:generated` marker) are always skipped unless the user explicitly asks to include them:
```
security.md was manually edited. Update anyway? This will overwrite your customizations. (y/n)
```

### 6. Output Results

```
Updated:
  code-quality.md   1.0.0 → 1.1.0
  go.md             1.0.0 → 1.2.0

Skipped:
  security.md       (manually edited)

Run /keel:doctor to verify governance health.
```
