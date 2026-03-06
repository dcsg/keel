# Base Rules

Base rules apply to all files in your project. Four are enabled by default; two are opt-in.

## code-quality

SOLID principles, naming conventions, size limits, early returns, DRY, library-first approach, and separation of concerns.

Key rules:
- Functions under 40 lines, files under 300 lines
- No `utils/`, `helpers/`, or `common/` packages — use domain-specific names
- Early returns to reduce nesting
- Don't reinvent what a library already does well

## testing

TDD red-green-refactor cycle, behavior-focused tests, mock boundaries, coverage expectations.

Key rules:
- Write the failing test before the implementation
- Test behavior, not implementation details
- Mock at architectural boundaries only — not every function
- Test names describe the scenario: `TestOrderService_Cancel_RefundsPayment`

## security

Input validation at boundaries, parameterized queries, no secrets in code, explicit auth checks.

Key rules:
- Validate and sanitize all external input at the entry point
- Never interpolate user input into queries — always parameterize
- Never log secrets, tokens, or PII
- Explicit authorization check before any data access

## error-handling

Typed/structured errors, context enrichment, no silent catches, validation at boundaries.

Key rules:
- Use typed errors, not string matching
- Wrap errors with context at each layer boundary
- Never silently swallow errors with empty catch blocks
- Validate at system boundaries (HTTP, CLI, queue consumers) — not deep in business logic

## frontend _(opt-in)_

Component patterns, accessibility, state management, performance.

Key rules:
- Components do one thing — separate display from data fetching
- Every interactive element has an accessible label
- Derive state from a single source of truth
- No premature optimization — measure before memoizing

## architecture _(opt-in)_

DDD bounded contexts, clean architecture layers, repository pattern, import restrictions.

Key rules:
- Domain layer has zero infrastructure imports
- Each bounded context owns its data — no cross-context direct DB access
- Use domain events for side effects that cross context boundaries
- Repository interface in domain, implementation in infrastructure
