# TODO: Init Onboarding — Remaining Work

**Created:** 2026-03-21
**Source:** UX audit at `30 - Resources/ProductResearcher/UX/Research/keel-init-ux-audit-2026-03-21.md`
**Status:** Parked — core fixes shipped, testing in progress

## What shipped (2026-03-21)

- 3-step flow with progress indicators (scan → configure → install)
- Combined rules + agents + SDLC in single configuration view (full roster)
- Team-join scenario: verify/sync instead of "reconfigure?"
- Reconfigure protects manually-edited files
- Greenfield prompt with inline example
- Progress during file generation
- Summary shows behaviors not mechanisms
- Before/after proof point in summary
- Undo instructions
- Empty directories get README.md
- PR template only installed if not already present
- Ticket system checks for API keys
- Explicit template paths (prevents Claude from exploring)

## What needs testing

- Greenfield flow end-to-end on empty project
- Established flow on a Go+Chi project and a TS+Next.js project
- Team-join scenario (second engineer runs init on existing keel project)
- Reconfigure with manually-edited rule files
- Ticket system selection with and without API keys set

## What remains from audit (not yet implemented)

- F-01: Show one tangible rule output mid-flow (before full generation) — deferred, need to see if the progress output is sufficient
- F-08: Install script retry on failure + idempotency message — low priority
- F-13: Install script download counts — low priority
- F-14: Hooks count consistency between command and website — check after all changes settle
- F-17: Getting-started vs init page content dedup — need to review after both pages stabilize

## Related

- UX audit: `30 - Resources/ProductResearcher/UX/Research/keel-init-ux-audit-2026-03-21.md`
- Init command: `commands/init.md`
- Website init page: `website/commands/init.md`
- Website getting-started: `website/getting-started.md`
