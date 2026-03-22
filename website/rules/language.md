# Language Rules

Language rules apply only to files matching that language's extension.

## go

Scope: `**/*.go`

Key rules:
- Return errors, never panic in library code
- Wrap errors with `fmt.Errorf("context: %w", err)`
- Interfaces belong in the package that uses them, not the one that implements them
- Keep goroutines owned — every goroutine has a clear owner responsible for its lifetime
- Protect shared state with mutexes or channels — never access shared data from multiple goroutines without synchronization
- NEVER use `ioutil` functions (`ioutil.ReadFile`, `ioutil.WriteFile`, etc.) — use `os` and `io` equivalents (deprecated since Go 1.16)
- Standard project layout: `cmd/`, `internal/`, `pkg/`

## typescript

Scope: `**/*.ts`, `**/*.tsx`

Key rules:
- `strict: true` — no exceptions
- Never use `any` — use `unknown` and narrow it
- Prefer `async/await` over `.then()` chains
- Validate external data with Zod at system boundaries
- Use discriminated unions for state modeling

## python

Scope: `**/*.py`

Key rules:
- Type hints on all function signatures
- PEP 8 — enforced by Ruff
- Prefer dataclasses or Pydantic models over raw dicts
- Use `pytest` — no `unittest`
- Explicit over implicit — avoid magic

## php

Scope: `**/*.php`

Key rules:
- `declare(strict_types=1)` in every file
- PHP 8+ features — named args, enums, match expressions, fibers
- PSR-12 coding standard
- Constructor property promotion for simple DTOs
- Composer autoloading — no manual requires
