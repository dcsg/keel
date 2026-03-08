# Keel

**Your coding standards, enforced. Your decisions, remembered.**

No more hoping Claude remembers. No more re-explaining your architecture.

```bash
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

---

## The problem

Every Claude Code session starts from zero. It doesn't know your error handling patterns. It doesn't know you chose DDD three months ago and why. It doesn't know your team agreed never to put business logic in HTTP handlers.

So it guesses. And every engineer on your team gets a different guess.

```
You:    "build the payment handler"

Claude: func HandlePayment(w http.ResponseWriter, r *http.Request) {
            db.Query("INSERT INTO payments...")  // business logic in handler
            panic("stripe not configured")       // told you a hundred times
        }

You:    "I said — no DB calls in handlers, return errors don't panic,
         use the service layer. We have an ADR for this."

Claude: "You're right, let me fix that..."

// Tomorrow. New session. Same mistakes.
```

Not because Claude is incapable. Because it started with no memory of your standards.

---

## The fix

```
/keel:init
```

Describe your project once. Keel installs your standards where Claude reads them automatically — before writing a single line of code.

```
You:    "build the payment handler"

Claude: // Thin handler — delegates to PaymentService
        // Returns error — no panics
        // No DB calls — service layer handles persistence
        // Named constants — no magic strings
        // Because it read .claude/rules/go.md, architecture.md, error-handling.md
        // before touching your code
```

The reminders disappear. The standards stick.

---

## What keel installs

**Guardrails** — `.claude/rules/` files Claude reads automatically. Path-conditional: Go rules only fire on `.go` files, framework rules only on their types. No noise on irrelevant files.

```
.claude/rules/code-quality.md       ← every file
.claude/rules/testing.md            ← every file
.claude/rules/security.md           ← every file
.claude/rules/error-handling.md     ← every file
.claude/rules/go.md                 ← **/*.go only
.claude/rules/chi.md                ← **/*.go only
```

**Specialist agents** — `.claude/agents/` matched to your stack. Principal Architect for design decisions. Staff Security for OWASP review. Principal DBA for migrations. They know your project and apply the right lens.

**Project memory** — `docs/soul.md`, `docs/decisions/`, `docs/invariants/`. Claude knows your project identity, architectural decisions, and hard constraints. Loaded automatically at session start via git-aware hooks.

---

## How it works in practice

### Session start — automatic
```
📋 Keel — since your last session (2d ago):
   3 migration files, 2 API files changed
   Relevant agents: principal-dba, senior-api
   Run /keel:context to load full project context.
```

### Planning a feature
```
/keel:plan add webhook delivery with retry logic
```
Keel interviews you, scans the codebase, breaks work into phases, and runs a pre-flight specialist review:
```
PRE-FLIGHT REVIEW
─────────────────────────────────────────
PRINCIPAL DBA
  🔴  Migration has no rollback — add DOWN migration
  🟡  No index on webhooks.status — queried in retry loop

SENIOR API
  🟢  Endpoint contract looks stable
```

### After implementation
```
/keel:review              ← specialist review of last commit
/keel:audit               ← OWASP scan before shipping
/keel:session             ← capture decisions before context is lost
```

### End of session
```
SESSION SUMMARY
─────────────────────────────────────────
Built:    webhook delivery (5 files), DB migration

Possible captures:
  💡 ADR: exponential backoff over fixed intervals → /keel:adr
  📄 Doc gap: POST /webhooks/retry — new endpoint → /keel:docs
```

---

## Commands

| Command | What it does |
|---------|-------------|
| `/keel:init` | Detect project, infer architecture, install guardrails |
| `/keel:context` | Load soul, decisions, invariants, and plan into session |
| `/keel:plan` | Phased execution plan with pre-flight specialist review |
| `/keel:review` | Post-implementation review routed to domain specialists |
| `/keel:audit` | OWASP security scan via staff-security agent |
| `/keel:session` | End-of-session sweep — capture decisions and doc gaps |
| `/keel:adr` | Capture an architecture decision record |
| `/keel:upgrade` | Upgrade hooks, agents, and rules to latest keel version |
| `/keel:doctor` | Validate governance setup, check version, report health |

---

## For teams

Commit `.claude/` and `docs/` to your repo. Every teammate gets:
- The same coding standards enforced automatically
- The same specialist agents installed
- The same project context loaded at session start
- The same architectural decisions and invariants

No per-developer setup. No drift between teammates. The junior engineer doesn't reinvent your patterns. The new hire understands the architecture from day one.

---

## Rule packs

| Tier | Rule | What it enforces |
|------|------|-----------------|
| Base | `code-quality` | SOLID, naming, size limits, no dead code |
| Base | `testing` | TDD, behavior-focused, mock boundaries |
| Base | `security` | Input validation, no secrets in code, OWASP |
| Base | `error-handling` | Typed errors, context enrichment, no silent catches |
| Lang | `go` | Error wrapping, interfaces, goroutine safety |
| Lang | `typescript` | Strict types, no `any`, async/await, Zod |
| Lang | `python` | Type hints, PEP 8, pytest patterns |
| Framework | `chi` | Thin handlers, middleware chains |
| Framework | `nextjs` | App Router, Server Components, Server Actions |
| Framework | `laravel` | Eloquent, Form Requests, Jobs |
| Framework | `django` | Models, views, ORM optimization |

---

## Claude Code only

Keel depends on features other tools don't have:

| Feature | Claude Code | Cursor | Copilot | Windsurf |
|---------|:-----------:|:------:|:-------:|:--------:|
| Path-conditional rules | ✓ | ✗ | ✗ | ✗ |
| SessionStart / Stop hooks | ✓ | ✗ | ✗ | ✗ |
| Pre-compact recovery | ✓ | ✗ | ✗ | ✗ |
| Slash commands | ✓ | ✗ | ✗ | ✗ |
| Specialist agents | ✓ | ✗ | ✗ | ✗ |

The knowledge base (soul.md, ADRs, docs) is plain markdown that works anywhere. The guardrail loop only works in Claude Code.

---

## No build step. No runtime. No magic.

Every file is a `.md` or `.yaml` you can read, edit, and version-control. Nine commands. That's the entire interface.
