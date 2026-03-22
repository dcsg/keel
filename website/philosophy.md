---
title: "Philosophy — Governance Over Context"
description: "keel's core principles: governance over context, enforcement over suggestion, traceability over trust, compound consistency."
---

# Philosophy

## Governance over context

Context makes Claude informed. Governance makes Claude consistent. Loading the right files is step one — but files Claude can read are not the same as standards Claude enforces. keel's job is not just making Claude informed. It's making Claude governed.

The difference: a CLAUDE.md file says "prefer returning errors over panicking." A governance rule in `.claude/rules/error-handling.md` enforces it automatically, every file, every session. The first is a suggestion. The second is a standard.

## Enforcement over suggestion

Documentation that Claude has to be told to read is documentation it will ignore. A CLAUDE.md that says "remember to use error wrapping" works in session one. By session ten, it's forgotten.

Rules installed in `.claude/rules/` are enforced automatically. Hooks fire without being invoked. Quality gates block progression without being asked. The standard is in the system, not in a reminder you repeat.

## Traceability over trust

Trusting that Claude followed the spec is not the same as verifying it. keel's governance chain — PRD → spec → artifacts → plan → execute → drift detection — creates a traceability path from intent to implementation.

Every decision in the chain is captured. Every step references the one before it. When `/keel:drift` runs, it doesn't check whether Claude "feels right" — it checks whether the implementation matches the spec and the PRD.

## Decisions compile into enforcement

Architectural decisions shouldn't live in documents Claude might read. They should compile into directives Claude follows automatically.

`/keel:compile` reads your accepted ADRs and active invariants and produces `.claude/rules/governance.md`. Update the ADR, recompile. The source of truth is the decision record. The enforcement format is the compiled output.

## Infer, don't interrogate

You describe your project in plain language. keel figures out the architecture, picks the rules, and generates everything. You confirm and adjust.

The alternative — answering 20 yes/no questions — produces worse results and worse UX. One good description beats a configuration wizard.

## Plain markdown, no magic

No build step. No runtime. No proprietary formats. Every file keel generates is a `.md` or `.yaml` you can read, edit, diff, and version control.

If keel disappeared tomorrow, all the value would still be there — in files you own.

## The linter analogy

The best engineering teams don't fix linting violations — they never write them in the first place. Not because they suppress warnings, but because the standards are enforced before the code is written.

keel works the same way. Rules tell Claude what the standards are before it writes code. The linter still exists as a safety net, but it rarely fires. The goal isn't fewer lint errors. The goal is not writing lint errors.

## Compound consistency

Every session builds on the last. Decisions accumulate, not decay. The governance chain grows as the project grows — more ADRs, more invariants, more compiled directives. The tenth session is governed more thoroughly than the first, not less.

This is the opposite of how CLAUDE.md files work. A CLAUDE.md gets stale. A governance layer compounds.
