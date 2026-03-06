# Greenfield Projects

Starting fresh? Keel is at its best here — no legacy to audit, just describe what you're building.

## Flow

1. Create your repo and make an initial commit
2. Open in Claude Code
3. Run `/keel:init`
4. Describe your project in plain language

## Example

```
/keel:init

> What are you building?

A SaaS platform for restaurant inventory management. Go backend with
Chi router, PostgreSQL, following DDD with bounded contexts for
inventory, orders, and suppliers. React + TypeScript frontend.
```

Keel infers:
- **Architecture:** DDD with 3 bounded contexts
- **Stack:** Go, Chi, TypeScript, React
- **Rules:** code-quality, testing, security, error-handling, architecture, go, chi, typescript

Shows toggle UI. Press enter to accept. Done.

## What You Get

A project structure ready for serious development:

```
your-project/
├── docs/
│   ├── soul.md              # seeded from your description
│   ├── decisions/           # architecture decision records
│   ├── invariants/          # hard constraints — never violate these
│   └── product/
│       ├── spec.md          # product spec stub
│       ├── prds/
│       └── plans/
├── .keel/config.yaml
└── .claude/
    ├── rules/               # 7 rule files installed
    ├── agents/              # reviewer + debugger
    ├── settings.json        # PreToolUse context gate + PreCompact recovery
    └── CLAUDE.md
```

## Tips

- The more specific your description, the better keel's inference
- Mention your architecture pattern explicitly (DDD, hexagonal, clean arch) if you have one in mind
- You can always re-run `/keel:init` to adjust rules after the first run
