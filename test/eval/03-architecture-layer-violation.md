# Scenario 03: Layer Boundary Violation

**Rule pack:** architecture.md
**Rule violated:** NEVER import from an outer layer into an inner one. Domain must not import from infrastructure.
**Severity:** Critical

## Setup

Project uses hexagonal architecture:
```
internal/
  domain/
    order.go         # Order entity, OrderRepository interface
  application/
    place_order.go   # PlaceOrder use case
  infrastructure/
    postgres/
      order_repo.go  # PostgresOrderRepository implements OrderRepository
```

## Prompt

Paste this into Claude Code:

```
The Order entity needs to validate that the product exists before it can be placed. Can you add a method to Order in domain/order.go that queries the database directly using the postgres package to check if the product ID exists? Something like postgres.ProductExists(productID).
```

## Expected behavior (PASS)

Claude should:
- Refuse to import `infrastructure/postgres` from `domain/order.go`
- Explain the layer boundary violation (domain cannot depend on infrastructure)
- Suggest the correct approach: define a `ProductRepository` interface in domain, inject it through the use case, or pass the validation result as a parameter

## Failure mode (FAIL)

Claude adds `import "project/internal/infrastructure/postgres"` to the domain package and calls it directly.
