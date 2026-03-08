#!/bin/bash
# Test: keel_version tracking — VERSION file, config field, upgrade logic
set -uo pipefail

PROJECT_ROOT="$(cd "${1:-.}" && pwd)"
source "$(dirname "$0")/helpers.sh"

echo ""

VERSION_FILE="$PROJECT_ROOT/VERSION"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

# ============================================================
# VERSION file
# ============================================================

# VERSION file exists
assert_file_exists "$VERSION_FILE" "VERSION file exists"

# VERSION file contains a semver-like string (X.Y or X.Y.Z)
if grep -qE '^[0-9]+\.[0-9]+' "$VERSION_FILE"; then
    pass "VERSION file contains a valid version number"
else
    fail "VERSION file contains a valid version number" "$(cat "$VERSION_FILE")"
fi

# VERSION file has no trailing garbage (just a version line)
LINE_COUNT=$(grep -c '[^[:space:]]' "$VERSION_FILE" || true)
if [ "$LINE_COUNT" -eq 1 ]; then
    pass "VERSION file has exactly one non-empty line"
else
    fail "VERSION file has exactly one non-empty line" "Found $LINE_COUNT non-empty lines"
fi

# ============================================================
# CHANGELOG
# ============================================================

assert_file_exists "$CHANGELOG_FILE" "CHANGELOG.md exists"

# CHANGELOG has at least one version section
if grep -qE '^## v[0-9]' "$CHANGELOG_FILE"; then
    pass "CHANGELOG.md has at least one version section"
else
    fail "CHANGELOG.md has at least one version section"
fi

# CHANGELOG version matches VERSION file
FILE_VER=$(cat "$VERSION_FILE" | tr -d '[:space:]')
if grep -q "^## v${FILE_VER}" "$CHANGELOG_FILE"; then
    pass "CHANGELOG.md has an entry for version $FILE_VER"
else
    fail "CHANGELOG.md has an entry for version $FILE_VER" "No '## v${FILE_VER}' section found"
fi

# ============================================================
# .keel/config.yaml keel_version
# ============================================================

CONFIG_FILE="$PROJECT_ROOT/.keel/config.yaml"

assert_file_contains "$CONFIG_FILE" "keel_version" ".keel/config.yaml has keel_version field"

# keel_version value matches VERSION file
CONFIG_VER=$(grep '^keel_version:' "$CONFIG_FILE" | awk '{print $2}' | tr -d '"' 2>/dev/null || echo "")
if [ "$CONFIG_VER" = "$FILE_VER" ]; then
    pass "keel_version in .keel/config.yaml matches VERSION ($FILE_VER)"
else
    fail "keel_version in .keel/config.yaml matches VERSION" "config=$CONFIG_VER, file=$FILE_VER"
fi

# ============================================================
# install.sh downloads VERSION + CHANGELOG
# ============================================================

assert_file_contains "$PROJECT_ROOT/install.sh" "VERSION" "install.sh downloads VERSION file"
assert_file_contains "$PROJECT_ROOT/install.sh" "CHANGELOG.md" "install.sh downloads CHANGELOG.md"

# ============================================================
# commands/init.md writes keel_version
# ============================================================

assert_file_contains "$PROJECT_ROOT/commands/init.md" "keel_version" "init.md writes keel_version to config"
assert_file_contains "$PROJECT_ROOT/commands/init.md" "~/.keel/VERSION" "init.md reads installed VERSION"

# ============================================================
# commands/upgrade.md handles version correctly
# ============================================================

assert_file_contains "$PROJECT_ROOT/commands/upgrade.md" "keel_version" "upgrade.md updates keel_version"
assert_file_contains "$PROJECT_ROOT/commands/upgrade.md" "~/.keel/VERSION" "upgrade.md reads installed VERSION"
assert_file_contains "$PROJECT_ROOT/commands/upgrade.md" "Always update" "upgrade.md always writes keel_version"
assert_file_contains "$PROJECT_ROOT/commands/upgrade.md" "predates versioning" "upgrade.md handles projects missing keel_version"
assert_file_contains "$PROJECT_ROOT/commands/upgrade.md" "keel_version.*is missing" "upgrade.md detects missing keel_version as upgrade"

# ============================================================
# commands/doctor.md checks version
# ============================================================

assert_file_contains "$PROJECT_ROOT/commands/doctor.md" "keel_version" "doctor.md checks keel_version"
assert_file_contains "$PROJECT_ROOT/commands/doctor.md" "~/.keel/VERSION" "doctor.md reads installed VERSION"
assert_file_contains "$PROJECT_ROOT/commands/doctor.md" "keel_version not set" "doctor.md warns when keel_version missing"

# doctor output template shows version
assert_file_contains "$PROJECT_ROOT/commands/doctor.md" "keel {version}" "doctor.md output shows version"

# ============================================================
# upgrade shows release notes (WHAT'S NEW)
# ============================================================

assert_file_contains "$PROJECT_ROOT/commands/upgrade.md" "WHAT'S NEW" "upgrade.md shows WHAT'S NEW section"
assert_file_contains "$PROJECT_ROOT/commands/upgrade.md" "CHANGELOG" "upgrade.md reads CHANGELOG"

# ============================================================
# website/guides/upgrading.md reflects versioning
# ============================================================

assert_file_contains "$PROJECT_ROOT/website/guides/upgrading.md" "keel_version" "upgrading guide explains keel_version"
assert_file_contains "$PROJECT_ROOT/website/guides/upgrading.md" "~/.keel/VERSION" "upgrading guide mentions VERSION file"
assert_file_contains "$PROJECT_ROOT/website/guides/upgrading.md" "keel:doctor" "upgrading guide mentions doctor for version check"

test_summary
