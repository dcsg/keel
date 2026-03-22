---
paths: "**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change breaks API contracts, versioning, or response format conventions.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# API Design

Rules for designing consistent, safe, and usable APIs.

## Critical

- NEVER return different error shapes from different endpoints. One error format across the entire API: `{ "error": "Human message", "code": "MACHINE_CODE" }`. Clients shouldn't need a different parser for each endpoint's errors.

## Standards

- REST URL conventions: plural nouns for resources (`/orders`, `/users`), kebab-case for multi-word segments (`/order-items`), no verbs in paths (`/orders/{id}/cancel` not `/cancelOrder/{id}`).
- HTTP methods by intent: GET (read, idempotent), POST (create or non-idempotent action), PUT (full replace, idempotent), PATCH (partial update), DELETE (remove, idempotent).
- Paginate all list endpoints. Return: `data`, `total`, and a cursor or `page`/`per_page`. Never return an unbounded list.
- Version the API from day one: `/api/v1/`. Adding a `v2` without a `v1` causes a breaking change with no migration path.
- Use 401 for unauthenticated requests, 403 for unauthorized (authenticated but not permitted), 404 for not found, 422 for semantic validation failures, 429 for rate limiting.
- Return `429 Too Many Requests` with `Retry-After` and `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` headers on rate-limited responses.

## Practices

- Use consistent timestamp formats: ISO 8601 UTC (`2026-03-21T14:30:00Z`). Never return epoch integers for timestamps in public APIs — they require the client to know the unit (seconds vs milliseconds).
- Request and response field names: `snake_case` or `camelCase` — pick one and use it everywhere. Mixed conventions in the same API are a maintenance problem.

## Critical

- NEVER return different error shapes from different endpoints.
