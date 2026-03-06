# Existing Projects

Keel audits your codebase and recommends rules based on what it actually finds.

## Flow

1. Open your existing project in Claude Code
2. Run `/keel:init`
3. Keel detects the project has history and runs a codebase audit
4. Review and confirm the recommendations

## What Gets Audited

- Languages and versions (`go.mod`, `package.json`, `pyproject.toml`, etc.)
- Frameworks and dependencies
- Directory structure pattern (flat, layered, domain-driven)
- Test setup and coverage tooling
- Existing linting config (`.golangci-lint.yaml`, `.eslintrc`, etc.)
- Git history depth

## What gets created

```
docs/
├── soul.md           # seeded from codebase audit
├── decisions/        # for architecture decisions going forward
├── invariants/       # hard constraints on the system
└── product/
    ├── spec.md       # product spec stub
    ├── prds/
    └── plans/
```

## Scattered Docs

If your project has docs spread across READMEs, wikis, or old ADR folders, run `/keel:intake` after init to organize everything into keel's structure.

## Tips

- Commit the generated files — your team benefits immediately
- The installed rules are a starting point — extend them with project-specific rules
- If the audit misses something, you can edit `.keel/config.yaml` and re-run init
