# ADR-002: Safe CLAUDE.md Merge via Sentinel Comments

**Date:** 2026-03-06
**Status:** Accepted

## Context

Keel needs to write content into `CLAUDE.md` during `keel:init` and when re-initializing. Projects often already have a `CLAUDE.md` with carefully crafted instructions, team conventions, tool configurations, or project-specific rules.

Overwriting the entire file is destructive and would make keel hostile to adoption on established projects. A "Write" approach also breaks re-init — running `keel:init` again would clobber any manual edits made since the last init.

## Decision

Keel manages its content in `CLAUDE.md` via sentinel HTML comments:

```
<!-- keel:start — managed by keel, do not edit manually -->
...keel-managed content...
<!-- keel:end -->
```

**Three cases:**

1. **No CLAUDE.md exists** — create the file containing only the keel block
2. **CLAUDE.md exists, no keel block** — append the keel block at the bottom, leave everything above untouched
3. **CLAUDE.md exists, keel block present** — replace only the content between `<!-- keel:start -->` and `<!-- keel:end -->`, leave everything outside untouched

Implementation uses Read + grep to find markers, then Edit (not Write) to replace only the sentinel block.

## Consequences

- **Safe for complex CLAUDE.md files** — team conventions, custom instructions, and project rules are never touched
- **Safe to re-run** — `keel:init` can be run repeatedly without clobbering manual edits
- **Clearly delimited** — the keel section is easy to find, understand, and remove if needed
- **No proprietary format** — just HTML comments, readable by anyone

## What is NOT in the keel block

User-owned sections of CLAUDE.md (outside the sentinels) are never read or modified by keel. If a user wants to customize keel behavior, they edit inside the block — or add their own sections outside it.
