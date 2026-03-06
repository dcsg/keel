# Keel install demo

Output demo/install.gif
Output demo/install.mp4

Set Shell "zsh"
Set FontSize 14
Set Width 900
Set Height 500
Set Theme "Catppuccin Mocha"
Set Padding 24
Set TypingSpeed 65ms

Hide
Type "PS1='$ ' ; clear"
Enter
Sleep 500ms
Show

Type "curl -fsSL https://raw.githubusercontent.com/danielgomes/keel/main/install.sh | bash"
Sleep 800ms
Enter
Sleep 400ms

Type "echo 'Installing keel...'"
Enter
Sleep 200ms
Type "echo ''"
Enter
Type "echo '> Installing commands...'"
Enter
Sleep 150ms
Type "echo '  init  context  plan  status  intake  migrate'"
Enter
Sleep 400ms
Type "echo '> Installing rule templates...'"
Enter
Sleep 150ms
Type "echo '  base/code-quality  base/testing  base/security  base/error-handling'"
Enter
Sleep 150ms
Type "echo '  lang/go  lang/typescript  lang/python  lang/php'"
Enter
Sleep 150ms
Type "echo '  framework/chi  framework/nextjs  framework/laravel  framework/django'"
Enter
Sleep 300ms
Type "echo '> Installing templates...'"
Enter
Sleep 300ms
Type "echo ''"
Enter
Type "echo 'Keel installed.'"
Enter
Sleep 200ms
Type "echo ''"
Enter
Type "echo '  Commands:  ~/.claude/commands/keel/'"
Enter
Type "echo '  Templates: ~/.keel/templates/'"
Enter
Type "echo ''"
Enter
Type "echo '  Open any project in Claude Code and run /keel:init'"
Enter
Sleep 1200ms

Type "ls ~/.claude/commands/keel/"
Enter
Sleep 1200ms

Type "ls ~/.keel/templates/rules/"
Enter
Sleep 3000ms
