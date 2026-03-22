# /keel:doctor

Validate governance setup and report what's healthy, what's missing, and how to fix it.

## Usage

```
/keel:doctor
```

## What it checks

| Check | Pass | Warn |
|-------|------|------|
| `.keel/config.yaml` valid | ✅ | Parse error shown |
| `{base}/project-context.md` exists | ✅ | Suggest `/keel:init` |
| `{base}/decisions/` ADRs | ✅ count | Empty → suggest `/keel:adr` |
| `{base}/invariants/` | ✅ count | — |
| `.claude/rules/` packs | ✅ count | Empty → suggest `/keel:init` |
| Rule pack freshness | ✅ current | Outdated → suggest `/keel:rules-update` |
| CLAUDE.md keel sentinel | ✅ | Missing → suggest `/keel:init` |
| SessionStart hook | ✅ | Outdated inline bash → suggest `/keel:upgrade` |
| Stop hook | ✅ | Outdated format or blocking error → suggest `/keel:upgrade` |
| PreToolUse hook | ✅ | Missing → suggest `/keel:init` |
| PreCompact hook | ✅ | Missing → suggest `/keel:init` |
| `{base}/product/spec.md` | ✅ | Missing → suggest `/keel:intake` |
| Active plans | ✅ count | None → suggest `/keel:plan` |
| Auto-memory | ✅ age/size | Stale or near limit → suggest `/keel:context` |
| Agents installed | ✅ count | None → suggest `/keel:init` |
| Extensibility (template + rule overrides) | ✅ | Extension file configured but missing |
| Linter sync | ✅ | Config newer than rules → suggest `/keel:sync` |
| Keel version | ✅ match | Project version differs from installed → suggest `/keel:upgrade` |

### Decision graph validation

Doctor also validates the consistency of the governance graph:

| Check | What it detects |
|-------|----------------|
| ADR contradictions | Pairs of accepted ADRs making opposing decisions on the same topic |
| Rule-invariant consistency | Rules that contradict an active invariant |
| Plan-ADR dependencies | Active plans referencing superseded ADRs |
| Invariant enforcement | Invariants not referenced by any rule or hook |
| Orphan artifacts | ADRs, PRDs, or specs not referenced by any other artifact |
| Stale artifacts | PRDs or specs stuck in `draft` for more than 7 days |
| State machine violations | Specs referencing unaccepted PRDs, or plans referencing draft artifacts |

## Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL DOCTOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [ok]   .keel/config.yaml valid
 [ok]   docs/project-context.md exists
 [ok]   docs/decisions/ — 4 ADRs
 [ok]   .claude/rules/ — 3 packs installed
 [!!]   go.md outdated (installed: 1.0, available: 1.2) — run /keel:rules-update
 [ok]   CLAUDE.md has keel sentinel
 [ok]   SessionStart hook is git-aware
 [ok]   Memory: 2 days old, 45/200 lines
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 14 passed, 1 warning, 0 failures
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recommendations:
  1. go.md outdated — run /keel:rules-update
```

## Natural language triggers

- "is keel set up correctly?"
- "check governance"
- "doctor"
- "any issues with keel?"
