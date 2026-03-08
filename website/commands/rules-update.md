# /keel:rules-update

Check for outdated rule packs and update them to the latest version from the keel registry.

## Usage

```
/keel:rules-update
```

## What it does

Compares the version of each installed `.claude/rules/*.md` file against the keel template registry. For any outdated pack, downloads the latest version and replaces the installed file.

Manually edited rule files (no `<!-- keel:generated -->` marker) are never overwritten — keel skips them and notes the manual edit.

## Output

```
Checking rule pack versions...

  go.md         1.0 → 1.2  updated
  typescript.md 1.1 → 1.1  ok
  security.md   1.3 → 1.3  ok
  nextjs.md     (manual edit — skipped)

1 pack updated.
```

## When to run

- When `/keel:doctor` warns that a pack is outdated
- Periodically to pick up new rules and improvements
- After the keel installer is updated

## Preserving customizations

If you've added custom rules to a keel-generated file, add a section below the generated content and remove the `<!-- keel:generated -->` marker. Keel will never touch that file again.

For extensible customization without losing updates, append rules in a separate file: `.claude/rules/my-custom-rules.md`.

## Natural language triggers

- "update rule packs"
- "are my rules up to date?"
- "update keel rules"
