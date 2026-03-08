# What is Keel?

**Your coding standards, enforced. Your decisions, remembered.**

Keel makes Claude behave like a senior engineer who's been on your project for months — not a stateless assistant who forgets everything between sessions.

## The problem every Claude Code user hits

You've told Claude your patterns. You've explained your architecture. You've corrected the same mistakes ten times. And then a new session starts, and you do it all over again.

This isn't a Claude problem. It's a setup problem. Claude is stateless by default. Without structure, every session starts from zero.

Here's what that looks like:

```
// Session 1
You:    "No business logic in handlers. Use the service layer. Return errors, don't panic."
Claude: "Got it, I'll follow those patterns."

// Session 2
You:    "build the order handler"
Claude: func HandleOrder(w http.ResponseWriter, r *http.Request) {
            order := &Order{}
            db.Create(order)          // direct DB call in handler
            if err != nil {
                panic(err)            // told you a hundred times
            }
        }

You:    "I told you — service layer, return errors."
Claude: "You're right, let me fix that..."

// Session 3. Same conversation.
```

On a team, it's worse. Every engineer gets a different version of Claude's guess.

## The fix is structural, not conversational

You can't fix a stateless tool by talking to it more. You fix it by installing state.

```
/keel:init
```

Describe your project once. Keel installs your standards in `.claude/rules/` — files Claude reads automatically before writing any code. It generates your `docs/soul.md`, your `CLAUDE.md`, your specialist agents. Everything in the right place.

```
// After /keel:init
You:    "build the order handler"
Claude: // Thin handler — delegates to OrderService
        // Returns error — no panics
        // No DB calls — service layer handles persistence
        // Because it read .claude/rules/go.md, architecture.md, error-handling.md
        // before writing a single line
```

The reminders stop. The patterns hold. Every session.

## Three things keel installs

### 1. Guardrails — `.claude/rules/`

One `.md` file per standard. Path-conditional — each rule only fires on the files it's relevant to. No noise.

```
.claude/rules/code-quality.md       ← fires on every file
.claude/rules/error-handling.md     ← fires on every file
.claude/rules/go.md                 ← fires on *.go files only
.claude/rules/chi.md                ← fires on *.go files only
```

**What gets enforced without being told:**
- No `panic` — return errors with context
- No business logic in HTTP handlers
- No raw SQL string concatenation — parameterized queries only
- No `any` in TypeScript — typed all the way down
- Test behavior, not implementation

### 2. Project memory — `docs/`

Claude knows your project identity, not just your file structure.

```
docs/soul.md          ← what the project is, stack, non-negotiables
docs/decisions/       ← why you chose PostgreSQL, why you went DDD
docs/invariants/      ← constraints that must NEVER be violated
```

Loaded automatically at session start. The git-aware SessionStart hook tells you what changed since last time and which specialist agents are relevant:

```
📋 Keel — since your last session (2d ago):
   3 migration files, 2 API files changed
   Relevant agents: principal-dba, senior-api
   Run /keel:context to load full project context.
```

### 3. Specialist agents — `.claude/agents/`

Role-based agents matched to your stack. Each applies a specific domain lens.

```
principal-architect    ← system design, ADRs, bounded contexts
staff-security         ← OWASP, threat modeling, auth patterns
principal-dba          ← schema design, migration safety, N+1 queries
senior-api             ← API contracts, versioning, breaking changes
staff-qa               ← testing strategy, coverage, flaky tests
```

Used in `/keel:plan`, `/keel:review`, and `/keel:audit` — or called directly.

## What changes day-to-day

**Planning a feature:**

Before: describe the feature, start coding, discover the migration is missing a rollback halfway through.

After:
```
/keel:plan add stripe webhook delivery with retry logic
```
Pre-flight review before you touch code:
```
PRE-FLIGHT REVIEW
─────────────────────────────────────────
PRINCIPAL DBA
  🔴  Migration has no rollback — add DOWN migration before executing
  🟡  No index on webhooks.status — this column is queried in retry loop

SENIOR API
  🟢  Endpoint contract looks stable
```
Fix the migration gap now. Takes 5 minutes. Would have taken an hour after.

**After implementation:**
```
/keel:review    ← domain-specific specialist review
/keel:audit     ← OWASP scan — catches what you miss tired at 6pm
```

**End of session:**
```
SESSION SUMMARY
─────────────────────────────────────────
Possible captures:
  💡 ADR: exponential backoff over fixed intervals → /keel:adr
  📄 Doc gap: POST /webhooks/retry is new, not in API docs → /keel:docs
```

Those decisions become ADRs in `docs/decisions/` — available to Claude in every future session.

## For teams

Commit `.claude/` and `docs/` to your repo. Every teammate gets:
- The same coding standards enforced — no per-developer configuration
- The same specialist agents — Principal Architect, Staff Security, Principal DBA
- The same architectural decisions loaded — no "why did we do it this way?" conversations
- The same invariants — hard constraints that never get violated by accident

The junior engineer doesn't reinvent your error handling. The new hire understands the architecture on day one.

## Why Claude Code only

| Feature | What keel uses it for |
|---------|----------------------|
| Path-conditional rules | Standards that fire only on relevant files |
| SessionStart hook | Git-aware context reminder at session open |
| Stop hook | Detect ADR/invariant/doc-gap signals after responses |
| PreCompact hook | Protect plan state before context compaction |
| Specialist agents | Domain-expert review and planning |
| Slash commands | Nine focused commands, each does one thing |

Other tools don't have these primitives. The knowledge base (soul.md, ADRs, docs) is plain markdown. The enforcement loop only works in Claude Code.
