---
title: "FAQ — Keel Governance for Claude Code"
description: "Common questions about keel: governance chain, drift detection, quality gates, compiled directives, team setup, and Claude Code compatibility."
---

# FAQ

## Do I commit `.claude/rules/` to git?

**Yes.** Commit everything keel generates — `.claude/rules/`, `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/agents/`, `docs/`, `.keel/config.yaml`. This is how the whole team benefits. When a teammate opens the project in Claude Code, they get the same governance automatically.

## Will keel overwrite my existing CLAUDE.md?

No. keel generates `.claude/CLAUDE.md` (inside the `.claude/` directory), not the root `CLAUDE.md`. If you have an existing root `CLAUDE.md`, keel won't touch it.

## What's the difference between keel and just writing a CLAUDE.md?

A hand-written CLAUDE.md is a suggestion Claude might follow. keel installs governance — and after init, you interact with that governance through natural language, not commands.

You say "what's our status?" and Claude shows the governance dashboard. You say "save this decision" and Claude captures the ADR. You say "does the implementation match the spec?" and Claude runs drift detection. The commands are what Claude runs behind the scenes — you don't need to know them.

Beyond the conversational experience, the structural difference:

- **Lifecycle hooks** — 9 hooks that fire automatically. You don't remind Claude to follow standards; the hooks enforce them. (You stop re-explaining.)
- **Governance chain** — PRD → spec → artifacts → plan → execute → drift detection. Every decision is traceable. (You verify instead of trust.)
- **Compiled directives** — your ADRs and invariants become enforcement rules. Update the decision, recompile. (Decisions persist instead of drift.)
- **Quality gates** — Critical findings block progression. Overrides are logged. (Standards are enforced, not suggested.)
- **Specialist agents** — 16 domain agents review plans and implementations. (Expert review without the experts.)
- **Path-conditional rules** — Go rules fire on Go files. No noise. (Precise enforcement, not blanket instructions.)

On a team, the gap widens: a shared CLAUDE.md requires every engineer to read it, remember it, and follow it. keel's rules fire automatically — no per-engineer discipline required.

A CLAUDE.md drifts. A governance layer compounds.

## What's the governance chain?

The sequence from intent to implementation to verification. You drive it through natural language:

- "Write a PRD for [feature]" → structured requirements with acceptance criteria
- "Write a spec for PRD-005" → technical specification from the accepted PRD
- "Generate spec artifacts for SPEC-005" → data model, API contracts, migrations, test strategy
- "Create a plan for SPEC-005" → phased execution with specialist pre-flight review
- Execute — Claude builds with enforced standards
- "Does the implementation match the spec?" → drift detection closes the loop

Each step references the one before it. Each must be accepted before the next begins.

**Full explanation:** [Governance Chain](/governance/chain)
**Command references:** `/keel:prd`, `/keel:spec`, `/keel:spec-artifacts`, `/keel:plan`, `/keel:drift`

## What's drift detection?

Ask Claude "does the implementation match the spec for SPEC-005?" and it compares the implementation against the technical specification and the original PRD. It identifies divergences — features that were specified but not built, patterns that were decided but not followed, acceptance criteria that aren't covered by tests.

Drift detection is the verification step that closes the governance chain.

**Command reference:** `/keel:drift SPEC-005`

## What are quality gates?

When a specialist agent detects a critical finding — a hardcoded secret, a migration without a rollback, an API breaking change — Claude presents it to you and blocks progression. You can override the gate, but overrides are logged with your git identity.

Gates fire automatically via the SubagentStop hook and pre-flight review. You don't trigger them.

Quality gates make enforcement visible. They're the difference between "we have standards" and "standards are enforced."

## How do I compile governance?

After capturing decisions with "Save this decision" or adding invariants with "That's a hard rule", tell Claude: "Compile governance."

Claude reads your accepted ADRs and active invariants and produces `.claude/rules/governance.md` — short, actionable directives Claude follows automatically every session. The ADRs are the source of truth. The compiled output is the enforcement format.

**Command reference:** `/keel:compile`

## Does keel replace my linter or CI pipeline?

No. keel works upstream — it tells Claude the standards before code is written, so violations are prevented rather than caught. Your linter still runs. Your CI still validates. keel's job is to make the linter boring.

## Can I use keel on a team?

Yes. Commit the generated files. Every teammate using Claude Code gets identical governance — same standards, same agents, same decisions, same quality gates. No per-developer setup, no drift.

## Can I use keel across multiple projects?

Yes. Run `/keel:init` in each project. Each project gets its own rules matched to its stack, its own decisions, its own agents. The governance chain and quality gates work independently per project.

If you want a shared baseline — say, your consultancy's core standards — set up a base `.keel/config.yaml` template and customize per project. The methodology stays constant; the stack-specific rules vary.

## What's the maintenance overhead?

Low. Rules update when you re-run the install script (new templates from upstream). Decisions update when you compile governance. There's no daemon running, no service to maintain, no subscription to manage. The files are in your repo — version-controlled like everything else.

Per project, maintenance is: update keel when a new version ships, recompile when you capture new decisions. Minutes per month, not hours.

## What happens when Claude Code updates?

keel uses Claude Code's official platform primitives — rules, hooks, agents, settings.json. These are Anthropic's documented surface area. When Claude Code ships new hook types or rule capabilities, keel adopts them.

keel has tracked every Claude Code platform change since rules were introduced. Breaking changes are rare; when they happen, keel ships a patch.

## Does it work with Cursor or other AI tools?

The knowledge base (project-context.md, ADRs, specs, product docs) is plain markdown that works anywhere. But the governance loop — lifecycle hooks, path-conditional rules, quality gates, specialist agents, slash commands — only works in Claude Code. See [Why Claude Code only](/what-is-keel#why-claude-code-only) for the full breakdown.

## How do I update rules after changing config?

Edit `.keel/config.yaml`, then run `/keel:init` again. keel regenerates rules from the updated config without touching files you've manually edited.

## Something broke. How do I reset?

Delete `.claude/rules/` and `.keel/config.yaml`, then run `/keel:init` again. Or run `/keel:doctor` to diagnose the issue first.

---

Still have questions? [Open an issue on GitHub](https://github.com/dcsg/keel/issues).

Ready to try it? [Get started in 5 minutes](/getting-started).
