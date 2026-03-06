# Commit Convention

## Format

```
{type}({scope}): {description}
```

## Types

| Type | When |
|------|------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or updating tests |
| `docs` | Documentation only |
| `chore` | Build, CI, tooling, dependencies |
| `perf` | Performance improvement |

## Rules

- Description is lowercase, no period at the end
- Scope is optional but recommended (module, feature, or area)
- Keep the first line under 72 characters
- Use the body for details if needed (separate with blank line)

## Examples

```
feat(orders): add bulk order creation endpoint
fix(auth): handle expired refresh tokens gracefully
refactor(payments): extract payment gateway interface
test(orders): add integration tests for order cancellation
docs: update API reference for v2 endpoints
chore(deps): upgrade Go to 1.22
```
