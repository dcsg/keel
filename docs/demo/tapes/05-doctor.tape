# Flow 5: Health check — /keel:doctor
#
# Story: Developer wants to verify their governance setup is complete
#         and correctly wired after init or migration.
#
# Usage: ./docs/demo/record.sh 05-doctor
# Setup: setup-established-project.sh

Output docs/demo/output/05-doctor.gif
Output docs/demo/output/05-doctor.mp4

Source docs/demo/shared.tape
Source docs/demo/env.tape

# Launch Claude Code
Type "claude"
Enter
Wait+Screen@30s />/

Sleep 1

# Run the health check
Type "/keel:doctor"
Enter
Wait+Screen@60s /keel:doctor/
Wait+Screen@120s />/

Sleep 5

Type "/exit"
Enter
Sleep 1
