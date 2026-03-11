# Gate 4: Pre-Deploy Rules

## Purpose
Final comprehensive quality gate before any deployment. Non-negotiable.

## Checks
1. **Full test suite:** Unit + integration + E2E tests must all pass
2. **Test coverage:** Must meet minimum threshold (default 80%, configured in stack.json)
3. **SAST security scan:** Static analysis for OWASP Top 10 patterns
   - SQL injection (string concatenation in queries)
   - XSS (dangerouslySetInnerHTML, innerHTML)
   - eval() usage
   - Command injection (exec, spawn with user input)
   - Path traversal (unchecked file paths)
4. **Secret scanning:** Comprehensive scan across ALL files
5. **TODO/FIXME/HACK:** None allowed in any file
6. **Dependency audit:** No known vulnerabilities in production dependencies
7. **License check:** All production dependencies use approved licenses
8. **API documentation:** All endpoints must be documented

## Enforcement
- Triggered manually at Phase 5 to Phase 6 transition
- Script: `.claude/hooks/pre-deploy.sh`
- BLOCKS deployment if ANY check fails
- Max 3 fix attempts per failure, then escalate to user

## False Positive Handling
If a security finding is a false positive:
1. Agent-X explains why at checkpoint
2. User approves suppression
3. Logged in `.agent-x/security-exceptions.md` with: finding, reason, approver, date, review-by date
4. Suppressions re-evaluated at each deploy
