# FAQ

## Do I commit `.claude/rules/` to git?

**Yes.** Commit everything keel generates — `.claude/rules/`, `.claude/CLAUDE.md`, `.claude/settings.json`, `docs/soul.md`, `.keel/config.yaml`. This is how the whole team benefits. When a teammate opens the project in Claude Code, they get the same context and guardrails automatically.

## Will keel overwrite my existing CLAUDE.md?

No. Keel generates `.claude/CLAUDE.md` (inside the `.claude/` directory), not the root `CLAUDE.md`. If you have an existing root `CLAUDE.md`, keel won't touch it.

## Can I use keel without a keel config?

Partially. The commands work — but `/keel:init` is what generates the config and rules. Without it, you're just using the commands standalone.

## Does it work with Cursor or other AI tools?

The knowledge base (soul.md, ADRs, product docs) is plain markdown that works anywhere. But the full guardrail loop — path-conditional rules, hooks, slash commands — only works in Claude Code. See [What is Keel?](/what-is-keel#why-claude-code-only) for the full breakdown.

## Can I use keel on a team?

Yes, and this is where it shines. Commit the generated files. Every teammate using Claude Code gets identical context and guardrails. No per-developer setup, no drift.

## How do I update rules after changing config?

Edit `.keel/config.yaml`, then run `/keel:init` again. Keel regenerates rules from the updated config without touching files you've manually edited.

## What's the difference between keel and just writing a CLAUDE.md?

A hand-written CLAUDE.md is a good start. Keel adds:

- **Path-conditional rules** — Go rules only fire on Go files
- **Opinionated defaults** — 16 pre-written rule packs you don't have to author
- **Structured context** — soul, plans, PRDs organized and loaded properly
- **Commands** — plan, status, intake as repeatable workflows
- **Compaction recovery** — progress survives context resets

## Something broke. How do I reset?

Delete `.claude/rules/` and `.keel/config.yaml`, then run `/keel:init` again.
