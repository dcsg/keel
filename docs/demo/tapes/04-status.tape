# Flow 4: Project dashboard — /keel:status
#
# Story: Developer checks project health at a glance — active plan
#         progress, installed rules, governance completeness.
#
# Usage: ./docs/demo/record.sh 04-status
# Setup: setup-established-project.sh

Output docs/demo/output/04-status.gif
Output docs/demo/output/04-status.mp4

Source docs/demo/shared.tape
Source docs/demo/env.tape

# Launch Claude Code
Type "claude --dangerously-skip-permissions"
Enter
Wait+Screen@30s /Type to talk/

Sleep 1

# Show the dashboard
Type "/keel:status"
Enter
Wait+Screen@60s /keel:status/
Wait+Screen@120s /Type to talk/

Sleep 5

Type "/exit"
Enter
Sleep 1
