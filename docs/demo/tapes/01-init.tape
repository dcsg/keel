# Flow 1: First-time setup — /keel:init on a bare project
#
# Story: Developer has a Go project, no keel. Runs init to get
#         guardrails, rules, and soul installed in one shot.
#
# Usage: ./docs/demo/record.sh 01-init
# Setup: setup-demo-project.sh (bare Go project)

Output docs/demo/output/01-init.gif
Output docs/demo/output/01-init.mp4

Source docs/demo/shared.tape
Source docs/demo/env.tape

# Show the bare project
Type "tree -L 2 --dirsfirst"
Enter
Sleep 2

Type "cat go.mod"
Enter
Sleep 2

# Launch Claude Code
Type "claude --dangerously-skip-permissions"
Enter
Wait+Screen@30s /Type to talk/

Sleep 1

# Run keel:init — the core onboarding command
Type "/keel:init"
Enter
Wait+Screen@120s /keel:init/

# Wait for init to complete (creates config, soul, rules, hooks)
Wait+Screen@180s /Type to talk/

Sleep 3

# Show what was created
Type "/exit"
Enter
Sleep 2

Type "tree -L 2 --dirsfirst"
Enter
Sleep 3

Type "cat docs/soul.md"
Enter
Sleep 3

Type "ls .claude/rules/"
Enter
Sleep 2
