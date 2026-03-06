#!/bin/bash
# Creates a temp project with scattered docs for the intake demo.
# Simulates a real project where docs are everywhere.
#
# Usage: DEMO_DIR=$(bash docs/demo/setup-messy-project.sh)

set -e

KEEL_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEMO_DIR="${1:-$(mktemp -d)}"
mkdir -p "$DEMO_DIR"

cd "$DEMO_DIR"
git init -q

# --- Project files ---
mkdir -p src cmd

cat > go.mod << 'EOF'
module github.com/acme/payments

go 1.22
EOF

cat > cmd/server/main.go << 'EOF'
package main

import "fmt"

func main() {
	fmt.Println("payments service")
}
EOF

# --- Scattered docs (the mess keel:intake will organize) ---
mkdir -p docs/adr docs/specs notes .dof/architecture/decisions .dof/architecture/invariants

# ADRs in non-standard location
cat > docs/adr/001-use-stripe.md << 'MD'
# Use Stripe for Payment Processing
We chose Stripe over Braintree for better developer experience and webhook support.
MD

cat > docs/adr/002-event-sourcing.md << 'MD'
# Event Sourcing for Transactions
All payment state changes are stored as events. Current state is derived from the event log.
MD

# Specs in wrong place
cat > docs/specs/payments-api.md << 'MD'
# Payments API Spec
REST API for processing payments, refunds, and subscription management.
MD

cat > docs/specs/requirements.md << 'MD'
# PRD: Payment Processing
Accept credit cards, handle refunds, manage subscriptions. PCI DSS compliance required.
MD

# Random notes with plan-like content
cat > notes/build-order.md << 'MD'
# Build Order
1. Domain models (Payment, Refund, Subscription)
2. Stripe adapter
3. API endpoints
4. Webhook handler
5. Integration tests
MD

cat > notes/progress.md << 'MD'
# Progress
- [x] Domain models
- [x] Stripe adapter
- [ ] API endpoints
- [ ] Webhook handler
- [ ] Integration tests
MD

# Legacy .dof content
cat > .dof/architecture/decisions/ADR-003-idempotency.md << 'MD'
# ADR-003: Idempotency Keys
All payment operations require an idempotency key to prevent double-charges.
MD

cat > .dof/architecture/invariants/INV-001-no-floats.md << 'MD'
# INV-001: No Floating Point for Money
All monetary amounts stored as integer cents. Never use float64 for money.
MD

cat > .dof/config.yaml << 'YAML'
base: docs
stack: [go]
YAML

# README at root
cat > README.md << 'MD'
# Payments Service
Handles payment processing for the Acme platform.

## Stack
- Go 1.22
- PostgreSQL
- Stripe API
MD

# Keel is initialized (needed for intake to run)
mkdir -p .keel
cat > .keel/config.yaml << 'YAML'
base: docs
stack: [go]
rules: {}
sdlc:
  commit-convention: conventional
YAML

# Install minimal rules so intake has something to work with
mkdir -p .claude/rules
cp "$KEEL_ROOT/templates/rules/base/code-quality.md" ".claude/rules/code-quality.md"
cp "$KEEL_ROOT/templates/settings.json.tmpl" ".claude/settings.json"

git add -A && git commit -q -m "init: payments service with scattered docs"

echo "$DEMO_DIR"
