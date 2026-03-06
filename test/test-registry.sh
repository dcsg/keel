#!/bin/bash
# Test: every registry entry points to an existing template file
set -uo pipefail

PROJECT_ROOT="${1:-.}"
source "$(dirname "$0")/helpers.sh"

REGISTRY="$PROJECT_ROOT/templates/rules/_registry.yaml"

echo ""

# Registry file exists
assert_file_exists "$REGISTRY" "Registry file exists"
assert_valid_yaml "$REGISTRY" "Registry is valid YAML"

# Extract template paths and verify each exists
templates=$(python3 -c "
import yaml
with open('$REGISTRY') as f:
    data = yaml.safe_load(f)
for name, info in data.items():
    if 'template' in info:
        print(info['template'])
" 2>/dev/null)

if [ -z "$templates" ]; then
    fail "Could not parse registry templates"
else
    all_found=true
    count=0
    for tmpl in $templates; do
        ((count++))
        full_path="$PROJECT_ROOT/templates/rules/$tmpl"
        if [ ! -f "$full_path" ]; then
            fail "Registry entry resolves: $tmpl" "File not found: $full_path"
            all_found=false
        fi
    done
    if $all_found; then
        pass "All $count registry entries resolve to existing files"
    fi
fi

# Every registry entry has required fields
missing_fields=$(python3 -c "
import yaml
with open('$REGISTRY') as f:
    data = yaml.safe_load(f)
for name, info in data.items():
    missing = []
    for field in ['tier', 'template', 'paths']:
        if field not in info:
            missing.append(field)
    if missing:
        print(f'{name}: missing {missing}')
" 2>/dev/null)

if [ -z "$missing_fields" ]; then
    pass "All registry entries have required fields (tier, template, paths)"
else
    fail "Registry entries missing fields" "$missing_fields"
fi

# Tier values are valid
invalid_tiers=$(python3 -c "
import yaml
with open('$REGISTRY') as f:
    data = yaml.safe_load(f)
valid_tiers = {'base', 'lang', 'framework'}
for name, info in data.items():
    if info.get('tier') not in valid_tiers:
        print(f\"{name}: invalid tier '{info.get('tier')}'\")
" 2>/dev/null)

if [ -z "$invalid_tiers" ]; then
    pass "All tier values are valid (base, lang, framework)"
else
    fail "Invalid tier values" "$invalid_tiers"
fi

# All entries have version field
missing_version=$(python3 -c "
import yaml
with open('$REGISTRY') as f:
    data = yaml.safe_load(f)
for name, info in data.items():
    if 'version' not in info:
        print(f'{name}: missing version')
" 2>/dev/null)

if [ -z "$missing_version" ]; then
    pass "All registry entries have version field"
else
    fail "Registry entries missing version" "$missing_version"
fi

# Registry version matches template frontmatter version
version_mismatch=$(python3 -c "
import yaml, re
with open('$REGISTRY') as f:
    data = yaml.safe_load(f)
for name, info in data.items():
    reg_ver = info.get('version', '')
    tmpl_path = '$PROJECT_ROOT/templates/rules/' + info['template']
    with open(tmpl_path) as t:
        content = t.read()
    # Extract version from YAML frontmatter
    fm = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
    if fm:
        tmpl_meta = yaml.safe_load(fm.group(1))
        tmpl_ver = tmpl_meta.get('version', '')
        if reg_ver != tmpl_ver:
            print(f'{name}: registry={reg_ver} template={tmpl_ver}')
    else:
        print(f'{name}: no frontmatter found')
" 2>/dev/null)

if [ -z "$version_mismatch" ]; then
    pass "Registry versions match template frontmatter versions"
else
    fail "Version mismatch between registry and templates" "$version_mismatch"
fi

# Framework entries have parent field
missing_parents=$(python3 -c "
import yaml
with open('$REGISTRY') as f:
    data = yaml.safe_load(f)
for name, info in data.items():
    if info.get('tier') == 'framework' and 'parent' not in info:
        print(f'{name}: framework without parent')
" 2>/dev/null)

if [ -z "$missing_parents" ]; then
    pass "All framework entries have parent field"
else
    fail "Framework entries missing parent" "$missing_parents"
fi

test_summary
