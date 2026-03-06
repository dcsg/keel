#!/bin/bash
# Test: all rule templates have valid frontmatter and content
set -uo pipefail

PROJECT_ROOT="${1:-.}"
source "$(dirname "$0")/helpers.sh"

RULES_DIR="$PROJECT_ROOT/templates/rules"

echo ""

# Find all .md template files
templates=$(find "$RULES_DIR" -name "*.md" | sort)

if [ -z "$templates" ]; then
    fail "No template files found in $RULES_DIR"
    test_summary
    exit $?
fi

# Count templates
count=$(echo "$templates" | wc -l | tr -d ' ')
pass "Found $count rule template files"

# Check each template
for tmpl in $templates; do
    name=$(echo "$tmpl" | sed "s|$RULES_DIR/||")

    # Must start with frontmatter delimiter
    assert_file_starts_with "$tmpl" "---" "Frontmatter start: $name"

    # Must have paths: in frontmatter
    assert_frontmatter_has "$tmpl" "paths" "Has paths: frontmatter: $name"

    # Must have a top-level heading
    assert_file_contains "$tmpl" "^# " "Has top-level heading: $name"

    # Must not have empty sections
    assert_no_empty_sections "$tmpl" "No empty sections: $name"

    # Must not contain placeholder text (check for actual TODO/FIXME markers, not mentions in rules)
    assert_file_not_contains "$tmpl" "^TODO:" "No TODO: markers: $name"
    assert_file_not_contains "$tmpl" "PLACEHOLDER" "No PLACEHOLDERs: $name"
    assert_file_not_contains "$tmpl" "^FIXME:" "No FIXME: markers: $name"
done

test_summary
