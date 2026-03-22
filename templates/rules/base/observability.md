---
paths: "**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change logs at wrong levels, exposes sensitive data, or breaks structured log format.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Observability

Rules for structured logging, request tracing, metrics, and health reporting.

## Critical

- NEVER use unstructured log strings for application logs — use structured logging (JSON or key-value pairs). Unstructured logs can't be queried, aggregated, or alerted on reliably.
- MUST propagate a request ID through the entire call chain. Every log line, span, and error for a given request must carry the same ID so the full trace is reconstructable.

## Standards

- Use log levels by intent: `ERROR` for failures requiring immediate attention, `WARN` for unexpected but handled conditions, `INFO` for significant business events, `DEBUG` for development troubleshooting. Don't use ERROR for expected failures (e.g., 404s).
- Log the request ID, user ID (if authenticated), and operation name on every significant log line. A log line without context is noise.
- Include the original error in all error log entries: `{ "error": err.message, "stack": err.stack }`. Logging only a human message loses the original failure context.
- Emit a health check endpoint (`GET /health` or `/healthz`) that returns 200 when the service is ready to serve traffic. Distinguish liveness (is the process alive) from readiness (is it ready to take requests).
- Use metric names that follow a consistent convention: `{service}_{component}_{measure}_{unit}` (e.g., `api_orders_request_duration_seconds`). Inconsistent metric names make dashboards unmaintainable.

## Practices

- Use `DEBUG` level for verbose data during development. Never leave `DEBUG`-level logging enabled in production — it produces too much volume and may log data that shouldn't be retained.
- Measure what matters: request latency (p50, p95, p99), error rate, and saturation (queue depth, connection pool usage). These three cover the vast majority of production incidents.
- Instrument background jobs and async tasks the same way as HTTP requests: start time, duration, success/failure, and a correlation ID linking back to the originating request where possible.
- Use distributed tracing spans for operations that cross service boundaries. Name spans as `{verb} {noun}`: `process order`, `fetch user`, `send email`.
- Log at application start: service version, environment, and key configuration (without secrets). This is the fastest way to confirm a deployment succeeded and what version is running.

## Critical

- NEVER log PII or sensitive data.
- MUST propagate request ID through the entire call chain.
