#!/bin/bash
# Creates a temp project that already has keel initialized.
# Used by demos that show post-init workflows (context, plan, status, doctor).
#
# Usage: DEMO_DIR=$(bash docs/demo/setup-established-project.sh)

set -e

KEEL_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEMO_DIR="${1:-$(mktemp -d)}"
mkdir -p "$DEMO_DIR"

cd "$DEMO_DIR"
git init -q

# --- Project files ---
mkdir -p internal/domain internal/adapters/http internal/adapters/db

cat > go.mod << 'EOF'
module github.com/acme/taskboard

go 1.22

require github.com/go-chi/chi/v5 v5.0.12
EOF

cat > main.go << 'EOF'
package main

import (
	"fmt"
	"net/http"
)

func main() {
	fmt.Println("taskboard starting on :8080")
	http.ListenAndServe(":8080", nil)
}
EOF

cat > internal/domain/task.go << 'EOF'
package domain

type Task struct {
	ID          string
	Title       string
	Status      string
	AssigneeID  string
}

type TaskRepository interface {
	Save(task Task) error
	FindByID(id string) (Task, error)
}
EOF

# --- Keel structure ---
mkdir -p .keel docs/decisions docs/invariants docs/plans docs/product/prds .claude/rules

cat > .keel/config.yaml << 'YAML'
base: docs
stack: [go]
rules:
  code-quality: { include: all }
  testing: { include: all }
  security: { include: all }
  error-handling: { include: all }
  go: { include: all }
  chi: { include: all }
sdlc:
  commit-convention: conventional
plans:
  dir: docs/plans
YAML

cat > docs/soul.md << 'MD'
# TaskBoard

A task management API for small teams.

## Stack
- Go 1.22 with Chi router
- PostgreSQL for persistence
- Hexagonal architecture (domain/adapters/ports)

## Users
- Small dev teams (5-20 people)
- Integrations via REST API

## Key Decisions
- Domain-driven design with clean boundaries
- No ORM — raw SQL via sqlc
- JWT authentication
MD

# Install rule packs from keel templates
for pack in code-quality testing security error-handling; do
    cp "$KEEL_ROOT/templates/rules/base/$pack.md" ".claude/rules/$pack.md"
done
cp "$KEEL_ROOT/templates/rules/lang/go.md" ".claude/rules/go.md"
cp "$KEEL_ROOT/templates/rules/framework/chi.md" ".claude/rules/chi.md"

# Decisions
cat > docs/decisions/001-hexagonal-arch.md << 'MD'
# ADR-001: Hexagonal Architecture
**Status:** Accepted
**Date:** 2026-02-15

## Decision
Use hexagonal (ports & adapters) architecture. Domain logic has zero infrastructure imports.

## Consequences
- Domain package is pure Go stdlib
- All I/O goes through adapter interfaces
- Testing domain logic requires no mocks of external systems
MD

cat > docs/decisions/002-chi-router.md << 'MD'
# ADR-002: Chi Router
**Status:** Accepted
**Date:** 2026-02-15

## Decision
Use go-chi/chi for HTTP routing. Lightweight, stdlib-compatible, middleware-friendly.

## Consequences
- No framework lock-in (handlers are stdlib http.HandlerFunc)
- Middleware chain for auth, logging, recovery
MD

cat > docs/decisions/003-jwt-auth.md << 'MD'
# ADR-003: JWT Authentication
**Status:** Accepted
**Date:** 2026-02-20

## Decision
Stateless JWT tokens for API authentication. Short-lived access tokens (15min) + refresh tokens.

## Consequences
- No server-side session storage needed
- Token revocation requires a deny-list
MD

# Invariants
cat > docs/invariants/INV-001-no-orm.md << 'MD'
# INV-001: No ORM
Raw SQL via sqlc only. No GORM, no Ent, no sqlx magic. Domain types must not leak database concerns.
MD

cat > docs/invariants/INV-002-domain-purity.md << 'MD'
# INV-002: Domain Purity
Domain package imports only stdlib. No HTTP, no SQL, no framework types in the domain layer.
MD

# Active plan
cat > docs/plans/PLAN-001-mvp.md << 'MD'
# Plan: TaskBoard MVP

## Overview
**Total Phases:** 4
**Approach:** Sequential

## Progress

| Phase | Status | Updated |
|-------|--------|---------|
| 1     | done   | 2026-03-01 |
| 2     | done   | 2026-03-03 |
| 3     | in-progress | 2026-03-05 |
| 4     | -      | -       |

## Phase 1: Domain Models
**Objective:** Define Task, User, Board domain types with validation.
**Completion promise:** `DOMAIN MODELS DONE`

## Phase 2: Persistence Layer
**Objective:** PostgreSQL adapter with sqlc queries for all domain types.
**Completion promise:** `PERSISTENCE DONE`

## Phase 3: API Layer
**Objective:** Chi router with CRUD endpoints, JWT middleware, error handling.
**Completion promise:** `API LAYER DONE`

## Phase 4: Integration Tests
**Objective:** End-to-end tests with testcontainers-go for PostgreSQL.
**Completion promise:** `TESTS DONE`
MD

# PRDs
cat > docs/product/prds/PRD-001-task-crud.md << 'MD'
# PRD-001: Task CRUD
Create, read, update, delete tasks. Tasks belong to boards. Validation on title (required, max 200 chars) and status (open/in-progress/done).
MD

cat > docs/product/spec.md << 'MD'
# TaskBoard — Product Spec
Task management for small teams. REST API first, web UI later.

## MVP Scope
- Task CRUD with board assignment
- JWT authentication
- Team membership

## Non-Goals (v1)
- Real-time updates (WebSocket)
- File attachments
- Notifications
MD

# Settings with hooks
cp "$KEEL_ROOT/templates/settings.json.tmpl" ".claude/settings.json"

# CLAUDE.md
cat > CLAUDE.md << 'MD'
# CLAUDE.md

<!-- keel:start -->
## Before Writing Code
1. Read `docs/soul.md` for project context
2. Rules are enforced automatically via `.claude/rules/`
3. If a plan is active, check `docs/plans/` for current phase
<!-- keel:end -->
MD

git add -A && git commit -q -m "init: taskboard project with keel"

echo "$DEMO_DIR"
