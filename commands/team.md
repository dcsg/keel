---
name: keel:team
description: "Onboard team members and show shared team configuration"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# keel:team

Manage team configuration and help new team members get set up quickly.

## Arguments

- No argument: show what's shared and how to onboard new members
- `setup`: validate this member's local environment against team requirements
- `init {team-name}`: add team config to `.keel/config.yaml`

## Instructions

### No argument — Team overview

1. Read `.keel/config.yaml` for `team:` block.
2. Check what's committed to git:
   ```bash
   git ls-files .keel/config.yaml .claude/rules/ .claude/agents/ .mcp.json .github/ 2>/dev/null
   ```
3. Read `.mcp.json` for required env vars (if it exists).
4. Output:

   If team block exists:
   ```
   Team: {team-name}

   Shared config (committed to git):
     .keel/config.yaml     — project config, rules, stack
     .claude/rules/        — {n} rule packs
     .claude/agents/       — {n} specialist agents
     .mcp.json             — {configured servers} (keys not committed)
     .github/              — PR template, CI

   Each member needs these environment variables:
     {list of required env vars from .mcp.json with setup links}

   Onboarding a new member:
     git clone {remote URL} && cd {project}
     /keel:team setup    — validates their local environment
   ```

   If no team block:
   ```
   No team config found. Run /keel:team init "Team Name" to add it.

   Shared config (committed to git):
     {list of what's currently tracked}
   ```

### `setup` — Validate member environment

Run environment checks for this member:

1. **Git identity:**
   ```bash
   git config user.name && git config user.email
   ```
   - ✅ if both set
   - ⚠️ if missing

2. **Claude Code:**
   ```bash
   claude --version 2>/dev/null
   ```
   - ✅ if found
   - ❌ if missing — "Install Claude Code: https://claude.ai/download"

3. **Keel config:**
   - ✅ if `.keel/config.yaml` exists
   - ❌ if missing — "Run /keel:init to set up this project"

4. **MCP environment variables:**
   Read `.mcp.json` and check each required env var:
   - Linear: `LINEAR_API_KEY`
   - GitHub: `GITHUB_TOKEN`
   - Jira: `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN`

5. **Git pre-push hook:**
   ```bash
   ls .git/hooks/pre-push 2>/dev/null
   ```
   - ✅ if `.git/hooks/pre-push` exists and is executable
   - ⚠️ if missing — install it:
     ```bash
     cp ~/.keel/templates/hooks/pre-push .git/hooks/pre-push
     chmod +x .git/hooks/pre-push
     ```
   Note: if `hooks: { pre-push: false }` is set in `.keel/config.yaml`, show as intentionally disabled (✅ disabled by config).

6. **Output:**
   ```
   Keel Team Setup — {team-name}

     ✅ Git configured (Daniel Gomes <daniel@example.com>)
     ✅ Claude Code v2.1.70
     ✅ Keel config found
     ✅ LINEAR_API_KEY set
     ⚠️  GITHUB_TOKEN not set
         Get a token (repo scope): https://github.com/settings/tokens
         Add to ~/.zshrc: export GITHUB_TOKEN="ghp_..."

   1 item needs attention. Fix it, then run /keel:team setup again.

   Once all green: run /keel:context to load project context.
   ```

   If all green:
   ```
   ✅ All checks passed — you're ready to go!
   Run /keel:context to load project context.
   ```

### `init {team-name}` — Add team config

1. Read `.keel/config.yaml`.
2. If `team:` block already exists: show current team config and exit.
3. Otherwise, add `team:` block:
   ```yaml
   team:
     name: "{team-name}"
   ```
4. Write updated config.
5. Output:
   ```
   ✅ Team config added to .keel/config.yaml

   Commit this to git so your team inherits it:
     git add .keel/config.yaml
     git commit -m "chore: add team config"

   Run /keel:team to see the full team overview.
   ```
