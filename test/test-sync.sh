#!/bin/bash
# Test: keel:sync command exists and is correctly structured
set -uo pipefail

PROJECT_ROOT="${1:-.}"
source "$(dirname "$0")/helpers.sh"

echo ""

# Command exists
assert_file_exists "$PROJECT_ROOT/commands/sync.md" "sync command exists"

# Has correct frontmatter
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "name: keel:sync" "sync has name"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "keel:sync" "sync references itself"

# Supports expected linters
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "golangci" "sync supports golangci-lint"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "eslint" "sync supports ESLint"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "ruff" "sync supports Ruff"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "rubocop" "sync supports RuboCop"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "prettier" "sync mentions prettier"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "biome" "sync supports Biome"

# Has dry-run
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "dry-run" "sync has --dry-run mode"

# Has monorepo support
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "onorepo" "sync supports monorepos"

# Has source frontmatter in generated rules
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "source: linter" "generated rules have source marker"

# Has generated-by marker
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "generated-by: keel:sync" "generated rules have generated-by marker"

# install.sh includes sync
assert_file_contains "$PROJECT_ROOT/install.sh" "sync" "install.sh includes sync command"

# doctor checks linter sync
assert_file_contains "$PROJECT_ROOT/commands/doctor.md" "keel:sync" "doctor references keel:sync"

# init wires sync for brownfield
assert_file_contains "$PROJECT_ROOT/commands/init.md" "keel:sync" "init wires keel:sync for established projects"

# Translation tables present for each linter
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "gomnd" "sync translates gomnd"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "cyclop" "sync translates cyclop"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "no-console" "sync translates no-console"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "F401" "sync translates Ruff F401"
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "Metrics/MethodLength" "sync translates RuboCop MethodLength"

# Frontmatter fields in generated files
assert_file_contains "$PROJECT_ROOT/commands/sync.md" "linter: golangci-lint" "generated rules have linter field"

test_summary
