---
name: keel:doctor
description: "Validate governance setup and report actionable warnings"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# keel:doctor

Validate the entire keel governance setup and report what's healthy, what's missing, and how to fix it.

## Instructions

### 1. Load Config

Read `.keel/config.yaml`. If not found:
```
[FAIL] .keel/config.yaml missing — run /keel:init to set up this project.
```
Stop here — nothing else can be validated without config.

Extract `base:` directory (default: `docs`).

### 2. Run Checks

Run all checks in parallel where possible. For each check, report one of:
- `[ok]` — check passed
- `[!!]` — warning (non-blocking, but should be fixed)
- `[FAIL]` — critical issue (blocks normal operation)

**Config:**
```bash
# Validate YAML is parseable
python3 -c "import yaml; yaml.safe_load(open('.keel/config.yaml'))" 2>&1 || echo "INVALID"
```
- `[ok]` if valid YAML
- `[FAIL]` if parse error — show the error

**Soul:**
- Check if `{base}/soul.md` exists
- `[ok]` if present, `[!!]` if missing — suggest `/keel:init`

**Decisions:**
```bash
ls {base}/decisions/*.md 2>/dev/null | wc -l
```
- `[ok] {base}/decisions/ — {n} ADRs`
- `[!!]` if directory missing or empty — suggest `/keel:intake` or creating first ADR

**Invariants:**
```bash
ls {base}/invariants/*.md 2>/dev/null | wc -l
```
- `[ok] {base}/invariants/ — {n} invariants`
- `[ok]` if empty (invariants are optional) — note "none defined"

**Rules:**
```bash
ls .claude/rules/*.md 2>/dev/null | wc -l
```
- `[ok] .claude/rules/ — {n} packs installed`
- `[!!]` if empty — suggest `/keel:init` to install rule packs
- For each rule file, check for `<!-- keel:generated -->` marker. If missing, note as manually edited (informational, not a warning).

**Rule pack freshness:**

For each `.claude/rules/*.md` file that has the `keel:generated` marker:
1. Read its `version:` from YAML frontmatter
2. Look up the pack name (filename without `.md`) in the registry
3. Compare versions:
   - Installed version == registry version: no output (already covered by Rules check)
   - Installed version < registry version: `[!!] {name} outdated (installed: {old}, available: {new}) — run /keel:rules-update`
   - No `version:` in installed file: `[!!] {name} has no version — may predate versioning`
   - Pack not in registry (custom rule): skip silently

**CLAUDE.md sentinel:**
```bash
grep -q 'keel:' CLAUDE.md 2>/dev/null
```
- `[ok]` if CLAUDE.md contains a keel reference
- `[!!]` if missing — suggest `/keel:init` to generate CLAUDE.md

**Hooks:**
```bash
# Check for PreToolUse and PreCompact hooks
python3 -c "
import json
s = json.load(open('.claude/settings.json'))
hooks = s.get('hooks', {})
pre_tool = hooks.get('PreToolUse', [])
pre_compact = hooks.get('PreCompact', [])
has_tool = any('Write|Edit' in str(h.get('matcher','')) for h in pre_tool)
has_compact = len(pre_compact) > 0
print(f'PreToolUse:{has_tool}')
print(f'PreCompact:{has_compact}')
" 2>/dev/null
```
- `[ok] PreToolUse hook (Write|Edit sentinel)` if present
- `[!!] PreToolUse hook missing` — suggest `/keel:init`
- `[ok] PreCompact hook` if present
- `[!!] PreCompact hook missing` — suggest `/keel:init`

**Product spec:**
- Check if `{base}/product/spec.md` exists
- `[ok]` if present
- `[!!]` if missing — suggest `/keel:intake` to onboard existing specs

**Plans:**
```bash
ls {base}/product/plans/PLAN-*.md {base}/plans/PLAN-*.md 2>/dev/null
```
- `[ok] {n} plans found` — list active ones
- `[!!] No PLAN-*.md found` — suggest `/keel:plan`

**Legacy directories:**
- Check for `.dof/` or `.conductor/` directories
- `[!!]` if found — suggest `/keel:intake` to migrate, then remove

### 3. Output Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL DOCTOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [ok]   .keel/config.yaml valid
 [ok]   {base}/soul.md exists
 [ok]   {base}/decisions/ — {n} ADRs
 [ok]   {base}/invariants/ — {n} invariants
 [ok]   .claude/rules/ — {n} packs installed
 [ok]   CLAUDE.md has keel sentinel
 [ok]   PreToolUse hook (Write|Edit sentinel)
 [ok]   PreCompact hook
 [ok]   {base}/product/spec.md exists
 [ok]   {n} plans found
 [!!]   .dof/ directory found — run /keel:intake to migrate

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 {pass_count} passed, {warn_count} warnings, {fail_count} failures
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 4. Recommendations

If there are warnings or failures, list actionable next steps:

```
Recommendations:
  1. {first issue} — run {command}
  2. {second issue} — run {command}
```

If everything passes:
```
All clear — governance is healthy.
```
