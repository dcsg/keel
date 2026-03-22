# Keel

**The governance layer for agentic engineering.**

Enforce coding standards, persist architectural decisions, and make agent behavior reproducible across every session and every engineer.

```bash
curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

Then open any project in Claude Code and run `/keel:init`.

## What it does

Without keel, every Claude Code session starts from scratch. Standards live in your head. Decisions get forgotten between sessions. Each engineer's Claude learns differently and drifts differently.

keel fixes this by installing your standards where Claude reads them automatically — before writing a single line of code. Rules enforce your coding conventions. Hooks automate your workflow. Agents review your work. Compiled directives turn your ADRs into enforcement.

## The full cycle

```
/keel:prd             → requirements and acceptance criteria
/keel:spec            → technical specification
/keel:spec-artifacts  → data model, API contracts, test strategy
/keel:plan            → phased execution with specialist review
  execute             → Claude builds with enforced standards
/keel:drift           → verify implementation matches the spec
```

## What keel installs

- **20 rule packs** — path-conditional standards (Go, TypeScript, Python, Next.js, Django, and more)
- **18 specialist agents** — architect, dba, security, api, qa, sre, and others
- **9 lifecycle hooks** — auto-format, plan injection, compaction recovery, quality gates
- **Compiled governance** — ADRs and invariants compile into directives Claude follows automatically
- **24 commands** — from init through drift detection

## Documentation

Full documentation, guides, and examples at **[keel.dcsg.me](https://keel.dcsg.me)**.

- [Getting Started](https://keel.dcsg.me/getting-started) — install and init in 5 minutes
- [How It Works](https://keel.dcsg.me/governance/chain) — the governance chain
- [Commands](https://keel.dcsg.me/commands/) — all 24 commands
- [Rule Packs](https://keel.dcsg.me/rules/) — what gets enforced

## Claude Code only

keel uses Claude Code's platform primitives — path-conditional rules, lifecycle hooks, slash commands, specialist agents, quality gates. Other tools don't have them. The knowledge base (project-context.md, ADRs, specs) is plain markdown that works anywhere. The governance loop only works in Claude Code.

## No build step. No runtime. No magic.

Every file is `.md` or `.yaml` you can read, edit, and version-control. Plain markdown, no dependencies.
