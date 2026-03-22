#!/usr/bin/env bash
# keel: PreToolUse hook (Write|Edit) — warn if project-context.md is missing
# Fires before every file write or edit to ensure keel is properly initialized.

if [ -f '.keel/config.yaml' ] && [ ! -f 'docs/project-context.md' ]; then
  echo '⚠️  Keel: docs/project-context.md not found. Run /keel:init to complete setup.'
fi
