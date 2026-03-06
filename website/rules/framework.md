# Framework Rules

Framework rules apply to framework-specific file patterns and extend the language rules.

## chi

Scope: `**/*.go` (Go projects using Chi)

Key rules:
- Group related routes with `r.Route()` — one router per domain context
- Middleware at the right level — auth at group level, logging at root
- Handlers are thin — extract business logic to service layer
- Use `r.Context()` for request-scoped values, typed keys only

## nextjs

Scope: `**/*.ts`, `**/*.tsx` (Next.js App Router projects)

Key rules:
- Prefer Server Components — only use `"use client"` when you need browser APIs or interactivity
- Data fetching in Server Components, not `useEffect`
- Use Server Actions for mutations — not separate API routes for simple cases
- Always export `generateMetadata` for pages with dynamic content

## laravel

Scope: `**/*.php` (Laravel projects)

Key rules:
- Form Requests for validation — never validate in controllers
- Eloquent relationships declared explicitly with return types
- Jobs for anything that can be async — no synchronous email sending in requests
- Events + Listeners for cross-domain side effects

## symfony

Scope: `**/*.php` (Symfony projects)

Key rules:
- Constructor injection only — no service locator pattern
- Doctrine entities are plain PHP — no framework annotations in domain
- Messenger for async — Commands and Queries as message classes
- Security voters for authorization — no manual role checks in controllers

## rails

Scope: `**/*.rb` (Rails projects)

Key rules:
- Fat models, skinny controllers — but extract complex logic to service objects
- ActiveRecord callbacks only for data integrity — not side effects
- Background jobs for async work — never `Net::HTTP` in a request cycle
- RSpec with `describe`/`context`/`it` — behavior-driven naming

## django

Scope: `**/*.py` (Django projects)

Key rules:
- Business logic in service functions or model methods — not in views
- `select_related` and `prefetch_related` to avoid N+1 queries
- Django signals only for cross-app concerns — not within the same app
- Celery tasks for async work — never blocking calls in views
