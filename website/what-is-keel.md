# What is Keel?

Keel is a context engine for Claude Code. It installs your coding standards as rules Claude reads automatically, and loads your project memory at the start of every session — so Claude behaves like a senior engineer who's been on the team for months, not a stateless code generator.

## Who it's for

**You, if you've ever:**
- Started a Claude session and spent the first 5 minutes re-explaining your architecture
- Seen Claude write `panic("not implemented")` in Go when you've told it a hundred times to return errors
- Had Claude ignore your ADRs because it didn't know they existed
- Wished your whole team got the same quality output from Claude, not just you

**In short:** developers who use Claude Code seriously and are tired of getting inconsistent results.

## The problem in one session

```
You:    "build the payment handler"
Claude: func HandlePayment(w http.ResponseWriter, r *http.Request) {
            // ... 80 lines of business logic in the handler
            panic("stripe not configured")
        }

You:    "I told you — no business logic in handlers, return errors, use the service layer"
Claude: "You're right, let me fix that..."

// Next session — same conversation, same mistakes
```

Not because Claude is incapable. Because it started the session with no memory of your standards.

## The solution

```bash
/keel:init
```

Describe your project once. Keel installs your standards in `.claude/rules/` — files Claude reads automatically before writing any code. It generates your `soul.md`, your `CLAUDE.md`, your agents. Everything in place.

```
// Same session, after keel:init

You:    "build the payment handler"
Claude: // Thin handler, delegates to PaymentService
        // Error returned, not panicked
        // Follows your DDD boundaries automatically
        // Because it read .claude/rules/go.md and .claude/rules/architecture.md
        // Before writing a single line
```

The rules don't change. The reminders disappear.

## Three things keel installs

### Guardrails — `.claude/rules/`

One `.md` file per topic. Path-conditional — Go rules only fire on `.go` files, framework rules only on their types. No noise on irrelevant files.

```
.claude/rules/
├── code-quality.md       ← every file
├── testing.md            ← every file
├── security.md           ← every file
├── error-handling.md     ← every file
├── go.md                 ← **/*.go only
└── chi.md                ← **/*.go only
```

### Specialist agents — `.claude/agents/`

Role-based agents with defined expertise, domain constraints, and transparent reasoning. Each agent names its role before starting so you know exactly what lens is being applied.

```
.claude/agents/
├── principal-architect.md   ← system design, ADRs, trade-offs
├── staff-engineer.md        ← implementation, code review
├── staff-security.md        ← OWASP, threat modeling
├── principal-dba.md         ← schema design, migration safety
├── staff-qa.md              ← testing strategy, coverage
└── ...                      ← stack-matched on init
```

### Context — `docs/`

Project memory that loads at session start. Claude knows who the project is — not just what files exist. Persisted to auto-memory so it's available without running `/keel:context` every time.

```
docs/
├── soul.md               ← identity, stack, non-negotiables
├── decisions/            ← architecture decision records
├── invariants/           ← hard constraints Claude must never violate
└── product/
    ├── spec.md           ← what you're building
    ├── prds/             ← feature requirements
    └── plans/            ← execution plans with progress
```

## Natural language, not slash commands

After init, you don't need to remember commands. Just talk:

> "what's our status?"
> "what should we work on next?"
> "load context"
> "let's plan the bulk upload feature"

Claude knows to run the right keel command. You have a conversation, not a CLI session.

## Why Claude Code only

Keel depends on features other tools don't have:

| Feature | Claude Code | Cursor | Copilot | Windsurf |
|---------|:-----------:|:------:|:-------:|:--------:|
| Path-conditional rules | ✓ | ✗ | ✗ | ✗ |
| SessionStart / Stop hooks | ✓ | ✗ | ✗ | ✗ |
| Pre-compact recovery hook | ✓ | ✗ | ✗ | ✗ |
| Slash commands | ✓ | ✗ | ✗ | ✗ |
| Custom specialist agents | ✓ | ✗ | ✗ | ✗ |
| Auto-memory persistence | ✓ | ✗ | ✗ | ✗ |
| MCP server wiring | ✓ | ✗ | ✗ | ✗ |

The knowledge base (soul.md, ADRs, docs) is plain markdown that works anywhere. The guardrail loop only works in Claude Code.
