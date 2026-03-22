---
paths: "**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change silently swallows errors, loses context, or mixes error strategies.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Error Handling

Rules for handling errors consistently and safely across all layers.

## Critical

- NEVER silently swallow errors. Every catch/except/recover block MUST do one of: handle the error (retry, fallback, user message), propagate with added context, or log with sufficient context for debugging. Empty catch blocks are never acceptable.

## Standards

- When propagating errors, wrap with context describing what operation failed: `failed to process order %s: %w`. The goal is that someone reading the log can trace the failure without opening the code.
- Define specific error types for different failure categories: `ValidationError`, `NotFoundError`, `AuthorizationError`. Don't throw generic exceptions for known failure modes — callers need to differentiate.
- Detect errors as early as possible. Check preconditions at function entry, return immediately if they fail. Don't let invalid state propagate through layers.
- External-facing errors: clear, actionable, no internal details. Internal errors (logs): full context, stack trace, correlation ID.

## Practices

- Reserve panic/crash for truly unrecoverable states (corrupted data, violated invariants). Return errors for recoverable failures — not found, validation failed, permission denied.
- If an empty catch block is genuinely correct, add a comment explaining why — the next reader will assume it's a bug.

## Critical

- NEVER silently swallow errors — every catch block must handle, propagate, or log.
