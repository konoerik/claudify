#!/usr/bin/env bash
# claudify test suite
# Run from anywhere: bash tests/run.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

pass() { echo "  pass: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

# ---------------------------------------------------------------------------
# 1. Shellcheck
# ---------------------------------------------------------------------------
echo "==> shellcheck"
if ! command -v shellcheck &>/dev/null; then
  echo "  skip: shellcheck not installed"
else
  for f in "$ROOT"/files/hooks/*.sh; do
    name="$(basename "$f")"
    if shellcheck "$f" 2>/dev/null; then
      pass "$name"
    else
      fail "$name"
    fi
  done
fi

# ---------------------------------------------------------------------------
# 2. Blueprint integrity — every src: file referenced must exist in files/
# ---------------------------------------------------------------------------
echo "==> blueprint integrity"
for blueprint in "$ROOT"/blueprints/*.yml; do
  bname="$(basename "$blueprint" .yml)"
  while IFS= read -r src; do
    # trim leading whitespace
    src="${src#"${src%%[![:space:]]*}"}"
    if [ -f "$ROOT/$src" ]; then
      pass "$bname: $src"
    else
      fail "$bname: $src — file not found"
    fi
  done < <(grep -- '- src:' "$blueprint" | sed 's/.*- src: *//')
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ]
