# Plan: Keel v2 — Specialist Agents, Reliable Artifact Capture, Memory Persistence, MCP Wiring, Teams

## Overview
**Task:** Keel v2 — close the gaps between keel's context engine and the full Claude Code feature surface
**Total Phases:** 5
**Estimated Cost:** ~$5–12
**Created:** 2026-03-08

## Progress

| Phase | Status | Updated |
|-------|--------|---------|
| 1 | done | 2026-03-08 |
| 2 | done | 2026-03-08 |
| 3 | done | 2026-03-08 |
| 4 | done | 2026-03-08 |
| 5 | done | 2026-03-08 |

**IMPORTANT:** Update this table as phases complete. This table is the persistent state that survives context compaction.

## Model Assignment

| Phase | Task | Model | Reasoning | Est. Cost |
|-------|------|-------|-----------|-----------|
| 1 | Reliable artifact capture & hook improvements | Sonnet | Hook schema + template work | ~$0.50 |
| 2 | Specialist agent system | Sonnet | Template generation + routing logic | ~$2.00 |
| 3 | Auto-memory persistence | Sonnet | Memory integration + staleness detection | ~$1.00 |
| 4 | MCP wiring | Sonnet | Config generation + command | ~$1.50 |
| 5 | Team support | Sonnet | Shared config + team commands | ~$1.50 |

## Execution Strategy

| Phase | Depends On | Parallel With |
|-------|-----------|---------------|
| 1 | None | - |
| 2 | 1 | - |
| 3 | 1 | 4 |
| 4 | 1 | 3 |
| 5 | 2, 3, 4 | - |

---

## Phase 1: Reliable Artifact Capture & Hook Improvements

**Objective:** Make artifact suggestions (ADR/invariant/PRD) actually fire after every response via a Stop hook; replace the fragile sentinel-file approach with a SessionStart hook; add a PostToolUse formatter hook template.
**Model:** `sonnet`
**Max Iterations:** 8
**Completion Promise:** `PHASE 1 COMPLETE`
**Dependencies:** None

**Prompt:**

Fix keel's hook system with three improvements:

### 1. Stop Hook for Artifact Suggestions

Current state: proactive suggestions (💡 ADR/invariant/PRD prompts) are written into CLAUDE.md instructions. This is unreliable — Claude doesn't always self-audit.

Fix: Add a `Stop` hook with `type: prompt` in `templates/settings.json.tmpl`. This fires after every Claude response and actively asks Claude to scan the response for artifact signals.

Hook spec:
```json
"Stop": [
  {
    "hooks": [
      {
        "type": "prompt",
        "prompt": "Review your last response. Did it contain: (1) a significant technical choice with trade-offs (database, pattern, API design, infra), (2) a hard constraint that must NEVER be violated (data integrity, security boundary, domain purity), or (3) a clearly defined new feature or user need? If yes, end your next response with ONE of: '💡 This looks like an ADR — run `/keel:adr` to capture it.' OR '💡 This is an invariant — run `/keel:invariant` to capture it.' OR '💡 This looks like a PRD — run `/keel:prd` to capture it.' Only suggest if the signal is strong. Skip for preferences, style choices, and implementation details."
      }
    ]
  }
]
```

### 2. SessionStart Hook to Replace Sentinel File

Current state: PreToolUse hook uses a `/tmp/keel-{hash}` sentinel file to detect first tool use per session. Fragile — temp files persist across sessions.

Fix: Add a `SessionStart` hook that:
- Checks if `.keel/config.yaml` exists
- If yes, outputs: "📋 Keel project detected. Read docs/soul.md and check docs/product/plans/ for active plan before writing code."
- Remove the sentinel-file logic from the PreToolUse hook

New SessionStart hook:
```json
"SessionStart": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "if [ -f '.keel/config.yaml' ] && [ -f 'docs/soul.md' ]; then echo '📋 Keel: Read docs/soul.md for project context. Check docs/product/plans/ for active plan.'; fi"
      }
    ]
  }
]
```

Simplified PreToolUse (remove sentinel logic, keep the Write|Edit matcher for a lightweight guard):
```json
"PreToolUse": [
  {
    "matcher": "Write|Edit",
    "hooks": [
      {
        "type": "command",
        "command": "if [ -f '.keel/config.yaml' ] && [ ! -f 'docs/soul.md' ]; then echo '⚠️  Keel: docs/soul.md not found. Run /keel:init to set up this project.'; fi"
      }
    ]
  }
]
```

### 3. PostToolUse Formatter Hook Template

Add a commented-out PostToolUse hook template in `templates/settings.json.tmpl` as an example teams can enable:
```json
// "PostToolUse": [
//   {
//     "matcher": "Write",
//     "hooks": [
//       {
//         "type": "command",
//         "command": "# Optional: run formatter after file writes. Example:\n# file=$(echo $CLAUDE_TOOL_RESULT | jq -r '.path // empty'); if [ -n \"$file\" ]; then case \"$file\" in *.go) gofmt -w \"$file\";; *.ts|*.tsx) prettier --write \"$file\" 2>/dev/null;; esac; fi"
//       }
//     ]
//   }
// ]
```

### Files to update:
- `templates/settings.json.tmpl` — all three hook changes
- `commands/init.md` — update the hooks JSON example (sections 5.5) to match new schema
- `docs/guides/commands.md` — add note about Stop hook for artifact suggestions
- `templates/CLAUDE.md.tmpl` — remove "After each response, check if..." self-audit instructions (now handled by Stop hook); keep the routing table

When complete, output: PHASE 1 COMPLETE

---

## Phase 2: Specialist Agent System

**Objective:** Create a full library of specialist agent templates (by role), update keel:init to install them based on detected stack, and add a `keel:agents` command for listing/managing installed agents.
**Model:** `sonnet`
**Max Iterations:** 12
**Completion Promise:** `PHASE 2 COMPLETE`
**Dependencies:** Phase 1

**Prompt:**

Build keel's specialist agent system. This makes Claude's "thinking role" visible and configurable.

### Agent Template Structure

Each agent lives in `templates/agents/{slug}.md` with this frontmatter:
```yaml
---
name: {Role Title}
description: "{One-line role description}"
model: claude-sonnet-4-6
tools:
  - Read
  - Grep
  - Glob
  # + role-specific tools
isolation: false
---
```

Body: system prompt with role identity, domain expertise, and constraints.

### Agents to Create

Create these agent templates in `templates/agents/`:

**Architecture & Engineering:**
- `principal-architect.md` — System design, ADRs, trade-off analysis. Tools: Read, Grep, Glob, Agent. Constraints: always documents decisions, never implements directly.
- `staff-engineer.md` — Implementation leadership, code review, refactoring. Tools: Read, Write, Edit, Grep, Glob, Bash. Constraints: follows existing patterns, references ADRs.
- `senior-backend.md` — Backend implementation. Tools: all standard. Stack-aware: detects Go/Python/PHP from soul.md.
- `principal-dba.md` — Database design, query optimization, migration safety. Tools: Read, Grep, Glob. Constraints: always considers migration reversibility, index impact, lock behavior.
- `staff-security.md` — Security review, OWASP, threat modeling. Tools: Read, Grep, Glob, Agent. Constraints: flags, never silently accepts.
- `staff-sre.md` — Reliability, observability, infrastructure. Tools: Read, Grep, Glob. Focus: SLOs, runbooks, monitoring.
- `staff-qa.md` — Testing strategy, test writing, coverage gaps. Tools: Read, Write, Edit, Grep, Glob, Bash. Constraints: TDD, no magic mocks.
- `staff-frontend.md` — Frontend implementation. Tools: all standard. Stack-aware: React/Next.js/Vue from soul.md.
- `principal-ux.md` — UX/UI design review and guidance. Tools: Read, Grep, Glob. Constraints: accessibility, user flows first.
- `senior-pm.md` — Product management, requirement clarification, PRD writing. Tools: Read, Write, Glob. Constraints: always ties to user value and business outcome.
- `senior-api.md` — API design, REST/GraphQL/gRPC. Tools: Read, Grep, Glob. Constraints: versioning, backwards compatibility, contracts.
- `senior-performance.md` — Performance profiling and optimization. Tools: Read, Grep, Glob, Bash.
- `principal-data.md` — Data modeling, analytics, pipelines. Tools: Read, Grep, Glob. Constraints: data integrity, schema evolution.

Each agent template body should:
1. Open with: "You are a [Title] at a software team. [2-sentence role identity]."
2. Include domain expertise bullets (5-8 specific things this role is expert at)
3. Include constraints (3-5 non-negotiables for this role)
4. Include: "Before starting any task, state your role and what lens you'll apply."
5. End with: "If you detect a decision worth capturing, suggest the appropriate keel command."

### Stack-to-Agent Mapping

Add a mapping in `templates/agents/_registry.yaml`:
```yaml
# Agent registry — maps stacks to recommended agents
# Format: stack-keyword: [agent-slugs]

always:
  - principal-architect
  - staff-engineer

go:
  - senior-backend
  - principal-dba
  - staff-qa

typescript:
  - staff-frontend
  - senior-backend
  - staff-qa

python:
  - senior-backend
  - principal-dba

php:
  - senior-backend

react:
  - staff-frontend
  - principal-ux

nextjs:
  - staff-frontend
  - principal-ux

security-keywords:  # triggers if soul.md mentions payment/auth/compliance/HIPAA/PCI
  - staff-security

all:
  - staff-sre
  - staff-qa
  - senior-pm
  - senior-api
```

### Update keel:init

In `commands/init.md`, section 5 (Generate Everything), add step 5.8:

**5.8 — Install agent templates**

After generating rules, install agents:
1. Check `~/.keel/templates/agents/` for available templates
2. Read `_registry.yaml` from agent templates
3. Based on detected stack (from config.yaml), select agents:
   - Always include: `always` agents
   - Add stack-matched agents
   - If soul.md mentions payment/auth/HIPAA/compliance → add `staff-security`
   - Include all `all` agents
4. Copy selected agent templates to `.claude/agents/`
5. Add to init summary: "Agents: {n} installed in .claude/agents/"

Note: If `~/.keel/templates/agents/` not found, output agents list but skip install (same pattern as rules).

### New Command: keel:agents

Create `commands/agents.md`:

```
---
name: keel:agents
description: "List, inspect, and manage specialist agents"
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash
---
```

The command does:
1. List installed agents in `.claude/agents/` with name and one-line description
2. Show available agents in `~/.keel/templates/agents/` not yet installed
3. Accept argument `add {slug}` to install an agent
4. Accept argument `remove {slug}` to uninstall
5. Accept argument `show {slug}` to print the agent's full prompt

Output format:
```
Installed agents (8):
  principal-architect  — System design, ADRs, trade-off analysis
  staff-engineer       — Implementation leadership, code review
  ...

Available (not installed):
  principal-data       — Data modeling, analytics, pipelines
  ...

Usage:
  /keel:agents add principal-data
  /keel:agents show staff-security
  /keel:agents remove senior-pm
```

### Update install.sh

Add `agents` to `KEEL_COMMANDS` array.
Create `${KEEL_HOME}/templates/agents/` directory.
Download all agent templates from BASE_URL.

### Update docs

- `docs/guides/commands.md`: Add keel:agents section
- `docs/guides/getting-started.md`: Add "Specialist Agents" section after "First Workflow"
- `docs/architecture/decisions/ADR-001-keel-architecture.md`: Update command count, add agents to pillar 1

When complete, output: PHASE 2 COMPLETE

---

## Phase 3: Auto-Memory Persistence

**Objective:** Wire keel:context to write a structured summary to Claude's auto-memory after each run, add a SessionStart staleness check, and validate memory in keel:doctor.
**Model:** `sonnet`
**Max Iterations:** 6
**Completion Promise:** `PHASE 3 COMPLETE`
**Dependencies:** Phase 1

**Prompt:**

Wire keel into Claude Code's auto-memory system so project context persists across sessions automatically.

### How Claude Code auto-memory works

Memory lives at: `~/.claude/projects/{encoded-path}/memory/MEMORY.md`
Where `{encoded-path}` is the project's absolute path with `/` replaced by `-`.
The first 200 lines of `MEMORY.md` are auto-loaded into every session.

### Update keel:context

At the end of `commands/context.md`, after printing the context summary, add:

**Auto-memory write step:**

1. Compute the memory path:
   ```bash
   PROJECT_PATH=$(pwd)
   ENCODED=$(echo "$PROJECT_PATH" | sed 's|/|-|g')
   MEMORY_DIR="$HOME/.claude/projects/${ENCODED}/memory"
   MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
   mkdir -p "$MEMORY_DIR"
   ```

2. Write a compact context snapshot to `MEMORY.md`. Keep it under 150 lines so the 200-line limit is respected:
   ```markdown
   # {Project Name} — Keel Memory

   _Last updated: {timestamp} via /keel:context_

   ## Soul
   {2-3 sentence summary from soul.md}

   ## Stack
   {stack from config.yaml}

   ## Active Plan
   {plan name + current phase title, or "None"}

   ## Architecture Decisions
   {list of ADR titles and statuses — one line each}

   ## Invariants
   {list of invariants — one line each, these are HARD RULES}

   ## Rules Installed
   {list of rule packs}

   ## Key Files
   - Config: .keel/config.yaml
   - Soul: docs/soul.md
   - Plans: docs/product/plans/
   - Decisions: docs/decisions/
   - Invariants: docs/invariants/
   ```

3. After writing, output: `  Memory: updated ~/.claude/projects/.../memory/MEMORY.md`

### Staleness Detection via SessionStart Hook

Update the SessionStart hook in `templates/settings.json.tmpl`:

Check if MEMORY.md is more than 7 days old. If so, suggest running keel:context:
```bash
if [ -f '.keel/config.yaml' ]; then
  ENCODED=$(echo "$PWD" | sed 's|/|-|g')
  MEMORY="$HOME/.claude/projects/${ENCODED}/memory/MEMORY.md"
  if [ -f "$MEMORY" ]; then
    AGE=$(( ($(date +%s) - $(date -r "$MEMORY" +%s 2>/dev/null || stat -f %m "$MEMORY" 2>/dev/null || echo 0)) / 86400 ))
    if [ "$AGE" -gt 7 ]; then
      echo "⚠️  Keel memory is ${AGE} days old. Run /keel:context to refresh."
    else
      echo "📋 Keel: $(head -1 \"$MEMORY\" 2>/dev/null || echo 'Memory loaded')"
    fi
  else
    echo "📋 Keel project detected. Run /keel:context to load project context.'
  fi
fi
```

### Update keel:doctor

In `commands/doctor.md`, add a memory health check:

```
Memory:
  Path:    ~/.claude/projects/.../memory/MEMORY.md
  Status:  {exists/missing}
  Age:     {N days old}
  Lines:   {count}/{200 limit}

  {warning if > 180 lines or > 14 days old}
```

### Update docs

- `docs/guides/getting-started.md`: Add "Memory Persistence" section explaining auto-memory
- `docs/guides/commands.md`: Update keel:context entry to mention memory write

When complete, output: PHASE 3 COMPLETE

---

## Phase 4: MCP Wiring

**Objective:** Generate `.mcp.json` for common tools (Linear, GitHub, Jira), add MCP config to keel:init flow, and create a `keel:mcp` command for managing MCP servers.
**Model:** `sonnet`
**Max Iterations:** 8
**Completion Promise:** `PHASE 4 COMPLETE`
**Dependencies:** Phase 1

**Prompt:**

Wire keel into Claude Code's MCP system. This lets specialist agents and keel commands access project management tools (Linear, GitHub, Jira) natively.

### How Claude Code MCP works

`.mcp.json` in the project root configures MCP servers at project scope. Each server entry has:
```json
{
  "mcpServers": {
    "linear": {
      "type": "http",
      "url": "https://mcp.linear.app/sse",
      "authorization_token": "${LINEAR_API_KEY}"
    }
  }
}
```

Environment variables referenced with `${VAR}` are expanded at runtime from the user's shell env.

### MCP Server Configs to Support

**Linear:**
```json
"linear": {
  "type": "http",
  "url": "https://mcp.linear.app/sse",
  "authorization_token": "${LINEAR_API_KEY}"
}
```
Setup note: User needs `LINEAR_API_KEY` in their shell environment.

**GitHub:**
```json
"github": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
  }
}
```
Setup note: Requires `GITHUB_TOKEN` in environment.

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
Setup note: Requires `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN` in environment.

### Update keel:init

In `commands/init.md`, after step 4 (SDLC preferences), add:

**Step 4b — MCP Configuration:**
```
Ticket system / project management? (optional)
  1. Linear  — add to .mcp.json (needs LINEAR_API_KEY env var)
  2. GitHub  — add to .mcp.json (needs GITHUB_TOKEN env var)
  3. Jira    — add to .mcp.json (needs JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN env vars)
  4. None

  Select (comma-separated, e.g. "1 2") or press enter to skip:
```

If user selects any: generate `.mcp.json` with selected servers. Add comment block with setup instructions above the JSON:
```
# .mcp.json — MCP server configuration for Claude Code
#
# Required environment variables:
# {list each required env var with description}
#
# Add these to your shell profile (~/.zshrc or ~/.bashrc):
# export LINEAR_API_KEY="lin_api_..."
#
# Team members each need their own API keys (not committed to git).
# Add this file to git — the keys stay in each person's local environment.
```

Also update `.keel/config.yaml` to add ticket config:
```yaml
ticket:
  system: linear  # or github, jira
  team: {team-name}
```

Prompt user for team name if Linear selected.

### Update keel:context

When ticket config is present in `.keel/config.yaml`, note it in the output:
```
  Tickets: Linear (GLO team) — MCP connected
```
vs
```
  Tickets: Linear configured — set LINEAR_API_KEY to activate MCP
```
(Check if the env var is set to distinguish "configured but not active" vs "active".)

### New Command: keel:mcp

Create `commands/mcp.md`:
```
---
name: keel:mcp
description: "Manage MCP server configuration"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---
```

The command:
1. With no args: show `.mcp.json` status — which servers are configured, which env vars are set/missing
2. `add linear|github|jira` — add a server config to `.mcp.json` (create if doesn't exist)
3. `remove {server}` — remove a server from `.mcp.json`
4. `status` — test each configured server (check if env vars are set)

Output format:
```
MCP Servers:

  linear    ✅ configured, LINEAR_API_KEY set
  github    ⚠️  configured, GITHUB_TOKEN not set
              Set: export GITHUB_TOKEN="ghp_..."

Not configured:
  jira      /keel:mcp add jira

.mcp.json is committed to git (team will inherit server configs, not keys).
```

### Update install.sh

Add `mcp` to `KEEL_COMMANDS` array.

### Update docs

- `docs/guides/getting-started.md`: Add "Connecting to Project Management" section
- `docs/guides/commands.md`: Add keel:mcp section
- Update keel:plan docs to mention ticket ID support works via MCP

When complete, output: PHASE 4 COMPLETE

---

## Phase 5: Team Support

**Objective:** Add team-oriented features: shared agent configuration, team health in keel:status, and a `keel:team` command for onboarding new team members.
**Model:** `sonnet`
**Max Iterations:** 8
**Completion Promise:** `PHASE 5 COMPLETE`
**Dependencies:** Phases 2, 3, 4

**Prompt:**

Add team-level features to keel so the entire team benefits from shared configuration.

### Team Config in .keel/config.yaml

Extend the config schema to support a `team:` block:
```yaml
team:
  name: "Invoicer Team"
  size: small  # small (1-5) | medium (6-20) | large (20+)
  ticket:
    system: linear
    team: GLO
  conventions:
    branches: "feat|fix|chore|docs/{ticket-id}-{slug}"
    commits: conventional
    pr-size: medium  # small (<200 lines) | medium (<500) | large (any)
```

### keel:team Command

Create `commands/team.md`:
```
---
name: keel:team
description: "Onboard team members and show team configuration"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---
```

The command handles two scenarios:

**No args (team lead view):**
```
Team: Invoicer Team (5 members)

Shared config committed to git:
  .keel/config.yaml     — project config, rules, stack
  .claude/rules/        — 6 rule packs
  .claude/agents/       — 9 specialist agents
  .mcp.json             — Linear + GitHub (keys not committed)
  .github/              — PR template, CI

Each member needs these environment variables:
  LINEAR_API_KEY    — https://linear.app/settings/api
  GITHUB_TOKEN      — https://github.com/settings/tokens

Onboarding a new member:
  git clone ... && cd project
  /keel:team setup    — validates their environment
```

**`setup` subcommand (new member view):**
1. Check git is configured (name + email)
2. Check required env vars from `.mcp.json` are set — list which are missing with setup links
3. Check Claude Code version (`claude --version`)
4. Verify `.keel/config.yaml` exists (confirms repo is keel-initialized)
5. Output a checklist:
```
Keel Team Setup — Invoicer Team

  ✅ Git configured (Daniel Gomes <daniel@example.com>)
  ✅ Claude Code v2.1.70
  ✅ Keel config found
  ✅ LINEAR_API_KEY set
  ⚠️  GITHUB_TOKEN not set — get one at https://github.com/settings/tokens (repo scope)

  1 item needs attention. Fix it, then run /keel:team setup again.

  Once all green: run /keel:context to load project context.
```

### Team Health in keel:status

Add a `TEAM` section to keel:status output:
```
 TEAM
 ────
 Shared: rules (6), agents (9), MCP (linear, github)
 Members need: LINEAR_API_KEY, GITHUB_TOKEN
 Conventions: conventional commits, feat|fix|chore/{id}-{slug} branches
```

### Update keel:init

After generating everything, add team config prompt:
```
Team setup? (optional — adds team block to config)
  Team name: [press enter to skip]
```

If provided, write team block to config.yaml.

### Update install.sh

Add `team` to `KEEL_COMMANDS` array.

### Update docs

- `docs/guides/getting-started.md`: Add "Team Setup" section at the end
- `docs/guides/commands.md`: Add keel:team section
- Update README.md to mention team features

When complete, output: PHASE 5 COMPLETE
