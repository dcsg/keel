# Flow 7: Full workflow — init → plan → execute → status
#
# Story: End-to-end demo. New project, zero to governed in one session.
#         This is the hero video for README / landing page.
#
# Usage: ./docs/demo/record.sh 07-workflow
# Setup: setup-demo-project.sh (bare Go project)

Output docs/demo/output/07-workflow.gif
Output docs/demo/output/07-workflow.mp4

Source docs/demo/shared.tape
Source docs/demo/env.tape

# Show the bare project
Type "tree --dirsfirst"
Enter
Sleep 2

# Launch Claude Code
Type "claude --dangerously-skip-permissions"
Enter
Wait+Screen@60s /bypass permissions/

Sleep 1

# ── Step 1: Initialize keel ──
Type "/keel:init"
Enter
Wait+Screen@120s /keel:init/
Wait+Screen@1800s /bypass permissions/

Sleep 3

# ── Step 2: Check governance status ──
Type "/keel:status"
Enter
Wait+Screen@120s /keel:status/
Wait+Screen@300s /bypass permissions/

Sleep 3

# ── Step 3: Load context before writing code ──
Type "/keel:context --depth=minimal"
Enter
Wait+Screen@120s /keel:context/
Wait+Screen@1800s /bypass permissions/

Sleep 3

Type "/exit"
Enter
Sleep 2
