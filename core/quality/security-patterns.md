# Security Patterns to Detect

## OWASP Top 10 — Static Analysis Patterns

### A01: Broken Access Control
- Missing authentication middleware on protected routes
- Direct object references without ownership checks
- Missing CORS configuration

### A02: Cryptographic Failures
- Hardcoded secrets, API keys, passwords
- Use of weak hashing (MD5, SHA1 for passwords)
- Missing HTTPS enforcement

### A03: Injection
- SQL: String concatenation in queries instead of parameterized queries
- NoSQL: Unvalidated user input in MongoDB queries
- Command: exec/spawn with user-controlled input
- XSS: innerHTML, dangerouslySetInnerHTML with unsanitized input

### A04: Insecure Design
- Missing rate limiting on authentication endpoints
- No account lockout after failed attempts
- Missing input validation on all user inputs

### A05: Security Misconfiguration
- Debug mode enabled in production config
- Default credentials in configuration
- Verbose error messages exposing internals
- Missing security headers (CSP, X-Frame-Options, etc.)

### A06: Vulnerable Components
- Dependencies with known CVEs
- Outdated framework versions
- Unlocked dependency versions (no lockfile)

### A07: Authentication Failures
- Weak password requirements
- Missing multi-factor authentication support
- JWT without expiration
- Session tokens in URLs

### A08: Data Integrity Failures
- Missing input validation
- Deserializing untrusted data
- No integrity checks on downloaded resources

### A09: Logging Failures
- Sensitive data in logs (passwords, tokens, PII)
- Missing audit logging for security events
- No log rotation or retention policy

### A10: SSRF
- Unvalidated URLs in server-side requests
- Missing allowlist for external service calls
