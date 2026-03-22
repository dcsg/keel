---
paths: "**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt,sql}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change includes unsafe migrations, missing indexes, or N+1 query patterns.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Database

Rules for safe database access, migrations, and query patterns.

## Critical

- NEVER use string concatenation or interpolation to construct SQL queries — use parameterized queries or the ORM's query builder. String-concatenated queries are SQL injection vulnerabilities.
- NEVER drop a column or table in the same deployment as the code that stops using it. Deploy the code change first, verify it's stable, then drop the column in a follow-up migration.
- NEVER run a migration that adds a non-nullable column without a default to a table with existing rows — it locks the table and fails in production.

## Standards

- Use migrations for ALL schema changes. Never alter a production database manually. Migrations are the only source of truth for schema history.
- Wrap operations that modify multiple tables in a transaction. Partial writes that leave the database in an inconsistent state are harder to recover from than a failed transaction.
- Add indexes on all foreign key columns, columns used in WHERE clauses, and columns used in ORDER BY. Missing FK indexes cause full table scans on every join.
- Use UTC for all timestamps. Never store timestamps in local time — timezone-aware comparisons and sorting require UTC at the storage layer.
- Name indexes explicitly: `idx_{table}_{columns}` (e.g., `idx_orders_user_id_status`). Auto-generated names are unreadable in query plans.

## Practices

- Use `EXPLAIN` / `EXPLAIN ANALYZE` on queries that touch large tables before shipping. A query that works fine in development can be a full table scan in production.
- Separate data migrations from schema migrations — run schema changes first, data backfills separately. This limits downtime and makes rollback cleaner.
- Foreign key constraints are not optional. Referential integrity enforced at the database level catches bugs that application code misses.
- Prefer `SERIAL` or `UUID` for primary keys. If using UUIDs, prefer UUIDv7 (time-ordered) over UUIDv4 — random UUIDs fragment B-tree indexes and degrade insert performance.
- Avoid `SELECT *` in application code. Selecting specific columns reduces data transfer and makes schema changes less likely to break existing queries silently.

## Critical

- NEVER construct SQL with string concatenation.
- NEVER drop a column in the same deployment as the code change that removes it.
