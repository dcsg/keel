# Commands

Keel has eleven commands. Each does exactly one thing. You rarely need to remember them — Claude responds to natural language after init.

## The commands

| Command | What it does |
|---------|-------------|
| [`/keel:init`](/commands/init) | Detect project, infer architecture, install rules, agents, and context |
| [`/keel:context`](/commands/context) | Load soul, plans, ADRs, and product docs into current session |
| [`/keel:plan`](/commands/plan) | Interview + phased execution plan with dependency tracking |
| [`/keel:status`](/commands/status) | Dashboard — plan progress, rules, what's next |
| [`/keel:intake`](/commands/intake) | Scan scattered docs and organize into keel structure |
| [`/keel:agents`](/commands/agents) | List, install, and manage specialist agent templates |
| [`/keel:mcp`](/commands/mcp) | Connect to Linear, GitHub, or Jira via MCP |
| [`/keel:team`](/commands/team) | Validate team member setup and show shared config |
| [`/keel:adr`](/commands/adr) | Capture an architecture decision record |
| [`/keel:invariant`](/commands/invariant) | Define a hard constraint that must never be violated |
| [`/keel:prd`](/commands/prd) | Write a product requirement document |

## You don't need to remember them

After `/keel:init`, Claude responds to how you naturally talk. You don't need to think about which command to run — just say what you need.

> "what's our status?" → `/keel:status`
> "what's next?" → `/keel:status`
> "load context" → `/keel:context`
> "let's plan this" → `/keel:plan`
> "capture this decision" → `/keel:adr`

See the full list on the [Natural Language](/natural-language) page.

## The one command you run once

`/keel:init` is the setup command. Everything else is day-to-day. After init, most interactions happen through natural language — the slash commands are there when you want explicit control.
