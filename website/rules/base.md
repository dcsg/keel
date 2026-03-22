# Base Rules

Base rules apply to all files in your project. Four are enabled by default; six are opt-in.

## code-quality

Guards against the most common Claude mistakes: hallucinating APIs, leaving placeholder code, drifting from established codebase patterns, introducing race conditions, ignoring edge cases, and over-engineering.

Key rules:
- NEVER use an API without verifying it exists in the codebase or library — don't hallucinate method signatures
- NEVER leave placeholder code (`// TODO`, `// implement this`, fake returns) in non-draft files
- Match the patterns already established in the codebase — don't introduce a new style in one file
- Consider race conditions for any shared state or concurrent access
- Functions under 40 lines, files under 300 lines
- No `utils/`, `helpers/`, or `common/` packages — use domain-specific names

## testing

Catches tautological tests (tests that can't fail), behavior-focused testing, and mock discipline.

Key rules:
- NEVER write a test that always passes — every test must be capable of failing
- Test behavior, not implementation details
- Mock at architectural boundaries only — not every function
- Test names describe the scenario: `TestOrderService_Cancel_RefundsPayment`

## security

Owns timing attack prevention, error exposure rules, and input validation across all packs. These concerns are centralized here to avoid duplication with api.md and error-handling.md.

Key rules:
- Use constant-time comparison for secrets and tokens — never early-exit string comparison
- Never expose internal error details to API consumers — log internally, return a generic message
- Validate and sanitize all external input at the entry point
- Never interpolate user input into queries — always parameterize
- Never log secrets, tokens, or PII
- Explicit authorization check before any data access

## error-handling

Typed/structured errors, context enrichment, no silent catches. Error exposure rules live in security.md.

Key rules:
- Use typed errors, not string matching
- Wrap errors with context at each layer boundary
- Never silently swallow errors with empty catch blocks
- Validate at system boundaries (HTTP, CLI, queue consumers) — not deep in business logic

## api _(opt-in)_

Consistent API design: error format, HTTP methods, status codes, pagination, versioning, and response shapes. Input validation and error exposure rules are owned by security.md — api.md handles design conventions only.

Key rules:
- One error format across the entire API: `{ "error": "Human message", "code": "MACHINE_CODE" }`
- Paginate all list endpoints — never return an unbounded list
- Version the API from day one: `/api/v1/`
- HTTP methods are semantic: GET is idempotent, POST creates, PUT/PATCH modifies, DELETE removes

## database _(opt-in)_

Safe database access, migrations, and query patterns — parameterization, transaction boundaries, index hygiene, and safe schema changes.

Key rules:
- Never use string concatenation to construct SQL — always parameterize
- Never drop a column in the same deployment as the code change that removes it
- Wrap multi-table writes in a transaction
- Add indexes on foreign keys, WHERE columns, and ORDER BY columns

## observability _(opt-in)_

Structured logging, request tracing, metrics, and health reporting — so production systems are diagnosable without a debugger.

Key rules:
- Never log sensitive data: passwords, tokens, API keys, or PII
- Always use structured logging (JSON or key-value) — unstructured logs can't be queried
- Propagate a request ID through the entire call chain
- Emit a health check endpoint (`/health` or `/healthz`)

## seo _(opt-in)_

Technical SEO: metadata, structured data, Core Web Vitals, and semantic markup for HTML and web-rendered pages. Owns alt text rules across all packs — frontend.md defers to seo.md on image accessibility.

Key rules:
- Every page needs a unique `<title>` (50-60 chars) and `<meta name="description">` (120-160 chars)
- Never render the same content at multiple URLs without a canonical tag
- Use one `<h1>` per page with sequential heading hierarchy
- Add `alt` text to every meaningful image

## frontend _(opt-in)_

Component patterns, accessibility, state management, performance. Alt text is owned by seo.md; handler separation is owned by code-quality.md.

Key rules:
- Components do one thing — separate display from data fetching
- Every interactive element has an accessible label
- Derive state from a single source of truth
- No premature optimization — measure before memoizing

## architecture _(opt-in)_

Layer boundary correctness and import discipline. If you use [archway](https://github.com/dcsg/archway) for architecture enforcement, skip this pack — archway handles the full architecture layer and keel defers to it.

Key rules:
- Domain layer has zero infrastructure imports
- Each bounded context owns its data — no cross-context direct DB access
- Use domain events for side effects that cross context boundaries
- Repository interface in domain, implementation in infrastructure
