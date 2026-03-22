---
paths: "**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt,sql}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change exposes secrets, accepts unsanitized input, or weakens authentication.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Security

Rules for writing secure code. Security is not optional — these apply to every change.

## Critical

- NEVER log: passwords, tokens, API keys, credit card numbers, SSNs, or health information — even in debug mode.
- NEVER commit: `.env` files, private keys, service account credentials, or any file containing secrets.
- NEVER hardcode secrets, API keys, connection strings, or passwords in source code. Use environment variables or a secret manager.
- NEVER use string concatenation or interpolation to construct SQL queries — use parameterized queries exclusively.
- NEVER use equality operators (==, ===, .equals()) to compare secrets, password hashes, HMAC digests, or authentication tokens — use constant-time comparison: crypto/subtle.ConstantTimeCompare (Go), crypto.timingSafeEqual (Node.js), hmac.compare_digest (Python), hash_equals (PHP).

## Standards

- Validate ALL external input at system boundaries: HTTP handlers, CLI parsers, message consumers, webhook handlers. Trust nothing from outside the process boundary.
- Internal calls between trusted modules do NOT need re-validation. Validate once, at the boundary.
- Check authorization BEFORE accessing or modifying any resource — not after loading it. Verify the authenticated user has permission for the SPECIFIC resource, not just the resource type.
- Never rely on client-side authorization checks alone. Always enforce on the server.
- Never expose internal error details to API clients: no stack traces, no SQL errors, no internal file paths.
- Set security headers: CORS, CSP, HSTS, `X-Content-Type-Options`. Use HTTPS for all external communication.
- Rate-limit authentication endpoints and expensive operations.

## Practices

- If you suspect a secret was logged or committed, treat it as compromised — rotate immediately, then investigate.
- Validate file types by content (magic bytes), not by extension. Validate file size. Never use user-provided filenames directly in file paths.
- Use the principle of least privilege: grant the minimum permissions needed for the operation.
- Review new dependencies before adding them: check maintenance status and known CVEs. Prefer packages with active security response.

## Critical

- NEVER log sensitive data: passwords, tokens, keys, PII.
- NEVER use string concatenation to construct SQL.
- NEVER hardcode secrets in source code.
