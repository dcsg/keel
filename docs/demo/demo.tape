# Keel Workflow Demo — Automated VHS Recording
#
# Usage:  vhs docs/demo/demo.tape
# Prereq: ./docs/demo/setup-demo-project.sh (creates temp project)
#
# Produces:
#   docs/demo/keel-workflow.gif
#   docs/demo/keel-workflow.mp4

Output docs/demo/keel-workflow.gif
Output docs/demo/keel-workflow.mp4

Set Shell "bash"
Set FontFamily "MesloLGS Nerd Font Mono"
Set FontSize 13
Set Width 1200
Set Height 700
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 50ms
Set CursorBlink false

# Start in the demo project
Source docs/demo/env.tape

# Show project structure
Type "ls -la"
Enter
Sleep 2

Type "cat go.mod"
Enter
Sleep 2

# Launch Claude Code
Type "claude"
Enter
Wait+Screen@30s />/

Sleep 1

# ── Step 1: /keel:init ──
Type "/keel:init"
Enter
Wait+Screen@120s /keel:init/
Wait+Screen@120s />/

Sleep 3

# ── Step 2: /keel:plan ──
Type "/keel:plan"
Enter
Wait+Screen@120s /keel:plan/
Wait+Screen@120s />/

Sleep 3

# ── Step 3: /keel:status ──
Type "/keel:status"
Enter
Wait+Screen@60s /keel:status/
Wait+Screen@120s />/

Sleep 3

# Exit
Type "/exit"
Enter
Sleep 2
