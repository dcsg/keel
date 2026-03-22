---
type: adr
id: ADR-006
status: accepted
created_at: 2026-03-20T00:00:00Z
decision-makers: [Daniel Gomes]
references:
  adrs: [ADR-001]
  invariants: [INV-001]
---

# ADR-006: Extensibility Model — Templates, Agents, and Rules

**Status:** accepted
**Date:** 2026-03-20

## Context and Problem Statement

Teams adopt keel with different conventions, document formats, and engineering practices. The built-in templates (PRD, spec, ADR, invariant), agent prompts, and rule packs are opinionated defaults. Without an extensibility model, teams must either accept keel's defaults entirely or fork the project.

How should teams customize keel's templates, agents, and rules without forking?

## Decision Drivers

- Teams must be able to customize without losing upgrade support
- Customizations should be version-controlled and shared via git
- The extension mechanism should be different per concern (templates vs agents vs rules have different needs)
- `/keel:upgrade` must not silently overwrite customizations

## Considered Options

### Unified override model
Single mechanism for everything — project files override keel defaults.
- Pros: simple to understand
- Cons: rules need extension (add to defaults), not just override; agents need per-file control

### Per-concern mechanisms (chosen)
Different mechanism for each concern type.
- Pros: each mechanism fits its use case
- Cons: three patterns to learn

## Decision

Three extensibility mechanisms, one per concern:

### 1. Templates — lookup-order override

Keel provides default templates. The project can override any template by placing a file in `.keel/templates/`.

```
Lookup order:
  1. .keel/templates/{name}.md       ← project override (if exists, use this)
  2. ~/.keel/templates/{name}.md.tmpl ← keel default (fallback)
```

Overridable templates:
- `prd.md` — PRD format
- `adr.md` — ADR format
- `invariant.md` — invariant format
- `spec.md` — technical specification format
- `artifacts/data-model.md` — data model artifact
- `artifacts/api-contract.md` — API contract artifact
- `artifacts/test-strategy.md` — test strategy artifact
- `artifacts/migrations.md` — migration plan artifact
- `artifacts/fixtures.md` — fixtures/seed data artifact
- `compile-output.md` — compiled governance format

Config:
```yaml
templates:
  dir: .keel/templates   # customizable
```

`/keel:doctor` reports which templates are custom vs default.

### 2. Agents — marker-based skip on upgrade

Agents install to `.claude/agents/` and teams can edit them freely. To prevent `/keel:upgrade` from overwriting customized agents:

Option A (config-based):
```yaml
agents:
  custom:
    - principal-dba       # skip on upgrade
    - my-team-reviewer    # not from keel templates
```

Option B (file-based): `<!-- keel:custom -->` marker in the agent file. If present, upgrade skips it.

Both options are supported. Config takes precedence.

Custom agents (not from keel templates) are always skipped by upgrade — they have no matching template to compare against.

### 3. Rules — override or extend

Two modes:

**Override:** Place a file at `.keel/rules/{name}.md`. If it exists, keel uses it instead of the built-in pack. The file should NOT have the `<!-- keel:generated -->` marker (so upgrade skips it).

**Extend:** Keep keel's built-in pack and append additional rules:
```yaml
rules:
  go:
    include: all
    extend: .keel/rules/go-extensions.md   # appended to keel's go.md
```

The extension file is concatenated after the built-in pack when rules are installed. Both the base pack and the extension are version-controlled.

`/keel:doctor` reports which rules are overridden, extended, or default.

## Consequences

### Good
- Teams customize without forking
- Customizations are version-controlled and shared via git
- `/keel:upgrade` respects customizations
- `/keel:doctor` surfaces the customization state

### Bad
- Three mechanisms to learn (mitigated by documentation + doctor reporting)
- Override templates completely replace the default — partial override not supported (mitigated by: copy the default, modify what you need)

### Neutral
- Custom templates require manual maintenance — keel template improvements won't auto-merge into overrides
- `/keel:doctor` becomes the tool for understanding what's customized vs default

## Confirmation

How to verify this decision is being followed:
- `/keel:doctor` reports custom vs default for templates, agents, and rules
- `/keel:upgrade` never overwrites a file marked as custom or listed in `agents.custom`
- Extension files are concatenated correctly (test with a rule that has both base + extension)
