---
status: draft
priority: high
---

# PRD: Linter-Aware Rule Generation

## Problem

Today there are two enforcement loops that don't talk to each other:

1. **Linter loop:** Claude writes code → linter rejects → Claude fixes → linter passes
2. **AI rules loop:** Keel installs opinionated rules → Claude follows them (or not)

The linter loop is wasteful — every rejection is a round-trip that could have been avoided if Claude already knew the linting constraints. The AI rules loop is disconnected from the actual linter config, meaning rules can drift or contradict.

The goal: **Claude reads linter rules before writing code and never produces violations in the first place.** The linter becomes a safety net that rarely fires.

## Solution

Keel reads existing linter configurations and translates them into natural-language AI rules scoped by path. The linter config becomes the single source of truth. AI rules are a projection of it.

### Flows

**Greenfield:**
1. `keel:init` generates opinionated AI rules (current behavior, unchanged)
2. User sets up linters later based on same standards
3. Future: `keel:sync` reads the linter config and updates AI rules to match

**Brownfield:**
1. `keel:init` detects existing linter configs during codebase audit
2. Translates linter rules into natural-language AI rules
3. Installs as `.claude/rules/` files scoped to the right paths
4. Linter config is the source of truth — AI rules follow

**Monorepo:**
1. `keel:init` scans each package for its own linter config
2. Generates separate path-scoped rule files per package
3. Claude gets different instructions depending on which file it's editing

### Linter Configs to Support

| Linter | Config file | Language |
|--------|-------------|----------|
| golangci-lint | `.golangci-lint.yaml` | Go |
| ESLint | `.eslintrc.*`, `eslint.config.*` | JS/TS |
| Ruff | `ruff.toml`, `pyproject.toml [tool.ruff]` | Python |
| PHP-CS-Fixer | `.php-cs-fixer.php` | PHP |
| RuboCop | `.rubocop.yml` | Ruby |
| Archway | `archway.yaml` | Any (structural) |

### Translation Examples

**Input** (golangci-lint):
```yaml
linters:
  enable:
    - gomnd        # magic number detection
    - cyclop       # cyclomatic complexity
    - goconst      # repeated strings
linters-settings:
  cyclop:
    max-complexity: 10
  gomnd:
    ignored-numbers: ["0", "1", "2"]
```

**Output** (`.claude/rules/billing.md`):
```markdown
---
paths:
  - "services/billing/**/*.go"
---

# Billing Service Rules

- Extract numeric literals to named constants (0, 1, 2 are acceptable)
- Keep function cyclomatic complexity under 10 — split complex functions
- Extract repeated string literals to constants
```

### Archway Integration

Archway's `analyze` command already detects architecture, frameworks, and dependency rules. Keel can consume archway's output:

- `archway.yaml` dependency rules → AI rules about import restrictions
- `archway.yaml` structure rules → AI rules about where to put new code
- `archway.yaml` function limits → AI rules about function size

Archway enforces deterministically (CI/pre-commit). Keel prevents violations before they're written.

## User Stories

1. As a developer with an existing Go project and golangci-lint config, I want `keel:init` to read my linter config and generate matching AI rules so Claude never produces linting violations.

2. As a monorepo maintainer, I want each package's linter config to produce separate path-scoped AI rules so Claude follows the right standards for each package.

3. As someone using archway for architecture enforcement, I want keel to read `archway.yaml` and generate AI rules that match so Claude respects layer boundaries before archway has to reject a PR.

4. As a developer who updates linter config, I want a way to re-sync AI rules so they stay in sync with the source of truth.

## Open Questions

- Should `keel:sync` be a separate command or part of `keel:init --refresh`?
- How to handle linter rules that don't translate well to natural language (e.g., formatting rules that are purely stylistic)?
- Should keel warn when AI rules and linter config are out of sync?
- How deep to go on translation — every rule, or just the ones that affect code structure/logic?

## Out of Scope

- Generating linter configs from AI rules (reverse direction)
- Running linters — that's the linter's job
- Replacing linters — they remain the deterministic safety net
