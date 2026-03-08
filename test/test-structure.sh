#!/bin/bash
# Test: project directory structure is correct
set -uo pipefail

PROJECT_ROOT="${1:-.}"
source "$(dirname "$0")/helpers.sh"

echo ""

# Core directories exist
assert_dir_exists "$PROJECT_ROOT/commands" "commands/ exists"
assert_dir_exists "$PROJECT_ROOT/templates" "templates/ exists"
assert_dir_exists "$PROJECT_ROOT/templates/rules" "templates/rules/ exists"
assert_dir_exists "$PROJECT_ROOT/templates/rules/base" "templates/rules/base/ exists"
assert_dir_exists "$PROJECT_ROOT/templates/rules/lang" "templates/rules/lang/ exists"
assert_dir_exists "$PROJECT_ROOT/templates/rules/framework" "templates/rules/framework/ exists"
assert_dir_exists "$PROJECT_ROOT/templates/agents" "templates/agents/ exists"
assert_dir_exists "$PROJECT_ROOT/templates/sdlc" "templates/sdlc/ exists"
assert_dir_exists "$PROJECT_ROOT/templates/hooks" "templates/hooks/ exists"
assert_dir_exists "$PROJECT_ROOT/test" "test/ exists"
assert_dir_exists "$PROJECT_ROOT/docs" "docs/ exists"

# Core files exist
assert_file_exists "$PROJECT_ROOT/CLAUDE.md" "CLAUDE.md exists"
assert_file_exists "$PROJECT_ROOT/README.md" "README.md exists"
assert_file_exists "$PROJECT_ROOT/.keel/config.yaml" ".keel/config.yaml exists"
assert_file_exists "$PROJECT_ROOT/.keel/soul.md" ".keel/soul.md exists"
assert_file_exists "$PROJECT_ROOT/templates/rules/_registry.yaml" "Registry exists"

# No legacy tool references
assert_file_not_contains "$PROJECT_ROOT/CLAUDE.md" "conductor:context" "CLAUDE.md has no conductor: command references"
# Note: can't grep for "conductor" because the repo might be in a path containing it
assert_file_not_contains "$PROJECT_ROOT/README.md" "conductor:context" "README.md has no conductor: command references"

# No legacy directories
assert_file_not_exists "$PROJECT_ROOT/.conductor/config.yaml" "No .conductor/ directory"
assert_file_not_exists "$PROJECT_ROOT/.dof/config.yaml" "No .dof/ directory"

# settings template has all four hooks
assert_file_contains "$PROJECT_ROOT/templates/settings.json.tmpl" "SessionStart" "settings.json.tmpl has SessionStart hook"
assert_file_contains "$PROJECT_ROOT/templates/settings.json.tmpl" "PreToolUse" "settings.json.tmpl has PreToolUse hook"
assert_file_contains "$PROJECT_ROOT/templates/settings.json.tmpl" "Stop" "settings.json.tmpl has Stop hook"
assert_file_contains "$PROJECT_ROOT/templates/settings.json.tmpl" "PreCompact" "settings.json.tmpl has PreCompact hook"
assert_file_contains "$PROJECT_ROOT/templates/settings.json.tmpl" "Write|Edit" "PreToolUse hook targets Write|Edit"
assert_file_contains "$PROJECT_ROOT/templates/settings.json.tmpl" "PostToolUse" "settings.json.tmpl has PostToolUse hook"
assert_file_contains "$PROJECT_ROOT/templates/settings.json.tmpl" "git log" "SessionStart hook is git-aware"

# All keel commands exist
for cmd in init context plan status intake doctor rules-update adr invariant prd agents mcp team docs sync audit review session; do
    assert_file_exists "$PROJECT_ROOT/commands/${cmd}.md" "commands/${cmd}.md exists"
done

# Shell preprocessing markers exist in artifact commands
assert_file_contains "$PROJECT_ROOT/commands/adr.md" '!`' "adr.md has shell preprocessing"
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" '!`' "invariant.md has shell preprocessing"
assert_file_contains "$PROJECT_ROOT/commands/prd.md" '!`' "prd.md has shell preprocessing"
assert_file_contains "$PROJECT_ROOT/commands/plan.md" '!`' "plan.md has shell preprocessing"
assert_file_contains "$PROJECT_ROOT/commands/adr.md" "keel:live" "adr.md injects live ADR number"
assert_file_contains "$PROJECT_ROOT/commands/invariant.md" "keel:live" "invariant.md injects live INV number"
assert_file_contains "$PROJECT_ROOT/commands/prd.md" "keel:live" "prd.md injects live PRD number"

# Agent templates directory exists
assert_dir_exists "$PROJECT_ROOT/templates/agents" "templates/agents/ exists"
assert_file_exists "$PROJECT_ROOT/templates/agents/_registry.yaml" "Agent registry exists"
assert_file_exists "$PROJECT_ROOT/templates/agents/staff-docs.md" "staff-docs agent exists"

# Git hook template exists
assert_file_exists "$PROJECT_ROOT/templates/hooks/pre-push" "pre-push hook template exists"
assert_file_contains "$PROJECT_ROOT/templates/hooks/pre-push" "KEEL_DOCS_SKIP" "pre-push hook has disable flag"
assert_file_contains "$PROJECT_ROOT/templates/hooks/pre-push" "exit 0" "pre-push hook never blocks (exits 0)"
assert_file_contains "$PROJECT_ROOT/templates/hooks/pre-push" "pre-push: false" "pre-push hook respects config disable"
assert_file_contains "$PROJECT_ROOT/templates/hooks/pre-push" "KEEL_SECURITY_SKIP" "pre-push has security skip flag"

# plan.md pre-flight review checks
assert_file_contains "$PROJECT_ROOT/commands/plan.md" "PRE-FLIGHT" "plan.md has pre-flight review"
assert_file_contains "$PROJECT_ROOT/commands/plan.md" "no-review" "plan.md supports --no-review flag"

# session.md checks
assert_file_contains "$PROJECT_ROOT/commands/session.md" "context: fork" "session.md has context: fork"
assert_file_contains "$PROJECT_ROOT/commands/session.md" "SESSION SUMMARY" "session.md has session summary output"
assert_file_contains "$PROJECT_ROOT/commands/session.md" "keel:adr" "session.md suggests artifact capture"

test_summary
