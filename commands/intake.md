---
name: keel:intake
description: "Onboard existing docs into keel's standard structure"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# keel:intake

Scan the project for existing documentation and organize it into keel's standard structure.

## Instructions

### 1. Verify Keel is Initialized

Check for `.keel/config.yaml`. If not found:
```
Run /keel:init first to set up the project structure.
```

Read config to get `base:` directory.

### 2. Scan for Existing Docs

Use an Agent to find documentation scattered across the project:

```
Agent(
  subagent_type: "Explore",
  prompt: """
  Find all documentation in this project. Look for:
  1. README files (README.md, readme.md at any level)
  2. docs/ or documentation/ directories
  3. Wiki content or markdown files outside src/
  4. Architecture docs (ADRs, decisions, RFCs)
  5. API documentation (OpenAPI/Swagger specs, API.md)
  6. Existing business rules or invariants docs
  7. Onboarding guides, contributing guides
  8. Product specs, PRDs, requirements docs
  9. Runbooks, playbooks, deployment docs
  10. .dof/ or .conductor/ content (legacy keel)

  For each file found, report:
  - Path
  - Type (architecture, product, reference, onboarding, api, etc.)
  - Brief summary of content (first 2-3 lines)

  Do NOT include: source code files, test files, generated docs, node_modules, vendor.
  """,
  description: "Scan for existing docs"
)
```

### 3. Categorize and Propose

Organize found docs into keel categories:

```
Found {n} documentation files:

  Architecture / Decisions:
    docs/adr/001-use-postgres.md     → {base}/decisions/001-use-postgres.md
    .dof/architecture/decisions/*.md → {base}/decisions/

  Invariants:
    .dof/architecture/invariants/*.md → {base}/invariants/

  Product / Requirements:
    docs/product-spec.md             → {base}/product/spec.md
    docs/requirements/feature-x.md   → {base}/product/prds/feature-x.md

  Reference:
    docs/api.md                      → {base}/reference/api.md
    docs/deployment.md               → {base}/reference/deployment.md
    CONTRIBUTING.md                   → {base}/reference/contributing.md

  Already in place:
    README.md                        → (keep as-is)

  Skip (not documentation):
    {list any files to skip}

Proceed with this organization? (y/n/edit)
```

### 4. Consolidate Execution Plans

After categorization, check if any files look like execution plans — files containing phases, milestones, roadmaps, checklists, progress tracking, build order, or prioritization.

If plan-related files are found:

```
EXECUTION PLANS DETECTED
────────────────────────
Found {n} plan-related docs:
  - build-order.md (build sequence with phases)
  - progress.md (status tracking)
  - refactor-checklist.md (task list with milestones)

These could consolidate into a single PLAN-001-{slug}.md with a phases table.

Options:
  [c] Consolidate into PLAN-001-{slug}.md (preserves all content as phases)
  [s] Keep separate — copy as-is to {base}/plans/
  [k] Skip — don't move plan files
```

**If consolidating:**
1. Read all plan-related files to extract phases, tasks, and milestones
2. Generate a `PLAN-001-{slug}.md` following keel's plan format:
   ```markdown
   # Plan: {Title derived from content}

   ## Overview
   **Total Phases:** {n}
   **Approach:** {derived from source docs}

   ## Progress

   | Phase | Status | Updated |
   |-------|--------|---------|
   | 1     | -      | -       |

   ## Phase 1: {Title}

   **Objective:** {extracted from source docs}

   **Tasks:**
   {consolidated task list}

   **Completion promise:** `{PHASE TITLE DONE}`
   ```
3. Save to `{base}/plans/PLAN-001-{slug}.md`
4. Track original plan files for the archive step

**If keeping separate:** copy files as-is to `{base}/plans/`.

### 5. Execute Moves

For each confirmed move:

1. Create target directory if needed: `mkdir -p {base}/{category}/`
2. Copy (not move) the file to its new location: `cp source target`
3. If the source is in a legacy directory (`.dof/`, `.conductor/`), note it for cleanup

**Important:** COPY, don't move. The user can delete originals after verifying. Never delete files without explicit confirmation.

### 6. Update Soul

If existing docs reveal project context not captured in `soul.md`, offer to update it:

```
Found additional context from existing docs:
- Stack: {details from README}
- Architecture: {details from ADRs}
- Users: {details from product docs}

Update soul.md with this information? (y/n)
```

### 7. Convert Legacy Content

If `.dof/` or `.conductor/` content was found:

- **Soul files**: merge into `{base}/soul.md`
- **ADRs/decisions**: copy to `{base}/decisions/`
- **Invariants**: copy to `{base}/invariants/`. If an invariant directly constrains code behavior, add a one-line reference in the relevant `.claude/rules/` file pointing to it.
- **Component contracts**: copy to `{base}/reference/`
- **Config**: note differences from current `.keel/config.yaml`

### 8. Output Summary

```
Intake complete!

  Organized: {n} files
  Copied to:
    {base}/decisions/     — {count} decision records
    {base}/invariants/    — {count} invariants
    {base}/plans/         — {count} plans {(consolidated) if applicable}
    {base}/product/prds/  — {count} product requirements
    {base}/reference/     — {count} reference docs

  Soul updated: {yes/no}
```

### 9. Archive Originals

After displaying the summary, offer cleanup for all copied files:

```
CLEANUP
───────
{n} original files were copied to new locations.

Options:
  [a] Archive originals to {base}/archive/ (removes from active, preserves history)
  [d] Delete originals (destructive — will confirm each file)
  [k] Keep both (default — safe, creates duplication)
```

**If archiving:**
1. `mkdir -p {base}/archive/`
2. Move each original to `{base}/archive/`, preserving relative paths
3. If legacy directories (`.dof/`, `.conductor/`) are now empty after archiving, note them for removal

**If deleting:**
1. List each file and ask for confirmation: `Delete {path}? (y/n)`
2. Only delete files the user confirms

**If keeping:** no action needed.

After cleanup:

```
  Legacy directories found:
    {.dof/ or .conductor/ — can be removed after verifying migration}

  Next: Review the organized docs and run /keel:context to load everything.
```
