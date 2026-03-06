---
paths: "**/*.php"
version: "1.0.0"
---
<!-- keel:generated -->

# Laravel

Rules for building Laravel applications.

## Architecture

- Follow Laravel conventions: models in `app/Models/`, controllers in `app/Http/Controllers/`, etc.
- For complex domains, organize by feature/domain inside `app/`: `app/Orders/`, `app/Payments/`, etc.
- Controllers are thin — validate request, call service/action, return response. No business logic.
- Use Action classes for complex operations: `app/Actions/CreateOrder.php`.

## Eloquent

- Define relationships in models. Don't write raw joins when a relationship exists.
- Always eager load relationships to avoid N+1 queries: `User::with('orders')->get()`.
- Use query scopes for reusable query logic: `scopeActive()`, `scopeRecent()`.
- Never trust user input in queries. Use Eloquent or the query builder's parameter binding.
- Mass assignment: define `$fillable` on every model. Never use `$guarded = []`.

```php
// BAD — N+1 query
$users = User::all();
foreach ($users as $user) {
    echo $user->orders->count(); // query per user
}

// GOOD
$users = User::with('orders')->get();
```

## Validation

- Use Form Request classes for controller validation, not inline `$request->validate()` for complex rules.
- Define validation rules as constants or methods on the Form Request, not strings scattered in controllers.
- Use custom validation rules for domain-specific logic.
- Always validate. Never trust request data, even from authenticated users.

## Routing

- Use resource routes for CRUD: `Route::resource('orders', OrderController::class)`.
- Group routes by middleware: `Route::middleware('auth')->group(...)`.
- Use route model binding: type-hint the model in the controller method signature.
- API routes go in `routes/api.php`, web routes in `routes/web.php`.

## Middleware

- Custom middleware for cross-cutting concerns: logging, rate limiting, tenant resolution.
- Don't put business logic in middleware.
- Register middleware in `bootstrap/app.php` (Laravel 11+) or `app/Http/Kernel.php`.

## Jobs & Queues

- Use jobs for anything that doesn't need to complete during the HTTP request: emails, notifications, report generation, external API calls.
- Jobs must be idempotent — running the same job twice should produce the same result.
- Set `$tries` and `$backoff` on every job. Don't let failed jobs retry infinitely.
- Use `ShouldBeUnique` for jobs that shouldn't overlap.

## Events & Listeners

- Use events for side effects that shouldn't block the main operation: sending emails after order placement, logging activity, syncing with external systems.
- Events carry data, listeners act on it. Don't put business logic in events.
- Queue listeners for non-critical side effects.

## Testing

- Use `RefreshDatabase` trait for tests that need a clean database.
- Use factories for test data: `User::factory()->create()`.
- Test behavior through HTTP tests (`$this->get('/orders')`) for feature tests.
- Unit test services/actions directly for business logic.
- Use `Mockery` or Laravel's built-in fakes (`Queue::fake()`, `Mail::fake()`) for external dependencies.

## Configuration

- Use `.env` for environment-specific values. Never commit `.env`.
- Access config through `config('app.key')`, never `env()` outside of config files.
- Cache config in production: `php artisan config:cache`.
