---
name: keel:drift
description: "Verify implementation matches spec, PRD, and ADRs"
---

# keel:drift

Compare desired state (PRD, spec, artifacts, ADRs, invariants) against current implementation. Produces a drift report showing what's compliant, what diverged, and what can't be verified.

CRITICAL: NEVER assign a severity level without reading the actual code — every finding must cite evidence (file:line or explicit reasoning for unknown status).

## Arguments

- `$ARGUMENTS` — SPEC identifier (e.g., `SPEC-005`), `--scope=` filter, `--output=json` for CI

## Instructions

1. Read `.keel/config.yaml`. Resolve all paths from the `paths:` section using the Path Defaults in the Reference section.

2. Find the spec: if `$ARGUMENTS` contains a SPEC identifier, locate `{specs_dir}/SPEC-{id}/spec.md`. If no identifier provided, use the most recent spec folder. If none exists, warn the user and suggest `/keel:spec` or `--scope=prd`.

3. Read the spec's frontmatter. Extract `source_prd:` and `references:`.

4. Parse `--scope=` from arguments. Use the Scope Definitions table in the Reference section to determine which layers to run. Default is full chain.

5. Gather context for each layer in scope: spec, artifacts, source PRD, referenced ADRs, invariants. Get the implementation diff using git log from the plan start date (or last 30 days as fallback). Read the changed files.

6. Route each layer to the appropriate specialist agent via the Agent tool. Pass the reference document, the implementation diff, and relevant codebase context. Use the Layer-to-Agent mapping in the Reference section.

7. Apply the Severity Model from the Reference section to each finding.

8. If `--output=json` is in arguments, use the JSON Output Format from the Reference section. Otherwise use the Terminal Output Format.

9. Save the report to `{reports_path}/drift-{SPEC-NNN}-{YYYY-MM-DD}.md` using the terminal format with frontmatter from the Reference section.

10. Log the drift event:
    ```bash
    source "$HOME/.keel/hooks/event-log.sh" 2>/dev/null
    keel_log_event "drift_report" '{"spec":"SPEC-{NNN}","compliant":{n},"diverged":{n}}'
    ```

11. When called from `/keel:review` (not directly): only run if an active spec exists, use `--scope=spec`, and append findings under a "DRIFT CHECK" section in the review output.

12. Output the confirmation:

    ```
    DRIFT REPORT — {SPEC identifier}
    ─────────────────────────────────────────────────
    {report content}
    ─────────────────────────────────────────────────

    Report saved: {reports_path}/drift-{SPEC-NNN}-{date}.md

    {If diverged findings:}
      {n} diverged finding(s). Want me to prioritize them?

    {If all compliant:}
      All clear — implementation matches governance.
    ```

---

REMEMBER: NEVER assign a severity without reading the actual code. Every finding must cite evidence (file:line or explicit reasoning). Compliant means you verified it, not that you assumed it.

## Reference

### Path Defaults

| Key | Default |
|---|---|
| `paths.specs` | `docs/product/specs` |
| `paths.reports` | `docs/reports` |
| `paths.decisions` | `docs/architecture/decisions` |
| `paths.invariants` | `docs/architecture/invariants` |
| `paths.plans` | `docs/plans` |

### Scope Definitions

| Scope | What it checks |
|---|---|
| (default) | PRD acceptance criteria + spec requirements + artifact contracts + ADR compliance + invariant compliance |
| `--scope=prd` | PRD acceptance criteria only |
| `--scope=spec` | Spec requirements only |
| `--scope=artifacts` | Artifact contracts only (data model, API contracts) |
| `--scope=adrs` | ADR compliance only |

### Layer-to-Agent Mapping

| Layer | What to check | Agent(s) |
|---|---|---|
| Layer 1: PRD Acceptance Criteria | For each acceptance criterion in the PRD, is it satisfied? | `architect` |
| Layer 2: Spec Requirements | For each requirement or component in the spec, was it implemented as specified? | `architect` + `engineer` |
| Layer 3: Artifact Contracts | `data-model.md` → actual schema matches? `contracts/api.md` → actual endpoints match? `test-strategy.md` → tests exist? `contracts/events.md` → event schema matches? Skip artifacts that don't exist. | `dba`, `api`, `qa`, `architect` |
| Layer 4: ADR Compliance | For each referenced ADR, does the implementation follow the decision? | `architect` |
| Layer 5: Invariant Compliance | For each invariant, is it violated by any changed file? | `architect` |

### Severity Model

| Level | Meaning | When to use |
|---|---|---|
| ✅ Compliant (high confidence) | Implementation matches the decision | Verified by reading code — the thing exists and works as specified |
| 🟡 Likely compliant (medium) | Appears to match but can't verify deterministically | Spec says "handle errors" and error handling exists, but full coverage can't be confirmed statically |
| ⚠️ Diverged (high confidence) | Implementation clearly differs from the decision | Spec says 2 agents get memory:project, only 1 does |
| ❓ Unknown | Not enough signal to determine | Spec says "context:fork on commands" — frontmatter check isn't possible from file reading alone |

### Terminal Output Format

Emoji summary at the top, then a table showing ALL findings across all severity levels. The table is the complete picture — nothing hidden.

```
DRIFT REPORT — {SPEC identifier}
─────────────────────────────────────────────────
Source: {SPEC-NNN} + {n} artifacts + {n} ADRs + {n} invariants
Scope:  {scope description}
Date:   {today}

SUMMARY
  ✅ {n} compliant    🟡 {n} likely compliant
  ⚠️  {n} diverged     ❓ {n} unknown

{If any non-compliant findings, show this table:}

┌─────┬────────┬───────────────────────────────────────────────────────────────────────────────┐
│  #  │ Status │ Description                                                                   │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────────┤
│  1  │  ⚠️    │ {source}: {description of divergence — cite file:line}                        │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────────┤
│  2  │  ⚠️    │ {source}: {description}                                                       │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────────┤
│  3  │  🟡    │ {source}: {description — why only likely compliant}                            │
├─────┼────────┼───────────────────────────────────────────────────────────────────────────────┤
│  4  │  ❓    │ {source}: {description — why unknown}                                          │
└─────┴────────┴───────────────────────────────────────────────────────────────────────────────┘
```

Key formatting rules:
- Emoji summary at the top for a quick read — compliant count lives here, not in the table
- Table shows ONLY non-compliant findings (⚠️ diverged, 🟡 likely, ❓ unknown)
- Sort: ⚠️ diverged first, then 🟡 likely, then ❓ unknown
- Compliant items are NOT in the table — the summary line is sufficient
- If diverged findings exist, end with: `{n} diverged finding(s). Want me to prioritize them?`
- If all compliant, skip the table entirely: `All clear — implementation matches governance.`

### JSON Output Format (CI)

```json
{
  "spec": "SPEC-005",
  "scope": "full",
  "date": "2026-03-20",
  "summary": {
    "compliant": 14,
    "likely_compliant": 3,
    "diverged": 2,
    "unknown": 1
  },
  "findings": [
    {
      "layer": "adr",
      "source": "ADR-003",
      "status": "diverged",
      "description": "Kafka tenant propagation missing",
      "expected": "customer_id as Kafka header",
      "found": "no tenant header in outbox publisher"
    }
  ]
}
```

Exit code:
- `0` if no diverged findings
- `1` if any diverged findings

### Report Frontmatter

```markdown
---
type: drift-report
spec: SPEC-{NNN}
scope: {scope}
date: {today}
summary:
  compliant: {n}
  likely_compliant: {n}
  diverged: {n}
  unknown: {n}
---
```
