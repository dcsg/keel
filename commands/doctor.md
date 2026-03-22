---
name: keel:doctor
description: "Validate governance setup and report actionable warnings"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# keel:doctor

Validate the entire keel governance setup and report what's healthy, what's missing, and how to fix it.

CRITICAL: NEVER skip a check or assume it passes — run every check from the Reference section and report an explicit status for each one.

## Instructions

1. Read `.keel/config.yaml`. If not found, output `[FAIL] .keel/config.yaml missing — run /keel:init to set up this project.` and stop.

2. Extract `base:` directory from config (default: `docs`).

3. Run all checks in parallel where possible. Use the check definitions in the Reference section below. For each check, report `[ok]`, `[!!]`, or `[FAIL]` as defined there.

4. Run checks in this order: Config, Project Context, Decisions, Invariants, Rules, Rule pack freshness, CLAUDE.md sentinel, Hooks (PreToolUse + PreCompact), Hooks (SessionStart + Stop), Product spec, Plans, Auto-memory, Agents, Extensibility, Linter sync, Keel version.

5. Run the Decision Graph checks from the Reference section. Report findings inline with the other checks.

6. Output the report using the Output Format in the Reference section.

7. If there are warnings or failures, list actionable next steps:
   ```
   Recommendations:
     1. {first issue} — run {command}
     2. {second issue} — run {command}
   ```

8. If everything passes, output: `All clear — governance is healthy.`

## Reference

### Check Definitions

**Config:**
```bash
python3 -c "import yaml; yaml.safe_load(open('.keel/config.yaml'))" 2>&1 || echo "INVALID"
```
- `[ok]` if valid YAML
- `[FAIL]` if parse error — show the error

**Project Context:**
- Check if `{base}/project-context.md` exists
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

**Hooks (PreToolUse + PreCompact):**
```bash
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

**Hooks (SessionStart + Stop):**

Check for SessionStart and Stop hooks in `.claude/settings.json`:

```python
import json
s = json.load(open('.claude/settings.json'))
# SessionStart
cmd = s.get('hooks', {}).get('SessionStart', [{}])[0].get('hooks', [{}])[0].get('command', '')
# Stop
stop = s.get('hooks', {}).get('Stop', [{}])[0].get('hooks', [{}])[0]
stop_prompt = stop.get('prompt', '') if stop.get('type') == 'prompt' else ''
```
- `[ok] SessionStart hook` if command references `.keel/hooks/session-start.sh`
- `[!!] SessionStart hook outdated (inline bash) — run /keel:upgrade` if command is inline bash
- `[ok] Stop hook` if prompt contains `"ok": true` AND does not use `"ok": false` for signals
- `[!!] Stop hook outdated (JSON validation error) — run /keel:upgrade` if prompt uses old free-text format
- `[!!] Stop hook causes blocking error — run /keel:upgrade` if prompt uses `{"ok": false, "reason":` to deliver signals (causes "Prompt hook condition was not met" error)

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

**Auto-memory:**
```bash
ENCODED=$(echo "$PWD" | sed 's|/|-|g')
MEMORY="$HOME/.claude/projects/${ENCODED}/memory/MEMORY.md"
```
- `[ok] Memory exists ({N} days old, {lines}/200 lines)` if present and fresh
- `[!!] Memory is stale ({N} days old)` — suggest `/keel:context` to refresh
- `[!!] Memory missing` — suggest `/keel:context` to create
- `[!!] Memory near limit ({lines}/200 lines)` — if > 180 lines, suggest pruning

**Agents:**
```bash
ls .claude/agents/*.md 2>/dev/null
```
- `[ok] {n} agents installed` if present
- `[--] No agents installed` — suggest `/keel:init` or `/keel:agents suggest`
- For each agent, check if it's customized:
  - Contains `<!-- keel:custom -->` → note as "custom"
  - Listed in `.keel/config.yaml` `agents.custom` → note as "custom (config)"
  - Report: `[ok] {n} agents installed ({m} custom, {k} default)`

**Extensibility:**
- Check `.keel/templates/` for template overrides:
  - For each file found: `[ok] Template override: {name}.md`
- Check `.keel/rules/` for rule overrides:
  - For each file found: `[ok] Rule override: {name}.md`
- Check `rules.{name}.extend` in config for rule extensions:
  - For each configured: check if the extension file exists
  - `[ok] Rule extension: {name} + {extend_file}`
  - `[!!] Rule extension configured but file missing: {extend_file}`

**Linter sync:**
```bash
find . -maxdepth 3 -name ".golangci-lint.yaml" -o -name ".golangci.yaml" -o -name ".eslintrc*" -o -name "eslint.config.*" -o -name "ruff.toml" -o -name ".rubocop.yml" -o -name "biome.json" 2>/dev/null | grep -v node_modules | grep -v .git
ls .claude/rules/linter-*.md 2>/dev/null
```
- For each linter config found with no corresponding `.claude/rules/linter-*.md`: `[!!] {config} found but no linter rules installed — run /keel:sync`
- For each `.claude/rules/linter-*.md`: compare its mtime to source config mtime. If config is newer: `[!!] Linter config changed since last sync — run /keel:sync`
- If no linter configs found: skip silently

**Keel version:**
```bash
INSTALLED=$(cat ~/.keel/VERSION 2>/dev/null | tr -d '[:space:]' || echo "unknown")
PROJECT=$(grep '^keel_version:' .keel/config.yaml | awk '{print $2}' | tr -d '"' || echo "unknown")
```
- `[ok] keel {PROJECT} (installed: {INSTALLED})` if versions match
- `[!!] project on keel {PROJECT}, installed is {INSTALLED} — run /keel:upgrade` if they differ
- `[!!] keel_version not set in .keel/config.yaml — run /keel:upgrade` if key missing

### Decision Graph Checks

Check the decision graph for consistency. Read all ADRs, invariants, and specs:

1. **ADR contradictions:** For each pair of ADRs with status `accepted`, check if they make contradictory decisions on the same topic. Example: ADR-001 says "Claude Code only" and ADR-007 says "support Cursor." Report:
   - `[!!] ADR contradiction: ADR-001 and ADR-007 make opposing decisions on multi-tool support`

2. **Rule-invariant consistency:** For each invariant, check if any installed `.claude/rules/*.md` file contradicts it. Example: invariant says "no compiled code" but a rule references TypeScript compilation. Report:
   - `[!!] Rule {name} may conflict with invariant {INV-NNN}: {reason}`

3. **Plan-ADR dependencies:** For each active plan, check if it references any ADRs with status `superseded`. Report:
   - `[!!] PLAN-{NNN} references ADR-{NNN} which is superseded — review plan assumptions`

4. **Invariant enforcement:** For each invariant, check if any rule or hook enforces it. If an invariant exists but nothing references or enforces it:
   - `[!!] INV-{NNN} is not referenced by any rule or hook — consider adding enforcement`

5. **Orphan artifacts:** Check for ADRs, PRDs, or specs that are not referenced by any other artifact (no plan, no spec, no references field points to them):
   - `[!!] ADR-{NNN} is not referenced by any spec or plan — still relevant or supersede?`

6. **Artifact status stale:** Check for PRDs or specs stuck in `draft` status for more than 7 days (based on file mtime):
   - `[!!] PRD-{NNN} has been in draft for {n} days — accept or archive`

7. **State machine violations:** Check if any spec references a PRD that is not `accepted`, or if any plan references artifacts that are not `accepted`:
   - `[!!] SPEC-{NNN} references PRD-{NNN} which is still in draft — PRD should be accepted first`

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 KEEL DOCTOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [ok]   keel {version} (installed: {installed})
 [ok]   .keel/config.yaml valid
 [ok]   {base}/project-context.md exists
 [ok]   {base}/decisions/ — {n} ADRs
 [ok]   {base}/invariants/ — {n} invariants
 [ok]   .claude/rules/ — {n} packs installed
 [ok]   CLAUDE.md has keel sentinel
 [ok]   SessionStart hook
 [ok]   Stop hook (artifact suggestions)
 [ok]   PreCompact hook
 [ok]   {base}/product/spec.md exists
 [ok]   {n} plans found
 [ok]   {n} agents installed in .claude/agents/
 [ok]   Memory: {n} days old, {lines}/200 lines
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 {pass_count} passed, {warn_count} warnings, {fail_count} failures
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
