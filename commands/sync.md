---
name: keel:sync
description: "Sync AI rules from linter configs — translate .golangci-lint.yaml, .eslintrc, ruff.toml etc. into .claude/rules/"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# keel:sync

Translate linter configurations into natural-language AI rules scoped by path. The linter config is the source of truth; AI rules are a projection of it.

## Usage

```
/keel:sync              — detect all linters, generate rules for all found
/keel:sync golangci     — sync only golangci-lint rules
/keel:sync go           — sync only golangci-lint rules (alias)
/keel:sync eslint       — sync only ESLint rules
/keel:sync ruff         — sync only Ruff rules
/keel:sync python       — sync only Ruff rules (alias)
/keel:sync rubocop      — sync only RuboCop rules
/keel:sync ruby         — sync only RuboCop rules (alias)
/keel:sync prettier     — note: prettier formatting is handled by PostToolUse hook, no rule needed
/keel:sync biome        — sync only Biome rules
/keel:sync --dry-run    — show what would be generated without writing files
```

## Instructions

### 1. Read Config

```bash
cat .keel/config.yaml 2>/dev/null || echo "No .keel/config.yaml found"
```

Extract `base:` directory (default: `docs`).

### 2. Determine Scope

Parse the argument passed to the command:

- No argument → scope = `all`
- `golangci` or `go` → scope = `golangci`
- `eslint` → scope = `eslint`
- `ruff` or `python` → scope = `ruff`
- `rubocop` or `ruby` → scope = `rubocop`
- `prettier` → scope = `prettier`
- `biome` → scope = `biome`
- `--dry-run` → scope = `all`, dry_run = true
- `{linter} --dry-run` → scope = `{linter}`, dry_run = true

### 3. Detect Linter Configs

For each linter in scope, search for config files at the project root and in subdirectories (for monorepo support).

**golangci-lint** (if scope is `all` or `golangci`):
```bash
# Root configs
ls .golangci-lint.yaml .golangci-lint.yml .golangci.yaml .golangci.yml 2>/dev/null

# Monorepo: subdirectory configs
find . -name ".golangci-lint.yaml" -o -name ".golangci-lint.yml" -o -name ".golangci.yaml" -o -name ".golangci.yml" 2>/dev/null | grep -v "^\./" | head -20
```

**ESLint** (if scope is `all` or `eslint`):
```bash
ls .eslintrc .eslintrc.js .eslintrc.cjs .eslintrc.json .eslintrc.yaml .eslintrc.yml eslint.config.js eslint.config.mjs eslint.config.cjs 2>/dev/null

find . -name ".eslintrc" -o -name ".eslintrc.js" -o -name ".eslintrc.json" -o -name ".eslintrc.yaml" -o -name ".eslintrc.yml" -o -name "eslint.config.js" -o -name "eslint.config.mjs" 2>/dev/null | grep -v node_modules | head -20
```

**Ruff** (if scope is `all` or `ruff`):
```bash
ls ruff.toml pyproject.toml 2>/dev/null

# For pyproject.toml, check if [tool.ruff] section exists
grep -l "\[tool.ruff\]" pyproject.toml 2>/dev/null

find . -name "ruff.toml" -o -name "pyproject.toml" 2>/dev/null | grep -v node_modules | xargs grep -l "\[tool.ruff\]" 2>/dev/null | head -20
```

**RuboCop** (if scope is `all` or `rubocop`):
```bash
ls .rubocop.yml .rubocop.yaml 2>/dev/null

find . -name ".rubocop.yml" -o -name ".rubocop.yaml" 2>/dev/null | head -20
```

**PHP CS Fixer** (if scope is `all`):
```bash
ls .php-cs-fixer.php .php-cs-fixer.dist.php 2>/dev/null
```

**Biome** (if scope is `all` or `biome`):
```bash
ls biome.json 2>/dev/null

find . -name "biome.json" 2>/dev/null | grep -v node_modules | head -20
```

**Prettier** (if scope is `all` or `prettier`):
```bash
ls .prettierrc .prettierrc.json .prettierrc.yaml .prettierrc.yml .prettierrc.js prettier.config.js prettier.config.mjs 2>/dev/null
```

### 4. Translate Each Detected Config

For each detected config file:

1. Read the config file
2. Identify which rules/linters are active and their settings
3. Generate natural-language rules following the translation tables below
4. If `--dry-run`: print the output, don't write files

#### Monorepo Path Scoping

If the config file is NOT at the project root (e.g., `services/billing/.golangci.yaml`):
- Determine the relative directory: `services/billing/`
- Set `paths:` to `services/billing/**/*.{ext}` in the generated rule frontmatter
- Name the rule file with a suffix: `linter-golangci-billing.md`

If the config is at the root:
- `paths:` is `**/*.go` (or relevant extension)
- Rule file: `linter-golangci.md`

#### Generated File Frontmatter

Every generated rule file must have this frontmatter:

```yaml
---
paths: "**/*.{ext}"
version: "1.0.0"
source: linter
linter: {linter-name}
generated-by: keel:sync
---
<!-- keel:generated -->
```

---

#### golangci-lint Translation

Read the config. Check `linters.enable` (or `linters-settings`) for these enabled linters and translate:

| Linter | Translation |
|--------|-------------|
| `gomnd` or `mnd` | Extract numeric literals to named constants — avoid magic numbers (0, 1, 2 are acceptable inline) |
| `cyclop` | Keep function cyclomatic complexity under {max-complexity, default 10} — split complex functions |
| `gocognit` | Keep cognitive complexity under {threshold, default 30} |
| `goconst` | Extract repeated string literals to named constants |
| `exhaustive` | Switch statements on enums must be exhaustive — handle all cases explicitly |
| `wrapcheck` | Wrap errors from external packages with context using fmt.Errorf("...context: %w", err) |
| `godot` | End all comments with a period |
| `dupl` | Avoid duplicate code blocks — extract shared logic to functions |
| `funlen` | Keep functions under {max, default 60} lines — extract complex logic to helpers |
| `gochecknoglobals` | Avoid package-level global variables — prefer dependency injection |
| `lll` | Keep lines under {line-length, default 120} characters |
| `nestif` | Avoid deeply nested if statements — use early returns or extract functions |

Read `linters-settings:` section to extract configured thresholds (e.g., `cyclop.max-complexity`, `funlen.lines`, `lll.line-length`).

If a linter is not in `linters.enable` AND not in the global `enable-all: true`, skip it.

Output file: `.claude/rules/linter-golangci.md` (or `linter-golangci-{subdir}.md` for monorepo).

Full output format:

```markdown
---
paths: "**/*.go"
version: "1.0.0"
source: linter
linter: golangci-lint
generated-by: keel:sync
---
<!-- keel:generated -->

# Go Linter Rules (golangci-lint)

Rules translated from `.golangci-lint.yaml` — these mirror your linter config so Claude produces compliant code.

{one bullet per enabled linter with translation}
```

---

#### ESLint Translation

Read the config. Check `rules:` section. For each enabled rule (value is `"error"`, `"warn"`, `2`, or `1`; not `"off"` or `0`):

| Rule | Translation |
|------|-------------|
| `no-console` | Do not use console.log — use a structured logger |
| `no-unused-vars` | Remove unused variables before committing |
| `prefer-const` | Use const for variables that are never reassigned |
| `eqeqeq` | Use === for equality checks, never == |
| `no-var` | Use let/const instead of var — never use var |
| `@typescript-eslint/no-explicit-any` | Avoid using any — provide specific types |
| `@typescript-eslint/explicit-function-return-type` | Declare return types on all functions |
| `import/no-unused-modules` | Remove unused module imports |
| `no-shadow` | Avoid variable shadowing — rename to clarify scope |
| `no-throw-literal` | Only throw Error objects, never plain strings or literals |
| `consistent-return` | Functions must always return a value or never return one |
| `no-param-reassign` | Do not reassign function parameters — use local variables |

For `eslint.config.js` / `eslint.config.mjs` (flat config format): parse the exported rules array.

Output file: `.claude/rules/linter-eslint.md`

Paths: `**/*.{ts,tsx,js,jsx}`

---

#### Ruff Translation

Read `ruff.toml` or the `[tool.ruff]` section from `pyproject.toml`.

Check `select`, `extend-select`, `ignore` arrays. Translate enabled rule codes:

| Code | Translation |
|------|-------------|
| `E501` | Keep lines under {max-line-length, default 88} characters |
| `F401` | Remove unused imports |
| `F841` | Remove unused local variables |
| `B006` | Do not use mutable objects (lists, dicts) as default argument values |
| `B007` | Prefix unused loop variables with underscore |
| `B008` | Do not call functions in default argument values |
| `C901` | Keep function complexity under {max-complexity, default 10} |
| `N802` | Function names must be lowercase (snake_case) |
| `N803` | Argument names must be lowercase (snake_case) |
| `N806` | Variable names in functions must be lowercase |
| `UP` prefix (any) | Use modern Python syntax — target Python {target-version}+ |
| `S` prefix (any) | Follow security best practices — avoid common security vulnerabilities |
| `ANN001` | Add type annotations to function arguments |
| `ANN201` | Add return type annotations to public functions |

Check `target-version` setting and include it in UP translations.

Skip `E1xx`, `E2xx`, `E3xx`, `W` codes (pure formatting — handled by PostToolUse formatter).

Output file: `.claude/rules/linter-ruff.md`

Paths: `**/*.py`

---

#### RuboCop Translation

Read `.rubocop.yml`. Check enabled cops under each department. Translate:

| Cop | Translation |
|-----|-------------|
| `Metrics/MethodLength` with `Max: N` | Keep methods under N lines — extract helpers for complex logic |
| `Metrics/CyclomaticComplexity` with `Max: N` | Keep cyclomatic complexity under N |
| `Metrics/AbcSize` with `Max: N` | Keep method ABC size under N — split complex methods |
| `Style/FrozenStringLiteralComment` | Add `# frozen_string_literal: true` to the top of every Ruby file |
| `Lint/UnusedMethodArgument` | Prefix unused method arguments with underscore |
| `Style/StringLiterals` with `EnforcedStyle: single_quotes` | Use single quotes for strings unless interpolation is needed |
| `Style/GuardClause` | Use guard clauses (early returns) instead of nested conditionals |
| `Rails/FindBy` | Use `find_by` instead of `where(...).first` |
| `Rails/TimeZone` | Use `Time.current` or zone-aware methods, not `Time.now` |

A cop is enabled unless it has `Enabled: false`. Also check `AllCops` defaults.

Output file: `.claude/rules/linter-rubocop.md`

Paths: `**/*.rb`

---

#### PHP CS Fixer Translation

Read `.php-cs-fixer.php` or `.php-cs-fixer.dist.php`. Parse the `$rules` array. Translate common rules:

| Rule | Translation |
|------|-------------|
| `declare_strict_types` | Add `declare(strict_types=1)` to every PHP file |
| `no_unused_imports` | Remove unused use statements |
| `ordered_imports` | Order imports alphabetically |
| `phpdoc_add_missing_param_annotation` | Add @param annotations to all function PHPDoc blocks |
| `return_type_declaration` | Always declare return types on functions |

Output file: `.claude/rules/linter-php-cs-fixer.md`

Paths: `**/*.php`

---

#### Biome Translation

Read `biome.json`. Parse `linter.rules` section. Translate enabled rules similarly to ESLint:

| Rule | Translation |
|------|-------------|
| `suspicious/noConsoleLog` | Do not use console.log — use a structured logger |
| `correctness/noUnusedVariables` | Remove unused variables before committing |
| `style/useConst` | Use const for variables that are never reassigned |
| `suspicious/noDoubleEquals` | Use === for equality checks, never == |
| `complexity/noBannedTypes` | Avoid banned TypeScript types (any, object, Function) |
| `style/noVar` | Use let/const instead of var |

Output file: `.claude/rules/linter-biome.md`

Paths: `**/*.{ts,tsx,js,jsx}`

---

#### Prettier

If prettier config is detected:

Output a note (do NOT generate a rule file):

```
⚠️  .prettierrc found — formatting is handled by keel's PostToolUse hook automatically.
    No rule file needed. Claude will format files via the hook after each edit.
```

---

### 5. Write Rule Files

For each generated rule:

1. Check if `.claude/rules/linter-{name}.md` already exists
2. If it does NOT exist: write it
3. If it DOES exist:
   - Show what changed (diff of new vs old content)
   - Ask: "Rule file already exists. Overwrite? (y/N)"
   - Only overwrite on explicit `y`

If `--dry-run` is active: print what would be written, do not write anything.

### 6. Output Summary

After all rules are generated:

```
keel:sync complete

  Generated:
  ✅ .claude/rules/linter-golangci.md   (12 rules from .golangci-lint.yaml)
  ✅ .claude/rules/linter-eslint.md     (8 rules from .eslintrc.json)
  ✅ .claude/rules/linter-ruff.md       (5 rules from ruff.toml)
  ⚠️  .prettierrc found — formatting handled by PostToolUse hook, no rule needed

  Monorepo (path-scoped):
  ✅ .claude/rules/linter-golangci-billing.md  (services/billing/**/*.go)

  No linter configs found for: rubocop, biome

  Run /keel:doctor to verify rule health.
  When linter config changes, run /keel:sync again.
```

If `--dry-run` was active, prefix the output with:

```
[dry-run] No files were written. Remove --dry-run to apply.
```

If no linter configs were found at all:

```
No linter configs detected in this project.

Supported: golangci-lint, ESLint, Ruff, RuboCop, PHP CS Fixer, Biome

If your linter config is in a non-standard location, pass the path directly or run /keel:sync {linter} after navigating to the package.
```
