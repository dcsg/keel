# Philosophy

## Context is everything

The difference between good and bad AI output is almost always context. Give Claude the right context and it writes like a senior engineer who's been on the team for months. Give it nothing and it writes generic, inconsistent code.

Keel's job is making sure Claude has the right context before it writes a single line.

## Guardrails over guidelines

Documentation that Claude has to be told to read is documentation it will forget. A CLAUDE.md that says "remember to use error wrapping" works in session one. By session ten, it's ignored.

Rules installed in `.claude/rules/` are enforced automatically — every session, every file. The standard is in the right place, not in a reminder you have to repeat.

## Infer, don't interrogate

You describe your project in plain language. Keel figures out the architecture, picks the rules, and generates everything. You confirm and adjust.

The alternative — answering 20 yes/no questions — produces worse results and worse UX. One good description beats a configuration wizard.

## Plain markdown, no magic

No build step. No runtime. No proprietary formats. Every file keel generates is a `.md` or `.yaml` you can read, edit, diff, and version control.

If keel disappeared tomorrow, all the value would still be there — in files you own.

## Minimal surface area

Six commands. That's the entire interface. Each does exactly one thing well.

`/keel:init` installs. `/keel:context` loads. `/keel:plan` plans. `/keel:status` shows. `/keel:intake` organizes. `/keel:migrate` converts.

No subcommands, no flags, no configuration UI. The right amount of interface for the problem.

## The linter as safety net

The best engineering teams don't fix linting violations — they never write them in the first place. Not because they're suppressing warnings, but because they've internalized the standards.

Keel works the same way. Rules tell Claude what the standards are before it writes code. The linter still exists as a safety net, but it rarely fires.

The goal isn't fewer lint errors. The goal is not writing lint errors.
