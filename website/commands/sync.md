# /keel:sync

Translate linter configs into Claude rule packs — so Claude enforces the same standards your linter does.

## Usage

```
/keel:sync              ← sync all detected linter configs
/keel:sync --dry-run    ← preview what would be generated
```

## What it does

Reads your existing linter configs (golangci-lint, ESLint, Ruff, RuboCop, Biome, PHP CS Fixer) and generates `.claude/rules/linter-*.md` files that teach Claude the same rules — with plain-English explanations of why each rule exists.

The result: Claude writes code that passes your linter on the first attempt, not after several correction rounds.

## Supported linters

| Linter | Config file |
|--------|------------|
| golangci-lint | `.golangci-lint.yaml`, `.golangci.yaml` |
| ESLint | `.eslintrc*`, `eslint.config.*` |
| Ruff | `ruff.toml`, `pyproject.toml [tool.ruff]` |
| RuboCop | `.rubocop.yml` |
| Biome | `biome.json` |
| PHP CS Fixer | `.php-cs-fixer.php`, `.php-cs-fixer.dist.php` |

## Monorepo support

In monorepos with per-package linter configs, keel generates scoped rules with path prefixes so the right rules apply to the right directories.

## Generated file format

```markdown
---
source: .golangci-lint.yaml
generated-by: keel:sync
linter: golangci-lint
paths: ["**/*.go"]
---

# Linter Rules: Go

<!-- keel:generated -->

## cyclop — Cyclomatic Complexity
Keep functions simple. Max complexity: 10.
...
```

## When to run

- After adding or changing a linter config
- After running `/keel:init` on an established project (it runs sync automatically)
- When `/keel:doctor` warns "linter config changed since last sync"

## Natural language triggers

- "sync linter rules"
- "update Claude with our lint config"
- "translate our linter config"
