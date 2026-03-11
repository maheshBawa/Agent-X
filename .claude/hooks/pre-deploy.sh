#!/usr/bin/env bash
# Gate 4: PRE-DEPLOY — Final quality gate before deployment
# Triggered manually at Phase 5 → Phase 6 transition
set -euo pipefail

# Resolve project root from the hook's own location (hooks live at <project>/.claude/hooks/)
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$HOOK_DIR/../.." && pwd)"
if [ ! -d "$PROJECT_ROOT/.agent-x" ] && [ ! -f "$PROJECT_ROOT/package.json" ]; then
  PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
STACK_DECISION="$PROJECT_ROOT/.agent-x/stack-decision.md"
ERRORS=""
WARNINGS=""

echo "============================================"
echo "  AGENT-X GATE 4: PRE-DEPLOY VERIFICATION"
echo "============================================"

# Check 1: Test coverage
echo "[1/8] Checking test coverage..."
if [ -f "$PROJECT_ROOT/package.json" ]; then
  if grep -qE '"test:coverage"|"coverage"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
    npm run test:coverage --silent 2>/dev/null || ERRORS="$ERRORS\nTest coverage check failed."
  fi
elif command -v pytest &>/dev/null; then
  pytest --cov --cov-fail-under=80 --quiet 2>/dev/null || ERRORS="$ERRORS\nTest coverage below 80%."
fi

# Check 2: Secret scanning (comprehensive, multi-pattern)
echo "[2/8] Scanning for secrets..."
SQ="'"
ASSIGN_PATTERN="(password|secret|api_key|apikey|token|private_key|db_pass|auth_token|aws_access|aws_secret|STRIPE|OPENAI|GITHUB_TOKEN|DATABASE_URL|MONGODB_URI)[[:space:]]*=[[:space:]]*[\"${SQ}][^\"${SQ}]{4,}"
JSON_PATTERN="(\"password\"|\"secret\"|\"api_key\"|\"token\"|\"private_key\"|\"db_pass\")[[:space:]]*:[[:space:]]*\"[^\"]{4,}\""
CONN_PATTERN="(postgresql|mongodb|mysql|redis|amqp)://[^:]+:[^@]+@"
while IFS= read -r file; do
  if [ -f "$file" ]; then
    case "$file" in
      *.md|*.lock|node_modules/*|.git/*) continue ;;
    esac
    S1=$(grep -nEi "$ASSIGN_PATTERN" "$file" 2>/dev/null || true)
    S2=$(grep -nEi "$JSON_PATTERN" "$file" 2>/dev/null || true)
    S3=$(grep -nEi "$CONN_PATTERN" "$file" 2>/dev/null || true)
    FOUND="${S1}${S2}${S3}"
    if [ -n "$FOUND" ]; then
      ERRORS="$ERRORS\nSecrets in $file:\n$FOUND"
    fi
  fi
done < <(git ls-files 2>/dev/null)

# Check 3: TODO/FIXME/HACK scan
echo "[3/8] Scanning for TODO/FIXME/HACK..."
while IFS= read -r file; do
  if [ -f "$file" ]; then
    case "$file" in
      *.md|*.lock|node_modules/*|.git/*) continue ;;
    esac
    TODOS=$(grep -nEi '\b(TODO|FIXME|HACK|XXX)\b' "$file" 2>/dev/null || true)
    if [ -n "$TODOS" ]; then
      ERRORS="$ERRORS\nTODO/FIXME in $file:\n$TODOS"
    fi
  fi
done < <(git ls-files 2>/dev/null)

# Check 4: .env files not in .gitignore
echo "[4/8] Checking .env protection..."
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
  if ! grep -q '\.env' "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    WARNINGS="$WARNINGS\n.env not in .gitignore — secrets could be committed."
  fi
fi

# Check 5: Dependency vulnerability scan
echo "[5/8] Scanning dependencies..."
if [ -f "$PROJECT_ROOT/package.json" ]; then
  npm audit --production 2>/dev/null || WARNINGS="$WARNINGS\nnpm audit found vulnerabilities."
elif [ -f "$PROJECT_ROOT/requirements.txt" ]; then
  if command -v pip-audit &>/dev/null; then
    pip-audit -r "$PROJECT_ROOT/requirements.txt" 2>/dev/null || WARNINGS="$WARNINGS\npip-audit found vulnerabilities."
  fi
fi

# Check 6: Common security anti-patterns in code (expanded OWASP coverage)
echo "[6/8] SAST scanning for security patterns..."
while IFS= read -r file; do
  if [ -f "$file" ]; then
    # A03: SQL injection patterns
    SQL_INJECT=$(grep -nE "(query|execute)[[:space:]]*\([[:space:]]*[\`\"${SQ}].*\\\$\{|\.query[[:space:]]*\([[:space:]]*[\`\"${SQ}].*\+" "$file" 2>/dev/null || true)
    if [ -n "$SQL_INJECT" ]; then
      ERRORS="$ERRORS\n[A03] Potential SQL injection in $file:\n$SQL_INJECT"
    fi

    # A03: XSS patterns (dangerouslySetInnerHTML, innerHTML)
    XSS=$(grep -nE '(dangerouslySetInnerHTML|innerHTML[[:space:]]*=)' "$file" 2>/dev/null || true)
    if [ -n "$XSS" ]; then
      WARNINGS="$WARNINGS\n[A03] Potential XSS in $file:\n$XSS"
    fi

    # A03: eval() usage
    EVAL=$(grep -nE '\beval[[:space:]]*\(' "$file" 2>/dev/null || true)
    if [ -n "$EVAL" ]; then
      ERRORS="$ERRORS\n[A03] eval() usage in $file (security risk):\n$EVAL"
    fi

    # A02: Weak cryptography (MD5, SHA1 for security purposes)
    WEAK_CRYPTO=$(grep -nEi '(md5|sha1)[[:space:]]*\(|createHash\([[:space:]]*["\x27](md5|sha1)' "$file" 2>/dev/null || true)
    if [ -n "$WEAK_CRYPTO" ]; then
      WARNINGS="$WARNINGS\n[A02] Weak cryptography in $file:\n$WEAK_CRYPTO"
    fi

    # A05: Security misconfiguration (CORS wildcard, missing helmet)
    CORS_WILD=$(grep -nE "cors\([[:space:]]*\{[[:space:]]*origin:[[:space:]]*[\"']\\*[\"']" "$file" 2>/dev/null || true)
    if [ -n "$CORS_WILD" ]; then
      WARNINGS="$WARNINGS\n[A05] CORS wildcard origin in $file:\n$CORS_WILD"
    fi

    # A10: SSRF — URL construction from variables
    SSRF=$(grep -nE "(fetch|axios|request|http\.get)\([[:space:]]*\`[^\`]*\\\$\{" "$file" 2>/dev/null || true)
    if [ -n "$SSRF" ]; then
      WARNINGS="$WARNINGS\n[A10] Potential SSRF in $file (URL from variable):\n$SSRF"
    fi
  fi
done < <(git ls-files '*.js' '*.ts' '*.jsx' '*.tsx' '*.py' 2>/dev/null)

# Check 7: License compatibility
echo "[7/8] Checking license compatibility..."
if [ -f "$PROJECT_ROOT/package.json" ] && command -v npx &>/dev/null; then
  npx license-checker --failOn 'GPL-3.0;AGPL-3.0' --production 2>/dev/null || WARNINGS="$WARNINGS\nLicense compatibility issues found."
fi

# Check 8: Full test suite
echo "[8/8] Running full test suite..."
if [ -f "$PROJECT_ROOT/package.json" ]; then
  TEST_SCRIPT=$(sed -n 's/.*"test"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$PROJECT_ROOT/package.json" | head -1)
  if [ -n "$TEST_SCRIPT" ] && ! echo "$TEST_SCRIPT" | grep -q "no test specified"; then
    npm test 2>/dev/null || ERRORS="$ERRORS\nFull test suite failed."
  else
    WARNINGS="$WARNINGS\nNo test script configured in package.json."
  fi
elif [ -d "$PROJECT_ROOT/tests" ] || [ -f "$PROJECT_ROOT/conftest.py" ]; then
  if command -v pytest &>/dev/null; then
    pytest 2>/dev/null || ERRORS="$ERRORS\nFull test suite failed."
  fi
fi

# Final report
echo ""
echo "============================================"
if [ -n "$ERRORS" ]; then
  echo "  GATE 4: FAILED"
  echo "============================================"
  printf '%b\n' "$ERRORS"
  if [ -n "$WARNINGS" ]; then
    echo ""
    echo "Warnings:"
    printf '%b\n' "$WARNINGS"
  fi
  exit 1
else
  if [ -n "$WARNINGS" ]; then
    echo "  GATE 4: PASSED WITH WARNINGS"
    echo "============================================"
    printf '%b\n' "$WARNINGS"
  else
    echo "  GATE 4: PASSED"
    echo "============================================"
  fi
  exit 0
fi
