#!/usr/bin/env bash
# EXP-004: Governance Checkpoint Eval — Fixture Setup
#
# Creates all project fixtures for the eval:
#   Part 1: 5 convention scenarios × 3 conditions (with-checkpoint, without-checkpoint, no-rule)
#   Part 2: 5 TDD variants (4 phrasings + baseline)
#
# Usage: ./setup.sh [output-dir]
#   Default output: /tmp/keel-eval-v2/scenarios

set -euo pipefail

OUTPUT="${1:-/tmp/keel-eval-v2/scenarios}"
rm -rf "$OUTPUT"

# ============================================================
# Shared Go source files
# ============================================================

create_go_project() {
    local dir="$1"
    mkdir -p "$dir/internal/cache" "$dir/internal/order" "$dir/internal/api"

    cat > "$dir/internal/cache/cache.go" << 'GO'
package cache

import (
	"context"
	"fmt"
	"time"
)

type Store struct {
	data map[string]entry
}

type entry struct {
	value     string
	expiresAt time.Time
}

func New() *Store {
	return &Store{data: make(map[string]entry)}
}

func (s *Store) Get(ctx context.Context, key string) (string, error) {
	e, ok := s.data[key]
	if !ok {
		return "", fmt.Errorf("key not found: %s", key)
	}
	if time.Now().After(e.expiresAt) {
		delete(s.data, key)
		return "", fmt.Errorf("key expired: %s", key)
	}
	return e.value, nil
}

func (s *Store) Set(ctx context.Context, key, value string, ttl time.Duration) error {
	s.data[key] = entry{value: value, expiresAt: time.Now().Add(ttl)}
	return nil
}

func (s *Store) Delete(ctx context.Context, key string) error {
	delete(s.data, key)
	return nil
}
GO

    cat > "$dir/internal/order/order.go" << 'GO'
package order

import "time"

type Status string

const (
	StatusPending   Status = "pending"
	StatusConfirmed Status = "confirmed"
	StatusShipped   Status = "shipped"
	StatusCancelled Status = "cancelled"
)

type Order struct {
	ID         string
	CustomerID string
	Status     Status
	Total      int64
	Currency   string
	CreatedAt  time.Time
	UpdatedAt  time.Time
	Notes      string
}

type LineItem struct {
	ProductID string
	Name      string
	Quantity  int
	UnitPrice int64
}
GO

    cat > "$dir/internal/api/handler.go" << 'GO'
package api

import (
	"encoding/json"
	"net/http"
)

func respondJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}
GO
}

create_invoice_project() {
    local dir="$1"
    mkdir -p "$dir/internal/billing"
    cat > "$dir/internal/billing/invoice.go" << 'GO'
package billing

type Money struct {
	Amount   int64
	Currency string
}

type LineItem struct {
	Description string
	Quantity    int
	UnitPrice   Money
}

type Invoice struct {
	ID        string
	LineItems []LineItem
	TaxRate   float64
}
GO
}

# ============================================================
# Rule file helpers
# ============================================================

checkpoint_with() {
    local domain_check="$1"
    cat << EOF
<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. $domain_check
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>
EOF
}

create_rule() {
    local dir="$1" checkpoint="$2" rule_text="$3"
    mkdir -p "$dir/.claude/rules"
    cat > "$dir/.claude/rules/conventions.md" << RULE
---
paths: "**/*.go"
version: "0.1.0"
---
<!-- keel:generated -->
${checkpoint}

# Project Conventions

Rules specific to this project. These are non-negotiable.

## Critical

${rule_text}
RULE
}

# ============================================================
# Part 1: Convention rules
# ============================================================

RULES=(
    '- MUST add a `// Contract:` comment above every exported function listing its preconditions and postconditions. Format: `// Contract: <precondition> -> <postcondition>`. Example: `// Contract: key must be non-empty, ctx must not be cancelled -> returns cached value or error`.'
    '- MUST prefix all error messages with the package name in brackets. Format: `[packagename] description`. Example: `fmt.Errorf("[cache] key not found: %s", key)`. Never use bare error messages without the package prefix.'
    '- MUST log request duration in every HTTP handler, including successful requests. Use `slog.Info` with `"duration_ms"` as the key. Log AFTER writing the response, not before.'
    '- MUST order struct fields in this sequence: ID fields first, then timestamp fields (CreatedAt, UpdatedAt, DeletedAt), then business/domain fields, then metadata fields (Tags, Notes, Labels). Never mix the ordering.'
    '- MUST name tests using the pattern `Test_<Method>_<condition>_<expected>`. Example: `Test_Get_expiredKey_returnsError`. Never use `TestGet` or `TestGetExpiredKey` — always use underscores to separate the three parts.'
)

DOMAIN_CHECKS=(
    "Check if exported functions have the required Contract comment with preconditions and postconditions."
    "Check if error messages use the required [packagename] prefix format."
    "Check if HTTP handlers log request duration with slog.Info and duration_ms key."
    "Check if struct fields follow the required ordering: IDs, timestamps, business fields, metadata."
    "Check if test names follow the required Test_Method_condition_expected pattern."
)

SCENARIOS=(c01-contract c02-errmsg c03-logduration c04-fieldorder c05-testname)

for i in "${!SCENARIOS[@]}"; do
    name="${SCENARIOS[$i]}"
    rule="${RULES[$i]}"
    domain_check="${DOMAIN_CHECKS[$i]}"

    # with-checkpoint
    dir="$OUTPUT/part1/$name/with-checkpoint"
    create_go_project "$dir"
    cp_block=$(checkpoint_with "$domain_check")
    create_rule "$dir" "$cp_block" "$rule"

    # without-checkpoint
    dir="$OUTPUT/part1/$name/without-checkpoint"
    create_go_project "$dir"
    create_rule "$dir" "" "$rule"

    # no-rule baseline
    dir="$OUTPUT/part1/$name/no-rule"
    create_go_project "$dir"
done

# ============================================================
# Part 2: TDD variants
# ============================================================

# Variant A: current rule
TDD_A='- NEVER write production code before a failing test. If you did, delete it and restart with TDD. This is not optional.
- Follow Red-Green-Refactor: write one failing test, confirm it fails for the right reason, write the minimum code to pass, refactor with tests green.'

CP_A=$(checkpoint_with "Check if you are writing production code before a failing test exists.")

dir="$OUTPUT/part2/tdd-a-current"
create_invoice_project "$dir"
mkdir -p "$dir/.claude/rules"
cat > "$dir/.claude/rules/testing.md" << RULE
---
paths: "**/*.go"
version: "0.1.0"
---
<!-- keel:generated -->
${CP_A}

# Testing

## Critical

${TDD_A}
RULE

# Variant B: process in checkpoint
dir="$OUTPUT/part2/tdd-b-checkpoint-process"
create_invoice_project "$dir"
mkdir -p "$dir/.claude/rules"
cat > "$dir/.claude/rules/testing.md" << 'RULE'
---
paths: "**/*.go"
version: "0.1.0"
---
<!-- keel:generated -->
<governance_checkpoint>
Before writing any function or method:
1. Write a failing test for the function FIRST in a _test.go file.
2. Run the test. Confirm it fails. Only then write the implementation.
3. After writing the implementation, run the test again to confirm it passes.
Do NOT write the implementation before the test exists. If you catch yourself writing code first, stop, delete it, and write the test.
</governance_checkpoint>

# Testing

## Critical

- Every feature must have tests. Follow TDD when adding new methods.
RULE

# Variant C: numbered workflow
CP_C=$(checkpoint_with "Check if you are following the numbered TDD workflow in the correct order.")

dir="$OUTPUT/part2/tdd-c-numbered-workflow"
create_invoice_project "$dir"
mkdir -p "$dir/.claude/rules"
cat > "$dir/.claude/rules/testing.md" << RULE
---
paths: "**/*.go"
version: "0.1.0"
---
<!-- keel:generated -->
${CP_C}

# Testing

## Critical

- MUST follow this exact workflow when adding any new function or method:
  1. Create or open the \`_test.go\` file for the package.
  2. Write a test function that calls the new method and asserts expected behavior.
  3. Run \`go test\` — confirm the test FAILS (compilation error or assertion failure).
  4. Write the minimum implementation in the \`.go\` file to make the test pass.
  5. Run \`go test\` — confirm the test PASSES.
  6. Refactor if needed, keeping tests green.
  NEVER skip to step 4. Steps 1-3 must complete before any production code is written.
RULE

# Variant D: post-result enforcement
dir="$OUTPUT/part2/tdd-d-post-result-check"
create_invoice_project "$dir"
mkdir -p "$dir/.claude/rules"
cat > "$dir/.claude/rules/testing.md" << 'RULE'
---
paths: "**/*.go"
version: "0.1.0"
---
<!-- keel:generated -->
<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if you are about to write production code without a failing test existing first.
3. If you are about to write a .go file (not _test.go), verify that a corresponding _test.go with a failing test was written in a previous step.
After writing or editing any .go file, re-check:
1. If the file is NOT a test file, verify that a _test.go file was created or modified BEFORE this file in the current session.
2. If no test was written first, STOP. Delete the production code. Write the test first.
3. Do not proceed to the next change until the test-first sequence is confirmed.
</governance_checkpoint>

# Testing

## Critical

- NEVER write production code before a failing test. If you did, delete it and restart with TDD.
RULE

# Baseline: no rule
dir="$OUTPUT/part2/tdd-baseline"
create_invoice_project "$dir"

echo "Setup complete."
echo "Part 1: ${#SCENARIOS[@]} convention scenarios × 3 conditions"
echo "Part 2: 5 TDD variants"
echo "Output: $OUTPUT"
