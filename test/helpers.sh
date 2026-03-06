#!/bin/bash
# Keel test helpers — assertion functions for bash tests

PASS_COUNT=0
FAIL_COUNT=0
TEST_NAME=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

# Set current test name
test_start() {
    TEST_NAME="$1"
}

# Record pass
pass() {
    local msg="${1:-$TEST_NAME}"
    echo -e "  ${GREEN}PASS${NC}  $msg"
    ((PASS_COUNT++))
}

# Record failure
fail() {
    local msg="${1:-$TEST_NAME}"
    local detail="${2:-}"
    echo -e "  ${RED}FAIL${NC}  $msg"
    if [ -n "$detail" ]; then
        echo -e "        ${RED}$detail${NC}"
    fi
    ((FAIL_COUNT++))
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    local msg="${2:-File exists: $file}"
    if [ -f "$file" ]; then
        pass "$msg"
    else
        fail "$msg" "File not found: $file"
    fi
}

# Assert file does not exist
assert_file_not_exists() {
    local file="$1"
    local msg="${2:-File does not exist: $file}"
    if [ ! -f "$file" ]; then
        pass "$msg"
    else
        fail "$msg" "File should not exist: $file"
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    local msg="${2:-Directory exists: $dir}"
    if [ -d "$dir" ]; then
        pass "$msg"
    else
        fail "$msg" "Directory not found: $dir"
    fi
}

# Assert file contains string (grep -q)
assert_file_contains() {
    local file="$1"
    local pattern="$2"
    local msg="${3:-File $file contains: $pattern}"
    if [ ! -f "$file" ]; then
        fail "$msg" "File not found: $file"
        return
    fi
    if grep -q "$pattern" "$file"; then
        pass "$msg"
    else
        fail "$msg" "Pattern not found in $file: $pattern"
    fi
}

# Assert file does NOT contain string
assert_file_not_contains() {
    local file="$1"
    local pattern="$2"
    local msg="${3:-File $file does not contain: $pattern}"
    if [ ! -f "$file" ]; then
        pass "$msg"
        return
    fi
    if grep -q "$pattern" "$file"; then
        fail "$msg" "Pattern should not be in $file: $pattern"
    else
        pass "$msg"
    fi
}

# Assert file starts with string (first non-empty line)
assert_file_starts_with() {
    local file="$1"
    local expected="$2"
    local msg="${3:-File $file starts with: $expected}"
    if [ ! -f "$file" ]; then
        fail "$msg" "File not found: $file"
        return
    fi
    local first_line
    first_line=$(head -1 "$file")
    if [ "$first_line" = "$expected" ]; then
        pass "$msg"
    else
        fail "$msg" "Expected: '$expected', got: '$first_line'"
    fi
}

# Assert valid YAML (requires yq or python)
assert_valid_yaml() {
    local file="$1"
    local msg="${2:-Valid YAML: $file}"
    if [ ! -f "$file" ]; then
        fail "$msg" "File not found: $file"
        return
    fi
    if command -v python3 &>/dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            pass "$msg"
        else
            fail "$msg" "Invalid YAML in $file"
        fi
    elif command -v yq &>/dev/null; then
        if yq '.' "$file" &>/dev/null; then
            pass "$msg"
        else
            fail "$msg" "Invalid YAML in $file"
        fi
    else
        echo -e "  ${YELLOW}SKIP${NC}  $msg (no yaml parser available)"
    fi
}

# Assert all paths in a list exist (one path per line)
assert_dir_structure() {
    local base="$1"
    local msg="${2:-Directory structure check}"
    shift 2
    local all_pass=true
    for path in "$@"; do
        if [ ! -e "$base/$path" ]; then
            fail "$msg" "Missing: $base/$path"
            all_pass=false
        fi
    done
    if $all_pass; then
        pass "$msg"
    fi
}

# Assert a markdown file has no empty sections (heading with no content before next heading)
assert_no_empty_sections() {
    local file="$1"
    local msg="${2:-No empty sections: $file}"
    if [ ! -f "$file" ]; then
        fail "$msg" "File not found: $file"
        return
    fi
    # Find headings followed immediately by another heading (empty section)
    local empty_sections
    empty_sections=$(awk '
        /^#/ {
            if (prev_heading && !has_content) {
                print NR": "prev_heading
            }
            prev_heading = $0
            has_content = 0
            next
        }
        /[^ \t]/ { has_content = 1 }
        END {
            if (prev_heading && !has_content) {
                print NR": "prev_heading
            }
        }
    ' "$file")
    if [ -z "$empty_sections" ]; then
        pass "$msg"
    else
        fail "$msg" "Empty sections found:\n$empty_sections"
    fi
}

# Assert frontmatter has a specific key
assert_frontmatter_has() {
    local file="$1"
    local key="$2"
    local msg="${3:-Frontmatter has '$key': $file}"
    if [ ! -f "$file" ]; then
        fail "$msg" "File not found: $file"
        return
    fi
    # Extract frontmatter between --- markers
    local frontmatter
    frontmatter=$(awk '/^---$/{n++; next} n==1{print} n==2{exit}' "$file")
    if echo "$frontmatter" | grep -q "^${key}:"; then
        pass "$msg"
    else
        fail "$msg" "Key '$key' not found in frontmatter of $file"
    fi
}

# Print summary and exit with appropriate code
test_summary() {
    local total=$((PASS_COUNT + FAIL_COUNT))
    echo ""
    if [ "$FAIL_COUNT" -eq 0 ]; then
        echo -e "${GREEN}${BOLD}All $total tests passed${NC}"
    else
        echo -e "${RED}${BOLD}$FAIL_COUNT of $total tests failed${NC}"
    fi
    echo ""
    return "$FAIL_COUNT"
}
