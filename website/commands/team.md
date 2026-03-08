# /keel:team

Onboard team members and show what's shared across the team.

## Usage

```
/keel:team
/keel:team setup
/keel:team init "Team Name"
```

## No argument — team overview

Shows what's committed to git and what each member needs locally.

```
/keel:team

Team: Orders API

Shared config (committed to git):
  .keel/config.yaml     — project config, rules, stack
  .claude/rules/        — 6 rule packs
  .claude/agents/       — 9 specialist agents
  .mcp.json             — linear, github (keys not committed)
  .github/              — PR template

Each member needs these environment variables:
  LINEAR_API_KEY    — https://linear.app/settings/api
  GITHUB_TOKEN      — https://github.com/settings/tokens

Onboarding a new member:
  git clone ... && cd project
  /keel:team setup    — validates their local environment
```

## `setup` — validate member environment

Run this when joining a project or after the team adds new MCP servers.

```
/keel:team setup

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

Checks:
- Git name and email configured
- Claude Code installed
- `.keel/config.yaml` exists (confirms keel-initialized repo)
- All env vars required by `.mcp.json` are set

## `init {name}` — add team config

```
/keel:team init "Orders API Team"
```

Adds a `team:` block to `.keel/config.yaml`:

```yaml
team:
  name: "Orders API Team"
```

Commit the updated config so the team name appears in `/keel:team` output for everyone.

## Onboarding workflow

For the team lead (once):
```bash
# 1. Run init
/keel:init

# 2. Configure MCP servers
/keel:mcp add linear
/keel:mcp add github

# 3. Commit everything
git add .claude/ .keel/ .mcp.json docs/
git commit -m "chore: initialize keel"
git push
```

For each new team member:
```bash
# 1. Clone and open in Claude Code
git clone ... && cd project

# 2. Validate environment
/keel:team setup

# 3. Fix any missing env vars (shown in setup output)

# 4. Load context
/keel:context
```

That's it — they're productive from the first session.
