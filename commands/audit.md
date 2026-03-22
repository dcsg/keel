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

Run a comprehensive security audit of this codebase using the `security` advisor agent.

CRITICAL: NEVER skip OWASP categories or secret detection patterns — run every check from the Reference section, even if the scope is narrow.

## Instructions

1. Check `$ARGUMENTS` for `--no-keel`. If present, strip it and use remaining text as scope, then jump to step 6 (Inline Audit Mode).

2. Determine scope from `$ARGUMENTS` using the Scope Definitions in the Reference section.

3. Output before spawning agents:
   ```
   🪝 keel: routing to security agent...
   🪝 keel: routing to sre agent...
   ```

4. Spawn TWO agents in parallel via the Agent tool:
   - `security` subagent — OWASP Top 10 scan, secret detection, input validation, auth coverage
   - `sre` subagent — observability gaps, exposed debug endpoints, missing health checks, logging sensitive data, rate limiting, deployment risks

5. Each agent discovers files in scope and runs their domain-specific checks from the Reference section. Both output results using the Output Format.

6. Consolidate findings from both agents into a single report, grouped by domain (Security, Reliability).

7. **Inline Audit Mode (`--no-keel`):** Use Read, Glob, Grep, and Bash tools to perform all checks directly — same checklists from the Reference section for both security and reliability. Output results using the Output Format.

## Reference

### Scope Definitions

- **No argument**: full codebase scan
- **`api`**: scan routes and handlers only (files matching `*route*, *handler*, *controller*, *endpoint*, *webhook*`)
- **`auth`**: scan authentication and authorization code only (files matching `*auth*, *jwt*, *oauth*, *session*, *token*, *permission*, *role*`)
- **`data`**: scan data access and storage code only (files matching `*.sql, *migration*, *schema*, *repository*, *store*, *model*`)
- **A file path**: scan that specific file or directory

### OWASP Top 10 Check Definitions

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

### Secret Detection Grep Patterns

Run these patterns on all in-scope files:

- `api_key\s*=\s*["'][^"']{8,}["']`
- `password\s*=\s*["'][^"']{8,}["']`
- `token\s*=\s*["'][^"']{8,}["']`
- `secret\s*=\s*["'][^"']{8,}["']`
- Hardcoded internal IPs: `\b10\.\d+\.\d+\.\d+\b` or `\b192\.168\.\d+\.\d+\b` in non-config files

### Input Validation Coverage

For each public route found:
- Does it validate/sanitize user input before processing?
- Are file uploads sanitized?
- Are SQL queries parameterized (not concatenated)?

### SRE / Reliability Check Definitions

**Observability Gaps**
- Missing health check endpoint (`/health`, `/healthz`, `/ready`)
- No structured logging (using fmt.Println / console.log instead of structured logger)
- Missing request ID propagation in HTTP middleware
- No metrics endpoint or instrumentation

**Exposed Debug Endpoints**
- Debug/profiling endpoints enabled without auth (`/debug/pprof`, `/debug/vars`)
- Verbose error responses exposing internal details in production config
- Development-only middleware present in production code path

**Logging Risks**
- PII logged without masking (email, phone, SSN in log statements)
- Tokens or secrets logged (access tokens, API keys in log output)
- Log levels too verbose for production (debug/trace level in prod config)

**Deployment Risks**
- Missing graceful shutdown handling
- No readiness/liveness probe configuration
- Missing timeout configuration on HTTP clients/servers
- No circuit breaker on external service calls

**Rate Limiting**
- Public endpoints without rate limiting
- Auth endpoints (login, register, reset) without rate limiting
- No backpressure mechanism on internal APIs

### Output Format

```
AUDIT REPORT — {date}
─────────────────────────────────────────────────────
Scope: {scope description}

SECURITY
🔴 CRITICAL
  • {file:line} — {finding} — {why it matters}

🟡 WARNINGS
  • {file:line} — {finding}

🟢 CLEAN
  • {area}: {status}

OWASP Checklist:
  A01 Access Control    ✅/⚠️/❌
  A02 Cryptography      ✅/⚠️/❌
  A03 Injection         ✅/⚠️/❌
  A04 Insecure Design   ✅/⚠️/❌
  A05 Misconfiguration  ✅/⚠️/❌
  A07 Auth Failures     ✅/⚠️/❌
  A09 Logging           ✅/⚠️/❌

RELIABILITY
🔴 CRITICAL
  • {file:line} — {finding} — {why it matters}

🟡 WARNINGS
  • {file:line} — {finding}

🟢 CLEAN
  • {area}: {status}

Reliability Checklist:
  Health checks         ✅/⚠️/❌
  Observability         ✅/⚠️/❌
  Debug endpoints       ✅/⚠️/❌
  Logging safety        ✅/⚠️/❌
  Graceful shutdown     ✅/⚠️/❌
  Rate limiting         ✅/⚠️/❌
─────────────────────────────────────────────────────
```

Use ✅ when no issues found, ⚠️ for warnings, ❌ for critical issues.

If no issues found:
```
✅ No security or reliability issues detected in this scope.
```
