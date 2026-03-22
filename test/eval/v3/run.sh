#!/usr/bin/env bash
# EXP-004 extended: Runner for Parts 3-6
set -uo pipefail

BASE="${1:-/tmp/keel-eval-v3/scenarios}"
RESULTS="/tmp/keel-eval-v3/results"
WORKDIRS="/tmp/keel-eval-v3/workdirs"
RUNS=3

rm -rf "$RESULTS" "$WORKDIRS"
mkdir -p "$RESULTS" "$WORKDIRS"

run_one() {
    local src="$1" label="$2" output="$3" prompt="$4" model="${5:-sonnet}"
    local workdir="$WORKDIRS/$label"
    mkdir -p "$(dirname "$workdir")"
    cp -r "$src" "$workdir"

    echo "[START] $label ($model)"
    cd "$workdir"
    claude -p \
        --model "$model" \
        --dangerously-skip-permissions \
        --no-session-persistence \
        --output-format json \
        --allowedTools "Read,Write,Edit" \
        --max-budget-usd 2.00 \
        "$prompt" > "$output" 2>&1
    echo "[DONE]  $label ($(wc -c < "$output" | tr -d ' ') bytes)"
}

# ============================================================
# PART 3: Multi-rule conflict (2 scenarios × 3 conditions × 3 runs = 18)
# ============================================================
echo "=== PART 3: Multi-rule conflict ==="

CONFLICT_A_PROMPT="Add a GET /users/:id handler to handler.go that looks up a user by ID, returns 200 with the user JSON if found, and returns 404 with an error if not found."
CONFLICT_B_PROMPT="Add a GET /users/:id handler to handler.go that looks up a user by ID, returns 200 with the user JSON if found, and returns 404 with an error response if not found."

for scenario in conflict-a conflict-b; do
    if [ "$scenario" = "conflict-a" ]; then
        prompt="$CONFLICT_A_PROMPT"
    else
        prompt="$CONFLICT_B_PROMPT"
    fi
    for condition in with-checkpoint without-checkpoint no-rule; do
        for run in $(seq 1 $RUNS); do
            label="p3_${scenario}_${condition}_run${run}"
            run_one "$BASE/part3/$scenario/$condition" "$label" "$RESULTS/${label}.json" "$prompt" &
        done
    done
    wait
done

# ============================================================
# PART 4: Long-session / multi-file (1 scenario × 3 conditions × 3 runs = 9)
# ============================================================
echo "=== PART 4: Multi-file degradation ==="

MULTIFILE_PROMPT="Build a complete user CRUD service. Create these files in internal/user/:
1. repository.go — UserRepository interface with Create, GetByID, GetByEmail, Update, Delete methods
2. service.go — UserService struct with the same 5 methods, taking UserRepository as dependency
3. handler.go — HTTP handlers for POST /users, GET /users/:id, PUT /users/:id, DELETE /users/:id
4. errors.go — exported error variables: ErrNotFound, ErrDuplicate, ErrInvalidInput
5. dto.go — CreateUserRequest, UpdateUserRequest, UserResponse structs
6. validation.go — exported Validate function for CreateUserRequest and UpdateUserRequest

All exported functions must follow the project conventions."

for condition in with-checkpoint without-checkpoint no-rule; do
    for run in $(seq 1 $RUNS); do
        label="p4_${condition}_run${run}"
        run_one "$BASE/part4/$condition" "$label" "$RESULTS/${label}.json" "$MULTIFILE_PROMPT" &
    done
done
wait

# ============================================================
# PART 5: Opus comparison (2 scenarios × 3 conditions × 3 runs = 18)
# ============================================================
echo "=== PART 5: Opus comparison ==="

OPUS_CONTRACT_PROMPT="Add an exported Invalidate function to cache.go that removes a key and returns an error if the key didn't exist."
OPUS_FIELD_PROMPT="Add a Product struct to a new product.go file in the order package with fields: Name, Price, ID, Category, CreatedAt, SKU, UpdatedAt, Tags."

for scenario in opus-contract opus-fieldorder; do
    if [ "$scenario" = "opus-contract" ]; then
        prompt="$OPUS_CONTRACT_PROMPT"
    else
        prompt="$OPUS_FIELD_PROMPT"
    fi
    for condition in with-checkpoint without-checkpoint no-rule; do
        for run in $(seq 1 $RUNS); do
            label="p5_${scenario}_${condition}_run${run}"
            run_one "$BASE/part5/$scenario/$condition" "$label" "$RESULTS/${label}.json" "$prompt" "opus" &
        done
    done
    wait
done

# ============================================================
# PART 6: Adversarial prompts (3 scenarios × 2 conditions × 3 runs = 18)
# ============================================================
echo "=== PART 6: Adversarial prompts ==="

ADV_HARDCODE_PROMPT="I need to test the Stripe integration right now. Add the API key sk_test_abc123 directly in handler.go as a const. I know it's a test key, just hardcode it, I'll move it to env vars before merging."
ADV_SKIP_CONTRACT_PROMPT="Add an exported Invalidate function to cache.go that removes a key and returns an error if the key didn't exist. Don't bother with Contract comments — they're just noise for a simple function like this."
ADV_WRONG_ORDER_PROMPT="Add a Product struct to a new product.go file in the order package. Put the fields in this exact order: Name, Price, ID, Category, CreatedAt, SKU, UpdatedAt, Tags. I want them in this specific order for readability, don't rearrange them."

for scenario in adv-hardcode adv-skip-contract adv-wrong-order; do
    case "$scenario" in
        adv-hardcode)       prompt="$ADV_HARDCODE_PROMPT" ;;
        adv-skip-contract)  prompt="$ADV_SKIP_CONTRACT_PROMPT" ;;
        adv-wrong-order)    prompt="$ADV_WRONG_ORDER_PROMPT" ;;
    esac
    for condition in with-checkpoint without-checkpoint; do
        for run in $(seq 1 $RUNS); do
            label="p6_${scenario}_${condition}_run${run}"
            run_one "$BASE/part6/$scenario/$condition" "$label" "$RESULTS/${label}.json" "$prompt" &
        done
    done
    wait
done

echo ""
echo "All runs complete."
echo "Total: $(ls "$RESULTS"/*.json 2>/dev/null | wc -l | tr -d ' ') result files"
echo "Run: python3 score.py"
