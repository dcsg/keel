# /keel:session

End-of-session sweep — summarize what was built and surface missed captures before context is lost.

## Usage

```
/keel:session
```

## What it does

At the end of a work session, `keel:session` reviews what changed (git diff, recent commits), checks the active plan's progress, and scans for architectural decisions, constraints, or doc gaps that should be captured — but haven't been yet.

Run it before ending a session or before `/compact`. The PreCompact hook reminds you automatically.

## What it checks

1. **Git summary** — what files changed, what was committed in the last few hours
2. **Plan progress** — which phases moved, what's still open
3. **Uncaptured decisions** — decision language in the conversation ("we decided to", "chose X over Y") not reflected in any ADR
4. **Uncaptured constraints** — constraint language ("never", "always must") not reflected in any invariant
5. **Doc gaps** — new routes, env vars, or services not yet documented

Before surfacing any suggestion, it cross-references against existing files to avoid noise. Only genuinely missing captures are flagged.

## Output

```
SESSION SUMMARY — 2026-03-08 17:42
─────────────────────────────────────────────────────
Built:    webhook delivery (3 files), DB migration
Commits:  feat(webhooks): delivery with retry logic
Updated:  PLAN-004 phase 2 → done

Possible captures:
  💡 ADR: exponential backoff over fixed retry intervals — clear trade-off discussed
     → Run /keel:adr to capture

  📄 Doc gap: POST /webhooks/retry — new endpoint not in API docs
     → Run /keel:docs to review

─────────────────────────────────────────────────────
2 possible captures. Context compaction coming — capture now or later.
```

If nothing was built:

```
Nothing built in this session — no captures needed.
```

## PreCompact integration

The PreCompact hook (triggered automatically before Claude compacts context) reminds you:

```
⚠️ Context compacting. (1) Update your active plan's progress table NOW.
(2) Run /keel:session to capture any decisions, constraints, or doc gaps before context is lost.
```

## Natural language triggers

- "end of session"
- "wrap up"
- "what did we miss?"
- "anything to capture?"
- "session summary"
