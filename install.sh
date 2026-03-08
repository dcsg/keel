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
mkdir -p "${CLAUDE_COMMANDS}/dof"

# Download keel commands (/keel:init, /keel:context, etc.)
KEEL_COMMANDS=(init context plan status intake doctor rules-update adr invariant prd)
info "Installing keel commands..."
for cmd in "${KEEL_COMMANDS[@]}"; do
  curl -fsSL "${BASE_URL}/commands/${cmd}.md" -o "${CLAUDE_COMMANDS}/keel/${cmd}.md"
  dim "keel:${cmd}"
done

# Download dof commands (/dof:migrate, etc.)
DOF_COMMANDS=(migrate)
info "Installing dof commands..."
for cmd in "${DOF_COMMANDS[@]}"; do
  curl -fsSL "${BASE_URL}/commands/dof/${cmd}.md" -o "${CLAUDE_COMMANDS}/dof/${cmd}.md"
  dim "dof:${cmd}"
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
for agent in reviewer debugger; do
  curl -fsSL "${BASE_URL}/templates/agents/${agent}.md" -o "${KEEL_HOME}/templates/agents/${agent}.md"
  dim "agents/${agent}"
done

# SDLC templates
for sdlc in pull_request_template commit-convention; do
  curl -fsSL "${BASE_URL}/templates/sdlc/${sdlc}.md" -o "${KEEL_HOME}/templates/sdlc/${sdlc}.md"
  dim "sdlc/${sdlc}"
done

echo
echo -e "${GREEN}${BOLD}Keel installed.${RESET}"
echo
echo "  Commands:  ${CLAUDE_COMMANDS}/keel/ and ${CLAUDE_COMMANDS}/dof/"
echo "  Templates: ${KEEL_HOME}/templates/"
echo
echo "  Open any project in Claude Code and run:"
echo -e "  ${BOLD}/keel:init${RESET}"
echo
