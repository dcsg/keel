# Plan: Keel v1 Implementation

## Overview
**Total Phases:** 7
**Approach:** Sequential (each phase builds on the previous)

## Phase Summary

| Phase | Task | Status |
|-------|------|--------|
| 1 | Clean slate — restructure repo for keel | Done |
| 2 | Rule templates — 16 rules + registry | Done |
| 3 | Test framework — bash harness, 113 tests | Done |
| 4 | Core commands — 6 keel commands | Done |
| 5 | Supporting templates — CLAUDE.md, agents, SDLC | Done |
| 6 | Distribution — install.sh + README storefront | Done |
| 7 | Dogfood — keel governs itself | Done |

---

## Phase 1: Clean Slate

**Objective:** Remove all old conductor/dof commands and restructure repo as keel.

**Tasks:**
1. Delete all 25 files in `commands/` (old conductor commands)
2. Rename `.conductor/` to `.keel/` (just config holder)
3. Restructure repo:
   ```
   keel/
   ├── commands/           # the 5 keel commands (phase 3)
   ├── templates/
   │   ├── rules/
   │   │   ├── _registry.yaml
   │   │   ├── base/
   │   │   ├── lang/
   │   │   └── framework/
   │   ├── agents/
   │   ├── sdlc/
   │   ├── soul.md.tmpl
   │   ├── product-spec.md.tmpl
   │   ├── prd.md.tmpl
   │   ├── CLAUDE.md.tmpl
   │   └── settings.json.tmpl
   ├── docs/
   │   ├── architecture/
   │   │   ├── decisions/
   │   │   └── invariants/
   │   └── plans/
   ├── install.sh
   ├── CLAUDE.md
   └── README.md
   ```
4. Update CLAUDE.md for keel identity
5. Update soul.md (already done)
6. Keep ADR-001 and INV-001 (already updated)

**Completion:** Repo is clean, structured, ready for content.

---

## Phase 2: Rule Templates

**Objective:** Write all rule template files — the core value of keel.

**Tasks:**

### 2.1 — Registry
Create `templates/rules/_registry.yaml` mapping every rule to its tier, template path, and `paths:` glob.

### 2.2 — Base rules (4 files)
- `templates/rules/base/code-quality.md` — Early returns, SOLID, DRY, naming (domain-specific, no utils/helpers), file/function size limits, separation of concerns, library-first approach
- `templates/rules/base/testing.md` — TDD red-green-refactor, test naming, mock anti-patterns, behavior-focused tests, coverage expectations
- `templates/rules/base/security.md` — Input validation at boundaries, parameterized queries, no secret logging, explicit auth checks, dependency awareness
- `templates/rules/base/error-handling.md` — Typed/structured errors, no silent catches, error context enrichment, validation at system boundaries

### 2.3 — Optional base (2 files)
- `templates/rules/base/frontend.md` — Component patterns, accessibility, state management, performance
- `templates/rules/base/architecture.md` — DDD bounded contexts, clean architecture layers, repository pattern, ubiquitous language, import restrictions by layer, domain events, value objects

### 2.4 — Language packs (4 files to start)
- `templates/rules/lang/go.md`
- `templates/rules/lang/typescript.md`
- `templates/rules/lang/python.md`
- `templates/rules/lang/php.md`

### 2.5 — Framework packs (6 files to start)
- `templates/rules/framework/chi.md`
- `templates/rules/framework/nextjs.md`
- `templates/rules/framework/laravel.md`
- `templates/rules/framework/symfony.md`
- `templates/rules/framework/rails.md`
- `templates/rules/framework/django.md`

**Completion:** All rule templates written and registered. These are the actual rule content files.

**Note:** Each rule file should follow the research insight — specific, enforceable, structural constraints. No aspirational fluff. Every line should change Claude's behavior.

---

## Phase 3: Test Framework

**Objective:** Build a bash test harness so every subsequent phase can be validated.

**Tasks:**

### 3.1 — Test runner
Create `test/run.sh` — discovers and runs all `test-*.sh` files, reports pass/fail with colors.

### 3.2 — Test helpers
Create `test/helpers.sh` with assertion functions:
- `assert_file_exists` — file must exist
- `assert_file_not_exists` — file must not exist
- `assert_file_contains` — file contains string/pattern
- `assert_file_starts_with` — check frontmatter headers
- `assert_valid_yaml` — YAML parses without error
- `assert_dir_structure` — given a list of expected paths, all exist
- `pass` / `fail` — test result output

### 3.3 — Template validation tests
- `test/test-registry.sh` — Every registry entry points to a real template file
- `test/test-templates.sh` — All templates have valid YAML frontmatter, no broken markdown links, `paths:` glob is present where required
- `test/test-rule-content.sh` — Rule files have no empty sections, every heading has content beneath it, no placeholder/TODO text left behind

### 3.4 — Install tests
- `test/test-install-global.sh` — Run install.sh in temp dir (global mode), verify files land in expected locations
- `test/test-install-project.sh` — Run install.sh in temp dir (project mode), verify files

### 3.5 — Init output tests (added after Phase 4)
- `test/test-init-greenfield.sh` — Init on empty git repo with fixture config → verify generated file tree
- `test/test-init-established.sh` — Init on fixture project (go.mod, package.json, etc.) → verify detected stack and generated rules

### 3.6 — Fixtures
```
test/fixtures/
├── greenfield/              # bare git repo
├── established-go/          # go.mod, cmd/, internal/, some .go files
├── established-ts/          # package.json, src/, tsconfig.json
└── established-fullstack/   # go.mod + package.json
```

**Completion:** `./test/run.sh` runs all tests. Green means templates, registry, and install are valid. New tests added as phases complete.

---

## Phase 4: Core Commands

**Objective:** Write the 5 keel slash commands.

### 4.1 — `/keel:init`
The big one. Intelligent onboarding:
1. Detect project age (git history, file count)
2. If greenfield: ask "what are you building?", infer architecture/rules/contexts
3. If established: run codebase audit (stack, structure, tests, CI), recommend rules
4. Show inferred selections with toggle UI
5. Generate: `.keel/config.yaml`, `.claude/rules/*`, `.claude/CLAUDE.md`, `.claude/settings.json`, `docs/soul.md`, SDLC files
6. Offer `/keel:intake` for established projects

### 4.2 — `/keel:context`
Load all project context into session:
1. Read `.keel/config.yaml` to know what exists
2. Read and summarize: soul.md, active product spec, active PRDs, active plan + progress
3. Output what was loaded (transparency)

### 4.3 — `/keel:plan`
Interview + phased execution plan:
1. Fetch ticket details if ticket ID provided
2. Interview for requirements (3-6 questions)
3. Load context
4. Analyze codebase for relevant files/patterns
5. Generate phased plan with: model assignment, dependencies, parallelism analysis, completion promises
6. Write plan to `docs/plans/` with progress table
7. Plan file IS the persistent state (compaction recovery)

### 4.4 — `/keel:status`
Dashboard showing:
1. Active plan + phase progress
2. Product spec roadmap status (if exists)
3. Rule packs installed + last updated
4. Governance health (are rules current? any manual edits detected?)

### 4.5 — `/keel:intake`
Onboard existing docs:
1. Scan for existing docs (README, wiki, docs/, existing ADRs, etc.)
2. Categorize: architecture decisions, business rules, product context, reference
3. Offer to organize into keel structure
4. Convert/copy to appropriate locations

### 4.6 — `/keel:migrate`
Migrate existing dof/conductor projects to keel:
1. Detect `.dof/` or `.conductor/` directory
2. Map old structure to new:
   - `.dof/soul.md` or `.conductor/soul.md` → `docs/soul.md`
   - `.dof/config.yaml` → `.keel/config.yaml` (rewrite format)
   - `.dof/architecture/invariants/*` → convert to `.claude/rules/` custom topics
   - `.dof/architecture/decisions/*` → `docs/decisions/` (optional, just move)
   - `.dof/design/components/*` → keep as-is or move to docs
   - Old `CLAUDE.md` / `.cursorrules` → regenerate from keel templates
3. Remove old directory after confirmation
4. Run init logic to fill gaps (generate rules from detected stack)
5. Output what was migrated and what's new

**Completion:** All 6 commands written and functional.

---

## Phase 5: Supporting Templates

**Objective:** Write templates for files keel generates during init.

**Tasks:**
- `templates/CLAUDE.md.tmpl` — Generated CLAUDE.md with: build/test/lint commands, context loading instructions, ADR-capture behavior, compaction recovery instructions
- `templates/soul.md.tmpl` — Soul file template seeded from user description
- `templates/product-spec.md.tmpl` — Product spec with Identity, Users, Features sections
- `templates/prd.md.tmpl` — PRD template
- `templates/settings.json.tmpl` — Hooks config (PreCompact for plan state saving)
- `templates/agents/reviewer.md` — Code review agent
- `templates/agents/debugger.md` — Debug agent
- `templates/sdlc/pull_request_template.md` — PR template
- `templates/sdlc/commit-convention.md` — Conventional commits reference

**Completion:** All templates ready for init to use.

---

## Phase 6: Distribution & Documentation

**Objective:** Make keel installable with one command and delightful to discover.

### 5.1 — Install script
Write `install.sh` — curl-friendly installer (~30 lines):
- Global mode: copies to `~/.claude/commands/`, templates to `~/.keel/templates/`
- Project mode: copies to `.claude/commands/`, templates to `.keel-templates/`

### 5.2 — README.md (the storefront)
This is how people decide whether to try keel. It needs to be excellent.

Structure:
1. **Hero** — One-sentence pitch + the problem in 3 lines
2. **Before/After** — Side-by-side showing Claude output without keel vs with keel (the "aha" moment)
3. **Install** — Single copy-paste line
4. **Quickstart** — 30-second flow: install → `keel:init` → describe project → done
5. **What You Get** — Visual tree of generated files with one-line descriptions
6. **Commands** — The 5 commands with example output (not just descriptions — show what the user sees)
7. **Rule Packs** — Table of all available packs with what each enforces
8. **How It Works** — Brief architecture: templates → config → generated rules → Claude reads them
9. **Extensibility** — Three levels (toggle, extend, create) with examples
10. **FAQ** — "Does it work with Cursor?" (partial), "Do I commit .claude/rules?" (yes), etc.

Tone: confident, concise, zero fluff. Show, don't tell. Every section earns its place.

### 5.3 — docs/ guides
- `docs/getting-started.md` — Expanded walkthrough with screenshots/examples
- `docs/rules.md` — Deep dive on the rules system, how to customize
- `docs/commands.md` — Full command reference with all options
- `docs/migration.md` — Coming from dof? Here's how to migrate.

**Completion:** Someone discovers keel on GitHub, understands what it does in 10 seconds, installs in 30 seconds, has it running in 2 minutes.

---

## Phase 7: Dogfood

**Objective:** Use keel on the keel repo itself.

**Tasks:**
1. Run `/keel:init` on this repo
2. Verify rules generate correctly
3. Verify context loads properly
4. Create a test plan with `/keel:plan`
5. Fix any issues found
6. Refine command wording and output based on experience

**Completion:** Keel governs its own development. Ship it.

---

## Execution Order

All phases are sequential — each builds on the previous:

```
Phase 1 (clean slate)
  → Phase 2 (rule templates)
    → Phase 3 (test framework)
      → Phase 4 (commands)
        → Phase 5 (supporting templates)
          → Phase 6 (distribution & docs)
            → Phase 7 (dogfood)
```

Phase 2 is the most content-heavy (16+ rule files). Phase 3 builds the safety net. Phase 4 is the most logic-heavy (init intelligence). The rest is straightforward.
