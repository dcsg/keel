---
paths: "**/*.go"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change misorders middleware, mixes business logic into handlers, or breaks route conventions.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Chi (Go HTTP Router)

Rules for building APIs with the Chi router.

## Critical

- NEVER put business logic in middleware. Middleware handles cross-cutting concerns only: logging, recovery, auth verification, rate limiting. If middleware is making domain decisions, extract a service.
- NEVER create a new context in a handler — always pass `r.Context()` to service and repository calls. Creating a new context breaks cancellation and deadline propagation.
- MUST map domain errors to HTTP status codes in ONE place (the error responder). Never scatter status code decisions across handlers.

## Standards

- Handlers are thin: extract request parameters, call the service, write the response. No business logic in handlers.
- Middleware order matters: Recoverer first, then Logger, then RealIP, then auth, then business middleware. Auth must come after logging so failed auth attempts are logged.
- Group related routes under a common prefix with `r.Route()`. Mount sub-routers for feature modules. Keep all route definitions in one place (`routes.go` or `router.go`).
- Use `chi.URLParam(r, "id")` for path parameters. Decode request bodies into typed structs, validate, then pass to the service layer.
- Access request-scoped values (user ID, request ID) through typed helper functions, not raw `ctx.Value(key)` calls.

## Practices

- Apply middleware at the right scope: global (all routes), group (authenticated routes), or route-specific (rate limiting on one endpoint). Don't apply global middleware to routes that don't need it.
- Return 400 with field-level error details for invalid requests. Use a validation library — don't validate with if/else chains in handlers.
- Consider using `chi.middleware.RequestID` and propagating it through context so request IDs appear in logs and error responses.
- Consider defining a `contextKey` type for all context keys to prevent key collisions from stringly-typed keys.

## Critical

- NEVER put business logic in middleware.
- MUST map domain errors to HTTP status codes in one central place.
