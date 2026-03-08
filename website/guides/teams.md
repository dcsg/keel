# Teams

Keel is designed to be committed — the whole team benefits automatically.

## Commit Everything

```bash
git add .claude/ .keel/ docs/soul.md docs/product/ .mcp.json
git commit -m "chore: add keel context and guardrails"
```

Every teammate who opens the project in Claude Code now has:
- The same coding standards enforced automatically
- The same specialist agents installed
- The same project context loaded at session start
- The same MCP server config (each person adds their own keys locally)

No per-developer setup. No drift between teammates.

## Onboarding New Teammates

New team member clones the repo and opens it in Claude Code. Then:

```
/keel:team setup
```

This validates their local environment:

```
Keel Team Setup — Orders API

  ✅ Git configured (Jane Smith <jane@example.com>)
  ✅ Claude Code v2.1.70
  ✅ Keel config found
  ✅ LINEAR_API_KEY set
  ⚠️  GITHUB_TOKEN not set
      Get a token (repo scope): https://github.com/settings/tokens
      Add to ~/.zshrc: export GITHUB_TOKEN="ghp_..."

1 item needs attention. Fix it, then run /keel:team setup again.

Once all green: run /keel:context to load project context.
```

Once all green, they run `/keel:context` and they're productive from the first session.

## Connecting to Project Management

Wire Claude to your ticket system:

```
/keel:mcp add linear    → adds Linear to .mcp.json
/keel:mcp add github    → adds GitHub to .mcp.json
/keel:mcp add jira      → adds Jira to .mcp.json
```

`.mcp.json` is committed — everyone inherits the server config. Each person adds their own API keys to their local shell environment (not committed):

```bash
# Each team member adds to their ~/.zshrc:
export LINEAR_API_KEY="lin_api_..."
export GITHUB_TOKEN="ghp_..."
```

Check status at any time:
```
/keel:mcp

MCP Servers:
  linear    ✅ configured, LINEAR_API_KEY set
  github    ⚠️  GITHUB_TOKEN not set — set: export GITHUB_TOKEN="ghp_..."
```

## Specialist Agents

Agents installed by `/keel:init` are committed to `.claude/agents/`. Every teammate gets the same role-based specialists — Principal Architect, Staff Engineer, Staff Security, etc. — without any per-person setup.

Add optional agents:
```
/keel:agents add principal-data
/keel:agents add senior-performance
```

Commit the new agent file. The whole team gets it on next pull.

## Keeping Rules in Sync

When you update `.keel/config.yaml` (add a rule, change config), re-run `/keel:init` and commit the updated `.claude/rules/` files. The PR diff shows exactly what changed.

```
/keel:rules-update    → check for outdated rule packs
```

## Shared Plans

Plans in `docs/product/plans/` are committed and shared. Any teammate can run `/keel:status` and see exactly where things stand — what's done, what's in progress, what's next.
