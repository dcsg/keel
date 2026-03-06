#!/bin/bash
# Creates a temp Go project for the keel demo recording.
# Run this BEFORE `vhs docs/demo/demo.tape`.
#
# Usage: eval $(./docs/demo/setup-demo-project.sh)
#
# This outputs the DEMO_DIR path. The demo.tape env.tape sources it.

set -e

DEMO_DIR=$(mktemp -d)

cd "$DEMO_DIR"
git init -q
mkdir -p internal/users internal/auth

cat > go.mod << 'EOF'
module github.com/demo/invoicer

go 1.22
EOF

cat > main.go << 'EOF'
package main

import "fmt"

func main() {
	fmt.Println("invoicer")
}
EOF

cat > internal/users/user.go << 'EOF'
package users

type User struct {
	ID    string
	Email string
}
EOF

git add -A && git commit -q -m "init: go project scaffold"

echo "$DEMO_DIR"
