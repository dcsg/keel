---
paths: "**/*.py"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change uses raw SQL without parameterization, skips migrations, or bypasses ORM conventions.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Django

Rules for building Django applications.

## Critical

- NEVER query inside a loop — it creates N+1 queries that scale linearly with result set size. Use `select_related()` for FK/OneToOne joins and `prefetch_related()` for ManyToMany and reverse FK.
- NEVER set `DEBUG = True` in production. It exposes source code, local variables, and settings in error pages.
- NEVER validate manually in views — use Django forms or DRF serializers. Manual validation is inconsistent and bypasses reuse.

## Standards

- Each app owns one domain concept. Minimize imports between apps — communicate through service functions, Django signals, or shared interfaces. Never import models from another app's internals.
- Define all constraints in the model: validators, `unique`, `null`, `blank`, `default`, `choices`. Add `__str__` to every model. Use `Meta` for ordering and composite indexes.
- Use `F()` expressions for database-level field operations — don't fetch, modify in Python, and save back when the database can do it atomically.
- Always call `form.is_valid()` or `serializer.is_valid(raise_exception=True)` before accessing `.cleaned_data` or `.validated_data`.
- Async tasks (Celery) MUST be idempotent. Set `max_retries` and `default_retry_delay`. Use `acks_late=True` with `reject_on_worker_lost=True`. Never send email synchronously in views.

## Practices

- Use `.only()` or `.defer()` to limit fields on large querysets. Use `.values()` or `.values_list()` when you don't need full model instances.
- Use `Q()` objects for complex OR/AND filters. Use model managers for reusable queryset logic.
- Migrations must be backwards-compatible in production: no column drops without a deprecation period, no non-nullable column adds without a default. Data migrations go in separate files from schema migrations.

## Critical

- NEVER query inside a loop — use `select_related()` or `prefetch_related()`.
- NEVER set `DEBUG = True` in production.
