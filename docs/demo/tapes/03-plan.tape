# Flow 3: Creating an execution plan — /keel:plan
#
# Story: Developer has a new feature to build. Uses keel:plan to
#         break it into phases with model assignments and cost estimates.
#
# Usage: ./docs/demo/record.sh 03-plan
# Setup: setup-established-project.sh

Output docs/demo/output/03-plan.gif
Output docs/demo/output/03-plan.mp4

Source docs/demo/shared.tape
Source docs/demo/env.tape

# Launch Claude Code
Type "claude --dangerously-skip-permissions"
Enter
Wait+Screen@30s />/

Sleep 1

# Create a plan for a new feature
Type "/keel:plan add webhook notifications for task status changes"
Enter
Wait+Screen@120s /keel:plan/

# Wait for the interview + plan generation
Wait+Screen@300s />/

Sleep 4

# Check status to see the new plan
Type "/keel:status"
Enter
Wait+Screen@60s /keel:status/
Wait+Screen@120s />/

Sleep 4

Type "/exit"
Enter
Sleep 1
