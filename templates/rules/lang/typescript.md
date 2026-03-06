---
paths: "**/*.{ts,tsx}"
---
<!-- keel:generated -->

# TypeScript

Rules for writing safe, idiomatic TypeScript code.

## Type Safety

- Enable `strict: true` in tsconfig.json. Never disable it per-file.
- Never use `any`. If the type is truly unknown, use `unknown` and narrow with type guards.
- Never use `@ts-ignore` or `@ts-expect-error` without a comment explaining why and a linked issue.
- Don't use type assertions (`as Type`) unless you can prove the type is correct. Prefer type guards.

```typescript
// BAD
const data = response as UserData
const value: any = getConfig()

// GOOD
if (isUserData(response)) { /* response is narrowed */ }
const value: unknown = getConfig()
```

## Interfaces & Types

- Use `interface` for object shapes that may be extended or implemented.
- Use `type` for unions, intersections, mapped types, and aliases.
- Export types that are part of the public API. Keep internal types unexported.
- Prefer specific types over broad ones: `'success' | 'error'` over `string`.

```typescript
// BAD
type Status = string

// GOOD
type Status = 'pending' | 'processing' | 'complete' | 'failed'
```

## Enums & Constants

- Prefer `as const` objects or union types over TypeScript `enum`.
- Enums have runtime behavior that adds bundle size and complexity. Const objects and unions are simpler.

```typescript
// Avoid
enum Direction { Up, Down, Left, Right }

// Prefer
const Direction = { Up: 'up', Down: 'down', Left: 'left', Right: 'right' } as const
type Direction = typeof Direction[keyof typeof Direction]
```

## Null Handling

- Enable `strictNullChecks` (included in `strict: true`).
- Use optional chaining (`?.`) and nullish coalescing (`??`) for safe null access.
- Don't use `!` (non-null assertion) unless you can prove the value is non-null. Prefer a runtime check.
- Be explicit about nullability in function signatures: `(user: User | null)` not `(user: User)` that might be null.

## Async/Await

- Always use async/await over raw Promises and `.then()` chains.
- Always handle errors in async functions — unhandled rejections crash Node processes.
- Use `Promise.all()` for independent concurrent operations, not sequential awaits.
- Use `Promise.allSettled()` when you need all results regardless of individual failures.

```typescript
// BAD — sequential when parallel is possible
const users = await getUsers()
const orders = await getOrders()

// GOOD — concurrent
const [users, orders] = await Promise.all([getUsers(), getOrders()])
```

## Module System

- Use ES modules (`import`/`export`), not CommonJS (`require`/`module.exports`).
- Use named exports for most things. Default exports are acceptable for React components and pages.
- Import order: node built-ins, external packages, internal modules, relative imports. Separate with blank lines.
- Use path aliases (`@/components/Button`) over deep relative paths (`../../../components/Button`).

## Functions

- Use arrow functions for callbacks and inline functions.
- Use regular function declarations for top-level named functions (they're hoisted and have better stack traces).
- Prefer destructuring in function parameters when accessing multiple properties.

```typescript
// BAD
function process(config: Config) {
  const name = config.name
  const timeout = config.timeout
}

// GOOD
function process({ name, timeout }: Config) {
  // direct access
}
```

## Zod / Runtime Validation

- Validate external data (API responses, form input, environment variables) at runtime with Zod or similar.
- TypeScript types are compile-time only — they don't protect against malformed runtime data.
- Define the Zod schema first, infer the TypeScript type from it: `type User = z.infer<typeof UserSchema>`.
