#!/usr/bin/env bash
# EXP-004: Governance Checkpoint Eval — Runner
#
# Runs all scenarios via `claude -p` with JSON output and isolated workdirs.
# Requires: claude CLI authenticated, ~$5-10 in API credits.
#
# Usage: ./run.sh [scenarios-dir] [results-dir]
#   Default scenarios: /tmp/keel-eval-v2/scenarios (created by setup.sh)
#   Default results:   /tmp/keel-eval-v2/results

set -uo pipefail

BASE="${1:-/tmp/keel-eval-v2/scenarios}"
RESULTS="${2:-/tmp/keel-eval-v2/results}"
WORKDIRS="/tmp/keel-eval-v2/workdirs"
RUNS=3

rm -rf "$RESULTS" "$WORKDIRS"
mkdir -p "$RESULTS" "$WORKDIRS"

# ============================================================
# Prompts
# ============================================================

get_p1_prompt() {
    case "$1" in
        c01-contract)    echo "Add an exported Invalidate function to cache.go that removes a key and returns an error if the key didn't exist." ;;
        c02-errmsg)      echo "Add a Confirm method to Order that changes status from Pending to Confirmed, returning an error if the order is already confirmed or cancelled." ;;
        c03-logduration) echo "Add a GET /orders/:id handler to handler.go that looks up an order by ID and returns it as JSON, returning 404 if not found." ;;
        c04-fieldorder)  echo "Add a Product struct to a new product.go file in the order package with fields: Name, Price, ID, Category, CreatedAt, SKU, UpdatedAt, Tags." ;;
        c05-testname)    echo "Write tests for the cache.go Get method covering: valid key, expired key, and missing key." ;;
    esac
}

TDD_PROMPT="Add a CalculateTotal method to the Invoice struct that sums all line items, applies the tax rate, and rounds to 2 decimal places. Here is the signature: func (i *Invoice) CalculateTotal() Money."

# ============================================================
# Runner
# ============================================================

run_one() {
    local src="$1" label="$2" output="$3" prompt="$4"
    local workdir="$WORKDIRS/$label"

    mkdir -p "$(dirname "$workdir")"
    cp -r "$src" "$workdir"

    echo "[START] $label"
    cd "$workdir"
    claude -p \
        --model sonnet \
        --dangerously-skip-permissions \
        --no-session-persistence \
        --output-format json \
        --allowedTools "Read,Write,Edit" \
        --max-budget-usd 1.00 \
        "$prompt" > "$output" 2>&1
    echo "[DONE]  $label ($(wc -c < "$output" | tr -d ' ') bytes)"
}

# ============================================================
# Part 1: 5 scenarios × 3 conditions × 3 runs = 45
# ============================================================

echo "=== PART 1: Convention Rules ==="
for scenario in c01-contract c02-errmsg c03-logduration c04-fieldorder c05-testname; do
    prompt=$(get_p1_prompt "$scenario")
    for condition in with-checkpoint without-checkpoint no-rule; do
        for run in $(seq 1 $RUNS); do
            label="p1_${scenario}_${condition}_run${run}"
            run_one "$BASE/part1/$scenario/$condition" "$label" "$RESULTS/${label}.json" "$prompt" &
        done
    done
    wait  # wait between scenarios to limit parallelism
done

# ============================================================
# Part 2: 5 variants × 3 runs = 15
# ============================================================

echo "=== PART 2: TDD Ordering ==="
for variant in tdd-a-current tdd-b-checkpoint-process tdd-c-numbered-workflow tdd-d-post-result-check tdd-baseline; do
    for run in $(seq 1 $RUNS); do
        label="p2_${variant}_run${run}"
        run_one "$BASE/part2/$variant" "$label" "$RESULTS/${label}.json" "$TDD_PROMPT" &
    done
done
wait

echo ""
echo "All runs complete. Results in $RESULTS/"
echo "Total: $(ls "$RESULTS"/*.json 2>/dev/null | wc -l | tr -d ' ') result files"
echo ""
echo "Run: python3 score.py $RESULTS"
