---
paths: "**/*.{ts,tsx}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change introduces `any`, unsafe type assertions, or implicit returns.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# TypeScript

Rules for writing safe, idiomatic TypeScript code.

## Critical

- NEVER use `any` — it disables type checking and hides bugs that would be caught at compile time. If the type is truly unknown, use `unknown` and narrow with a type guard.
- NEVER use `@ts-ignore` without a comment explaining why and a linked issue. `@ts-ignore` is a suppression, not a fix.
- MUST enable `strict: true` in tsconfig.json. Never disable it per-file or per-project.

## Standards

- Avoid type assertions (`as Type`) unless you can prove the type is correct. Prefer a runtime type guard that actually narrows the type.
- NEVER use `!` (non-null assertion) when a runtime check is possible. `user!.id` is a future null pointer error waiting to happen.
- Use `interface` for object shapes that may be extended or implemented. Use `type` for unions, intersections, mapped types, and aliases.
- Prefer specific types over broad ones: `'success' | 'error'` over `string` for a status field.
- Prefer `as const` objects or union types over TypeScript `enum`. Enums add runtime behavior that increases bundle size for no benefit.
- Always use async/await over raw Promise chains. Use `Promise.all()` for independent concurrent operations — sequential awaits for independent calls are a performance bug.
- Validate external data at runtime with Zod or equivalent. TypeScript types are compile-time only and provide no protection against malformed API responses or environment variables. Define the schema first, infer the type from it: `type User = z.infer<typeof UserSchema>`.

## Practices

- Use regular function declarations for top-level named functions (hoisted, better stack traces). Use arrow functions for callbacks and inline functions.
- Prefer destructuring in function parameters when accessing multiple properties of an object argument.
- Export types that are part of the public API. Keep internal types unexported.
- Use `Promise.allSettled()` when you need all results regardless of individual failures, rather than catching inside `Promise.all`.

## Critical

- NEVER use `any` — use `unknown` and narrow with type guards.
- MUST enable `strict: true` — never disable.
