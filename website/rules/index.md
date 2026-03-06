# Rule Packs

Keel's rules are organized in three tiers. Each rule is a single `.md` file installed to `.claude/rules/` with `paths:` frontmatter so it only activates on relevant files.

## Tiers

| Tier | What | Scope |
|------|------|-------|
| **Base** | Universal coding standards | All files |
| **Language** | Language-specific patterns | `**/*.{ext}` |
| **Framework** | Framework conventions | Framework file patterns |

## All Packs

### Base (enabled by default)

| Pack | Enforces |
|------|---------|
| [code-quality](/rules/base#code-quality) | SOLID, naming, size limits, early returns, DRY |
| [testing](/rules/base#testing) | TDD, behavior-focused tests, mock boundaries |
| [security](/rules/base#security) | Input validation, parameterized queries, no secret logging |
| [error-handling](/rules/base#error-handling) | Typed errors, context enrichment, no silent catches |

### Base (opt-in)

| Pack | Enforces |
|------|---------|
| [frontend](/rules/base#frontend) | Component patterns, a11y, state management |
| [architecture](/rules/base#architecture) | DDD, clean architecture, layer boundaries |

### Language

| Pack | Scope |
|------|-------|
| [go](/rules/language#go) | `**/*.go` |
| [typescript](/rules/language#typescript) | `**/*.ts`, `**/*.tsx` |
| [python](/rules/language#python) | `**/*.py` |
| [php](/rules/language#php) | `**/*.php` |

### Framework

| Pack | Scope |
|------|-------|
| [chi](/rules/framework#chi) | `**/*.go` |
| [nextjs](/rules/framework#nextjs) | `**/*.ts`, `**/*.tsx` |
| [laravel](/rules/framework#laravel) | `**/*.php` |
| [symfony](/rules/framework#symfony) | `**/*.php` |
| [rails](/rules/framework#rails) | `**/*.rb` |
| [django](/rules/framework#django) | `**/*.py` |

## Customization

See [Custom Rules](/rules/custom) for toggling packs, extending existing rules, and creating new rule topics.
