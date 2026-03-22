#!/bin/bash
# Test: template quality, rule pack quality, extensibility, configurable paths
set -uo pipefail

PROJECT_ROOT="${1:-.}"
source "$(dirname "$0")/helpers.sh"

echo ""

# ============================================================
# Rule pack quality — v0.1.0 standards
# ============================================================

RULES_DIR="$PROJECT_ROOT/templates/rules"

# All rule packs should be v0.1.0
for rule in "$RULES_DIR"/base/*.md "$RULES_DIR"/lang/*.md "$RULES_DIR"/framework/*.md; do
    name=$(echo "$rule" | sed "s|$RULES_DIR/||")
    if grep -q 'version: "0.1.0"' "$rule" 2>/dev/null; then
        pass "Rule pack version 0.1.0: $name"
    else
        fail "Rule pack version 0.1.0: $name"
    fi
done

# All rule packs should have keel:generated marker
for rule in "$RULES_DIR"/base/*.md "$RULES_DIR"/lang/*.md "$RULES_DIR"/framework/*.md; do
    name=$(echo "$rule" | sed "s|$RULES_DIR/||")
    assert_file_contains "$rule" "keel:generated" "Has keel:generated marker: $name"
done

# All rule packs must have governance checkpoint
for rule in "$RULES_DIR"/base/*.md "$RULES_DIR"/lang/*.md "$RULES_DIR"/framework/*.md; do
    name=$(echo "$rule" | sed "s|$RULES_DIR/||")
    assert_file_contains "$rule" "<governance_checkpoint>" "Has governance checkpoint: $name"
done

# Governance checkpoint must appear before the first heading (correct position)
for rule in "$RULES_DIR"/base/*.md "$RULES_DIR"/lang/*.md "$RULES_DIR"/framework/*.md; do
    name=$(echo "$rule" | sed "s|$RULES_DIR/||")
    cp_line=$(grep -n "<governance_checkpoint>" "$rule" 2>/dev/null | head -1 | cut -d: -f1)
    h1_line=$(grep -n "^# " "$rule" 2>/dev/null | head -1 | cut -d: -f1)
    if [ -n "$cp_line" ] && [ -n "$h1_line" ] && [ "$cp_line" -lt "$h1_line" ]; then
        pass "Checkpoint before title: $name"
    else
        fail "Checkpoint before title: $name"
    fi
done

# Base packs should NOT use paths: "**/*" (should scope to code files)
for rule in "$RULES_DIR"/base/*.md; do
    name=$(basename "$rule")
    if grep -q 'paths: "\*\*/\*"' "$rule" 2>/dev/null; then
        fail "Base pack should scope to code files, not **/*: $name"
    else
        pass "Base pack properly scoped: $name"
    fi
done

# All packs should use four-tier phrasing (at least NEVER or MUST)
for rule in "$RULES_DIR"/base/*.md "$RULES_DIR"/lang/*.md "$RULES_DIR"/framework/*.md; do
    name=$(echo "$rule" | sed "s|$RULES_DIR/||")
    if grep -qE "^- NEVER |^- MUST " "$rule" 2>/dev/null; then
        pass "Uses NEVER/MUST phrasing: $name"
    else
        fail "Missing NEVER/MUST phrasing: $name"
    fi
done

# Rule count should be 7-25 per pack (lower bound reduced after cross-pack dedup)
for rule in "$RULES_DIR"/base/*.md "$RULES_DIR"/lang/*.md "$RULES_DIR"/framework/*.md; do
    name=$(echo "$rule" | sed "s|$RULES_DIR/||")
    count=$(grep -cE "^- " "$rule" 2>/dev/null)
    if [ "$count" -ge 7 ] && [ "$count" -le 25 ]; then
        pass "Rule count in range (${count}): $name"
    else
        fail "Rule count out of range (${count}, want 7-25): $name"
    fi
done

# New packs exist
assert_file_exists "$RULES_DIR/base/api.md" "New pack exists: api.md"
assert_file_exists "$RULES_DIR/base/database.md" "New pack exists: database.md"
assert_file_exists "$RULES_DIR/base/observability.md" "New pack exists: observability.md"
assert_file_exists "$RULES_DIR/base/seo.md" "New pack exists: seo.md"

# ============================================================
# Template quality — new sections in artifact templates
# ============================================================

# PRD template has numbered requirements
assert_file_contains "$PROJECT_ROOT/commands/prd.md" "FR-001" "PRD has numbered requirements (FR-001)"
assert_file_contains "$PROJECT_ROOT/commands/prd.md" "AC-001" "PRD has numbered acceptance criteria (AC-001)"
assert_file_contains "$PROJECT_ROOT/commands/prd.md" "NEEDS CLARIFICATION" "PRD has NEEDS CLARIFICATION markers"
assert_file_contains "$PROJECT_ROOT/commands/prd.md" "Verify:" "PRD acceptance criteria have verification methods"
assert_file_contains "$PROJECT_ROOT/commands/prd.md" "stakeholders" "PRD has stakeholders in frontmatter"

# ADR template has MADR sections
assert_file_contains "$PROJECT_ROOT/commands/adr.md" "Confirmation" "ADR has Confirmation section"
assert_file_contains "$PROJECT_ROOT/commands/adr.md" "Decision Drivers" "ADR has Decision Drivers section"
assert_file_contains "$PROJECT_ROOT/commands/adr.md" "decision-makers" "ADR has decision-makers in frontmatter"
assert_file_contains "$PROJECT_ROOT/commands/adr.md" "supersedes" "ADR has supersedes in frontmatter"
assert_file_contains "$PROJECT_ROOT/commands/adr.md" "Rejected because" "ADR alternatives have rejection reasons"

# Invariant template has new sections
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" "severity:" "Invariant has severity in frontmatter"
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" "scope:" "Invariant has scope in frontmatter"
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" "Violation Consequences" "Invariant has Violation Consequences"
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" "Verification" "Invariant has Verification section"
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" "Exceptions" "Invariant has Exceptions section"

# Spec template has new sections
assert_file_contains "$PROJECT_ROOT/commands/spec.md" "Non-Goals" "Spec has Non-Goals section"
assert_file_contains "$PROJECT_ROOT/commands/spec.md" "Alternatives Considered" "Spec has Alternatives Considered"
assert_file_contains "$PROJECT_ROOT/commands/spec.md" "Risks" "Spec has Risks section"
assert_file_contains "$PROJECT_ROOT/commands/spec.md" "AC-001" "Spec has numbered acceptance criteria"
assert_file_contains "$PROJECT_ROOT/commands/spec.md" "NEEDS CLARIFICATION" "Spec has NEEDS CLARIFICATION markers"
assert_file_contains "$PROJECT_ROOT/commands/spec.md" "implements:" "Spec uses implements: (not source_prd:)"

# Compile output has primacy + recency
assert_file_contains "$PROJECT_ROOT/commands/compile.md" "Non-Negotiable Constraints" "Compile has constraints at top"
assert_file_contains "$PROJECT_ROOT/commands/compile.md" "Reminder:" "Compile has reminder at bottom (recency)"
assert_file_contains "$PROJECT_ROOT/commands/compile.md" "directives:" "Compile output has directive count"

# ============================================================
# Command quality — CRITICAL + REMEMBER blocks
# ============================================================

for cmd in doctor audit drift plan compile review; do
    assert_file_contains "$PROJECT_ROOT/commands/${cmd}.md" "CRITICAL:" "${cmd} has CRITICAL statement"
done

for cmd in prd adr invariant spec spec-artifacts compile drift; do
    assert_file_contains "$PROJECT_ROOT/commands/${cmd}.md" "REMEMBER:" "${cmd} has REMEMBER block"
done

# Commands use paths: config (not hardcoded)
for cmd in prd adr invariant spec drift compile; do
    assert_file_contains "$PROJECT_ROOT/commands/${cmd}.md" "paths:" "${cmd} references paths: config"
done

# ============================================================
# Configurable paths
# ============================================================

# Config has paths section
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "paths:" "Config has paths: section"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "decisions:" "Config has decisions path"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "invariants:" "Config has invariants path"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "plans:" "Config has plans path"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "specs:" "Config has specs path"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "prds:" "Config has prds path"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "guidelines:" "Config has guidelines path"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "reports:" "Config has reports path"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "soul:" "Config has soul path"

# Config has features section
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "features:" "Config has features: section"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "auto-format:" "Config has auto-format feature"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "session-summary:" "Config has session-summary feature"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "signal-detection:" "Config has signal-detection feature"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "plan-injection:" "Config has plan-injection feature"
assert_file_contains "$PROJECT_ROOT/.keel/config.yaml" "quality-gates:" "Config has quality-gates feature"

# Hooks respect feature config
assert_file_contains "$PROJECT_ROOT/templates/hooks/post-tool-use.sh" "auto-format: false" "PostToolUse checks auto-format config"
assert_file_contains "$PROJECT_ROOT/templates/hooks/session-start.sh" "session-summary: false" "SessionStart checks session-summary config"
assert_file_contains "$PROJECT_ROOT/templates/hooks/stop-hook.sh" "signal-detection: false" "Stop checks signal-detection config"
assert_file_contains "$PROJECT_ROOT/templates/hooks/user-prompt-submit.sh" "plan-injection: false" "UserPromptSubmit checks plan-injection config"
assert_file_contains "$PROJECT_ROOT/templates/hooks/subagent-stop.sh" "quality-gates: false" "SubagentStop checks quality-gates config"

# Reports directory exists
assert_dir_exists "$PROJECT_ROOT/docs/reports" "Reports directory exists"

# Init creates reports directory
assert_file_contains "$PROJECT_ROOT/commands/init.md" "reports" "Init creates reports directory"

# ============================================================
# Extensibility (ADR-006)
# ============================================================

# Init supports template overrides
assert_file_contains "$PROJECT_ROOT/commands/init.md" ".keel/templates" "Init checks for template overrides"

# Upgrade respects custom agents
assert_file_contains "$PROJECT_ROOT/commands/upgrade.md" "keel:custom" "Upgrade respects custom agent marker"
assert_file_contains "$PROJECT_ROOT/commands/upgrade.md" "agents.custom" "Upgrade respects custom agent config"

# Rules-update handles overrides and extensions
assert_file_contains "$PROJECT_ROOT/commands/rules-update.md" "Overridden" "Rules-update detects overridden packs"
assert_file_contains "$PROJECT_ROOT/commands/rules-update.md" "extend" "Rules-update handles extensions"

# Doctor reports extensibility state
assert_file_contains "$PROJECT_ROOT/commands/doctor.md" "Template override" "Doctor reports template overrides"
assert_file_contains "$PROJECT_ROOT/commands/doctor.md" "Rule override" "Doctor reports rule overrides"

# ============================================================
# Version consistency
# ============================================================

# VERSION file
FILE_VER=$(cat "$PROJECT_ROOT/VERSION" | tr -d '[:space:]')
if [ "$FILE_VER" = "0.1.0" ]; then
    pass "VERSION file is 0.1.0"
else
    fail "VERSION file is 0.1.0" "Got: $FILE_VER"
fi

# Config version matches
CONFIG_VER=$(grep 'keel_version:' "$PROJECT_ROOT/.keel/config.yaml" | awk '{print $2}' | tr -d '"')
if [ "$CONFIG_VER" = "$FILE_VER" ]; then
    pass "Config keel_version matches VERSION ($FILE_VER)"
else
    fail "Config keel_version matches VERSION" "Config=$CONFIG_VER, File=$FILE_VER"
fi

# No old version references in active code (excluding historical docs)
OLD_REFS=$(grep -rn '"4\.0"\|"3\.9"\|"3\.8"' "$PROJECT_ROOT/commands/" "$PROJECT_ROOT/templates/" "$PROJECT_ROOT/install.sh" "$PROJECT_ROOT/README.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$OLD_REFS" -eq 0 ]; then
    pass "No old version references in active code"
else
    fail "Old version references found in active code" "$OLD_REFS occurrences"
fi

# ============================================================
# No old agent names in active code
# ============================================================

OLD_AGENTS=$(grep -rn "principal-\|staff-\|senior-" "$PROJECT_ROOT/commands/" "$PROJECT_ROOT/templates/" "$PROJECT_ROOT/website/" --include="*.md" --include="*.yaml" --include="*.sh" --include="*.ts" 2>/dev/null | grep -v node_modules | grep -v ".vitepress/dist" | wc -l | tr -d ' ')
if [ "$OLD_AGENTS" -eq 0 ]; then
    pass "No old agent names (principal-/staff-/senior-) in codebase"
else
    fail "Old agent names found" "$OLD_AGENTS occurrences"
fi

# ============================================================
# Website builds
# ============================================================

if command -v npx >/dev/null 2>&1 && [ -d "$PROJECT_ROOT/website" ]; then
    BUILD_OUTPUT=$(cd "$PROJECT_ROOT/website" && npx vitepress build 2>&1)
    if echo "$BUILD_OUTPUT" | grep -q "build complete"; then
        pass "VitePress website builds successfully"
    else
        fail "VitePress website build failed"
    fi
else
    echo "  SKIP  VitePress build (npx not available)"
fi

test_summary
