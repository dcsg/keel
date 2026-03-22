# /keel:docs

Review documentation gaps — surfaces new routes, env vars, CLI flags, and services that may need docs.

## Usage

```
/keel:docs                  ← show pending doc gaps
/keel:docs audit            ← full sweep with fixes
/keel:docs audit api        ← API routes vs API docs only
/keel:docs audit readme     ← env vars, install steps, deps vs README
/keel:docs audit infra      ← docker-compose, k8s, queues vs infra docs
```

## Arguments

| Argument | Description |
|----------|-------------|
| (none) | Scan recent changes for public surface changes without doc updates |
| `audit` | Walk through each gap interactively and draft missing doc sections |
| `audit api` | Scope to API routes and handlers vs API docs only |
| `audit readme` | Scope to env vars, install steps, and service deps vs README |
| `audit infra` | Scope to docker-compose, k8s, and queues vs infrastructure docs |

## What it does

Compares recent code changes against existing documentation to find public surfaces that haven't been documented. It does not write docs for you — it tells you what's missing so you can decide what to capture.

## What it detects

- **New HTTP routes or API endpoints** — added handlers not in API docs
- **New environment variables or config keys** — referenced in code but not in README or config docs
- **New CLI flags or commands** — added to a CLI tool without documentation
- **New infrastructure components** — Docker services, queues, cron jobs, external dependencies

## What it ignores

- Internal refactors, bug fixes, test changes, renames, formatting
- Private or internal functions with no public surface

## Proactive suggestions

The `Stop` hook watches every Claude response for doc gap signals. When a new route, env var, or service is added, Claude ends its response with:

```
📄 Doc gap: POST /webhooks/retry — new endpoint. Run `/keel:docs` to review.
```

The pre-push git hook also scans for undocumented public surfaces before every push and warns (never blocks).

## Disable

```bash
KEEL_DOCS_SKIP=1 git push          # skip for one push
```

Or permanently in `.keel/config.yaml`:
```yaml
hooks:
  pre-push: false
```

## Natural language triggers

- "any doc gaps?"
- "what needs documentation?"
- "check docs"
