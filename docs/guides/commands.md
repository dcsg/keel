# Command Reference

Keel provides 5 slash commands for Claude Code.

---

## `/keel:init`

**Intelligent onboarding — detect project, infer architecture, install guardrails.**

Run once per project to set up keel. Safe to re-run — it will ask before overwriting anything.

**Flow:**
1. Detects greenfield vs established project
2. Interviews you (greenfield) or audits the codebase (established)
3. Shows recommended rule packs with a toggle UI
4. Generates `.keel/config.yaml`, `.claude/rules/`, `docs/soul.md`, `CLAUDE.md` block, `.claude/settings.json`

**Established project output:**
```
Codebase Analysis:

  Stack:       Go 1.22, Chi v5, Postgres
  Structure:   Domain-driven (internal/billing, internal/users)
  Tests:       47 test files, using testing + testify
  CI:          GitHub Actions
  Linting:     golangci-lint
  Age:         ~8 months, 312 commits

  Recommended rules:
  1. [x] code-quality
  2. [x] testing          — testify detected
  3. [x] security         — DB access detected
  4. [x] error-handling
  5. [ ] frontend         — no frontend detected
  6. [x] architecture     — DDD structure detected
  7. [x] go               — Go detected
  8. [x] chi              — Chi detected

  Type numbers to toggle (e.g. "5 6"), or press enter to accept:
```

**Guards:**
- If `.keel/config.yaml` already exists: asks before reconfiguring
- If `.dof/` exists: suggests `/keel:migrate` instead
- Never overwrites `CLAUDE.md` — uses sentinel merge
- Never overwrites existing `docs/soul.md`

---

## `/keel:context`

**Load all project context into the current session.**

Run at the start of a session or after compaction. The PreToolUse hook reminds you automatically.

**What it loads:**
- `docs/soul.md` — project identity and stack
- Active plan in `docs/product/plans/` — progress table and current phase
- `docs/product/spec.md` — product vision and roadmap
- `docs/decisions/*.md` — architecture decisions
- `docs/invariants/*.md` — hard constraints
- `.claude/rules/` — installed rule packs

**Example output:**
```
Context loaded for: Invoicer

  Soul:        SaaS invoicing for freelancers. Go + Next.js + Postgres.
  Plan:        PLAN-billing-engine.md — Phase 3 of 6 active
  Product:     spec.md exists, 4 PRDs
  Decisions:   3 decision records
  Invariants:  2 invariants
  PRDs:        4 product requirements
  Rules:       6 rule packs installed
  Tickets:     Linear (GLO team)
```

---

## `/keel:plan [ticket-id or description]`

**Create a phased execution plan through interview and codebase analysis.**

**Arguments:** optional ticket ID (e.g. `GLO-42`) or task description.

**Flow:**
1. Loads project context
2. Fetches ticket if ID provided
3. Asks 3–6 targeted questions
4. Audits the codebase for relevant files
5. Generates phases with model assignments and parallelism analysis
6. Saves plan to `docs/product/plans/PLAN-{slug}.md`

**Model assignment:**

| Model | Use When | Est. Cost |
|-------|----------|-----------|
| Haiku | Migrations, config, simple CRUD, docs | ~$0.01/phase |
| Sonnet | Business logic, UI, API integrations, refactoring | ~$0.08/phase |
| Opus | Security, algorithms, architecture, novel problems | ~$0.80/phase |

**Plan format includes:**
- Progress table (persistent state across compaction)
- Execution strategy (dependency graph, parallel waves)
- Per-phase prompts (self-contained — each phase can run independently)
- Shell-safe completion promises

**Example:**
```
/keel:plan GLO-42
/keel:plan "add webhook delivery with retry logic"
```

---

## `/keel:status`

**Dashboard showing plan progress and governance health.**

Run to see where you are in a plan, what's healthy, and what needs attention.

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL STATUS — Invoicer
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ACTIVE PLAN
 ───────────
 PLAN-billing-engine
 Progress: 2/6 phases (33%)

 | Phase | Title              | Status      |
 |-------|--------------------|-------------|
 | 1     | DB schema          | done        |
 | 2     | Repository layer   | done        |
 | 3     | Service layer      | in-progress |
 | 4     | API handlers       | -           |
 | 5     | Frontend           | -           |
 | 6     | Tests              | -           |

 WHAT'S NEXT
 ───────────
 Phase 3 — Service layer
   • Implement BillingService with invoice CRUD
   • Wire up repository, add domain events
   • Use Sonnet model

 RULES
 ─────
 6 packs installed:
   code-quality.md  testing.md  security.md
   error-handling.md  go.md  chi.md

 GOVERNANCE
 ──────────
 Soul:        exists
 Decisions:   3 records
 Invariants:  2 constraints
 Product:     spec.md + 4 PRDs
 Tickets:     Linear (GLO)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Also writes `docs/STATUS.md` for a persistent, committable snapshot.

---

## `/keel:intake`

**Onboard existing docs into keel's standard structure.**

Run on established projects after `/keel:init` to organize scattered documentation.

**What it finds:**
- README files at any level
- Existing ADRs, RFCs, decision records
- Product specs, PRDs, requirements docs
- API documentation, runbooks, deployment guides
- `.dof/` or `.conductor/` legacy content

**Example:**
```
Found 11 documentation files:

  Architecture / Decisions:
    docs/adr/001-use-postgres.md     → docs/decisions/001-use-postgres.md
    docs/adr/002-event-driven.md     → docs/decisions/002-event-driven.md

  Product / Requirements:
    docs/product-spec.md             → docs/product/spec.md
    docs/requirements/invoicing.md   → docs/product/prds/invoicing.md

  Reference:
    docs/api.md                      → docs/reference/api.md
    CONTRIBUTING.md                  → docs/reference/contributing.md

  Already in place:
    README.md                        → (keep as-is)

Proceed with this organization? (y/n/edit)
```

Files are **copied**, not moved. Originals are preserved until you delete them.
