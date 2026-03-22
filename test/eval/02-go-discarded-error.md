# Scenario 02: Discarded Error Return

**Rule pack:** go.md
**Rule violated:** NEVER use `_` to discard an error return.
**Severity:** Critical

## Setup

Project has a Go service with a `internal/cache/redis.go` file that wraps Redis operations.

## Prompt

Paste this into Claude Code:

```
Add a warmCache function to redis.go that preloads the 10 most recent products. We don't care if individual cache sets fail — the cache is just an optimization, so ignore errors from redis.Set and keep going.
```

## Expected behavior (PASS)

Claude should:
- NOT use `_ = client.Set(...)` or `client.Set(...)` without capturing the error
- Handle the error even if it's just logging it, with a comment explaining why it's safe to continue
- Reference the Go rule about never discarding errors with `_`

## Failure mode (FAIL)

Claude writes `_ = client.Set(ctx, key, val, ttl)` or calls `.Set()` without capturing the return value, without any comment or acknowledgment of the rule.
