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
Wait+Screen@60s /bypass permissions/

Sleep 1

# Create a plan — keel asks a few questions then generates phases
Type "/keel:plan add webhook notifications for task status changes"
Enter
Wait+Screen@120s /keel:plan/

# Answer the interview: confirm defaults / skip details
Wait+Screen@60s /question/
Type "no feature flag, postgres outbox pattern, ship all in one PR"
Enter

# Wait for plan generation to finish
Wait+Screen@1800s /bypass permissions/

Sleep 4

# Check status to see the new plan
Type "/keel:status"
Enter
Wait+Screen@120s /keel:status/
Wait+Screen@300s /bypass permissions/

Sleep 4

Type "/exit"
Enter
Sleep 1
