# Existing Projects

**The problem:** Your project has been running for months. Claude has no idea about the patterns you've established, the ADRs you've made, or the invariants your system depends on. Every session it guesses.

Keel audits what you have and installs guardrails that match.

## Flow

1. Open your existing project in Claude Code
2. Run `/keel:init`
3. Keel detects the project has history and runs a codebase audit
4. Review and confirm the recommendations

## What the audit finds

```
Ceel detected:
  Language:     Go 1.22 (go.mod)
  Framework:    Chi v5 (go.mod)
  Architecture: Layered (handler/ service/ repository/)
  Test setup:   Go testing + testify (found 47 test files)
  Lint config:  .golangci-lint.yaml found
  Git history:  847 commits over 14 months

Recommended rules:
  ✓ code-quality    (base — always recommended)
  ✓ testing         (base — always recommended)
  ✓ security        (base — always recommended)
  ✓ error-handling  (base — always recommended)
  ✓ go              (detected: Go 1.22)
  ✓ chi             (detected: Chi v5)
  ○ architecture    (opt-in — add if you want layer boundary enforcement)

Toggle rules on/off, then confirm.
```

## The difference it makes

Here's Claude before keel on an established Go project:

```go
// Asked to add a new repository method
func (r *OrderRepo) FindByStatus(status string) []Order {
    var orders []Order
    r.db.Where("status = ?", status).Find(&orders)  // no error handling
    return orders                                     // silently returns nil on error
}
```

After keel installs `error-handling.md` and `go.md`:

```go
func (r *OrderRepo) FindByStatus(ctx context.Context, status string) ([]Order, error) {
    var orders []Order
    if err := r.db.WithContext(ctx).Where("status = ?", status).Find(&orders).Error; err != nil {
        return nil, fmt.Errorf("find orders by status %q: %w", status, err)
    }
    return orders, nil
}
```

Context propagation. Error wrapping. Return value. Claude got there because it read the rules, not because you corrected it again.

## Capturing what already exists

Your project has implicit decisions baked into the code. Surface them:

```
/keel:adr we use repository pattern for all data access
/keel:adr all monetary amounts use decimal not float64
/keel:invariant payments table is append-only, never update or delete rows
```

These become ADRs and invariants in `docs/`. Claude reads them in every future session. The decisions stop living only in your head.

If you have scattered docs — READMEs, old ADR folders, wiki pages — bring them in:
```
/keel:intake
```

Keel scans and organizes them into the standard structure.

## Tips

- Start by committing the generated files — your team gets the benefit immediately
- The first session after init, run `/keel:context` and then capture a few invariants you know about
- If the audit misses something, edit `.keel/config.yaml` and re-run init
- Run `/keel:doctor` to verify the setup is healthy
