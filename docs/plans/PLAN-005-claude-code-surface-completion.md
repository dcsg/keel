# Plan: Claude Code Surface Completion

## Overview
**Task:** Close the remaining Claude Code feature gaps identified in the audit
**Total Phases:** 4
**Estimated Cost:** ~$4–8
**Created:** 2026-03-08

## Progress

| Phase | Status | Updated |
|-------|--------|---------|
| 1     | done   | 2026-03-08 |
| 2     | done   | 2026-03-08 |
| 3     | done   | 2026-03-08 |
| 4     | done   | 2026-03-08 |

**IMPORTANT:** Update this table as phases complete. This table is the persistent state that survives context compaction.

## Context

Audit findings (all confirmed against codebase):

- `templates/settings.json.tmpl` has 4 hooks (SessionStart, PreToolUse, Stop, PreCompact) — **zero PostToolUse**
- `commands/adr.md`, `commands/invariant.md`, `commands/prd.md` all use manual "ls + count" guidance for artifact numbering — **zero shell preprocessing**
- `commands/doctor.md`, `commands/status.md` have read-only tool declarations but **no `context: fork`**
- `commands/docs.md` has **no YAML frontmatter at all** (structural bug)
- `commands/sync.md` does not exist; linter-aware rule generation is unimplemented

## Model Assignment

| Phase | Task | Model | Reasoning | Est. Cost |
|-------|------|-------|-----------|-----------|
| 1 | PostToolUse auto-format hook | Haiku | Template edit + formatter detection logic | ~$0.50 |
| 2 | Shell preprocessing in artifact commands | Haiku | Simple frontmatter + injection additions | ~$0.50 |
| 3 | `context: fork` + docs.md frontmatter fix | Haiku | Frontmatter additions only | ~$0.25 |
| 4 | `keel:sync` — linter-aware rule generation | Sonnet | New command with translation logic | ~$3.00 |

## Execution Strategy

| Phase | Depends On | Parallel With |
|-------|-----------|---------------|
| 1     | None      | 2, 3          |
| 2     | None      | 1, 3          |
| 3     | None      | 1, 2          |
| 4     | 1, 2, 3   | -             |

Phases 1, 2, 3 are independent and can run in parallel. Phase 4 depends on all three completing.

---

## Phase 1: PostToolUse Auto-Format Hook

**Objective:** After every Claude edit to a source file, automatically run the project's formatter so code is always clean without a manual step.
**Model:** `claude-haiku-4-5-20251001`
**Max Iterations:** 3
**Completion Promise:** `PHASE 1 COMPLETE`
**Dependencies:** None

**Prompt:**

Add a `PostToolUse` hook to `templates/settings.json.tmpl` that auto-formats source files after edits.

### What to implement

Add a new `PostToolUse` entry in `.claude/settings.json.tmpl` with a `Write|Edit` matcher. The hook command must:

1. **Check disable flags first:**
   ```bash
   if [ "${KEEL_FORMAT_SKIP:-0}" = "1" ]; then exit 0; fi
   if grep -q "post-tool-use: false" .keel/config.yaml 2>/dev/null; then exit 0; fi
   ```

2. **Get the file path** from the tool input. In PostToolUse hooks, the file path is available as `$CLAUDE_TOOL_INPUT_FILE_PATH` (for Write) or `$CLAUDE_TOOL_INPUT_PATH` (for Edit).

3. **Skip non-source files** — only format when extension is in: `.go`, `.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.rb`, `.php`, `.rs`, `.java`, `.swift`, `.kt`

4. **Detect and run formatter** based on file extension:
   - `.go` → `gofmt -w "$FILE"` (if `gofmt` found in PATH)
   - `.ts`, `.tsx`, `.js`, `.jsx` → `npx prettier --write "$FILE"` (if `prettier` found or `node_modules/.bin/prettier` exists)
   - `.py` → `black "$FILE"` (if `black` found in PATH), else `ruff format "$FILE"` (if `ruff` found)
   - `.rb` → `rubocop -A "$FILE"` (if `rubocop` found)
   - `.php` → `php-cs-fixer fix "$FILE"` (if `php-cs-fixer` found)
   - `.rs` → `rustfmt "$FILE"` (if `rustfmt` found)

5. **Silent on failure** — if no formatter detected, exit 0 quietly. Never block or error.

### Exact location in settings.json.tmpl

Add the PostToolUse entry AFTER the PreToolUse block and BEFORE the Stop block:

```json
"PostToolUse": [
  {
    "matcher": "Write|Edit",
    "hooks": [
      {
        "type": "command",
        "command": "<the full command>"
      }
    ]
  }
]
```

The full command should be a single-line bash string (escape inner quotes with \"). Here is the logic written out:

```bash
if [ "${KEEL_FORMAT_SKIP:-0}" = "1" ]; then exit 0; fi
if [ ! -f ".keel/config.yaml" ]; then exit 0; fi
if grep -q "post-tool-use: false" .keel/config.yaml 2>/dev/null; then exit 0; fi
FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-${CLAUDE_TOOL_INPUT_PATH:-}}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then exit 0; fi
EXT="${FILE##*.}"
case "$EXT" in
  go) command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE" ;;
  ts|tsx|js|jsx) if [ -f "node_modules/.bin/prettier" ]; then node_modules/.bin/prettier --write "$FILE" 2>/dev/null; elif command -v prettier >/dev/null 2>&1; then prettier --write "$FILE" 2>/dev/null; fi ;;
  py) if command -v black >/dev/null 2>&1; then black "$FILE" 2>/dev/null; elif command -v ruff >/dev/null 2>&1; then ruff format "$FILE" 2>/dev/null; fi ;;
  rb) command -v rubocop >/dev/null 2>&1 && rubocop -A "$FILE" 2>/dev/null ;;
  php) command -v php-cs-fixer >/dev/null 2>&1 && php-cs-fixer fix "$FILE" 2>/dev/null ;;
  rs) command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE" 2>/dev/null ;;
esac
exit 0
```

### Also update

- `commands/init.md` section 5.5 — add PostToolUse to the list of hooks generated and their descriptions
- `commands/doctor.md` — add a check: "Is PostToolUse hook present in `.claude/settings.json`?"
- `test/test-hooks.sh` — add assertions: PostToolUse hook present, has Write|Edit matcher, has disable guard for KEEL_FORMAT_SKIP
- `test/test-structure.sh` — add: `assert_file_contains "$PROJECT_ROOT/templates/settings.json.tmpl" "PostToolUse"`

When complete, output: PHASE 1 COMPLETE

---

## Phase 2: Shell Preprocessing for Artifact Numbering

**Objective:** Inject the correct next artifact number into `/keel:adr`, `/keel:invariant`, `/keel:prd`, and `/keel:plan` so Claude never guesses wrong.
**Model:** `claude-haiku-4-5-20251001`
**Max Iterations:** 3
**Completion Promise:** `PHASE 2 COMPLETE`
**Dependencies:** None

**Prompt:**

Add shell preprocessing (`` !`command` `` syntax) to four command files so that live project state is injected before Claude processes the command.

### What shell preprocessing does

In Claude Code, slash command frontmatter can declare:

```yaml
---
allowed-tools: [...]
---
!`shell command here`
# rest of the command file
```

The output of the shell command is prepended to the prompt Claude sees. This happens before Claude reads the file body.

### Changes required

#### `commands/adr.md`

Add after the existing frontmatter block, before the `# /keel:adr` heading:

```
!`BASE=$(grep "^base:" .keel/config.yaml 2>/dev/null | awk '{print $2}' || echo "docs"); COUNT=$(ls "${BASE}/decisions/"*.md 2>/dev/null | wc -l | tr -d ' '); printf "<!-- keel:live -->\nNext ADR number: %03d\nExisting ADRs: %s\n<!-- /keel:live -->" "$((COUNT + 1))" "$(ls ${BASE}/decisions/*.md 2>/dev/null | xargs -I{} basename {} .md | sort | tr '\n' ', ' | sed 's/,$//')"`
```

Also update the instruction text in `commands/adr.md` that currently says "Note the highest existing number" — change it to say "The correct next ADR number is provided at the top of this prompt in the `<!-- keel:live -->` block. Use it exactly."

#### `commands/invariant.md`

Same pattern for invariants:

```
!`BASE=$(grep "^base:" .keel/config.yaml 2>/dev/null | awk '{print $2}' || echo "docs"); COUNT=$(ls "${BASE}/invariants/"*.md 2>/dev/null | wc -l | tr -d ' '); printf "<!-- keel:live -->\nNext INV number: %03d\nExisting invariants: %s\n<!-- /keel:live -->" "$((COUNT + 1))" "$(ls ${BASE}/invariants/*.md 2>/dev/null | xargs -I{} basename {} .md | sort | tr '\n' ', ' | sed 's/,$//')"`
```

Update the manual counting instruction similarly.

#### `commands/prd.md`

Same pattern for PRDs:

```
!`BASE=$(grep "^base:" .keel/config.yaml 2>/dev/null | awk '{print $2}' || echo "docs"); COUNT=$(ls "${BASE}/product/prds/"*.md 2>/dev/null | wc -l | tr -d ' '); printf "<!-- keel:live -->\nNext PRD number: %03d\nExisting PRDs: %s\n<!-- /keel:live -->" "$((COUNT + 1))" "$(ls ${BASE}/product/prds/*.md 2>/dev/null | xargs -I{} basename {} .md | sort | tr '\n' ', ' | sed 's/,$//')"`
```

#### `commands/plan.md`

Inject current active plan state:

```
!`PLAN=$(ls -t docs/product/plans/*.md docs/plans/*.md 2>/dev/null | head -1); if [ -n "$PLAN" ]; then NAME=$(basename "$PLAN"); PHASE=$(grep -A1 "in.progress\|In Progress\|in_progress" "$PLAN" 2>/dev/null | head -1); printf "<!-- keel:live -->\nActive plan: %s\nCurrent phase: %s\n<!-- /keel:live -->" "$NAME" "${PHASE:-(none in progress)}"; fi`
```

### Placement rule

The `` !`command` `` line must be placed AFTER the YAML frontmatter block (after the closing `---`) and BEFORE the `#` heading. Example:

```
---
name: keel:adr
allowed-tools: [...]
---
!`...shell command...`

# /keel:adr
...
```

### Also update

- `test/test-structure.sh` — add assertions that each of the four command files contains the `!`` ` `` preprocessing marker

When complete, output: PHASE 2 COMPLETE

---

## Phase 3: `context: fork` on Read-Only Commands + Fix docs.md Frontmatter

**Objective:** Isolate diagnostic commands from the main session context; fix the missing frontmatter in docs.md.
**Model:** `claude-haiku-4-5-20251001`
**Max Iterations:** 2
**Completion Promise:** `PHASE 3 COMPLETE`
**Dependencies:** None

**Prompt:**

Two tasks:

### Task A: Add `context: fork` to read-only commands

The `context: fork` frontmatter key tells Claude Code to run the command in an isolated subagent. The result is returned to the user but doesn't pollute the main session context.

Add `context: fork` to the frontmatter of these three commands:

**`commands/doctor.md`** — change frontmatter from:
```yaml
---
name: keel:doctor
description: "Validate governance setup and report actionable warnings"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---
```
to:
```yaml
---
name: keel:doctor
description: "Validate governance setup and report actionable warnings"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---
```

**`commands/status.md`** — same pattern, add `context: fork` to existing frontmatter.

**`commands/docs.md`** — this file currently has NO frontmatter (structural bug found in audit). Add full frontmatter:
```yaml
---
name: keel:docs
description: "Audit documentation gaps — find what changed in code but wasn't reflected in docs"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---
```

### Task B: Verify which commands should NOT get context: fork

Do NOT add `context: fork` to:
- `keel:init` — writes many files
- `keel:context` — writes to auto-memory
- `keel:adr`, `keel:invariant`, `keel:prd` — write artifact files
- `keel:plan` — writes plan file
- `keel:agents`, `keel:mcp`, `keel:team` — may write config files
- `keel:intake` — writes and moves files

### Also update

- `test/test-structure.sh` — add assertions:
  - `doctor.md` contains `context: fork`
  - `status.md` contains `context: fork`
  - `docs.md` contains `context: fork`
  - `docs.md` contains YAML frontmatter (name field)

When complete, output: PHASE 3 COMPLETE

---

## Phase 4: `keel:sync` — Linter-Aware Rule Generation

**Objective:** Implement the linter config → AI rules translation as a new `keel:sync` command, and wire it into `keel:init` for brownfield projects.
**Model:** `claude-sonnet-4-6`
**Max Iterations:** 5
**Completion Promise:** `PHASE 4 COMPLETE`
**Dependencies:** 1, 2, 3

**Prompt:**

Create `commands/sync.md` implementing linter-aware AI rule generation. This is the most complex phase — read `docs/product/prds/PRD-linter-aware-rules.md` before starting.

### What keel:sync does

Scans the project for linter config files, translates their rules into natural-language AI rules scoped by path, and writes them to `.claude/rules/`. The linter config is the source of truth; AI rules are a projection of it.

### Linter configs to support

| Linter | Config file(s) | Language |
|--------|---------------|----------|
| golangci-lint | `.golangci-lint.yaml`, `.golangci.yaml` | Go |
| ESLint | `.eslintrc`, `.eslintrc.js`, `.eslintrc.json`, `.eslintrc.yaml`, `eslint.config.js`, `eslint.config.mjs` | JS/TS |
| Ruff | `ruff.toml`, `pyproject.toml` (under `[tool.ruff]`) | Python |
| PHP CS Fixer | `.php-cs-fixer.php`, `.php-cs-fixer.dist.php` | PHP |
| RuboCop | `.rubocop.yml`, `.rubocop.yaml` | Ruby |
| Prettier | `.prettierrc`, `.prettierrc.json`, `.prettierrc.yaml`, `prettier.config.js` | JS/TS formatting |
| Biome | `biome.json` | JS/TS |

### Translation approach

For each detected linter config:

1. Read the config file
2. Identify the active rules and their settings
3. Translate to natural language — focus on rules that affect code structure/logic, skip pure formatting rules (those are handled by PostToolUse formatter)
4. Write to `.claude/rules/linter-{name}.md` with appropriate `paths:` frontmatter

**Translation examples:**

golangci-lint with `gomnd` enabled:
```markdown
---
paths: "**/*.go"
version: "1.0.0"
source: linter
linter: golangci-lint
---
<!-- keel:generated -->
# Go Linter Rules (golangci-lint)

- Extract numeric literals to named constants — avoid magic numbers (0, 1, 2 are acceptable)
```

golangci-lint with `cyclop` at max-complexity 10:
```markdown
- Keep function cyclomatic complexity under 10 — if a function is complex, split it
```

ESLint with `no-console`:
```markdown
---
paths: "**/*.{ts,tsx,js,jsx}"
---
- Do not use console.log in production code — use a proper logger
```

Prettier (skip translation — formatting is handled by PostToolUse hook, not AI rules):
```markdown
# Note: prettier formatting is handled automatically by keel's PostToolUse hook
```

### Key translation rules

- `golangci-lint` linters to rules: `gomnd`→no magic numbers, `cyclop`→complexity limit, `goconst`→extract repeated strings, `gocognit`→cognitive complexity, `godot`→comment punctuation, `dupl`→no duplicate code blocks, `exhaustive`→exhaust switches, `wrapcheck`→wrap external errors
- ESLint rules: map each rule to a plain-language instruction; group by category
- Ruff: `E`/`W` codes → formatting (skip), `F` codes → correctness rules, `C` → complexity, `B` → bugbear (translate all), `N` → naming conventions
- Skip rules where translation would be too vague or speculative

### Monorepo support

If multiple linter configs exist at different paths (e.g. `services/billing/.golangci.yaml`), generate separate rule files with scoped `paths:` frontmatter:
```yaml
paths: "services/billing/**/*.go"
```

### Command structure

```
/keel:sync              — detect all linters, generate rules for all found
/keel:sync golangci     — sync only golangci-lint rules
/keel:sync eslint       — sync only ESLint rules
/keel:sync --dry-run    — show what would be generated without writing
```

### Wire into keel:init

Update `commands/init.md` section 3B (established project flow). After the codebase audit, add:

```
If linter configs were found:
  Running keel:sync to generate linter-aware AI rules...
  {list what was generated}

  These rules are a projection of your linter config. When linter config changes, run /keel:sync to update.
```

### Wire into keel:doctor

Update `commands/doctor.md` to add a check:
- If linter config exists but no `linter-*.md` in `.claude/rules/` → warn: "Linter config detected but no linter-aware rules installed. Run `/keel:sync`."
- If linter config's modification time is newer than `linter-*.md` rule file → warn: "Linter config may have changed. Run `/keel:sync` to update."

### Update install.sh

Add `sync` to `KEEL_COMMANDS` array in `install.sh`.

### Tests

Create `test/test-sync.sh`:
- Test that sync command file exists
- Test that it contains translation logic for each supported linter
- Test monorepo path scoping
- Test dry-run mode mention

Update `test/test-structure.sh`:
- Add `sync` to the commands existence check

When complete, output: PHASE 4 COMPLETE

---

## After All Phases

Update the plan progress table above. Then:

1. Run `./test/run.sh` — all suites must pass
2. Update `website/commands/` — add sync command page
3. Commit: `feat(surface): complete Claude Code feature surface adoption`
