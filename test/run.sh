#!/bin/bash
# Keel test runner — discovers and runs all test-*.sh files

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}Keel Test Suite${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SUITE_COUNT=0
FAILED_SUITES=0

for test_file in "$SCRIPT_DIR"/test-*.sh; do
    if [ ! -f "$test_file" ]; then
        echo "No test files found."
        exit 0
    fi

    suite_name=$(basename "$test_file" .sh | sed 's/^test-//')
    echo ""
    echo -e "${BOLD}[$suite_name]${NC}"
    ((SUITE_COUNT++))

    chmod +x "$test_file"
    if ! bash "$test_file" "$PROJECT_ROOT"; then
        ((FAILED_SUITES++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$FAILED_SUITES" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}All $SUITE_COUNT test suites passed${NC}"
else
    echo -e "${RED}${BOLD}$FAILED_SUITES of $SUITE_COUNT test suites had failures${NC}"
fi
echo ""

exit "$FAILED_SUITES"
