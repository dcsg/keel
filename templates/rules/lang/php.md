---
paths: "**/*.php"
version: "1.0.0"
---
<!-- keel:generated -->

# PHP

Rules for writing modern, safe, idiomatic PHP code.

## Type Safety

- Declare `strict_types=1` in every file: `declare(strict_types=1);`
- Add type declarations to all function parameters, return types, and class properties.
- Use union types (`string|int`) and nullable types (`?string`) instead of mixed.
- Avoid `mixed` type. If you don't know the type, narrow it.

```php
// BAD
function getUser($id) {
    // ...
}

// GOOD
function getUser(string $id): ?User {
    // ...
}
```

## Error Handling

- Throw specific exceptions, not generic `\Exception`.
- Define custom exception classes for domain errors.
- Never use `@` error suppression operator.
- Catch specific exception types. Never `catch (\Throwable $e)` without re-throwing.

```php
// BAD
try {
    $user = $repo->find($id);
} catch (\Exception $e) {
    // swallowed
}

// GOOD
try {
    $user = $repo->find($id);
} catch (UserNotFoundException $e) {
    return new NotFoundResponse($e->getMessage());
}
```

## Naming

- Follow PSR-12: `PascalCase` for classes, `camelCase` for methods and variables, `UPPER_SNAKE` for constants.
- Interfaces: suffix with `Interface` only if there's a naming conflict. `UserRepository` over `UserRepositoryInterface` when unambiguous.
- No abbreviations in names unless universally understood (`id`, `url`, `http`).

## Modern PHP Features

- Use constructor property promotion (PHP 8.0+).
- Use named arguments for readability when calling functions with many parameters.
- Use enums (PHP 8.1+) instead of class constants for finite sets of values.
- Use readonly properties (PHP 8.1+) for immutable data.
- Use match expressions instead of switch statements.

```php
// BAD
class User {
    private string $name;
    private string $email;

    public function __construct(string $name, string $email) {
        $this->name = $name;
        $this->email = $email;
    }
}

// GOOD
class User {
    public function __construct(
        public readonly string $name,
        public readonly string $email,
    ) {}
}
```

## Dependency Injection

- Never instantiate dependencies inside a class. Accept them through the constructor.
- Use the container for wiring, not for service location. Don't call `$container->get()` inside business logic.
- Type-hint interfaces in constructors, not concrete classes.

## Database

- Use parameterized queries or an ORM. Never concatenate user input into SQL.
- Use migrations for schema changes. Never modify the database manually.
- Use transactions for operations that modify multiple tables.

## Testing

- Use PHPUnit with descriptive test names: `testRejectsInvalidEmailFormat`.
- Use data providers for table-driven tests.
- Use mock objects sparingly — prefer integration tests with a test database for repository tests.
- Structure: `tests/Unit/` for unit tests, `tests/Integration/` for integration tests, `tests/Feature/` for full-stack tests.

## Composer

- Pin exact versions for production dependencies in `composer.lock`. Commit the lock file.
- Use PSR-4 autoloading exclusively. No `require` or `include` for class files.
- Keep `composer.json` clean: dev dependencies in `require-dev`, production in `require`.
