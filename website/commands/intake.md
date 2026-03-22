# /keel:intake

Scans for scattered docs and organizes them into keel's structure.

## Usage

```
/keel:intake
```

## What It Does

Many projects accumulate docs in random places — READMEs with architecture notes, Notion exports, old ADR folders, Wiki dumps. Intake finds them and organizes everything.

1. **Scans** for existing docs: `README`, `docs/`, `wiki/`, existing ADRs, spec files
2. **Categorizes** each file: architecture decision, business rule, product context, or reference
3. **Shows** what it found and where it would move things
4. **Asks** for confirmation before moving anything
5. **Organizes** into keel structure

## Example

```
Found 7 documents:

  docs/ARCHITECTURE.md      → docs/decisions/architecture-overview.md
  docs/api-spec.md          → docs/product/spec.md
  docs/adr/                 → docs/decisions/ (3 ADRs)
  README.md (arch section)  → extract to docs/project-context.md
  notes/onboarding.md       → docs/reference/onboarding.md

Proceed? (enter to confirm, n to cancel)
```

## When to Use

Run intake once when setting up keel on an existing project with scattered documentation.
