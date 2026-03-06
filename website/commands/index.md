# Commands

Keel has six commands. Each does exactly one thing.

| Command | Purpose |
|---------|---------|
| [`/keel:init`](/commands/init) | Intelligent onboarding — detect project, infer architecture, install everything |
| [`/keel:context`](/commands/context) | Load soul, plans, ADRs, and product docs into current session |
| [`/keel:plan`](/commands/plan) | Interview + phased execution plan with dependency tracking |
| [`/keel:status`](/commands/status) | Dashboard — plan progress, installed rules, governance health |
| [`/keel:intake`](/commands/intake) | Scan for scattered docs and organize into keel structure |
| [`/keel:migrate`](/commands/migrate) | Convert dof/conductor projects to keel |

## Natural Language Triggers

You don't need to remember commands. CLAUDE.md teaches Claude to respond to natural language:

| Say this... | Claude runs... |
|-------------|---------------|
| "what's our status?" | `/keel:status` |
| "what's next?" | `/keel:status` |
| "load context" | `/keel:context` |
| "let's plan this" | `/keel:plan` |
