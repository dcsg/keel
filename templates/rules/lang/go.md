---
paths: "**/*.go"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change discards errors, starts unmanaged goroutines, or misuses interfaces.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Go

Rules for writing idiomatic, production-grade Go code.

## Critical

- NEVER use `_` to discard an error return — always check errors. If an error is genuinely ignorable, add a comment explaining why.
- NEVER start a goroutine without a plan for how it stops. Use `context.Context` for cancellation and `sync.WaitGroup` or `errgroup` to wait for completion.
- MUST use `fmt.Errorf("operation context: %w", err)` when wrapping errors — this preserves the error chain for `errors.Is` and `errors.As`.

## Standards

- Use `errors.Is()` and `errors.As()` for error comparison, never string matching. Define sentinel errors (`var ErrNotFound = errors.New(...)`) or custom error types for errors callers need to differentiate.
- Follow Go naming: `MixedCaps` for exported, `mixedCaps` for unexported. No underscores in names except test files. Receivers: 1-2 letters, consistent across the type's methods — `(o *Order)` not `(order *Order)`.
- Interfaces: single-method interfaces use method name + "er" suffix (`Reader`, `Writer`). Packages: short, lowercase, singular — `order` not `orders`, `user` not `userService`. No stutter: `order.Order` is fine, `order.OrderService` is not.
- Define interfaces where they are USED, not where they are implemented. Keep interfaces to 1-2 methods — compose larger ones from smaller. Don't define an interface until you have two implementations or need one for testing.
- `context.Context` is always the first parameter. Never store context in a struct. Use it for cancellation and deadlines, not for passing business data (request IDs in middleware are the rare accepted exception).
- Use pointer receivers when the method mutates, when the struct is large, or for consistency. Don't mix pointer and value receivers on the same type. Initialize structs with field names: `User{Name: "alice"}` not `User{"alice"}`.
- NEVER write to a map, slice, or struct field from multiple goroutines without a sync.Mutex, sync.RWMutex, or channel. Use `go test -race` on all packages — a data race is a bug, not a warning.
- NEVER use deprecated stdlib functions — use `io.ReadAll` not `ioutil.ReadAll`, `os.ReadFile` not `ioutil.ReadFile`, `os.MkdirTemp` not `ioutil.TempDir`. The `ioutil` package is deprecated since Go 1.16.

## Practices

- Prefer channels for communication between goroutines. Use `errgroup.Group` for concurrent operations that need error collection.
- `internal/` for packages that must not be imported outside the module. Keep the exported API surface minimal.
- Consider `defer cancel()` immediately after creating a context with deadline or timeout — don't let the cancel call get separated from its creation.

## Critical

- NEVER discard error returns with `_`.
- NEVER start a goroutine without a cancellation and completion strategy.
