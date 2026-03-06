# Monorepos

Keel supports monorepos via path-scoped rule files — different rules per package.

## How It Works

Each `.claude/rules/*.md` file has a `paths:` frontmatter field. Claude only reads a rule file when editing files that match those paths.

```
.claude/rules/
├── code-quality.md          ← paths: all files (global)
├── testing.md               ← paths: all files (global)
├── go.md                    ← paths: **/*.go
├── billing.md               ← paths: services/billing/**/*.go
├── notifications.md         ← paths: services/notifications/**/*.go
└── web.md                   ← paths: web/**/*.ts,web/**/*.tsx
```

## Setup

Run `/keel:init` from the repo root. Keel detects the monorepo structure and may ask which packages to configure.

Then create package-specific rules manually for any packages with unique standards:

```markdown
---
paths:
  - "services/billing/**/*.go"
description: "Billing service rules"
---

# Billing Rules

- All monetary amounts use `decimal.Decimal`, never `float64`
- Every charge mutation requires an idempotency key
```

## Tips

- Global rules (no `paths:` restriction) apply everywhere — keep them universal
- Package-specific rules should only add to global rules, not contradict them
- Name rule files clearly: `billing.md`, `web.md` — not `rules1.md`
