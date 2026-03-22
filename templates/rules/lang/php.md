---
paths: "**/*.php"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change uses loose comparisons, skips type declarations, or ignores PSR standards.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# PHP

Rules for writing modern, safe, idiomatic PHP code.

## Critical

- NEVER use the `@` error suppression operator — it hides errors that should be handled, logged, or bubbled up.
- NEVER catch `\Throwable` or `\Exception` without re-throwing — broad catches that swallow errors are the PHP equivalent of a bare except.
- MUST declare `strict_types=1` in every file. Without it, PHP silently coerces types and hides bugs.

## Standards

- Add type declarations to all function parameters, return types, and class properties. Use union types (`string|int`) and nullable types (`?string`). Avoid `mixed` — if you don't know the type, narrow it.
- Use constructor property promotion (PHP 8.0+). Use `readonly` properties (PHP 8.1+) for immutable data. These aren't style preferences — they reduce the surface area for mutation bugs.
- Use PHP 8.1+ `enum` for finite sets of values instead of class constants. Enums are type-safe; constants are not.
- Use `match` expressions instead of `switch` statements — `match` is strict (no type coercion), throws on unhandled cases, and is an expression.
- NEVER instantiate dependencies inside a class. Accept them through the constructor and type-hint the interface, not the concrete class. Never call `$container->get()` inside business logic — that's service location, not injection.
- Follow PSR-12: `PascalCase` for classes, `camelCase` for methods and variables, `UPPER_SNAKE` for constants.

## Practices

- Commit `composer.lock`. It ensures reproducible installs across environments — not committing it means production can silently get a different version than development.
- Use PSR-4 autoloading exclusively. No `require` or `include` for class files.
- Keep `composer.json` clean: dev dependencies in `require-dev`, production in `require`.
- Use named arguments for readability when calling functions with many parameters (PHP 8.0+).
- Use PHPUnit with descriptive test names. Use data providers for table-driven tests. Prefer integration tests with a test database for repository tests over mocking the DB.
- Structure tests as: `tests/Unit/` for unit tests, `tests/Integration/` for integration tests, `tests/Feature/` for full-stack tests.

## Critical

- NEVER use `@` error suppression.
- MUST declare `strict_types=1` in every file.
