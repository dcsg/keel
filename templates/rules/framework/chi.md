---
paths: "**/*.go"
---

# Chi (Go HTTP Router)

Rules for building APIs with the Chi router.

## Route Organization

- Group related routes under a common prefix using `r.Route()`.
- Mount sub-routers for bounded contexts or feature modules.
- Keep route definitions in one place (usually `routes.go` or `router.go`) — don't scatter them across files.

```go
r.Route("/api/v1", func(r chi.Router) {
    r.Mount("/orders", orderRouter())
    r.Mount("/users", userRouter())
})
```

## Middleware

- Apply middleware at the appropriate scope: global (logging, recovery, CORS), group (auth), or route-specific (rate limiting).
- Order matters: recovery first, then logging, then auth, then business middleware.
- Write middleware as `func(next http.Handler) http.Handler` — the standard Chi pattern.
- Don't put business logic in middleware. Middleware handles cross-cutting concerns only.

```go
r.Use(middleware.Recoverer)
r.Use(middleware.Logger)
r.Use(middleware.RealIP)

r.Group(func(r chi.Router) {
    r.Use(authMiddleware)
    r.Get("/profile", getProfile)
})
```

## Handlers

- Handlers are thin — extract request, call service, write response. No business logic in handlers.
- Use `chi.URLParam(r, "id")` for path parameters.
- Decode request bodies into typed structs, validate, then pass to the service layer.
- Always set `Content-Type` header on responses.

```go
func (h *OrderHandler) GetOrder(w http.ResponseWriter, r *http.Request) {
    id := chi.URLParam(r, "id")

    order, err := h.service.FindByID(r.Context(), id)
    if err != nil {
        respondError(w, err)
        return
    }

    respondJSON(w, http.StatusOK, order)
}
```

## Context

- Pass `r.Context()` to service/repository calls. Never create a new context in handlers.
- Use Chi's context for request-scoped values set by middleware (user ID, request ID).
- Access context values through typed helper functions, not raw `ctx.Value()`.

## Response Helpers

- Create shared `respondJSON(w, status, data)` and `respondError(w, err)` helpers.
- Map domain errors to HTTP status codes in ONE place (the error responder), not scattered across handlers.
- Return consistent error response format: `{"error": "message", "code": "ERROR_CODE"}`.

## Request Validation

- Validate request bodies in the handler layer before passing to services.
- Use a validation library or custom validators — don't validate with if/else chains in handlers.
- Return 400 with specific field errors for invalid requests.
