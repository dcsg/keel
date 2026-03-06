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
assert_dir_exists "$PROJECT_ROOT/test" "test/ exists"
assert_dir_exists "$PROJECT_ROOT/docs" "docs/ exists"

# Core files exist
assert_file_exists "$PROJECT_ROOT/CLAUDE.md" "CLAUDE.md exists"
assert_file_exists "$PROJECT_ROOT/README.md" "README.md exists"
assert_file_exists "$PROJECT_ROOT/.keel/config.yaml" ".keel/config.yaml exists"
assert_file_exists "$PROJECT_ROOT/.keel/soul.md" ".keel/soul.md exists"
assert_file_exists "$PROJECT_ROOT/templates/rules/_registry.yaml" "Registry exists"

# No old conductor/dof references
assert_file_not_contains "$PROJECT_ROOT/CLAUDE.md" "conductor:context" "CLAUDE.md has no conductor: command references"
assert_file_not_contains "$PROJECT_ROOT/CLAUDE.md" "\.dof" "CLAUDE.md has no .dof references"
# Note: can't grep for "conductor" because the repo might be in a path containing it
# Instead check for specific old branding
assert_file_not_contains "$PROJECT_ROOT/README.md" "conductor:context" "README.md has no conductor: command references"
assert_file_not_contains "$PROJECT_ROOT/README.md" "\.dof" "README.md has no .dof references"

# No old directories
assert_file_not_exists "$PROJECT_ROOT/.conductor/config.yaml" "No .conductor/ directory"
assert_file_not_exists "$PROJECT_ROOT/.dof/config.yaml" "No .dof/ directory"

test_summary
