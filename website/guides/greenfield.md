# Greenfield Projects

**The problem:** You're starting fresh. You want Claude to follow your architecture from commit one — not drift into whatever patterns it defaults to.

Keel is at its best here. Describe what you're building once. Everything gets installed before you write a line of code.

## Flow

1. Create your repo and make an initial commit
2. Open in Claude Code
3. Run `/keel:init`
4. Describe your project in plain language

## Example

```
/keel:init

> What are you building?

A SaaS platform for restaurant inventory management. Go backend with
Chi router, PostgreSQL, following DDD with bounded contexts for
inventory, orders, and suppliers. React + TypeScript frontend.
```

Keel infers:
- **Architecture:** DDD with 3 bounded contexts
- **Stack:** Go, Chi, TypeScript, React
- **Rules to install:** code-quality, testing, security, error-handling, architecture, go, chi, typescript

Shows all available rules and agents with recommended items checked. Toggle by name or say "looks good" to proceed.

## What changes immediately

Before keel, Claude would write:

```go
// Claude's default: flat structure, mixed concerns
func HandleCreateOrder(w http.ResponseWriter, r *http.Request) {
    var order Order
    json.NewDecoder(r.Body).Decode(&order)
    db.Create(&order)                          // DB in handler
    sendConfirmationEmail(order.CustomerEmail) // side effect in handler
    w.WriteHeader(http.StatusCreated)
}
```

After `/keel:init` with DDD + Go rules:

```go
// Claude reads architecture.md + go.md before writing
func (h *OrderHandler) CreateOrder(w http.ResponseWriter, r *http.Request) {
    cmd, err := h.decoder.Decode(r)
    if err != nil {
        h.respond.BadRequest(w, err)
        return
    }
    if err := h.orderService.PlaceOrder(r.Context(), cmd); err != nil {
        h.respond.Error(w, err)
        return
    }
    h.respond.Created(w)
}
```

The handler delegates. Errors are returned. Business logic lives in the service layer. Not because you told Claude — because it read the rules.

## What gets generated

```
your-project/
├── docs/
│   ├── project-context.md   # seeded from your description
│   ├── decisions/           # ready for your first ADR
│   ├── invariants/          # hard constraints
│   └── product/
│       ├── spec.md          # product spec stub
│       └── plans/
├── .keel/
│   └── config.yaml          # keel_version, stack, rules
└── .claude/
    ├── rules/               # 7 rule files enforcing your standards
    ├── agents/              # specialist agents matched to your stack
    ├── settings.json        # hooks: SessionStart, Stop, PreCompact
    └── CLAUDE.md            # project context block
```

## Tips

- The more specific your description, the better keel's inference — mention your architecture pattern explicitly
- Commit everything immediately — your team benefits from the first push
- Your first ADR should be the architecture decision you just made. Run `/keel:adr` and describe it
