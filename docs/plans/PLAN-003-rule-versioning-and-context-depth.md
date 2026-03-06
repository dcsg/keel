# Plan: Rule Versioning and Context Depth

## Overview
**Total Phases:** 4
**Approach:** Sequential — versioning infra first, then the update command, then context depth

Rule packs are installed once and never updated. Context loads everything
regardless of project size. This plan adds version tracking to rule packs and
depth control to keel:context.

## Phase Summary

| Phase | Task | Status | Effort |
|-------|------|--------|--------|
| 1 | Add version frontmatter to all rule templates | Done | Low |
| 2 | Add version to registry + keel:init stamps version on install | Done | Low |
| 3 | keel:doctor warns on stale packs + keel:rules-update command | Done | Medium |
| 4 | keel:context depth control | Done | Medium |

---

## Phase 1: Version Frontmatter in Rule Templates

**Objective:** Every rule template declares its version so installed copies can be
compared against source.

**Tasks:**
1. Add `version:` to the YAML frontmatter of all 16 rule templates:
   ```yaml
   ---
   paths: "**/*"
   version: "1.0.0"
   ---
   <!-- keel:generated -->
   ```
2. Use semver: `1.0.0` as the starting version for all existing templates
3. Update the test suite to validate that every rule template has a `version:` field

**Completion promise:** All 16 templates have `version:` frontmatter. Tests validate it.

---

## Phase 2: Registry Version + Init Stamps Version

**Objective:** The registry tracks the current version per pack, and `keel:init`
stamps the version into installed rule files.

**Tasks:**
1. Add `version:` field to each entry in `templates/rules/_registry.yaml`:
   ```yaml
   code-quality:
     tier: base
     template: base/code-quality.md
     paths: "**/*"
     version: "1.0.0"
     default: true
   ```
2. Update `commands/init.md` step 5.4 to note: when copying a template to
   `.claude/rules/`, the version frontmatter is preserved from the template.
   This is already the case (full file copy), but make it explicit in the
   instructions so future edits don't strip it.
3. Update test suite: registry test should verify every entry has a `version:`
   field matching its template's frontmatter version.

**Completion promise:** Registry has version per entry. Init preserves version on install.
Tests validate version consistency between registry and templates.

---

## Phase 3: Stale Pack Detection + keel:rules-update

**Objective:** `keel:doctor` warns when installed packs are outdated.
New `keel:rules-update` command refreshes stale packs.

**Tasks:**

### 3a: Doctor stale detection
1. In `commands/doctor.md`, enhance the Rules check:
   - For each `.claude/rules/*.md` file, read its `version:` frontmatter
   - Compare against the registry version for that pack name
   - If installed version < registry version: `[!!] {pack} outdated (installed: 1.0.0, available: 1.1.0)`
   - If no version in installed file: `[!!] {pack} has no version — may predate versioning`
   - If file has no `keel:generated` marker: skip version check (manually edited)

### 3b: keel:rules-update command
2. Create `commands/rules-update.md`:
   - List all installed packs with version comparison
   - Show diff summary for each outdated pack (what changed)
   - Offer to update: all, selective, or skip
   - For manually edited packs (no `keel:generated` marker), warn and skip by default
   - After update, show what was refreshed

   ```
   Rule Pack Updates
   ─────────────────
   code-quality.md   1.0.0 → 1.1.0  (new: extract-method size threshold)
   go.md             1.0.0 → 1.0.0  (up to date)
   chi.md            1.0.0 → 1.2.0  (new: middleware ordering rules)
   testing.md        —     → 1.0.0  (no version — predates versioning)
   security.md       [manually edited — skipped]

   Update? (all / select / skip)
   ```

**Completion promise:** Doctor warns on stale packs. `keel:rules-update` refreshes them.

---

## Phase 4: Context Depth Control

**Objective:** `keel:context` supports depth levels so large projects don't overwhelm
the context window.

**Tasks:**
1. Add `argument-hint:` to `commands/context.md` frontmatter:
   ```yaml
   argument-hint: "[--depth=full|focused|minimal]"
   ```

2. Define three depth levels:

   **`--depth=full`** (default, current behavior):
   - Soul + all decisions + all invariants + all rules + product + plans + PRDs

   **`--depth=focused`**:
   - Soul (always)
   - Active plan — current phase only (not all phases)
   - Relevant decisions — match by:
     - Current git branch name (e.g., branch `feat/auth` matches ADR with "auth" in title)
     - Active plan phase title keywords
     - If no matches, load the 5 most recent ADRs
   - All invariants (always — they're hard constraints)
   - Rules (just list names, don't re-read — they're in `.claude/rules/` already)

   **`--depth=minimal`**:
   - Soul (always)
   - Active plan — current phase title + tasks only
   - Invariants (always)
   - Skip decisions, product, PRDs, rules listing

3. Add auto-detection: if no `--depth` flag is provided and the project has
   more than 15 ADRs or more than 5 PRDs, suggest focused mode:
   ```
   Note: This project has 30 ADRs and 9 PRDs. Consider --depth=focused
   to reduce context size. Using --depth=full (default).
   ```

4. Update the output summary to show which depth was used:
   ```
   Context loaded for: {project name} (depth: focused)
   ```

**Completion promise:** `keel:context` supports three depth levels with auto-detection hint.

---

## Notes

- Phase 1-2 are low-risk additive changes (adding frontmatter, no behavior change)
- Phase 3 introduces a new command — follow the pattern of existing commands
- Phase 4 modifies keel:context behavior — default remains `full` for backwards compat
