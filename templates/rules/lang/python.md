---
paths: "**/*.py"
---

# Python

Rules for writing clean, idiomatic Python code.

## Type Hints

- Add type hints to all function signatures (parameters and return types).
- Use `from __future__ import annotations` for modern annotation syntax.
- Use `typing` module types: `Optional`, `Union`, `list[str]`, `dict[str, int]`.
- Run a type checker (mypy, pyright) in CI. Type hints without checking are documentation, not safety.

```python
# BAD
def get_user(user_id):
    ...

# GOOD
def get_user(user_id: str) -> User | None:
    ...
```

## Error Handling

- Catch specific exceptions, never bare `except:` or `except Exception:` without re-raising.
- Use custom exception classes for domain-specific errors.
- Use context managers (`with`) for resource management (files, connections, locks).
- Don't use exceptions for flow control. Check conditions before operating.

```python
# BAD
try:
    process(data)
except:
    pass

# GOOD
try:
    process(data)
except ValidationError as e:
    logger.warning("invalid data", extra={"error": str(e)})
    raise
```

## Naming

- Follow PEP 8: `snake_case` for functions and variables, `PascalCase` for classes, `UPPER_SNAKE` for constants.
- Modules and packages: short, lowercase, no underscores where possible.
- Private attributes: single underscore prefix `_internal_method`. Avoid double underscore (name mangling) unless necessary.
- Boolean variables and functions: use `is_`, `has_`, `can_` prefixes.

## Imports

- Order: standard library, third-party, local. Separate with blank lines.
- Use absolute imports over relative imports.
- Import modules, not individual names (unless it's a common pattern in the codebase).
- Never use `from module import *`.

```python
import os
from pathlib import Path

import requests
from sqlalchemy import select

from myapp.models import User
from myapp.services import OrderService
```

## Data Classes & Models

- Use `dataclasses` or Pydantic `BaseModel` for structured data — not plain dicts.
- Use `frozen=True` on dataclasses for immutable value objects.
- Use Pydantic for data that comes from external sources (API requests, config files, environment).

```python
# BAD
user = {"name": "alice", "email": "alice@example.com"}

# GOOD
@dataclass(frozen=True)
class User:
    name: str
    email: str
```

## Async

- Use `asyncio` for I/O-bound concurrent operations. Don't use threads for HTTP calls.
- Never call blocking I/O inside an async function without `asyncio.to_thread()`.
- Use `async with` and `async for` for async context managers and iterators.
- Use `asyncio.gather()` for concurrent tasks, `asyncio.TaskGroup()` (3.11+) for structured concurrency.

## Testing

- Use `pytest` with descriptive test names: `test_rejects_empty_email`.
- Use `pytest.fixture` for shared setup, not `setUp`/`tearDown`.
- Use `pytest.mark.parametrize` for table-driven tests.
- Mock external dependencies with `unittest.mock.patch`, but prefer dependency injection where possible.

## Project Structure

- One concern per module. Don't put models, views, and utilities in the same file.
- Use `__init__.py` to define public API. Import what should be public, leave internals private.
- Keep `__init__.py` minimal — don't put logic in it.
- Use `pyproject.toml` for project configuration (not `setup.py` or `setup.cfg`).
