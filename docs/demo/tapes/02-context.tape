# Flow 2: Loading context — /keel:context
#
# Story: Developer starts a session on an established project.
#         Loads context to understand what exists before coding.
#
# Usage: ./docs/demo/record.sh 02-context
# Setup: setup-established-project.sh

Output docs/demo/output/02-context.gif
Output docs/demo/output/02-context.mp4

Source docs/demo/shared.tape
Source docs/demo/env.tape

# Show the project has keel set up
Type "ls docs/"
Enter
Sleep 2

# Launch Claude Code
Type "claude --dangerously-skip-permissions"
Enter
Wait+Screen@60s /bypass permissions/

Sleep 1

# Load full context — shows soul, decisions, invariants, rules
Type "/keel:context"
Enter
Wait+Screen@120s /keel:context/
Wait+Screen@1800s /bypass permissions/

Sleep 4

Type "/exit"
Enter
Sleep 1
