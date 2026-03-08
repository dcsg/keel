---
name: keel:session
description: "End-of-session sweep — summarize what happened, surface missed captures before context is lost"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

You are performing an end-of-session sweep. Your job is to summarize what happened this session and surface any missed captures (ADRs, invariants, doc gaps) before context is lost.

## Step 1: What changed (git)

Run these commands to understand what happened this session:

```bash
git diff HEAD --name-only 2>/dev/null
git diff --staged --name-only 2>/dev/null
git log --since="3 hours ago" --oneline 2>/dev/null
```

Group the changed files into logical areas (e.g., "webhook delivery (3 files)", "DB migration", "auth routes"). If there are no changes and no recent commits, output:

```
Nothing built in this session — no captures needed.
```

And stop.

## Step 2: Plan progress

Find the most recently modified plan file under `docs/plans/`:

```bash
ls -t docs/plans/*.md 2>/dev/null | head -1
```

Read it and check if any phases have moved to `done` or `in-progress` recently (look at the progress table and updated timestamps). Report what changed, or "no plans updated" if nothing moved.

## Step 3: Scan for uncaptured decisions

Review the current conversation context for decision language:
- "we decided to...", "going with...", "chose X over Y", "trade-off is...", "because of..."

Then check existing ADRs:

```bash
ls docs/decisions/*.md 2>/dev/null || ls docs/architecture/decisions/*.md 2>/dev/null
```

Read the ADR list. Only flag a decision as a possible ADR if:
1. A clear decision was made (not just a preference)
2. There was reasoning or an alternative considered
3. The topic is NOT already covered in an existing ADR

Only surface STRONG signals — skip implementation details and style choices.

## Step 4: Scan for uncaptured constraints

Review the conversation for constraint language:
- "never...", "always must...", "required on all...", "violating this would..."

Then check existing invariants:

```bash
ls docs/invariants/*.md 2>/dev/null || ls docs/architecture/invariants/*.md 2>/dev/null
```

Only flag constraints not already captured in an existing invariant file.

## Step 5: Scan for doc gaps

From the git diff, look for:
- New HTTP routes or endpoints added
- New environment variables introduced
- New services or infrastructure components
- Breaking changes to existing APIs

Same logic as `/keel:docs`, but scoped to this session's changes only. Skip internal refactors, test changes, and formatting.

## Step 6: Cross-reference to avoid noise

Before surfacing any suggestion:
- Verify it's not already in `docs/decisions/` (or `docs/architecture/decisions/`)
- Verify it's not already in `docs/invariants/` (or `docs/architecture/invariants/`)
- Verify it's not already documented

Only surface genuinely missing captures.

## Output format

```
SESSION SUMMARY — {date} {time}
─────────────────────────────────────────────────────
Built:    {changed areas — e.g., "webhook delivery (3 files), DB migration"}
Commits:  {recent commit messages, or "none yet"}
Updated:  {plan progress changes, or "no plans updated"}

Possible captures:
  💡 ADR: {decision description} — {why it qualifies as an ADR}
     → Run /keel:adr to capture

  💡 Invariant: {constraint description}
     → Run /keel:invariant to capture

  📄 Doc gap: {new public surface} — not in {doc file}
     → Run /keel:docs to review

─────────────────────────────────────────────────────
{count} possible captures. Context compaction coming — capture now or later.
```

If there are no possible captures, output instead:
```
✅ Session looks complete — nothing missed.
```
