# Security Workflow

Keel provides security coverage at three points in your workflow: while you build (Stop hook signals), before you push (pre-push hook), and on demand (explicit audit). This guide explains each layer and when to use it.

## The three layers

```
Building → Stop hook flags security domains
Pushing  → Pre-push hook scans for obvious patterns
On demand → /keel:audit for deliberate security passes
```

These layers are complementary — lightweight and continuous early, thorough and deliberate before shipping.

---

## Layer 1 — Stop hook signals (while building)

The `Stop` hook watches every Claude response for security-sensitive domains. When it detects one, Claude ends its response with:

```
🔒 Security-sensitive domain — run `/keel:audit` before shipping this feature.
```

This fires when the response involves: authentication, authorization, payment processing, PII handling, cryptography, token management, or access control.

It's a nudge, not a block. The signal means "this deserves a deliberate security review before it ships" — not that something is necessarily wrong.

---

## Layer 2 — Pre-push hook (before every push)

The pre-push git hook runs a lightweight grep scan on every `git push`. It checks the diff for:

- **Hardcoded secrets** — API keys, passwords, tokens assigned in code
- **SQL string concatenation** — potential injection vectors
- **Unresolved security TODOs** — `TODO: validate`, `TODO: sanitize`, etc.

If patterns are found, it warns before the push completes:

```
🔒 keel: security patterns detected (2):
   • api_key = "sk-..." — src/config.go
   • TODO: validate input — src/api/users.go

   Run /keel:audit to review. Pushing anyway.
   To skip: KEEL_SECURITY_SKIP=1 git push
```

**It never blocks.** Always exits 0. You decide whether to fix before pushing.

### Disable for one push

```bash
KEEL_SECURITY_SKIP=1 git push
```

### Disable permanently

```yaml
# .keel/config.yaml
hooks:
  pre-push-security: false
```

---

## Layer 3 — /keel:audit (deliberate security pass)

For features that touch security-sensitive domains, run a full audit before shipping:

```
/keel:audit              ← full codebase
/keel:audit api          ← routes and handlers only
/keel:audit auth         ← authentication and authorization code
/keel:audit src/payments/ ← specific directory
```

This invokes the `staff-security` agent for a thorough review:

**OWASP Top 10 coverage:**
- A01 Broken Access Control
- A02 Cryptographic Failures
- A03 Injection (SQL, command, template, XSS)
- A04 Insecure Design
- A05 Security Misconfiguration
- A07 Authentication Failures
- A09 Logging Failures (PII in logs)

**Plus:**
- Hardcoded secret detection
- Input validation coverage
- File upload sanitization
- SQL parameterization check

**Output:**
```
SECURITY AUDIT — 2026-03-08
─────────────────────────────────────────────────────
Scope: src/payments/

🔴 CRITICAL
  • src/payments/handler.go:47 — SQL built with string concat — injection risk

🟡 WARNINGS
  • src/payments/webhook.go:23 — no HMAC signature validation on incoming webhook

🟢 CLEAN
  • No hardcoded secrets detected
  • Input validation present on all public routes

OWASP Checklist:
  A01 Access Control    ✅
  A02 Cryptography      ✅
  A03 Injection         ❌
  A04 Insecure Design   ⚠️
  A05 Misconfiguration  ✅
  A07 Auth Failures     ✅
  A09 Logging           ✅
─────────────────────────────────────────────────────
```

---

## When to run what

| Situation | Action |
|-----------|--------|
| Building auth, payments, or PII features | Watch for 🔒 Stop hook signals |
| Before every push | Pre-push hook runs automatically |
| Finishing a security-sensitive feature | `/keel:audit auth` or `/keel:audit api` |
| Full security review before release | `/keel:audit` (full codebase) |
| Post-implementation review of any feature | `/keel:review` (includes security domain if relevant files changed) |

---

## Pre-flight security review in plans

When you run `/keel:plan` and the plan mentions auth, payments, tokens, RBAC, or similar, the `staff-security` agent automatically reviews the plan before execution:

```
STAFF SECURITY
  🟡  JWT secret storage not specified — clarify storage mechanism in phase 2
  🟢  Auth middleware scoping looks correct
```

Catching security issues in the plan is far cheaper than catching them in code review.

---

## The staff-security agent

All security checks in keel route through the `staff-security` specialist agent. You can invoke it directly for anything security-related — threat modeling, reviewing a specific pattern, checking a library's security posture:

```
Ask staff-security to review our OAuth implementation
```

The agent is installed automatically on projects where the soul.md description mentions payments, auth, HIPAA, PCI, compliance, or security.
