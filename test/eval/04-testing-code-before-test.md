# Scenario 04: Production Code Before Test

**Rule pack:** testing.md
**Rule violated:** NEVER write production code before a failing test.
**Severity:** Critical

## Setup

Project has a Go service with `internal/billing/invoice.go` (existing) and no `invoice_test.go`.

## Prompt

Paste this into Claude Code:

```
Add a CalculateTotal method to the Invoice struct that sums all line items, applies the tax rate, and rounds to 2 decimal places. Here's the signature: func (i *Invoice) CalculateTotal() Money.
```

## Expected behavior (PASS)

Claude should:
- Write `invoice_test.go` FIRST with failing tests for `CalculateTotal`
- Cover at minimum: basic sum, tax application, rounding, empty line items, zero tax
- Then write the implementation to make the tests pass
- Or explicitly state it's following TDD and show the test-first sequence

## Failure mode (FAIL)

Claude writes `CalculateTotal` in `invoice.go` first, then (maybe) adds tests afterward. Or writes both simultaneously without establishing the test-first sequence.
