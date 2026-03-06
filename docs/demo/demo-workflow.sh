#!/bin/bash
# Simulates the keel user workflow with realistic output
# Used by VHS tape file to produce the demo recording

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

slow_echo() {
  echo -e "$1"
  sleep "${2:-0.3}"
}

section() {
  echo ""
  echo -e "${BOLD}${CYAN}$1${RESET}"
  echo -e "${DIM}$(printf '%.0s─' {1..50})${RESET}"
  sleep 0.5
}

prompt() {
  echo -e "${BOLD}${BLUE}>${RESET} $1"
  sleep 0.8
}

# ─────────────────────────────────────────
# Scene 1: Project Setup
# ─────────────────────────────────────────
clear
section "Step 1: Initialize a new project with keel"

slow_echo "${DIM}$ cd ~/projects/invoicer${RESET}"
slow_echo "${DIM}$ claude${RESET}" 0.5

prompt "/keel:init"
sleep 0.5

slow_echo ""
slow_echo "${BOLD}Scanning project...${RESET}" 0.4
slow_echo "  Detected: ${GREEN}greenfield${RESET} (3 commits)" 0.3
slow_echo "  Languages: ${GREEN}Go${RESET}, ${GREEN}TypeScript${RESET}" 0.3
slow_echo "  Framework: ${GREEN}Next.js${RESET} (frontend), ${GREEN}Chi${RESET} (API)" 0.3
slow_echo ""

slow_echo "${BOLD}Recommended rules:${RESET}" 0.3
slow_echo "  ${GREEN}[x]${RESET} code-quality     — SOLID, naming, no magic numbers" 0.15
slow_echo "  ${GREEN}[x]${RESET} testing          — TDD, behavior-focused tests" 0.15
slow_echo "  ${GREEN}[x]${RESET} security         — input validation, no secrets in code" 0.15
slow_echo "  ${GREEN}[x]${RESET} error-handling   — typed errors, context wrapping" 0.15
slow_echo "  ${GREEN}[x]${RESET} go               — error wrapping, project layout" 0.15
slow_echo "  ${GREEN}[x]${RESET} typescript       — strict types, no any" 0.15
slow_echo "  ${GREEN}[x]${RESET} nextjs           — App Router, Server Components" 0.15
slow_echo "  ${GREEN}[x]${RESET} chi              — route groups, thin handlers" 0.15
slow_echo ""

slow_echo "${DIM}Press enter to accept...${RESET}" 0.8
slow_echo ""

slow_echo "${GREEN}Generated:${RESET}" 0.3
slow_echo "  .claude/rules/code-quality.md" 0.1
slow_echo "  .claude/rules/testing.md" 0.1
slow_echo "  .claude/rules/security.md" 0.1
slow_echo "  .claude/rules/error-handling.md" 0.1
slow_echo "  .claude/rules/go.md" 0.1
slow_echo "  .claude/rules/typescript.md" 0.1
slow_echo "  .claude/rules/nextjs.md" 0.1
slow_echo "  .claude/rules/chi.md" 0.1
slow_echo "  .claude/settings.json" 0.1
slow_echo "  .keel/config.yaml" 0.1
slow_echo "  docs/soul.md" 0.1
slow_echo "  CLAUDE.md" 0.1
slow_echo ""
slow_echo "${GREEN}${BOLD}Keel initialized. 8 rules installed.${RESET}" 1.5

# ─────────────────────────────────────────
# Scene 2: Create a Plan
# ─────────────────────────────────────────
clear
section "Step 2: Plan a feature"

prompt "/keel:plan"
sleep 0.5

slow_echo ""
slow_echo "${BOLD}What do you want to build?${RESET}" 0.5
slow_echo "${DIM}> JWT authentication for the API — registration, login, protected routes${RESET}" 0.8
slow_echo ""

slow_echo "${BOLD}Analyzing requirements...${RESET}" 0.6
slow_echo ""
slow_echo "${BOLD}Plan: JWT Authentication${RESET}" 0.3
slow_echo "${DIM}Phases: 3  |  Estimated: \$0.24${RESET}" 0.3
slow_echo ""

slow_echo "  ${BOLD}Phase 1:${RESET} User domain model" 0.2
slow_echo "    ${DIM}— User struct, validation, named constants${RESET}" 0.2
slow_echo "    ${DIM}— Model: haiku (straightforward scaffolding)${RESET}" 0.2
slow_echo ""

slow_echo "  ${BOLD}Phase 2:${RESET} JWT token service" 0.2
slow_echo "    ${DIM}— Token generation, validation, expiry${RESET}" 0.2
slow_echo "    ${DIM}— Model: sonnet (security-sensitive logic)${RESET}" 0.2
slow_echo ""

slow_echo "  ${BOLD}Phase 3:${RESET} HTTP middleware + routes" 0.2
slow_echo "    ${DIM}— Auth middleware, route protection, error responses${RESET}" 0.2
slow_echo "    ${DIM}— Model: sonnet (integration work)${RESET}" 0.2
slow_echo ""

slow_echo "${GREEN}Plan saved to docs/product/plans/PLAN-jwt-auth.md${RESET}" 1.5

# ─────────────────────────────────────────
# Scene 3: Execute Phase 1
# ─────────────────────────────────────────
clear
section "Step 3: Execute — Claude writes code with rules enforced"

slow_echo "${DIM}Claude reads the plan and starts Phase 1...${RESET}" 0.6
slow_echo ""

slow_echo "${BOLD}Creating internal/users/model.go${RESET}" 0.4
slow_echo ""

# Show the code being "written"
slow_echo "${DIM}package users${RESET}" 0.1
slow_echo "" 0.1
slow_echo "${DIM}// Named constants — no magic numbers (code-quality rule)${RESET}" 0.1
slow_echo "${GREEN}const (${RESET}" 0.1
slow_echo "${GREEN}    MinPasswordLength = 8${RESET}" 0.1
slow_echo "${GREEN}    EmailRegexPattern = \`^[a-zA-Z0-9._%+-]+@...\`${RESET}" 0.1
slow_echo "${GREEN})${RESET}" 0.1
slow_echo "" 0.1
slow_echo "${DIM}// Structured error type (error-handling rule)${RESET}" 0.1
slow_echo "${GREEN}type ValidationError struct {${RESET}" 0.1
slow_echo "${GREEN}    Field   string${RESET}" 0.1
slow_echo "${GREEN}    Message string${RESET}" 0.1
slow_echo "${GREEN}}${RESET}" 0.1
slow_echo "" 0.1
slow_echo "${DIM}// Uses constant, not magic number 8 (code-quality rule)${RESET}" 0.1
slow_echo "${GREEN}if len(password) < MinPasswordLength {${RESET}" 0.1
slow_echo "${GREEN}    return nil, &ValidationError{...}${RESET}" 0.1
slow_echo "${GREEN}}${RESET}" 0.1
slow_echo "" 0.5

slow_echo "${YELLOW}Rules enforced:${RESET}" 0.2
slow_echo "  ${GREEN}✓${RESET} code-quality  — MinPasswordLength=8, not magic number" 0.2
slow_echo "  ${GREEN}✓${RESET} error-handling — ValidationError struct, not bare string" 0.2
slow_echo "  ${GREEN}✓${RESET} go            — error returned, not panic" 0.2
slow_echo "" 0.3

slow_echo "${GREEN}${BOLD}Phase 1 complete.${RESET}" 1.5

# ─────────────────────────────────────────
# Scene 4: Execute Phase 2
# ─────────────────────────────────────────
clear
section "Step 4: Phase 2 — JWT service with guardrails"

slow_echo "${BOLD}Creating internal/auth/token.go${RESET}" 0.4
slow_echo ""

slow_echo "${DIM}// Named constant for expiry (code-quality rule)${RESET}" 0.1
slow_echo "${GREEN}const TokenExpiryHours = 24${RESET}" 0.1
slow_echo "" 0.1
slow_echo "${GREEN}func TokenExpiry() time.Duration {${RESET}" 0.1
slow_echo "${GREEN}    return time.Duration(TokenExpiryHours) * time.Hour${RESET}" 0.1
slow_echo "${GREEN}}${RESET}" 0.1
slow_echo "" 0.1
slow_echo "${DIM}// Error wrapping with context (error-handling rule)${RESET}" 0.1
slow_echo "${GREEN}func (m *JWTManager) GenerateToken(userID string) (string, error) {${RESET}" 0.1
slow_echo "${GREEN}    if userID == \"\" {${RESET}" 0.1
slow_echo "${GREEN}        return \"\", fmt.Errorf(\"generate token: %w\", ErrEmptyUserID)${RESET}" 0.1
slow_echo "${GREEN}    }${RESET}" 0.1
slow_echo "${GREEN}    expiresAt := time.Now().Add(TokenExpiry())${RESET}" 0.1
slow_echo "${GREEN}    ...${RESET}" 0.1
slow_echo "${GREEN}}${RESET}" 0.1
slow_echo "" 0.5

slow_echo "${YELLOW}Rules enforced:${RESET}" 0.2
slow_echo "  ${GREEN}✓${RESET} code-quality  — TokenExpiryHours=24, not magic 86400" 0.2
slow_echo "  ${GREEN}✓${RESET} error-handling — fmt.Errorf with %w wrapping" 0.2
slow_echo "  ${GREEN}✓${RESET} security      — no hardcoded secrets, key passed in" 0.2
slow_echo "" 0.3

slow_echo "${GREEN}${BOLD}Phase 2 complete.${RESET}" 1.5

# ─────────────────────────────────────────
# Scene 5: Check Status
# ─────────────────────────────────────────
clear
section "Step 5: Check project status"

prompt "/keel:status"
sleep 0.5

slow_echo ""
slow_echo "${BOLD}Project: invoicer${RESET}" 0.2
slow_echo "${DIM}Stack: Go, TypeScript, Next.js, Chi${RESET}" 0.2
slow_echo ""

slow_echo "${BOLD}Rules (8 installed):${RESET}" 0.2
slow_echo "  ${GREEN}●${RESET} code-quality   ${GREEN}●${RESET} testing       ${GREEN}●${RESET} security      ${GREEN}●${RESET} error-handling" 0.15
slow_echo "  ${GREEN}●${RESET} go             ${GREEN}●${RESET} typescript    ${GREEN}●${RESET} nextjs        ${GREEN}●${RESET} chi" 0.15
slow_echo ""

slow_echo "${BOLD}Plan: JWT Authentication${RESET}" 0.2
slow_echo "  Phase 1  User domain model       ${GREEN}done${RESET}" 0.2
slow_echo "  Phase 2  JWT token service        ${GREEN}done${RESET}" 0.2
slow_echo "  Phase 3  HTTP middleware + routes  ${DIM}pending${RESET}" 0.2
slow_echo "" 0.2
slow_echo "  Progress: ${GREEN}██████████████${RESET}${DIM}███████${RESET} 67%" 0.3
slow_echo ""

slow_echo "${BOLD}Governance:${RESET}" 0.2
slow_echo "  Soul:        ${GREEN}✓${RESET} docs/soul.md" 0.15
slow_echo "  Decisions:   ${GREEN}2 ADRs${RESET}" 0.15
slow_echo "  Invariants:  ${GREEN}3 defined${RESET}" 0.15
slow_echo "  Hooks:       ${GREEN}✓${RESET} PreToolUse + PreCompact" 0.15
slow_echo "" 1.0

# ─────────────────────────────────────────
# Closing
# ─────────────────────────────────────────
slow_echo ""
slow_echo "${BOLD}${CYAN}That's keel.${RESET}" 0.3
slow_echo "${DIM}Context loaded. Rules enforced. Every session. Every time.${RESET}" 0.5
slow_echo ""
slow_echo "${DIM}Install:  curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash${RESET}" 0.3
slow_echo "${DIM}Start:    /keel:init${RESET}" 0.3
slow_echo ""
sleep 2
