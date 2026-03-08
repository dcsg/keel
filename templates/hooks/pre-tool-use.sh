#!/usr/bin/env bash
# keel: PreToolUse hook (Write|Edit) — warn if soul.md is missing
# Fires before every file write or edit to ensure keel is properly initialized.

if [ -f '.keel/config.yaml' ] && [ ! -f 'docs/soul.md' ]; then
  echo '⚠️  Keel: docs/soul.md not found. Run /keel:init to complete setup.'
fi
