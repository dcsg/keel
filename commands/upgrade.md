---
name: keel:upgrade
description: "Upgrade keel in this project — hooks, agents, and rules to the latest installed version"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# keel:upgrade

Upgrade keel in this project to match the currently installed keel version. Updates hooks, agent templates, and rule packs — never overwrites customizations without asking.

## Instructions

### 1. Check Prerequisites

Read `.keel/config.yaml`. If not found:
```
No keel config found. Run /keel:init to set up this project.
```

Check that keel templates exist at `~/.keel/templates/`. If not:
```
Keel templates not found. Re-install keel:
  curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash
```

Read the installed keel version:
```bash
INSTALLED_VERSION=$(cat ~/.keel/VERSION 2>/dev/null | tr -d '[:space:]' || echo "unknown")
PROJECT_VERSION=$(grep '^keel_version:' .keel/config.yaml | awk '{print $2}' | tr -d '"' || echo "unknown")
```

Show at the top of the output:
```
Installed keel: {INSTALLED_VERSION}
Project keel:   {PROJECT_VERSION}
```

If both versions match AND there are no changes detected in step 2, AND `keel_version` is already set in `.keel/config.yaml`, show:
```
✅ Already up to date (keel {INSTALLED_VERSION}) — nothing to upgrade.
```
and stop.

If `keel_version` is missing from `.keel/config.yaml` (project predates versioning), always proceed — adding the version is itself an upgrade.

### 2. Detect What Needs Upgrading

Run all three checks in parallel and collect findings.

#### 2a. Hooks check

Read `.claude/settings.json`. Read `~/.keel/templates/settings.json.tmpl`.

For each hook type, check two things: (1) is the content correct, and (2) is it using the modern `.sh` script reference format?

**Migration check — inline bash vs. script references:**
If any `type: command` hook has its logic inline (a long bash string) rather than referencing `$HOME/.keel/hooks/*.sh`, it is outdated regardless of content. Note: "using inline bash — migrate to script reference".

**Content checks:**
- `SessionStart`: command should be `$HOME/.keel/hooks/session-start.sh` (or contain `git log` if inline) — if not → outdated
- `PostToolUse`: must be present with `Write|Edit` matcher — if missing → missing
- `Stop`: prompt must always return `{"ok": true}` with signals as plain text before the JSON. Two outdated patterns to detect:
  1. Old free-text format ("end your next response with...") → outdated (causes JSON validation errors)
  2. Uses `{"ok": false, "reason": "..."}` for signals → outdated (causes "Prompt hook condition was not met" blocking error)
- `PreCompact`: command should reference `$HOME/.keel/hooks/pre-compact.sh` or contain `/keel:session` — if not → outdated

For each outdated or missing hook, note what changed in plain English:
- "SessionStart: inline bash → migrate to `$HOME/.keel/hooks/session-start.sh`"
- "PostToolUse: missing (now auto-formats files after edits)"
- "Stop: old free-text format → fix JSON validation error (now returns `{\"ok\": true}` always)"
- "Stop: uses `ok: false` for signals → fix 'Prompt hook condition was not met' error (signals must be plain text before `{\"ok\": true}`)"
- "PreCompact: inline bash → migrate to `$HOME/.keel/hooks/pre-compact.sh`"

#### 2b. Agent check

List files in `.claude/agents/`. For each, check if a matching template exists in `~/.keel/templates/agents/`.

For each agent that has a keel template, compare modification times:
```bash
template_mtime=$(stat -f %m ~/.keel/templates/agents/{slug}.md 2>/dev/null || stat -c %Y ~/.keel/templates/agents/{slug}.md 2>/dev/null)
installed_mtime=$(stat -f %m .claude/agents/{slug}.md 2>/dev/null || stat -c %Y .claude/agents/{slug}.md 2>/dev/null)
```

- If template is newer → outdated
- If installed is newer or same → up to date

Do NOT touch agents that have no matching template (user-created agents).

#### 2c. Rule packs check

If `.claude/rules/` does not exist or contains no `.md` files → mark rule packs as "nothing installed, skip" (not outdated).

Otherwise, same logic as `/keel:rules-update`:
- Compare `version:` frontmatter in installed vs template
- Only flag as outdated if installed version < template version
- Skip files without `<!-- keel:generated -->` marker (manually edited)
- Skip files not in the registry (custom rules)

### 3. Show Upgrade Summary

Show what will change in this project before touching anything:

```
KEEL UPGRADE
─────────────────────────────────────────────────────
Hooks (.claude/settings.json)
  ⬆  SessionStart   — inline bash → script reference
  ⬆  PostToolUse    — missing, will add auto-format hook
  ⬆  Stop           — fix "Prompt hook condition was not met" error (ok:false → ok:true always)
  ⬆  PreCompact     — inline bash → script reference

Agents (.claude/agents/)
  ⬆  principal-dba.md   — template updated
  ⬆  staff-security.md  — template updated
  ✓  principal-architect.md  — up to date

Rule packs (.claude/rules/)
  ⬆  go.md          1.0 → 1.2
  ⬆  code-quality.md 1.0 → 1.1
  ✓  testing.md      — up to date
  —  my-custom.md    — custom, skipped
  —  security.md     — manually edited, skipped

─────────────────────────────────────────────────────
4 hook changes, 2 agents, 2 rule packs
```

If no rule packs are installed (`.claude/rules/` is missing or empty), show:
```
Rule packs (.claude/rules/)
  —  no rule packs installed
```
Do NOT show any `⬆` icon for rules in this case.

If everything is already up to date:
```
✅ Already up to date — nothing to upgrade.
```

### 4. Confirm

Ask the user:
```
Apply these upgrades? (y/n/select)
  y      — apply all
  n      — cancel
  select — choose which sections to apply (hooks / agents / rules)
```

Wait for response. If `select`, ask separately for each section.

If cancelled:
```
Upgrade cancelled — no changes made.
```

### 5. Apply Upgrades

#### Hooks

Read the current `.claude/settings.json`. Read the template.

For each outdated hook, replace ONLY that hook's entry — do not touch other hooks or non-hook settings (like `permissions`). Merge carefully:

```python
# Pseudocode
settings = read_json('.claude/settings.json')
template_hooks = read_json('~/.keel/templates/settings.json.tmpl')['hooks']

for hook_type in ['SessionStart', 'PreToolUse', 'PostToolUse', 'Stop', 'PreCompact']:
    if hook_type needs upgrade:
        settings['hooks'][hook_type] = template_hooks[hook_type]

write_json('.claude/settings.json', settings)
```

**Never remove** hooks that exist in `settings.json` but not in the template (the user may have added their own).

#### Agents

For each outdated agent:
1. Read the installed file
2. Read the template
3. Replace the installed file with the template content

Skip agents without a matching template. Skip user-created agents (no matching template slug).

#### Rule packs

Same as `/keel:rules-update` logic — replace outdated packs, skip manually edited and custom ones.

### 6. Post-Upgrade

After applying:

1. Always update `keel_version` in `.keel/config.yaml` to the installed version — even if no other changes were applied:
   - If a `keel_version:` line exists, replace it
   - If it doesn't exist (project predates versioning), add it as the first non-comment line after any leading `#` comment block at the top of the file

2. Check if linter configs exist and linter rules are outdated (template mtime > linter rule mtime):
   ```
   Linter configs found. Run /keel:sync to regenerate linter rules.
   ```

3. Output results:

If only `keel_version` was added (everything else was already current):
```
UPGRADE COMPLETE
─────────────────────────────────────────────────────
Version:     {old or "unset"} → {new}
Hooks:       ✓ up to date
Agents:      ✓ up to date
Rule packs:  ✓ up to date

Commit to record the version:
  git add .keel/config.yaml && git commit -m "chore: set keel_version to {new}"

Run /keel:doctor to verify governance health.

WHAT'S NEW in {new}
─────────────────────────────────────────────────────
{content of the most recent changelog section from ~/.keel/CHANGELOG.md}
─────────────────────────────────────────────────────
```

If changes were applied:
```
UPGRADE COMPLETE
─────────────────────────────────────────────────────
Version:     {old} → {new}
Hooks:       4 updated
Agents:      2 updated
Rule packs:  2 updated (1 skipped — manually edited)

Commit these changes to share the upgrade with your team:
  git add .claude/ .keel/config.yaml && git commit -m "chore: upgrade keel to {new}"

Run /keel:doctor to verify governance health.

WHAT'S NEW in {new}
─────────────────────────────────────────────────────
{content of the most recent changelog section from ~/.keel/CHANGELOG.md}
─────────────────────────────────────────────────────
```
