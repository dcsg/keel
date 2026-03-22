# /keel:review-governance

Review governance documents for language quality. Checks whether ADRs, invariants, guidelines, and compiled directives are specific enough, actionable enough, and phrased correctly to achieve reliable compliance when Claude reads them.

This is a language quality review — not a structural check ([`/keel:doctor`](/commands/doctor)) or a contradiction check ([`/keel:compile --check`](/commands/compile)).

## Usage

```
/keel:review-governance
/keel:review-governance compiled
/keel:review-governance ADR-003
/keel:review-governance guidelines
```

## Arguments

| Argument | Description |
|----------|-------------|
| (none) | Review all governance docs + compiled output |
| `compiled` | Review only `.claude/rules/governance.md` |
| `ADR-NNN` | Review a specific ADR |
| `INV-NNN` | Review a specific invariant |
| `guidelines` | Review all guideline files |

## What it checks

Every directive is scored on four dimensions:

| Dimension | Strong | Vague |
|-----------|--------|-------|
| **Specificity** | Names exact patterns, functions, or formats | Could mean anything to different readers |
| **Actionability** | One clear action, no ambiguity | No actionable instruction |
| **Phrasing** | NEVER/MUST with one-clause reason for hard constraints | Reads as a suggestion |
| **Testability** | Verifiable by grep, test, or code review | Cannot be verified |

For the compiled output, it also checks:
- Directive count (warns above 30)
- Phrasing consistency (NEVER vs Never)
- Primacy (invariants first)
- Recency (invariants restated at end)
- Source references on every directive
- Redundancy between directives

## Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GOVERNANCE REVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

docs/architecture/decisions/ADR-003.md (4 directives)

  [strong]   "NEVER hardcode secrets — they persist in git history"
  [adequate] "Use consistent error format across endpoints"
  [weak]     "Try to keep things backward compatible"
             → Rewrite: "NEVER remove or rename existing API fields —
               add new fields alongside old ones. Removal requires a
               versioned deprecation period."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Document-level checks (compiled output)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [ok]   Directive count: 12 (under 30)
  [ok]   Phrasing consistency: all NEVER/MUST uppercase
  [ok]   Primacy: invariants first
  [ok]   Recency: invariants restated at bottom
  [!!]   2 directives without source references

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Documents reviewed: 8
  Directives analyzed: 14
  Strong: 10 | Adequate: 3 | Weak: 1 | Vague: 0

  Top recommendations:
    1. ADR-003: rewrite "Try to keep things backward compatible"
       with NEVER + specific behavior
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Why this matters

Keel's [EXP-004 experiment](/experiments/governance-checkpoint) ran 123 eval scenarios and proved that well-written rules achieve 100% compliance on conventions Claude has never seen in training. The rule text is the mechanism — not the enforcement layer on top. This means governance quality is directly proportional to how well the documents are written.

A vague directive like "handle errors properly" compiles into a vague governance rule. A specific directive like "every catch block MUST handle, propagate, or log — no empty catches" compiles into an enforceable one.

## When to run

- After writing a new ADR or invariant — check the language before accepting
- After `/keel:compile` — review the compiled output as a whole
- Periodically — governance docs accumulate; quality can drift over time
- Before onboarding a new team member — clean governance is clearer governance

## How it relates to other commands

| Command | What it checks |
|---------|---------------|
| [`/keel:doctor`](/commands/doctor) | Is governance *set up* correctly? (structural health) |
| [`/keel:compile --check`](/commands/compile) | Do governance docs *contradict* each other? (logical consistency) |
| **`/keel:review-governance`** | Is governance *written well enough* to work? (language quality) |
| [`/keel:drift`](/commands/drift) | Does implementation *match* governance? (runtime compliance) |

## Natural language triggers

- "review our governance docs"
- "are our ADRs well written?"
- "check governance quality"
- "review the compiled directives"
- "is our governance enforceable?"

## What's next

- [Governance Chain](/governance/chain) — how governance flows from decisions to enforcement
- [/keel:compile](/commands/compile) — compile reviewed docs into directives
- [EXP-004: Governance Checkpoint](/experiments/governance-checkpoint) — the research behind these quality criteria
