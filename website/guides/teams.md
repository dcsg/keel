# Teams

**The problem:** Your team uses Claude Code. Every engineer gets different output — different error handling, different architectural choices, different levels of quality. The junior engineer writes handlers with DB calls. The new hire doesn't know about the DDD boundaries you established six months ago.

Keel fixes this by making the standards and decisions the same for everyone.

## How it works

One engineer runs `/keel:init`, commits the output, and pushes. Every other engineer gets:
- The same coding standards enforced automatically — `.claude/rules/`
- The same specialist agents installed — `.claude/agents/`
- The same project context at session start — `docs/soul.md`, decisions, invariants
- The same hooks — git-aware SessionStart, Stop signal detection, PreCompact recovery

```bash
git add .claude/ .keel/ docs/soul.md docs/product/ CLAUDE.md
git commit -m "chore: add keel guardrails and context"
git push
```

No per-developer setup. No drift.

## What consistency looks like

**Before keel — three engineers, three styles:**

```go
// Engineer 1 (experienced, remembers the patterns)
func (h *UserHandler) Create(w http.ResponseWriter, r *http.Request) {
    cmd, err := h.decoder.Decode(r)
    if err != nil { h.respond.BadRequest(w, err); return }
    if err := h.userService.Create(r.Context(), cmd); err != nil {
        h.respond.Error(w, err); return
    }
    h.respond.Created(w)
}

// Engineer 2 (newer, didn't get the memo)
func CreateUser(w http.ResponseWriter, r *http.Request) {
    var user User
    json.NewDecoder(r.Body).Decode(&user)
    db.Save(&user)
    w.WriteHeader(201)
}

// Engineer 3 (different session, different Claude)
func handleUserCreate(w http.ResponseWriter, r *http.Request) {
    body, _ := io.ReadAll(r.Body)
    var req CreateUserRequest
    json.Unmarshal(body, &req)
    result := database.CreateUser(req)
    json.NewEncoder(w).Encode(result)
}
```

**After keel — same rules, same output:**

All three engineers get handlers that delegate to the service layer, return errors properly, and follow your DDD boundaries — because they all read the same `.claude/rules/` files.

## Onboarding a new teammate

New engineer clones the repo, opens it in Claude Code, runs:
```
/keel:team setup
```

```
Keel Team Setup — Orders API

  ✅ Git configured (Jane Smith <jane@example.com>)
  ✅ Claude Code v2.1.70
  ✅ keel_version: 3.1 (installed: 3.1)
  ✅ LINEAR_API_KEY set
  ⚠️  GITHUB_TOKEN not set
      Get a token (repo scope): https://github.com/settings/tokens
      Add to ~/.zshrc: export GITHUB_TOKEN="ghp_..."

1 item needs attention. Fix it, then run /keel:context to load project context.
```

Once all green, they run `/keel:context` and they're productive from their first session. No handoff docs. No onboarding checklist. The project teaches itself.

## Shared architectural decisions

Every ADR you capture is available to every engineer:

```
docs/decisions/
├── 001-ddd-bounded-contexts.md    ← why you went DDD
├── 002-postgresql-over-mongodb.md ← the tradeoffs you evaluated
├── 003-chi-over-gin.md            ← why Chi for routing
└── 004-decimal-for-money.md       ← never float64
```

When a new engineer asks Claude "why do we use decimal for money?", Claude already knows — because it read the ADR. The decision doesn't live only in the head of whoever was there when it was made.

## Keeping rules in sync

When keel releases a new version, one engineer upgrades and commits the changes:

```
/keel:upgrade   ← shows what changed, applies with confirmation
```

```
WHAT'S NEW
─────────────────────────────────────────────────────
v3.1 — Stop hook JSON fix, hooks migrated to ~/.keel/hooks/ scripts

KEEL UPGRADE
─────────────────────────────────────────────────────
Version:  3.0 → 3.1
Hooks:    2 updated (Stop hook JSON fix, PreCompact migration)
Agents:   1 updated (staff-security improvements)
─────────────────────────────────────────────────────
Apply? (y/n)
```

```bash
git add .claude/ .keel/config.yaml
git commit -m "chore: upgrade keel to 3.1"
git push
```

The whole team gets the upgrade on next pull.

## Shared specialist agents

Agents committed in `.claude/agents/` are available to everyone. Add one:

```
/keel:agents add principal-data
```

Commit the file. The whole team gets Principal Data on next pull — no individual setup.

## Check health across the team

```
/keel:doctor
```

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL DOCTOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 [ok]   keel 3.1 (installed: 3.1)
 [ok]   .keel/config.yaml valid
 [ok]   docs/soul.md exists
 [ok]   docs/decisions/ — 4 ADRs
 [ok]   docs/invariants/ — 2 invariants
 [ok]   .claude/rules/ — 6 packs installed
 [ok]   SessionStart hook
 [ok]   Stop hook
 [ok]   6 agents installed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 12 passed, 0 warnings, 0 failures
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If it's green for you, it's green for your teammates. The governance setup is the same because it's version-controlled.
