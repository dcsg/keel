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
required = ['always', 'common']
for cat in required:
    if cat not in reg:
        print(f'Registry missing required category: {cat}')
        sys.exit(1)
# always must include architect and qa
always = reg.get('always', [])
for slug in ['architect', 'qa']:
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
    architect
    dba
    security
    api
    backend
    frontend
    qa
    sre
    platform
    docs
    pm
    ux
    data
    performance
    compliance
    mobile
    seo
    gtm
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

    # Has required frontmatter fields (no model: field — ADR-007)
    python3 -c "
import sys
content = open('$FILE').read()
parts = content.split('---', 2)
if len(parts) < 3:
    print('No frontmatter block')
    sys.exit(1)
import yaml
fm = yaml.safe_load(parts[1])
for field in ['name', 'description', 'tools']:
    if field not in fm:
        print(f'Missing frontmatter field: {field}')
        sys.exit(1)
if 'model' in fm:
    print('Agent has model: field — should not per ADR-007')
    sys.exit(1)
" 2>/dev/null \
        && pass "Has required frontmatter (no model): ${slug}.md" \
        || fail "Has required frontmatter (no model): ${slug}.md"

    # Body contains role identity
    grep -q "specialist\|You are\|expert" "$FILE" \
        && pass "Has role identity: ${slug}.md" \
        || fail "Has role identity: ${slug}.md"

    # Body has REMEMBER block (recency reinforcement)
    grep -q "REMEMBER:" "$FILE" \
        && pass "Has REMEMBER block: ${slug}.md" \
        || fail "Has REMEMBER block: ${slug}.md"
done

pass "Found $FOUND/${#EXPECTED_AGENTS[@]} expected agent templates"

# ============================================================
# Specific agent checks
# ============================================================

# dba and security should have memory: project
assert_file_contains "$AGENTS_DIR/dba.md" "memory: project" "dba.md has memory: project"
assert_file_contains "$AGENTS_DIR/security.md" "memory: project" "security.md has memory: project"

# Write-capable agents should have Write and Edit tools
for writer in backend frontend qa mobile; do
    assert_file_contains "$AGENTS_DIR/${writer}.md" "Write" "${writer}.md has Write tool"
    assert_file_contains "$AGENTS_DIR/${writer}.md" "Edit" "${writer}.md has Edit tool"
done

# Write-capable agents should have File Formatting section
for writer in backend frontend qa mobile; do
    assert_file_contains "$AGENTS_DIR/${writer}.md" "File Formatting" "${writer}.md has File Formatting section"
done

# Read-only agents should NOT have Write tool
for reader in architect dba security api sre platform docs ux data performance compliance seo gtm; do
    if grep -q "^  - Write$" "$AGENTS_DIR/${reader}.md" 2>/dev/null; then
        fail "${reader}.md should be read-only but has Write tool"
    else
        pass "${reader}.md is read-only (no Write tool)"
    fi
done

# Description includes "proactively" for auto-routing
for slug in "${EXPECTED_AGENTS[@]}"; do
    assert_file_contains "$AGENTS_DIR/${slug}.md" "proactively\|Use proactively" "${slug}.md has proactive routing trigger"
done

# Old agent files should NOT exist
for old in principal-architect principal-dba principal-ux principal-data staff-engineer staff-security staff-frontend staff-qa staff-sre staff-docs senior-api senior-backend senior-pm senior-performance reviewer debugger; do
    if [ -f "$AGENTS_DIR/${old}.md" ]; then
        fail "Old agent file should be removed: ${old}.md"
    else
        pass "Old agent removed: ${old}.md"
    fi
done

test_summary
