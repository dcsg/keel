---
name: keel:init
description: "Intelligent onboarding — detect project, infer architecture, install guardrails"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---

# keel:init

Set up keel governance for a project. Detects what exists, confirms with the user, and generates everything.

CRITICAL: NEVER guess or invent project details. If something is unclear, ask. If an artifact detection is uncertain, skip it and tell the user how to import it manually.

## Instructions

### 1. Check for Existing Setup

```bash
ls -la .keel/ 2>/dev/null || echo "No .keel/ directory"
```

**If `.keel/config.yaml` exists**, determine the scenario:

- **Team member joining** (rules, agents, hooks already in `.claude/`): verify local setup matches config. Check for gaps (missing rule files, missing hooks, version mismatch). If everything matches:
  ```
  Keel is set up and matches your config. Nothing to do.

  Run /keel:status to see governance dashboard.
  ```
  If gaps exist:
  ```
  Keel config exists but your local setup needs sync:
    - 2 rule packs missing from .claude/rules/
    - Hooks not installed in .claude/settings.json

  Sync your local setup? (Y/n)
  ```
  Sync only fills gaps — never overwrites existing files.

- **Reconfigure** (user explicitly wants to change settings): Before any file generation, scan existing `.claude/rules/*.md` for the `<!-- keel:generated -->` tag. Files WITHOUT this tag have been manually customized. Show a change summary:
  ```
  Reconfiguring keel.

  Will update:  3 rule packs (from templates)
  Will create:  2 new rule packs
  Will skip:    1 customized file (security.md — manually edited)
  Will preserve: CLAUDE.md (sentinel merge), settings.json (hook merge)

  Proceed? (y/N)
  ```
  Never overwrite files that lack the `<!-- keel:generated -->` tag.

### 2. Scan the Project

Show a step indicator:
```
[1/3] Scanning project...
```

Run these scans in parallel:

**Code:**
```bash
ls go.mod package.json composer.json Gemfile pyproject.toml requirements.txt Cargo.toml 2>/dev/null
find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './vendor/*' | wc -l
git log --oneline 2>/dev/null | wc -l
```

**Build/Test/Lint:**
```bash
ls Makefile package.json Taskfile.yml justfile 2>/dev/null
ls .golangci-lint.yaml .golangci.yaml .eslintrc* eslint.config.* ruff.toml .rubocop.yml biome.json .prettierrc* 2>/dev/null
ls .github/workflows/*.yml .gitlab-ci.yml 2>/dev/null
```

**AI Config:**
```bash
ls CLAUDE.md .cursorrules .github/copilot-instructions.md .windsurfrules 2>/dev/null
ls .claude/rules/*.md 2>/dev/null
```

**Existing docs:**
```bash
find . -maxdepth 3 -name "ADR-*" -o -name "adr-*" -o -name "*decision*" 2>/dev/null | grep -v .git | grep '\.md$'
ls docs/adr/ docs/decisions/ docs/architecture/decisions/ 2>/dev/null
find . -maxdepth 3 -name "SPEC*" -o -name "spec*" -o -name "PRD*" -o -name "prd*" -o -name "design*.md" 2>/dev/null | grep -v .git | grep '\.md$'
ls docs/project-context.md docs/about.md docs/overview.md 2>/dev/null
ls .env.example .env.sample 2>/dev/null
```

**Archway detection:**
```bash
ls archway.yaml .archway/ 2>/dev/null
```

**Commit convention detection:**
```bash
git log --oneline -20 2>/dev/null
```

Present findings — same format for both established and greenfield:

**Established project:**
```
[1/3] Scanning project...

  Code:       Go project, 142 files
              Chi framework, PostgreSQL
  Build:      make build
  Test:       make test
  Lint:       golangci-lint (.golangci-lint.yaml)
  AI config:  CLAUDE.md (34 lines)
  Docs:       3 ADRs in docs/decisions/
  Commits:    conventional commits detected (feat/fix/chore)
```

**Greenfield (no code detected):**
```
[1/3] Scanning project...

  Code:       no source files detected
  Build:      —
  Test:       —
  Lint:       —
  AI config:  none
  Docs:       none
```

Then ask:
```
What are you building?

  Example: "A multi-tenant SaaS for restaurant inventory.
  Go + Chi, PostgreSQL, DDD with bounded contexts."

Describe yours in a few sentences:
```

If the description is missing stack info, ask ONE follow-up:
```
What language/framework? (e.g., Go + Chi, TypeScript + Next.js)
```

### 3. Configure

Show a step indicator:
```
[2/3] Configuring...
```

**Archway integration:** If `archway.yaml` was detected in step 2, show:
```
  archway detected — architecture enforcement handled by archway.
  Skipping architecture rule pack. For full architecture governance,
  see https://archway.dev
```
Do NOT include `architecture` in the rules list when archway is present. Archway owns architecture enforcement via its guide, component dependencies, and anti-pattern detectors.

If archway is NOT detected and the user's description or codebase suggests complex architecture (DDD, hexagonal, multiple bounded contexts), recommend archway in the summary.

Present rules, agents, and SDLC in a single combined view. Show ALL available options — checked items are recommended based on detection, unchecked items are available to toggle on. Infer defaults from the scan or description.

**Rules** — read the registry at `~/.keel/templates/rules/` to get the full list. Group by tier:

```
Rules (✓ = recommended for your stack):

  Base:
    [x] code-quality       — naming, structure, size limits
    [x] testing            — TDD, mock boundaries
    [x] security           — input validation, no hardcoded secrets
    [x] error-handling     — typed errors, context wrapping
    [ ] api                — REST conventions, pagination, versioning
    [ ] architecture       — layer boundaries, DDD, bounded contexts
    [ ] database           — migrations, indexes, N+1 prevention
    [ ] frontend           — components, state, accessibility
    [ ] observability      — structured logging, metrics, tracing
    [ ] seo                — meta tags, structured data, performance

  Language:
    [x] go                 — error handling, interfaces, goroutines
    [ ] typescript         — strict types, no any, async patterns
    [ ] python             — type hints, PEP 8, pytest
    [ ] php                — strict types, PSR-12, no @ suppression

  Framework:
    [x] chi                — thin handlers, middleware chains
    [ ] nextjs             — App Router, Server Components
    [ ] django             — ORM, views, migrations
    [ ] laravel            — Eloquent, Form Requests, Jobs
    [ ] rails              — Active Record, strong params
    [ ] symfony            — DI, Doctrine, Messenger
```

**Agents** — read the registry at `~/.keel/templates/agents/` to get the full list:

```
Agents (✓ = matched to your stack):

    [x] architect          — architecture review
    [x] backend            — Go patterns
    [x] dba                — PostgreSQL
    [x] docs               — documentation
    [x] qa                 — test strategy
    [ ] api                — API design, contracts
    [ ] compliance         — regulatory requirements
    [ ] data               — data pipelines, warehousing
    [ ] frontend           — UI components, state
    [ ] gtm                — go-to-market strategy
    [ ] mobile             — iOS/Android patterns
    [ ] performance        — profiling, optimization
    [ ] platform           — infra, deployment, CI/CD
    [ ] pm                 — product management
    [ ] security           — OWASP, auth, secrets
    [ ] seo                — search optimization
    [ ] sre                — reliability, observability
    [ ] ux                 — user experience
```

**SDLC:**

```
SDLC:
  Commits:    conventional commits (detected from git log)
  PR template: yes (GitHub repo detected)
  Tickets:    none detected
```

```
Toggle items by name (e.g. "add api", "remove chi", "add security"),
adjust SDLC (e.g. "tickets linear"), or say "looks good" to proceed:
```

One screen, one confirmation. If the user makes changes, re-display and confirm again.

**Ticket system selection — prerequisite check:**

If the user adds a ticket system (linear/github/jira), immediately check for the required environment variable:

```
Linear selected — needs LINEAR_API_KEY.
  Set it:  export LINEAR_API_KEY="lin_api_..."
  Get one: https://linear.app/settings/api

  I'll add the config. The connection activates once the key is set.
```

### 4. Generate

Show a step indicator and progress during generation:
```
[3/3] Installing...
```

Generate all files, showing each as it completes:

```
  ✓ Config          .keel/config.yaml
  ✓ Project context docs/project-context.md
  ✓ Rules           6 packs → .claude/rules/
  ✓ Agents          5 specialists → .claude/agents/
  ✓ Hooks           .claude/settings.json (9 behaviors)
  ✓ CLAUDE.md       updated (sentinel merge)
  ✓ Directories     docs/architecture/, docs/plans/, docs/product/
  {if PR template}: ✓ PR template    .github/pull_request_template.md
  {if ticket sys}:  ✓ Tickets        .mcp.json (Linear)
  {if linters}:     ✓ Linter sync    .claude/rules/linter-golangci.md
```

#### File generation details

**`.keel/config.yaml`** — Read `~/.keel/VERSION` for version.

```yaml
# .keel/config.yaml — generated by keel:init
keel_version: {version}
base: docs

stack: [{detected or stated stack}]

paths:
  decisions: {adapted or default: docs/architecture/decisions}
  invariants: {adapted or default: docs/architecture/invariants}
  plans: docs/plans
  specs: docs/product/specs
  prds: docs/product/prds
  guidelines: docs/guidelines
  reports: docs/reports
  soul: docs/project-context.md

rules:
  {name}: { include: all }

# Toggle optional behaviors. All default to true.
# The governance core (rules, compile, drift, review-governance) is always on.
features:
  auto-format: true        # format files after every edit
  session-summary: true    # git-aware "since your last session" on start
  signal-detection: true   # detect ADR/invariant candidates on stop
  plan-injection: true     # inject active plan phase on every prompt
  quality-gates: true      # block on critical findings from gate agents

sdlc:
  commit-convention: {choice or "none"}
  pr-template: {true/false}
```

**`docs/project-context.md`** — Seed from description or codebase analysis. Never overwrite if it already exists.

**`.claude/rules/`** — For each enabled rule, use these EXACT paths. Do NOT search or explore — read directly:

```bash
# Rule template paths (~ = $HOME):
# Base rules:      ~/.keel/templates/rules/base/{name}.md
# Language rules:  ~/.keel/templates/rules/lang/{name}.md
# Framework rules: ~/.keel/templates/rules/framework/{name}.md
#
# Example: to install the "go" rule pack:
#   Read: ~/.keel/templates/rules/lang/go.md
#   Write to: .claude/rules/go.md
#
# Example: to install the "code-quality" rule pack:
#   Read: ~/.keel/templates/rules/base/code-quality.md
#   Write to: .claude/rules/code-quality.md
```

For each enabled rule:
1. Check for project override at `.keel/templates/{name}.md` — use it if exists
2. Otherwise Read the template from the exact path above (base/lang/framework tier)
3. Write to `.claude/rules/{name}.md`

Tier mapping:
- Base: code-quality, testing, security, error-handling, api, architecture, database, frontend, observability, seo
- Lang: go, typescript, python, php
- Framework: chi, nextjs, django, laravel, rails, symfony

If the template file doesn't exist at the expected path:
```
Rule template not found: ~/.keel/templates/rules/{tier}/{name}.md
Install keel globally: curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

**`CLAUDE.md`** — Read the template from `~/.keel/templates/CLAUDE.md.tmpl`. Sentinel merge using `<!-- keel:start -->` / `<!-- keel:end -->`. Fill template variables from config. If CLAUDE.md exists without keel block, append. If keel block exists, replace between sentinels only. Never Write the whole file — use Read + Edit.

**`.claude/settings.json`** — Generate hook config referencing `$HOME/.keel/hooks/`. If settings.json exists, merge hooks — preserve existing non-keel settings.

**PR template** — Only install `.github/pull_request_template.md` if it does NOT already exist. Never overwrite.

**`.mcp.json`** — If ticket system selected, add MCP server config. If `.mcp.json` exists, merge.

**Directories** — Create all directories from paths config. Add a minimal README.md to each governance directory:

```markdown
<!-- docs/architecture/decisions/README.md -->
# Architecture Decisions

Capture decisions with: "save this decision" or /keel:adr

Format: ADR-NNN-title.md
```

```markdown
<!-- docs/architecture/invariants/README.md -->
# Invariants

Capture hard constraints with: "that's a hard rule" or /keel:invariant

Format: INV-NNN-title.md
```

```markdown
<!-- docs/plans/README.md -->
# Plans

Create execution plans with: "let's plan this" or /keel:plan

Format: PLAN-NNN-title.md
```

```markdown
<!-- docs/product/prds/README.md -->
# Product Requirements

Write PRDs with: "write a PRD for X" or /keel:prd

Format: PRD-NNN-title.md
```

```markdown
<!-- docs/product/specs/README.md -->
# Technical Specifications

Write specs with: "write a spec for X" or /keel:spec

Format: SPEC-NNN-title/spec.md
```

**Specialist agents** — Use these EXACT paths. Do NOT search or explore:

```bash
# Agent template path: ~/.keel/templates/agents/{name}.md
# Write to: .claude/agents/{name}.md
#
# Example: to install the "architect" agent:
#   Read: ~/.keel/templates/agents/architect.md
#   Write to: .claude/agents/architect.md
```

For each enabled agent from step 3, Read the template and Write to `.claude/agents/{name}.md`.

**Linter sync** — If linter configs were found, run `/keel:sync` logic.

**Import existing artifacts** — For findings from step 2:
- **Confident** (clear ADRs, Makefile commands, .cursorrules): act on them
- **Uncertain** (ambiguous docs): skip with a hint showing the exact prompt to import later

### 5. Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL INITIALIZED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Rules:   6 packs — code-quality, testing, security,
           error-handling, go, chi
  Agents:  5 specialists — architect, qa, backend, dba, docs
  Hooks:   auto-format on edit, context on session start,
           plan injection on every prompt, compaction recovery,
           decision detection on session end

  {If imported}: Imported: 3 ADRs from docs/decisions/

What just changed:

  Before keel, Claude writes code with no project standards,
  no architecture awareness, and forgets everything between sessions.

  Now Claude reads your 6 rule packs before writing any code.
  Try it — ask Claude to write a function and watch it follow
  your project's error handling and testing patterns.

  Commit .keel/, .claude/, and docs/ to git — your team gets
  identical governance automatically.

  To undo: git checkout . && rm -rf .keel/ (before committing)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Key formatting rules for the summary:
- Name behaviors, not mechanisms ("auto-format on edit" not "PostToolUse hook")
- One concrete before/after to demonstrate the transformation
- Single next step: start building. No list of 4 equal alternatives.
- Undo instructions for safety
- Commit reminder for teams

---

REMEMBER: NEVER guess project details or invent content. If uncertain, skip and tell the user the exact prompt to handle it manually. The init must feel trustworthy — every action should be explainable. Show progress throughout — the user should always know where they are and how much is left.

## Reference

### MCP Server Configs

**Linear:**
```json
"linear": {
  "type": "http",
  "url": "https://mcp.linear.app/sse",
  "authorization_token": "${LINEAR_API_KEY}"
}
```
Required: `LINEAR_API_KEY` — https://linear.app/settings/api

**GitHub Issues:**
```json
"github": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}" }
}
```
Required: `GITHUB_TOKEN`

**Jira:**
```json
"jira": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "mcp-atlassian"],
  "env": {
    "JIRA_URL": "${JIRA_URL}",
    "JIRA_USERNAME": "${JIRA_USERNAME}",
    "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
  }
}
```
Required: `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN`
