# Flow 2: Loading context — /keel:context at different depths
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
Wait+Screen@30s />/

Sleep 1

# Full context — loads everything
Type "/keel:context"
Enter
Wait+Screen@120s /keel:context/
Wait+Screen@180s />/

Sleep 4

# Focused context — only branch-relevant ADRs
Type "/keel:context --depth=focused"
Enter
Wait+Screen@120s /depth: focused/
Wait+Screen@180s />/

Sleep 4

# Minimal context — soul + phase + invariants only
Type "/keel:context --depth=minimal"
Enter
Wait+Screen@120s /depth: minimal/
Wait+Screen@180s />/

Sleep 3

Type "/exit"
Enter
Sleep 1
