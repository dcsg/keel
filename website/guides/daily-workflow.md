# Daily Workflow

Keel works best when you follow a consistent session loop. This guide shows the full pattern — from starting a session to wrapping up cleanly.

## The loop

```
Start session → Load context → Build → Review → End session
```

Every part of this is either automatic (hooks fire without you doing anything) or a single command when you want explicit control.

---

## 1. Starting a session

**What happens automatically:**

The `SessionStart` hook fires when you open Claude Code. If keel is set up, it checks what changed in git since your last session and tells you which specialist agents are relevant:

```
📋 Keel — since your last session (2d ago):
   3 migration/schema files changed
   Relevant agents: principal-dba
   Run /keel:context to load full project context.
```

If nothing changed, it just confirms memory age:

```
📋 Keel — 2d since last session. Run /keel:context to load context.
```

**When to run `/keel:context`:**

Always — especially after a few days away, after a big merge, or when switching tasks. It loads soul, decisions, invariants, and the active plan into Claude's context so it's working with full awareness.

---

## 2. Planning work

For anything non-trivial, run `/keel:plan` before writing code.

```
/keel:plan add webhook delivery with retry logic
```

Keel interviews you (3–6 questions), scans the codebase, breaks the work into phases, and — new in v3 — runs a **pre-flight specialist review** on the plan before you execute:

```
PRE-FLIGHT REVIEW
─────────────────────────────────────────────────────
Domains detected: database, api

PRINCIPAL DBA
  🔴  Migration has no rollback — add DOWN migration
  🟡  No index on webhooks.status — queried in retry loop

SENIOR API
  🟢  Endpoint contract looks stable
─────────────────────────────────────────────────────
1 critical, 1 warning. Address before executing?
```

Fix issues in the plan now, or note them as known risks. Much cheaper than fixing after implementation.

Skip pre-flight for simple tasks:
```
/keel:plan --no-review fix typo in error message
```

---

## 3. Building

Just build. Keel works in the background:

- **PostToolUse hook** auto-formats files after every edit (gofmt, prettier, black, rubocop — whatever your stack uses)
- **Stop hook** watches every response for signals worth capturing — architectural decisions, hard constraints, new feature requirements — and suggests the right command

When Claude ends a response with:
```
💡 This looks like an ADR — run `/keel:adr` to capture it.
```
...that's the Stop hook firing. Run the command to lock in the decision before you move on.

**Update your plan as you go.** The progress table in the plan file is the persistent state — it survives context compaction. Update it when a phase completes:

```
| Phase | Status | Updated    |
|-------|--------|------------|
| 1     | done   | 2026-03-08 |
| 2     | done   | 2026-03-08 |
```

---

## 4. Reviewing what you built

After finishing an implementation, run `/keel:review` to get specialist eyes on what changed:

```
/keel:review             ← review last commit
/keel:review --branch    ← review everything on this branch
```

Keel classifies changed files by domain and routes to the right agents automatically — you don't have to know which agents to ask:

```
IMPLEMENTATION REVIEW
─────────────────────────────────────────────────────
Scope: 5 files changed
Domains: database, api

PRINCIPAL DBA
  🔴  Missing index on webhooks.delivered_at
  🟢  Transaction boundaries look correct

SENIOR API
  🟢  No breaking changes detected
─────────────────────────────────────────────────────
1 critical. Address before shipping?
```

For security-sensitive features, also run `/keel:audit` before pushing. The pre-push hook does a lightweight grep scan automatically, but a full audit is worth it for auth, payments, or PII.

---

## 5. Ending a session

**What happens automatically:**

The `PreCompact` hook fires before context compaction:
```
⚠️ Context compacting. (1) Update your active plan's progress table NOW.
   (2) Run /keel:session to capture any decisions, constraints, or doc gaps
   before context is lost.
```

**Run `/keel:session` explicitly** at end of day or before a long break:

```
SESSION SUMMARY — 2026-03-08 17:42
─────────────────────────────────────────────────────
Built:    webhook delivery (5 files), DB migration
Commits:  feat(webhooks): delivery with retry logic
Updated:  PLAN-007 phase 2 → done

Possible captures:
  💡 ADR: exponential backoff chosen over fixed intervals
     → Run /keel:adr to capture

  📄 Doc gap: POST /webhooks/retry — new endpoint
     → Run /keel:docs to review
─────────────────────────────────────────────────────
2 possible captures.
```

Capture what matters, skip what doesn't. Context compaction won't erase what you've recorded in files.

---

## The full loop at a glance

| Step | Automatic | Explicit |
|------|-----------|---------|
| Session start | SessionStart hook surfaces git changes | `/keel:context` |
| Planning | — | `/keel:plan` |
| Pre-flight review | Runs at end of `/keel:plan` | `--no-review` to skip |
| Building | PostToolUse formats, Stop hook flags signals | `/keel:adr`, `/keel:invariant`, `/keel:prd` |
| Review | — | `/keel:review` |
| Security | Pre-push hook scans on every push | `/keel:audit` |
| End of session | PreCompact reminds you | `/keel:session` |

## Check governance health anytime

```
/keel:doctor
```

Shows what's healthy, what's outdated, and what to fix — in under a second.
