# Flow 6: Onboarding existing docs — /keel:intake
#
# Story: Developer has a project with scattered docs (ADRs in docs/adr/,
#         specs in random places). Uses intake to organize into keel structure.
#
# Usage: ./docs/demo/record.sh 06-intake
# Setup: setup-messy-project.sh (project with scattered docs)

Output docs/demo/output/06-intake.gif
Output docs/demo/output/06-intake.mp4

Source docs/demo/shared.tape
Source docs/demo/env.tape

# Show the messy doc structure
Type "find . -name '*.md' | head -20"
Enter
Sleep 2

# Launch Claude Code
Type "claude --dangerously-skip-permissions"
Enter
Wait+Screen@30s />/

Sleep 1

# Run intake to organize
Type "/keel:intake"
Enter
Wait+Screen@120s /keel:intake/

# Wait for scan + categorization + user prompts
Wait+Screen@300s />/

Sleep 4

Type "/exit"
Enter
Sleep 2

# Show the organized structure
Type "tree docs/ -L 2 --dirsfirst"
Enter
Sleep 3
