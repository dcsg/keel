---
paths: "**/*.rb"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change bypasses Active Record conventions, skips strong parameters, or misuses callbacks.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Ruby on Rails

Rules for building Rails applications.

## Critical

- NEVER use `params.permit!` — it permits all parameters and bypasses strong parameter protection entirely. Always enumerate permitted params explicitly.
- NEVER use `raw` or `html_safe` on user-provided content — Rails escapes output by default, using these overrides re-opens XSS vulnerabilities.
- NEVER store plaintext passwords. Use `has_secure_password` or Devise. Never roll your own password hashing.

## Standards

- Eager load associations to avoid N+1 queries: `includes(:orders)`, `preload(:items)`. Never lazy-load in loops. Use the Bullet gem in development to detect N+1s automatically.
- Stick to RESTful actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`. If you need non-REST actions, extract a new resource.
- Define validations in models, not controllers. Use scopes for reusable query logic.
- Migrations MUST be reversible. Define both `up`/`down` or use `change` with reversible methods. Use `null: false` and defaults where appropriate. Add foreign key constraints.

## Practices

- Jobs MUST be idempotent. Set `retry_on` and `discard_on` for error handling. Use `deliver_later` for all emails — never `deliver_now` in a controller action.
- Use `credentials.yml.enc` for secrets. Never commit unencrypted secrets. Access via `Rails.application.credentials.key`.

## Critical

- NEVER use `params.permit!`.
- NEVER use `raw` or `html_safe` on user-provided content.
