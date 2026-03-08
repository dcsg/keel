# Daily Workflow

The problem keel solves is session-to-session drift — Claude forgetting your standards, losing your decisions, starting over every time. The daily workflow is how you prevent that.

```
Start session → Load context → Build → Review → Capture → End session
```

Most of this is automatic. The explicit steps are one command each.

---

## 1. Starting a session

**The problem without keel:** You open Claude Code, start describing what you want to build, and realize five messages in that Claude has no idea about your architecture or patterns.

**What happens automatically with keel:**

The SessionStart hook fires and tells you what changed since last time:

```
📋 Keel — since your last session (2d ago):
   3 migration/schema files changed
   Relevant agents: principal-dba
   Run /keel:context to load full project context.
```

If nothing significant changed:
```
📋 Keel — 2d since last session. Run /keel:context to load context.
```

**Then run:**
```
/keel:context
```

This loads your soul, active plan, decisions, invariants, and installed rules into Claude's session. After this, Claude knows your project — not just your files.

---

## 2. Planning work

**The problem without keel:** You describe a feature, Claude starts coding, and halfway through you discover the migration is missing a rollback, there's no index on the query column, and the API contract breaks a mobile client.

**With keel:**
```
/keel:plan add webhook delivery with retry logic
```

Keel interviews you (3–6 focused questions), scans the codebase for relevant patterns, breaks work into phases, then runs a pre-flight specialist review before execution:

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

Fix the migration gap now. It takes 5 minutes. After implementation it takes an hour.

Skip pre-flight for simple tasks:
```
/keel:plan --no-review fix typo in error message
```

---

## 3. Building

Just build. Keel works in the background:

**PostToolUse hook** auto-formats after every edit — gofmt, prettier, black, rubocop. No manual formatter runs.

**Stop hook** watches every response for signals worth capturing:

```
💡 ADR candidate — run /keel:adr to capture it.
📄 Doc gap: new /webhooks/retry endpoint — run /keel:docs to review.
🔒 Security-sensitive domain — run /keel:audit before shipping.
```

When you see one of these, run the command. That decision becomes a permanent record, not a conversation that gets lost.

**Update your plan progress table** as phases complete — it's the state that survives context compaction:

```
| Phase | Status | Updated    |
|-------|--------|------------|
| 1     | done   | 2026-03-08 |
| 2     | in-progress | 2026-03-08 |
```

---

## 4. Reviewing what you built

**The problem without keel:** You push code that has a missing index, a security gap you missed at 6pm, or an API response that breaks an existing client. You find out in code review or production.

**With keel:**
```
/keel:review             ← review last commit
/keel:review --branch    ← review everything on this branch
```

Keel classifies changed files by domain and routes to the right specialists automatically:

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

For security-sensitive features (auth, payments, PII), also run:
```
/keel:audit
```

---

## 5. Ending a session

**The problem without keel:** You make three architectural decisions during a session. Context compacts. Next session you can't remember why you chose exponential backoff, what the new endpoint is called, or whether you captured the constraint about idempotency keys.

**What happens automatically:**

The PreCompact hook fires before context compression:
```
⚠️ Context compacting. Update your active plan's progress table NOW.
   Run /keel:session to capture decisions before context is lost.
```

**Run explicitly at end of day:**
```
/keel:session
```

```
SESSION SUMMARY — 2026-03-08
─────────────────────────────────────────────────────
Built:    webhook delivery (5 files), DB migration
Commits:  feat(webhooks): delivery with retry logic
Updated:  PLAN-007 phase 2 → done

Possible captures:
  💡 ADR: exponential backoff over fixed intervals
     → Run /keel:adr to capture

  📄 Doc gap: POST /webhooks/retry — new endpoint
     → Run /keel:docs to review
─────────────────────────────────────────────────────
```

Capture what matters. What you save in `docs/decisions/` is available to Claude in every future session.

---

## The full loop at a glance

| Step | Automatic | Explicit |
|------|-----------|---------|
| Session start | SessionStart hook surfaces git changes | `/keel:context` |
| Planning | — | `/keel:plan` |
| Pre-flight | Runs at end of `/keel:plan` | `--no-review` to skip |
| Building | PostToolUse formats, Stop hook flags signals | `/keel:adr`, `/keel:invariant` |
| Review | — | `/keel:review` |
| Security | Pre-push hook scans on push | `/keel:audit` |
| End of session | PreCompact reminds you | `/keel:session` |
