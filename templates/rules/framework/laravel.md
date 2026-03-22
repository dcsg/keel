---
paths: "**/*.php"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change bypasses Eloquent conventions, skips validation, or misuses service providers.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Laravel

Rules for building Laravel applications.

## Critical

- NEVER use `$guarded = []` on a model — it disables all mass assignment protection. Define `$fillable` explicitly with only the columns that should be user-assignable.
- NEVER call `env()` outside of config files — it returns `null` after `config:cache` runs in production. Always access config through `config('app.key')`.

## Standards

- Always eager load relationships to avoid N+1 queries: `User::with('orders')->get()`. Never lazy-load in loops.
- Use Form Request classes for controller validation. Inline `$request->validate()` is acceptable for simple single-rule checks; for anything with multiple fields or custom rules, use a Form Request.
- Jobs MUST be idempotent — running the same job twice must produce the same result. Set `$tries` and `$backoff` on every job. Use `ShouldBeUnique` where overlap would cause problems.
- Use route model binding: type-hint the model in the controller signature. Don't manually call `Model::findOrFail($id)` when binding can do it.
- Use events and listeners for side effects that shouldn't block the HTTP response: emails, notifications, audit logging. Queue listeners for non-critical effects.

## Practices

- Use Laravel's built-in fakes in tests (`Queue::fake()`, `Mail::fake()`, `Event::fake()`) — don't mock the full framework stack.

## Critical

- NEVER use `$guarded = []` — define `$fillable` explicitly.
- NEVER call `env()` outside of config files.
