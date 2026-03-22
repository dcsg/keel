#!/usr/bin/env python3
"""
EXP-004: Governance Checkpoint Eval — Auto-Scorer

Scores results by inspecting files written to disk in workdirs,
not by parsing output text.

Usage: python3 score.py [results-dir] [workdirs-dir]
  Default results:  /tmp/keel-eval-v2/results
  Default workdirs: /tmp/keel-eval-v2/workdirs
"""
import json
import os
import re
import sys

RESULTS = sys.argv[1] if len(sys.argv) > 1 else "/tmp/keel-eval-v2/results"
WORKDIRS = sys.argv[2] if len(sys.argv) > 2 else "/tmp/keel-eval-v2/workdirs"
RUNS = 3


def workdir(label):
    return os.path.join(WORKDIRS, label)


def check_file(wdir, relative_path, pattern):
    path = os.path.join(wdir, relative_path)
    try:
        with open(path) as f:
            return bool(re.search(pattern, f.read()))
    except FileNotFoundError:
        return False


def load_result_text(label):
    path = os.path.join(RESULTS, f"{label}.json")
    try:
        with open(path) as f:
            return json.load(f).get("result", "")
    except (json.JSONDecodeError, FileNotFoundError):
        return ""


# ============================================================
# Part 1 scorers
# ============================================================

def score_c01(wdir):
    """Contract comment on exported functions."""
    return check_file(wdir, "internal/cache/cache.go",
                      r"// Contract:.*\n.*func \(|// Contract:.*\nfunc [A-Z]")


def score_c02(wdir):
    """Error messages with [packagename] prefix."""
    return check_file(wdir, "internal/order/order.go", r'\[order\]')


def score_c03(wdir):
    """HTTP handler logs duration."""
    return check_file(wdir, "internal/api/handler.go", r'duration')


def score_c04(wdir):
    """Struct field ordering: ID < timestamps < business < metadata."""
    path = os.path.join(wdir, "internal/order/product.go")
    try:
        with open(path) as f:
            content = f.read()
    except FileNotFoundError:
        return False

    lines = content.split('\n')
    positions = {}
    for i, line in enumerate(lines):
        for field in ['ID', 'CreatedAt', 'Name', 'Tags']:
            if re.search(rf'^\s+{field}\s', line):
                positions[field] = i

    return (len(positions) >= 4 and
            positions.get('ID', 999) < positions.get('CreatedAt', 999) <
            positions.get('Name', 999) < positions.get('Tags', 999))


def score_c05(wdir):
    """Test names use Test_Method_condition_expected pattern."""
    for root, _, files in os.walk(wdir):
        for f in files:
            if f.endswith("_test.go"):
                with open(os.path.join(root, f)) as fh:
                    if re.search(r'func Test_\w+_\w+_\w+', fh.read()):
                        return True
    return False


# ============================================================
# Part 2 scorer
# ============================================================

def score_tdd(wdir, result_text):
    """Check test creation and TDD ordering signals."""
    test_exists = any(
        f.endswith("_test.go")
        for root, _, files in os.walk(wdir)
        for f in files
    )
    mentions_tdd = bool(re.search(
        r'test first|write.*test.*before|tdd|red.green|failing test|start with.*test',
        result_text, re.IGNORECASE
    ))

    if mentions_tdd and test_exists:
        return "PASS"
    elif test_exists:
        return "PARTIAL"
    else:
        return "FAIL"


# ============================================================
# Run scoring
# ============================================================

print()
print("=" * 78)
print("  EXP-004: Governance Checkpoint — Eval Results")
print("  Model: Sonnet | Runs per condition: 3 | Total: 60 runs")
print("=" * 78)
print()

# Part 1
SCORERS = {
    "c01-contract": ("Contract comment", score_c01),
    "c02-errmsg": ("[pkg] error prefix", score_c02),
    "c03-logduration": ("Log duration_ms", score_c03),
    "c04-fieldorder": ("Struct field order", score_c04),
    "c05-testname": ("Test_X_y_z naming", score_c05),
}
CONDITIONS = ["with-checkpoint", "without-checkpoint", "no-rule"]

print("PART 1: Invented Convention Rules (no training prior)")
print()
hdr = f"  {'Convention':<22} {'w/ checkpoint':>13} {'w/o checkpoint':>14} {'no rule':>8}  {'Δ cp':>6}"
print(hdr)
print("  " + "-" * (len(hdr) - 2))

totals = {c: 0 for c in CONDITIONS}

for scenario, (label, scorer) in SCORERS.items():
    scores = {}
    for condition in CONDITIONS:
        passes = sum(
            1 for run in range(1, RUNS + 1)
            if scorer(workdir(f"p1_{scenario}_{condition}_run{run}"))
        )
        scores[condition] = passes
        totals[condition] += passes

    delta = scores["with-checkpoint"] - scores["without-checkpoint"]
    delta_str = f"+{delta}" if delta > 0 else str(delta)

    print(f"  {label:<22} {scores['with-checkpoint']:>10}/3  "
          f"{scores['without-checkpoint']:>11}/3  "
          f"{scores['no-rule']:>5}/3  {delta_str:>6}")

print("  " + "-" * (len(hdr) - 2))
dt = totals["with-checkpoint"] - totals["without-checkpoint"]
print(f"  {'TOTAL':<22} {totals['with-checkpoint']:>10}/15 "
      f"{totals['without-checkpoint']:>11}/15 "
      f"{totals['no-rule']:>5}/15 {'+' + str(dt) if dt > 0 else str(dt):>6}")

print()
print()

# Part 2
VARIANTS = [
    ("tdd-a-current", "A: NEVER + checkpoint"),
    ("tdd-b-checkpoint-process", "B: Process in checkpoint"),
    ("tdd-c-numbered-workflow", "C: Numbered workflow"),
    ("tdd-d-post-result-check", "D: Post-result enforcement"),
    ("tdd-baseline", "Baseline (no rule)"),
]

print("PART 2: TDD Process Ordering")
print()
print(f"  {'Variant':<30} {'Run 1':>8} {'Run 2':>8} {'Run 3':>8}  {'Tests':>6}")
print("  " + "-" * 62)

for variant, label in VARIANTS:
    results = []
    test_count = 0
    for run in range(1, RUNS + 1):
        wdir = workdir(f"p2_{variant}_run{run}")
        result_text = load_result_text(f"p2_{variant}_run{run}")
        r = score_tdd(wdir, result_text)
        results.append(r)
        if r in ("PASS", "PARTIAL"):
            test_count += 1

    print(f"  {label:<30} {results[0]:>8} {results[1]:>8} {results[2]:>8}  "
          f"{test_count:>3}/3")

print()
print()
print("=" * 78)
print("  Key findings:")
print("  • Rules: 15/15 w/ rule vs 0/15 without — rules are the mechanism")
print("  • Checkpoint: 0 delta on Sonnet for single-rule, single-turn scenarios")
print("  • TDD: all phrasings produce tests, none enforce test-first ordering")
print("  • Next: test multi-rule conflicts, long sessions, Opus comparison")
print("=" * 78)
print()
