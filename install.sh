#!/usr/bin/env bash
set -euo pipefail

# Keel installer
# Usage: curl -fsSL https://raw.githubusercontent.com/dcsg/keel/main/install.sh | bash

REPO="dcsg/keel"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

KEEL_HOME="${HOME}/.keel"
CLAUDE_COMMANDS="${HOME}/.claude/commands"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

info()  { echo -e "${GREEN}>${RESET} $1"; }
dim()   { echo -e "${DIM}  $1${RESET}"; }
error() { echo -e "${RED}error:${RESET} $1" >&2; exit 1; }

# Check dependencies
command -v curl >/dev/null 2>&1 || error "curl is required"
command -v git >/dev/null 2>&1  || error "git is required"

echo -e "${BOLD}Installing keel...${RESET}"
echo

# Create directories
mkdir -p "${KEEL_HOME}/templates/rules/base"
mkdir -p "${KEEL_HOME}/templates/rules/lang"
mkdir -p "${KEEL_HOME}/templates/rules/framework"
mkdir -p "${KEEL_HOME}/templates/agents"
mkdir -p "${KEEL_HOME}/templates/sdlc"
mkdir -p "${CLAUDE_COMMANDS}/keel"

# Download keel commands (/keel:init, /keel:context, etc.)
KEEL_COMMANDS=(init context plan status intake doctor rules-update upgrade adr invariant prd agents mcp team docs sync audit review session)
info "Installing keel commands..."
for cmd in "${KEEL_COMMANDS[@]}"; do
  curl -fsSL "${BASE_URL}/commands/${cmd}.md" -o "${CLAUDE_COMMANDS}/keel/${cmd}.md"
  dim "keel:${cmd}"
done

# Download rule templates
info "Installing rule templates..."

# Registry
curl -fsSL "${BASE_URL}/templates/rules/_registry.yaml" -o "${KEEL_HOME}/templates/rules/_registry.yaml"

# Base rules
for rule in code-quality testing security error-handling frontend architecture; do
  curl -fsSL "${BASE_URL}/templates/rules/base/${rule}.md" -o "${KEEL_HOME}/templates/rules/base/${rule}.md"
  dim "base/${rule}"
done

# Language rules
for rule in go typescript python php; do
  curl -fsSL "${BASE_URL}/templates/rules/lang/${rule}.md" -o "${KEEL_HOME}/templates/rules/lang/${rule}.md"
  dim "lang/${rule}"
done

# Framework rules
for rule in chi nextjs laravel symfony rails django; do
  curl -fsSL "${BASE_URL}/templates/rules/framework/${rule}.md" -o "${KEEL_HOME}/templates/rules/framework/${rule}.md"
  dim "framework/${rule}"
done

# Download supporting templates
info "Installing templates..."
for tmpl in CLAUDE.md.tmpl soul.md.tmpl product-spec.md.tmpl prd.md.tmpl settings.json.tmpl; do
  curl -fsSL "${BASE_URL}/templates/${tmpl}" -o "${KEEL_HOME}/templates/${tmpl}"
  dim "${tmpl}"
done

# Agent templates
for agent in reviewer debugger principal-architect staff-engineer senior-backend principal-dba staff-security staff-sre staff-qa staff-frontend principal-ux senior-pm senior-api senior-performance principal-data staff-docs; do
  curl -fsSL "${BASE_URL}/templates/agents/${agent}.md" -o "${KEEL_HOME}/templates/agents/${agent}.md"
  dim "agents/${agent}"
done
curl -fsSL "${BASE_URL}/templates/agents/_registry.yaml" -o "${KEEL_HOME}/templates/agents/_registry.yaml"
dim "agents/_registry.yaml"

# Hook scripts (Claude Code hooks + git hooks)
mkdir -p "${KEEL_HOME}/templates/hooks"
mkdir -p "${KEEL_HOME}/hooks"

# Claude Code hook scripts — installed to ~/.keel/hooks/ and referenced from settings.json
for hook in session-start pre-tool-use post-tool-use pre-compact stop-hook; do
  curl -fsSL "${BASE_URL}/templates/hooks/${hook}.sh" -o "${KEEL_HOME}/hooks/${hook}.sh"
  chmod +x "${KEEL_HOME}/hooks/${hook}.sh"
  dim "hooks/${hook}.sh"
done

# Git pre-push hook template
curl -fsSL "${BASE_URL}/templates/hooks/pre-push" -o "${KEEL_HOME}/templates/hooks/pre-push"
chmod +x "${KEEL_HOME}/templates/hooks/pre-push"
dim "hooks/pre-push"

# SDLC templates
for sdlc in pull_request_template commit-convention; do
  curl -fsSL "${BASE_URL}/templates/sdlc/${sdlc}.md" -o "${KEEL_HOME}/templates/sdlc/${sdlc}.md"
  dim "sdlc/${sdlc}"
done

# Version + Changelog
curl -fsSL "${BASE_URL}/VERSION" -o "${KEEL_HOME}/VERSION"
curl -fsSL "${BASE_URL}/CHANGELOG.md" -o "${KEEL_HOME}/CHANGELOG.md"

echo
echo -e "${GREEN}${BOLD}Keel installed.${RESET}"
echo
echo "  Commands:  ${CLAUDE_COMMANDS}/keel/"
echo "  Templates: ${KEEL_HOME}/templates/"
echo
echo "  Open any project in Claude Code and run:"
echo -e "  ${BOLD}/keel:init${RESET}"
echo
