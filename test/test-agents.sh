#!/bin/bash
# Test: agent templates and registry
set -uo pipefail

PROJECT_ROOT="${1:-.}"
source "$(dirname "$0")/helpers.sh"

echo ""

AGENTS_DIR="$PROJECT_ROOT/templates/agents"
REGISTRY="$AGENTS_DIR/_registry.yaml"

# ============================================================
# Registry checks
# ============================================================

assert_file_exists "$REGISTRY" "Agent registry exists"

# All slugs in registry must have a corresponding .md file
python3 -c "
import yaml, sys, os
reg = yaml.safe_load(open('$REGISTRY'))
agents_dir = '$AGENTS_DIR'
missing = []
seen = set()
for category, slugs in reg.items():
    if not isinstance(slugs, list):
        continue
    for slug in slugs:
        if slug in seen:
            continue
        seen.add(slug)
        path = os.path.join(agents_dir, slug + '.md')
        if not os.path.exists(path):
            missing.append(slug)
if missing:
    print('Missing agent templates: ' + ', '.join(missing))
    sys.exit(1)
" 2>/dev/null \
    && pass "All registry slugs resolve to existing agent templates" \
    || fail "All registry slugs resolve to existing agent templates"

# Required categories exist
python3 -c "
import yaml, sys
reg = yaml.safe_load(open('$REGISTRY'))
required = ['always', 'all']
for cat in required:
    if cat not in reg:
        print(f'Registry missing required category: {cat}')
        sys.exit(1)
# always must include principal-architect and staff-engineer
always = reg.get('always', [])
for slug in ['principal-architect', 'staff-engineer']:
    if slug not in always:
        print(f'always category missing: {slug}')
        sys.exit(1)
" 2>/dev/null \
    && pass "Registry has required categories and always-install agents" \
    || fail "Registry has required categories and always-install agents"

# ============================================================
# Per-agent template checks
# ============================================================

EXPECTED_AGENTS=(
    principal-architect
    staff-engineer
    senior-backend
    principal-dba
    staff-security
    staff-sre
    staff-qa
    staff-frontend
    principal-ux
    senior-pm
    senior-api
    senior-performance
    principal-data
)

FOUND=0
for slug in "${EXPECTED_AGENTS[@]}"; do
    FILE="$AGENTS_DIR/${slug}.md"
    if [ ! -f "$FILE" ]; then
        fail "Agent template exists: ${slug}.md"
        continue
    fi
    FOUND=$((FOUND + 1))

    # Has YAML frontmatter
    head -1 "$FILE" | grep -q "^---$" \
        && pass "Has frontmatter: ${slug}.md" \
        || fail "Has frontmatter: ${slug}.md"

    # Has name field in frontmatter
    python3 -c "
import sys
content = open('$FILE').read()
parts = content.split('---', 2)
if len(parts) < 3:
    print('No frontmatter block')
    sys.exit(1)
import yaml
fm = yaml.safe_load(parts[1])
for field in ['name', 'description', 'model', 'tools']:
    if field not in fm:
        print(f'Missing frontmatter field: {field}')
        sys.exit(1)
" 2>/dev/null \
        && pass "Has required frontmatter fields: ${slug}.md" \
        || fail "Has required frontmatter fields: ${slug}.md"

    # Body contains role identity statement
    grep -q "You are a" "$FILE" \
        && pass "Has role identity statement: ${slug}.md" \
        || fail "Has role identity statement: ${slug}.md"

    # Body mentions keel command suggestion
    grep -q "keel" "$FILE" \
        && pass "References keel commands: ${slug}.md" \
        || fail "References keel commands: ${slug}.md"
done

pass "Found $FOUND/${#EXPECTED_AGENTS[@]} expected agent templates"

# ============================================================
# Legacy agent templates still exist
# ============================================================

assert_file_exists "$AGENTS_DIR/reviewer.md" "Legacy reviewer.md still present"
assert_file_exists "$AGENTS_DIR/debugger.md" "Legacy debugger.md still present"

test_summary
