# Rules System

Rules are markdown files that Claude Code reads automatically when you work on files matching their `paths:` glob. They're the core mechanism that makes Claude consistent.

## How Rules Work

Each rule file has a frontmatter `paths:` glob. When you open or edit a file matching that glob, Claude loads the corresponding rule — silently, automatically, every time.

```yaml
---
paths: "**/*.go"
---

# Go Rules

## Error Handling

Always return errors as the last return value...
```

Rules live in `.claude/rules/`. Claude Code picks them up with no configuration needed.

## Rule Tiers

Keel ships three tiers of rules:

### Base Rules (language-agnostic)

Apply to all source files. Every project gets these.

| Rule | What It Enforces |
|------|-----------------|
| `code-quality.md` | SOLID principles, naming (domain-specific, no `utils/helpers`), file/function size limits, library-first |
| `testing.md` | TDD red-green-refactor, test naming, mock anti-patterns, behavior-focused tests |
| `security.md` | Input validation at boundaries, parameterized queries, no secret logging, explicit auth checks |
| `error-handling.md` | Typed/structured errors, no silent catches, error context enrichment |
| `frontend.md` | Component patterns, accessibility, state management, performance |
| `architecture.md` | DDD bounded contexts, clean architecture layers, import restrictions, domain events |

### Language Packs

| Rule | Language |
|------|----------|
| `go.md` | Go |
| `typescript.md` | TypeScript / JavaScript |
| `python.md` | Python |
| `php.md` | PHP |

### Framework Packs

| Rule | Framework |
|------|-----------|
| `nextjs.md` | Next.js (App Router) |
| `chi.md` | Chi (Go HTTP router) |
| `laravel.md` | Laravel |
| `symfony.md` | Symfony |
| `rails.md` | Ruby on Rails |
| `django.md` | Django |

## Configuring Rules

Rules are selected during `/keel:init` and recorded in `.keel/config.yaml`:

```yaml
rules:
  # Base
  code-quality: { include: all }
  testing: { include: all }
  security: { include: all }
  error-handling: { include: all }
  # frontend: { include: all }
  # architecture: { include: all }

  # Language
  go: { include: all }

  # Framework
  chi: { include: all }
```

Commented-out rules are not installed. Uncomment and re-run `/keel:init` to add them.

## Three Levels of Customization

### 1. Toggle packs on/off

Edit `.keel/config.yaml` and re-run `/keel:init` to regenerate `.claude/rules/`.

### 2. Extend a built-in pack

Add your own content to an existing rule file. Mark your additions so keel doesn't overwrite them on regeneration:

```markdown
<!-- keel:generated — content below this line is managed by keel -->
...generated content...
<!-- keel:generated:end -->

## Our Custom Rules

Never use `context.Background()` outside of main.
Always use `pkg/errors` for wrapping.
```

Content outside the sentinel block is preserved when rules are regenerated.

### 3. Create a custom pack

Add a new `.md` file directly to `.claude/rules/`:

```markdown
---
paths: "internal/payments/**/*.go"
---

# Payments Domain Rules

- Never log raw card numbers or CVVs
- All payment operations must be idempotent
- Use the `payments.Amount` type, never raw floats
```

Register it in `.keel/config.yaml` so keel knows about it:

```yaml
rules:
  # ...
  payments-domain:
    type: custom
    source: .claude/rules/payments-domain.md
    paths: "internal/payments/**/*.go"
```

## Rules Are Not Guidelines

Every line in a rule file should change Claude's behavior. No aspirational fluff. If it doesn't constrain a decision, it shouldn't be in a rule.

Good rule:
```
Return errors as the last return value. Never panic in library code.
Use fmt.Errorf("context: %w", err) to wrap errors with context.
```

Bad rule:
```
Write good code. Think about error handling. Be consistent.
```
