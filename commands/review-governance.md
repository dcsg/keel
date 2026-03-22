---
name: keel:review-governance
description: "Review governance document language for enforceability and clarity"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# keel:review-governance

Review governance documents (ADRs, invariants, guidelines, compiled directives) for language quality. Checks whether directives are specific enough, actionable enough, and phrased correctly to achieve reliable compliance when Claude reads them.

This is a language quality review, not a structural check (that's `/keel:doctor`) or a contradiction check (that's `/keel:compile --check`).

CRITICAL: Every finding must cite the specific text that fails the check and provide a concrete rewrite. Never flag a directive without showing how to fix it.

## Arguments

- `$ARGUMENTS` — optional scope:
  - No arguments: review all governance docs + compiled output
  - `compiled` or `governance.md`: review only the compiled directives file
  - `ADR-NNN`: review a specific ADR
  - `INV-NNN`: review a specific invariant
  - `guidelines`: review all guideline files

## Instructions

1. Read `.keel/config.yaml`. Resolve paths from the `paths:` section.

2. Determine scope from `$ARGUMENTS`. If no scope, gather all documents:
   - ADRs with `status: accepted` from `{paths.decisions}`
   - Invariants with `status: active` from `{paths.invariants}`
   - Guidelines from `{paths.guidelines}`
   - Compiled output from `.claude/rules/governance.md` (if it exists)

3. For each document, extract all directives — lines that instruct Claude to do or not do something. In ADRs, these are in the Decision section. In invariants, the Rule section. In guidelines, all bullet points. In the compiled file, all `- ` lines.

4. Score each directive against the Quality Criteria in the Reference section. A directive can have multiple findings.

5. Score the compiled output as a whole against the Document-Level Checks in the Reference section.

6. Output the report using the Output Format in the Reference section.

7. For each finding rated `weak` or `vague`, provide a concrete rewrite that passes the check. Use the Rewrite Examples in the Reference section as a model.

8. Output the summary:
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    GOVERNANCE REVIEW
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Documents reviewed: {n}
    Directives analyzed: {n}
    Strong: {n} | Adequate: {n} | Weak: {n} | Vague: {n}

    {If weak + vague > 0}:
    Top recommendations:
      1. {most impactful fix}
      2. {second most impactful fix}
      3. {third most impactful fix}

    {If all strong/adequate}:
    All directives are enforceable. Governance language is production-grade.
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

---

REMEMBER: This command reviews LANGUAGE QUALITY, not structure or contradictions. The question is: "If Claude reads this directive, will it know exactly what to do?" Every finding must include the original text and a concrete rewrite.

## Reference

### Quality Criteria

Score each directive on these dimensions. A directive is the weakest rating it receives on any dimension.

**1. Specificity** — Does it name the exact thing to do or avoid?

| Rating | Definition | Example |
|---|---|---|
| Strong | Names specific patterns, functions, or formats | "Use `fmt.Errorf("context: %w", err)` for error wrapping" |
| Adequate | Describes the behavior clearly without exact syntax | "Wrap errors with context describing the operation that failed" |
| Weak | Uses subjective terms without measurable criteria | "Write clean error handling code" |
| Vague | Could mean anything to different readers | "Handle errors properly" |

**2. Actionability** — Can Claude follow this without interpretation?

| Rating | Definition | Example |
|---|---|---|
| Strong | One clear action, no ambiguity about what to produce | "Every HTTP handler MUST return `Content-Type: application/json`" |
| Adequate | Clear intent, minor interpretation needed | "Use consistent error response format across all endpoints" |
| Weak | Multiple interpretations possible | "Keep the API consistent" |
| Vague | No actionable instruction | "Think about the user experience" |

**3. Phrasing** — Does it use the right emphasis level?

| Rating | Definition | Example |
|---|---|---|
| Strong | NEVER/MUST for hard constraints with one-clause reason | "NEVER hardcode secrets — they persist in git history" |
| Adequate | Clear imperative without emphasis marker | "Use parameterized queries for all SQL" |
| Weak | Soft language for a hard constraint | "Try to avoid hardcoding secrets" |
| Vague | No imperative, reads as suggestion | "It would be good to not hardcode secrets" |

**4. Testability** — Can compliance be verified?

| Rating | Definition | Example |
|---|---|---|
| Strong | Verifiable by grep, test, or code review with specific criteria | "All endpoints return `{ "error": "message", "code": "CODE" }` on failure" |
| Adequate | Verifiable by reading the code with clear criteria | "Error responses include a machine-readable error code" |
| Weak | Requires subjective judgment to verify | "Error responses should be helpful" |
| Vague | Cannot be verified | "The system should be reliable" |

### Document-Level Checks

Apply these to the compiled output (`.claude/rules/governance.md`) as a whole:

1. **Directive count**: If > 30 directives, flag as `[!!] {n} directives — exceeds recommended maximum of 30. Claude's compliance degrades with instruction count. Consider consolidating related directives.`

2. **Phrasing consistency**: Check if NEVER/MUST/ALWAYS are used consistently (all uppercase or all mixed). If mixed: `[!!] Inconsistent emphasis — {n} use NEVER (uppercase), {m} use Never (title case). Standardize to uppercase for hard constraints.`

3. **Primacy**: Check if invariants appear first. If not: `[!!] Invariants should be the first section — primacy bias means earlier directives get more attention.`

4. **Recency**: Check if invariants are restated at the end. If not: `[!!] Missing recency reinforcement — invariants should be restated at the bottom to exploit the U-shaped attention curve.`

5. **Cross-references**: Check if every directive has a `(ref: ADR-NNN)` or `(ref: INV-NNN)` source. If not: `[!!] {n} directives without source references — traceability is lost.`

6. **Redundancy**: Flag directives that say the same thing in different words. Report: `[!!] Redundant directives: "{directive A}" and "{directive B}" — consolidate into one.`

### Rewrite Examples

```
BEFORE (vague):
  "Follow good coding practices" (ref: guidelines/quality.md)

AFTER (strong):
  "Functions MUST be under 50 lines. Extract helpers when a function
   does more than one thing." (ref: guidelines/quality.md)
  Rating: Vague → Strong (specific line count, clear extraction trigger)
```

```
BEFORE (weak):
  "Try to keep the API backward compatible" (ref: ADR-003)

AFTER (strong):
  "NEVER remove or rename existing API fields — add new fields alongside
   old ones. Removal requires a versioned deprecation period." (ref: ADR-003)
  Rating: Weak → Strong (NEVER + specific behavior + process for exceptions)
```

```
BEFORE (weak phrasing for a hard constraint):
  "Secrets should not be in source code" (ref: INV-002)

AFTER (strong):
  "NEVER hardcode secrets, API keys, or passwords in source code — use
   environment variables or a secret manager. Secrets in code persist
   in git history even after removal." (ref: INV-002)
  Rating: Weak → Strong (NEVER + enumerated items + reason)
```

```
BEFORE (not testable):
  "The system should handle errors gracefully" (ref: ADR-005)

AFTER (testable):
  "Every API error response MUST return HTTP status code + JSON body with
   'error' (human message) and 'code' (machine-readable). No stack traces
   or internal details in production responses." (ref: ADR-005)
  Rating: Vague → Strong (specific format, verifiable by inspection)
```

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GOVERNANCE REVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{document name} ({n} directives)

  [strong]   "NEVER hardcode secrets — they persist in git history" (ref: INV-002)
  [adequate] "Use consistent error format across endpoints" (ref: ADR-003)
  [weak]     "Try to keep things backward compatible" (ref: ADR-003)
             → Rewrite: "NEVER remove or rename existing API fields — add new
               fields alongside old ones. Removal requires a versioned
               deprecation period." (ref: ADR-003)
  [vague]    "Handle errors properly" (ref: guidelines/quality.md)
             → Rewrite: "Every catch block MUST do one of: handle (retry,
               fallback), propagate with context, or log with correlation ID.
               Empty catch blocks are never acceptable."

{next document}
  ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Document-level checks (compiled output)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [ok]   Directive count: {n} (under 30)
  [ok]   Phrasing consistency: all NEVER/MUST uppercase
  [ok]   Primacy: invariants first
  [ok]   Recency: invariants restated at bottom
  [!!]   2 directives without source references
  [!!]   Redundant: "validate input at boundaries" appears in both
         ADR-002 directive and INV-003 directive — consolidate

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Research Basis

These criteria are grounded in empirical results:

- **EXP-004** (123 runs): well-written rules achieve 100% compliance on invented conventions. Poorly phrased rules were not tested because all keel rules are already strong — this command catches user-authored governance docs before they degrade the system.
- **IFEval++ (2025)**: phrasing inconsistency costs 18-31% compliance. Consistent NEVER/MUST phrasing outperforms mixed emphasis.
- **IFScale (2025)**: primacy bias peaks at 150-200 instructions. Earlier directives get more attention.
- **Lost in the Middle (Liu et al., 2023)**: 20%+ degradation for content in mid-document positions. U-shaped attention curve supports primacy + recency design.
- **Anthropic context engineering**: "Informative, yet tight" — every directive must earn its place.
