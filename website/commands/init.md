# /keel:init

Intelligent onboarding. Detects your project, infers architecture and rules, and installs everything in three steps.

## Usage

```
/keel:init
```

No arguments. Keel figures out the rest.

## The three steps

### [1/3] Scan

Keel scans your codebase — languages, frameworks, linters, existing docs, commit conventions, and governance tooling — and shows what it found:

```
[1/3] Scanning project...

  Code:       Go project, 142 files
              Chi framework, PostgreSQL
  Build:      make build
  Test:       make test
  Lint:       golangci-lint (.golangci-lint.yaml)
  AI config:  CLAUDE.md (34 lines)
  Docs:       3 ADRs in docs/decisions/
  Commits:    conventional commits detected
  Governance: archway.yaml detected — architecture pack skipped
```

For greenfield projects (no code), keel asks one question:

```
What are you building?

  Example: "A multi-tenant SaaS for restaurant inventory.
  Go + Chi, PostgreSQL, DDD with bounded contexts."

Describe yours in a few sentences:
```

### [2/3] Configure

All available rules and agents in a single view. Recommended items are checked, everything else is available to toggle on:

```
Rules (✓ = recommended for your stack):

  Base:
    [x] code-quality       — naming, structure, size limits
    [x] testing            — TDD, mock boundaries
    [x] security           — input validation, no hardcoded secrets
    [x] error-handling     — typed errors, context wrapping
    [ ] api                — REST conventions, pagination, versioning
    [ ] architecture       — layer boundaries, import discipline (skipped: archway detected)
    [ ] database           — migrations, indexes, N+1 prevention
    ...

  Language:
    [x] go                 — error handling, interfaces, goroutines
    ...

  Framework:
    [x] chi                — thin handlers, middleware chains
    ...

Agents (✓ = matched to your stack):

    [x] architect          — architecture review
    [x] backend            — Go patterns
    [x] dba                — PostgreSQL
    [x] qa                 — test strategy
    [x] docs               — documentation
    [ ] security           — OWASP, auth, secrets
    [ ] api                — API design, contracts
    ...

SDLC:
  Commits:    conventional commits (detected from git log)
  PR template: yes (GitHub repo detected)

Toggle items by name (e.g. "add api", "add security"),
or say "looks good" to proceed.
```

One screen. Say "looks good" when the selection is right. Toggle anything by name.

### [3/3] Install

```
[3/3] Installing...

  ✓ Config          .keel/config.yaml
  ✓ Project context docs/project-context.md
  ✓ Rules           6 packs → .claude/rules/
  ✓ Agents          5 specialists → .claude/agents/
  ✓ Hooks           .claude/settings.json (9 behaviors)
  ✓ CLAUDE.md       updated
  ✓ Directories     docs/architecture/, docs/plans/, docs/product/
```

## What gets installed

| File | Purpose |
|------|---------|
| `.keel/config.yaml` | Governance configuration |
| `.claude/rules/*.md` | Rule packs (tagged `<!-- keel:generated -->`) |
| `.claude/agents/*.md` | Specialist agents matched to your stack |
| `.claude/settings.json` | 9 automatic behaviors (see below) |
| `CLAUDE.md` | Project block (safe merge — never overwrites existing content) |
| `docs/project-context.md` | Project identity |
| `docs/architecture/` | Decisions + invariants directories with READMEs |
| `docs/product/` | PRDs, specs, plans directories with READMEs |

### Automatic behaviors

9 lifecycle hooks, described by what they do:

| Behavior | What happens |
|----------|-------------|
| Session refresh | Surfaces what changed since last session |
| Governance check | Validates setup before Claude writes code |
| Auto-format | Formats code after every edit |
| Decision detection | Suggests ADR capture when decisions are made |
| Plan injection | Injects active plan phase on every prompt |
| Context preservation | Preserves plan state before compaction |
| Context recovery | Recovers plan + invariants after compaction |
| Agent logging | Logs agent activity, enforces quality gates |
| Rule tracking | Logs which rule packs load each session |

### Agents

Always installed: `architect`, `docs`, `qa`

Stack-matched: Go → `backend`, `dba` · TypeScript + React → `frontend`, `ux` · security keywords → `security`

Manage with `/keel:agents`.

## Re-running

Running `/keel:init` on an existing keel project handles three scenarios:

**Team member joining** — config exists, local files match: "Nothing to do." If gaps exist (missing rules, no hooks), keel syncs the gaps without overwriting anything.

**Reconfigure** — shows exactly what will change before writing anything. Files you've manually edited (no `<!-- keel:generated -->` tag) are never overwritten.

**Upgrade** — for version upgrades, use `/keel:upgrade` instead.

## Natural language triggers

- "set up keel"
- "initialize governance"
- "configure this project"
