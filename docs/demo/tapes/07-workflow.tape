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
Type "claude"
Enter
Wait+Screen@30s />/

Sleep 1

# ── Step 1: Initialize keel ──
Type "/keel:init"
Enter
Wait+Screen@120s /keel:init/
Wait+Screen@180s />/

Sleep 3

# ── Step 2: Create a plan ──
Type "/keel:plan build user authentication with JWT"
Enter
Wait+Screen@120s /keel:plan/
Wait+Screen@300s />/

Sleep 3

# ── Step 3: Check status ──
Type "/keel:status"
Enter
Wait+Screen@60s /keel:status/
Wait+Screen@120s />/

Sleep 3

# ── Step 4: Load context and start working ──
Type "/keel:context"
Enter
Wait+Screen@120s /keel:context/
Wait+Screen@180s />/

Sleep 3

Type "/exit"
Enter
Sleep 2
