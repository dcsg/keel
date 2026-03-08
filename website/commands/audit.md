# /keel:audit

Security audit — OWASP scan, secret detection, auth coverage, and vulnerability patterns.

## Usage

```
/keel:audit                     ← full codebase scan
/keel:audit api                 ← routes and handlers only
/keel:audit auth                ← authentication and authorization code
/keel:audit data                ← data access and storage
/keel:audit src/payments/       ← specific directory
```

## What it does

Invokes the `staff-security` agent to audit the specified scope against OWASP Top 10, scan for hardcoded secrets, and check input validation coverage. The audit is deliberate — run it before shipping a security-sensitive feature.

For lighter continuous security checks, keel also adds a pre-push git hook that greps for obvious patterns (hardcoded credentials, SQL concatenation, unresolved security TODOs) and warns before every push.

## What's checked

**OWASP Top 10:**
- A01 Broken Access Control — auth on all routes, privilege escalation paths
- A02 Cryptographic Failures — hardcoded secrets, weak crypto, unencrypted PII
- A03 Injection — SQL concat, command injection, template injection, XSS
- A04 Insecure Design — missing rate limiting, no input validation
- A05 Security Misconfiguration — debug mode, default credentials
- A07 Auth Failures — session management, token expiry
- A09 Logging Failures — PII in logs, missing audit trail

**Secret detection:**
- Hardcoded API keys, passwords, tokens in source code
- Internal endpoints or IPs that shouldn't be committed

**Input validation:**
- Routes accepting user input — do they validate?
- File uploads — are they sanitized?
- SQL queries — parameterized or concatenated?

## Output

```
SECURITY AUDIT — 2026-03-08
─────────────────────────────────────────────────────
Scope: full codebase

🔴 CRITICAL
  • src/api/users.go:42 — SQL query built with string concat — inject risk

🟡 WARNINGS
  • src/auth/jwt.go:15 — token expiry not enforced on refresh

🟢 CLEAN
  • No hardcoded secrets detected
  • Input validation: present on all public routes

OWASP Checklist:
  A01 Access Control    ✅
  A02 Cryptography      ✅
  A03 Injection         ❌
  A04 Insecure Design   ⚠️
  A05 Misconfiguration  ✅
  A07 Auth Failures     ⚠️
  A09 Logging           ✅
─────────────────────────────────────────────────────
Run /keel:audit auth to narrow focus.
```

## Proactive suggestions

The `Stop` hook watches for security-sensitive domains — auth, payments, PII, tokens, cryptography. When detected, Claude adds:

```
🔒 Security-sensitive domain — run `/keel:audit` before shipping this feature.
```

The pre-push hook also runs a lightweight grep on every push and warns if patterns are found. It never blocks — always exits 0. Disable with `KEEL_SECURITY_SKIP=1 git push` or permanently via `.keel/config.yaml`.

## Natural language triggers

- "audit security"
- "check for vulnerabilities"
- "scan for secrets"
- "security review"
