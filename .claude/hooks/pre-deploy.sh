#!/usr/bin/env bash
# Gate 4: PRE-DEPLOY — Final quality gate before deployment
# Triggered manually at Phase 5 → Phase 6 transition
set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
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

# Check 2: Secret scanning (comprehensive)
echo "[2/8] Scanning for secrets..."
SECRET_PATTERNS='(password|secret|api_key|apikey|token|private_key|aws_access|aws_secret|DATABASE_URL|MONGODB_URI)[[:space:]]*=[[:space:]]*["\x27][^"\x27]{8,}'
for file in $(git ls-files 2>/dev/null); do
  if [ -f "$file" ]; then
    case "$file" in
      *.md|*.lock|node_modules/*|.git/*) continue ;;
    esac
    FOUND=$(grep -nEi "$SECRET_PATTERNS" "$file" 2>/dev/null || true)
    if [ -n "$FOUND" ]; then
      ERRORS="$ERRORS\nSecrets in $file:\n$FOUND"
    fi
  fi
done

# Check 3: TODO/FIXME/HACK scan
echo "[3/8] Scanning for TODO/FIXME/HACK..."
for file in $(git ls-files 2>/dev/null); do
  if [ -f "$file" ]; then
    case "$file" in
      *.md|*.lock|node_modules/*|.git/*) continue ;;
    esac
    TODOS=$(grep -nEi '\b(TODO|FIXME|HACK|XXX)\b' "$file" 2>/dev/null || true)
    if [ -n "$TODOS" ]; then
      ERRORS="$ERRORS\nTODO/FIXME in $file:\n$TODOS"
    fi
  fi
done

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

# Check 6: Common security anti-patterns in code
echo "[6/8] SAST scanning for security patterns..."
for file in $(git ls-files '*.js' '*.ts' '*.jsx' '*.tsx' '*.py' 2>/dev/null); do
  if [ -f "$file" ]; then
    # SQL injection patterns
    SQL_INJECT=$(grep -nE '(query|execute)\s*\(\s*[`"\x27].*\$\{|\.query\s*\(\s*[`"\x27].*\+' "$file" 2>/dev/null || true)
    if [ -n "$SQL_INJECT" ]; then
      ERRORS="$ERRORS\nPotential SQL injection in $file:\n$SQL_INJECT"
    fi

    # XSS patterns (dangerouslySetInnerHTML, innerHTML)
    XSS=$(grep -nE '(dangerouslySetInnerHTML|innerHTML\s*=)' "$file" 2>/dev/null || true)
    if [ -n "$XSS" ]; then
      WARNINGS="$WARNINGS\nPotential XSS in $file:\n$XSS"
    fi

    # eval() usage
    EVAL=$(grep -nE '\beval\s*\(' "$file" 2>/dev/null || true)
    if [ -n "$EVAL" ]; then
      ERRORS="$ERRORS\neval() usage in $file (security risk):\n$EVAL"
    fi
  fi
done

# Check 7: License compatibility
echo "[7/8] Checking license compatibility..."
if [ -f "$PROJECT_ROOT/package.json" ] && command -v npx &>/dev/null; then
  npx license-checker --failOn 'GPL-3.0;AGPL-3.0' --production 2>/dev/null || WARNINGS="$WARNINGS\nLicense compatibility issues found."
fi

# Check 8: Full test suite
echo "[8/8] Running full test suite..."
if [ -f "$PROJECT_ROOT/package.json" ]; then
  npm test 2>/dev/null || ERRORS="$ERRORS\nFull test suite failed."
elif command -v pytest &>/dev/null; then
  pytest 2>/dev/null || ERRORS="$ERRORS\nFull test suite failed."
fi

# Final report
echo ""
echo "============================================"
if [ -n "$ERRORS" ]; then
  echo "  GATE 4: FAILED"
  echo "============================================"
  echo -e "$ERRORS"
  if [ -n "$WARNINGS" ]; then
    echo ""
    echo "Warnings:"
    echo -e "$WARNINGS"
  fi
  exit 1
else
  if [ -n "$WARNINGS" ]; then
    echo "  GATE 4: PASSED WITH WARNINGS"
    echo "============================================"
    echo -e "$WARNINGS"
  else
    echo "  GATE 4: PASSED"
    echo "============================================"
  fi
  exit 0
fi
