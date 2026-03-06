# Custom Rules

Three levels of customization — from simple toggles to brand new rule topics.

## Toggle Rules On/Off

Edit `.keel/config.yaml` and remove or add pack names:

```yaml
rules:
  base:
    - code-quality
    - testing
    - security
    - error-handling
    # - frontend     ← disabled
  lang:
    - go
  framework:
    - chi
```

Run `/keel:init` again to regenerate `.claude/rules/` from the updated config.

## Extend Existing Rules

Add custom sections directly to any generated `.claude/rules/*.md` file. Keel tracks checksums — it won't overwrite your additions on re-init.

```markdown
# Go Rules

<!-- keel-generated content above -->

## Project-Specific

- All monetary amounts use `decimal.Decimal`, never `float64`
- Database calls only in adapter layer, never in domain
```

## Create New Rule Topics

Drop any `.md` file into `.claude/rules/` with `paths:` frontmatter:

```markdown
---
paths:
  - "internal/billing/**/*.go"
description: "Billing domain rules"
---

# Billing Rules

- All monetary amounts use `decimal.Decimal`, never `float64`
- Every charge mutation requires an idempotency key
- Refunds must go through the RefundService, never direct DB writes
```

Claude will read this file automatically when editing files matching `internal/billing/**/*.go`.

## Monorepo Rules

For monorepos with different standards per package, create one rule file per package:

```
.claude/rules/
├── code-quality.md          ← all files
├── services-billing.md      ← internal/billing/**/*.go
├── services-notifications.md ← internal/notifications/**/*.go
└── web.md                   ← web/**/*.ts
```
