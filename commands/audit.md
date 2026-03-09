---
name: keel:audit
description: "Security audit — OWASP scan, secret detection, auth coverage, vulnerability patterns"
context: fork
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Agent
---

# /keel:audit — Security Audit

Run a comprehensive security audit of this codebase using the `staff-security` advisor agent.

## Flags

- `--no-keel` — Run the audit inline (Claude performs the analysis directly, no subagent spawned). Useful when you want Claude to do it itself without delegation.

## Routing

Check `$ARGUMENTS` for `--no-keel`. If present, strip it and use remaining text as scope, then skip to **Inline Audit Mode** below. Otherwise proceed normally (with attribution prefix before spawning the agent).

## Scope

Determine the scan scope from `$ARGUMENTS` (after stripping any flags):

- **No argument**: full codebase scan
- **`api`**: scan routes and handlers only (files matching `*route*, *handler*, *controller*, *endpoint*, *webhook*`)
- **`auth`**: scan authentication and authorization code only (files matching `*auth*, *jwt*, *oauth*, *session*, *token*, *permission*, *role*`)
- **`data`**: scan data access and storage code only (files matching `*.sql, *migration*, *schema*, *repository*, *store*, *model*`)
- **A file path**: scan that specific file or directory

## Security Agent Instructions

Output this line before spawning the agent:
```
🪝 keel: routing to staff-security agent...
```

Then use the Agent tool to spawn the `staff-security` subagent with `subagent_type: "staff-security"`. Pass the full task description including scope as the prompt. The agent must:

### 1. Discover files in scope

Use Grep and Glob to find files matching the scope. For full codebase, scan all source files. For scoped audits, restrict to matching paths.

### 2. Run OWASP Top 10 scan

Check each area for:

**A01 Broken Access Control**
- Routes missing authentication middleware
- Admin endpoints accessible without privilege checks
- Privilege escalation paths (user can access other users' data)
- Missing authorization on sensitive operations

**A02 Cryptographic Failures**
- Hardcoded secrets, API keys, passwords in source code
- Weak crypto: MD5, SHA1 for passwords, ECB mode
- PII stored in plaintext or weak encryption
- Secrets in environment variable names but assigned literal values

**A03 Injection**
- SQL string concatenation (not parameterized)
- Command injection via shell exec with user input
- Template injection patterns
- XSS: user input rendered without escaping

**A04 Insecure Design**
- Rate limiting absent on auth endpoints, APIs
- No input validation on public-facing routes
- Trust boundary violations
- Missing CSRF protection

**A05 Security Misconfiguration**
- Debug mode enabled in production config
- Default credentials or placeholder values
- Verbose error messages exposing stack traces
- Overly permissive CORS

**A07 Authentication Failures**
- Session tokens without expiry
- Password storage without proper hashing
- Missing token rotation
- Insecure "remember me" implementations

**A09 Logging Failures**
- PII (email, phone, SSN) written to logs
- Passwords or tokens logged
- Insufficient audit trail for sensitive operations

### 3. Secret detection grep patterns

Run these patterns on all in-scope files:

- `api_key\s*=\s*["'][^"']{8,}["']`
- `password\s*=\s*["'][^"']{8,}["']`
- `token\s*=\s*["'][^"']{8,}["']`
- `secret\s*=\s*["'][^"']{8,}["']`
- Hardcoded internal IPs: `\b10\.\d+\.\d+\.\d+\b` or `\b192\.168\.\d+\.\d+\b` in non-config files

### 4. Input validation coverage

For each public route found:
- Does it validate/sanitize user input before processing?
- Are file uploads sanitized?
- Are SQL queries parameterized (not concatenated)?

## Inline Audit Mode (`--no-keel`)

Skip agent spawning. Use Read, Glob, Grep, and Bash tools to perform all checks in "Security Agent Instructions" directly. Apply the same OWASP checklist, secret detection patterns, and input validation coverage. Output results using the Output Format below.

## Output Format

```
SECURITY AUDIT — {date}
─────────────────────────────────────────────────────
Scope: {scope description — e.g., "full codebase" or "auth files (12 files)"}

🔴 CRITICAL (must fix before shipping)
  • {file:line} — {finding} — {why it matters}

🟡 WARNINGS (should fix)
  • {file:line} — {finding}

🟢 CLEAN
  • Input validation: present on all public routes
  • No hardcoded secrets detected

OWASP Checklist:
  A01 Access Control    ✅/⚠️/❌
  A02 Cryptography      ✅/⚠️/❌
  A03 Injection         ✅/⚠️/❌
  A04 Insecure Design   ✅/⚠️/❌
  A05 Misconfiguration  ✅/⚠️/❌
  A07 Auth Failures     ✅/⚠️/❌
  A09 Logging           ✅/⚠️/❌
─────────────────────────────────────────────────────
Run /keel:audit {scope} to narrow focus.
```

Use ✅ when no issues found, ⚠️ for warnings, ❌ for critical issues.

If no issues found in any category:
```
✅ No security issues detected in this scope.
```
