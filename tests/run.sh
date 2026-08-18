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
# 3. Add-on integrity — every src: file referenced must exist, and every
#    manifest must declare a non-empty context: field
# ---------------------------------------------------------------------------
echo "==> add-on integrity"
for addon in "$ROOT"/addons/*.yml; do
  [ -e "$addon" ] || continue
  aname="$(basename "$addon" .yml)"
  while IFS= read -r src; do
    src="${src#"${src%%[![:space:]]*}"}"
    if [ -f "$ROOT/$src" ]; then
      pass "$aname: $src"
    else
      fail "$aname: $src — file not found"
    fi
  done < <(grep -- '- src:' "$addon" | sed 's/.*- src: *//')

  if grep -qE '^context: *".+"' "$addon"; then
    pass "$aname: context"
  else
    fail "$aname: context missing or empty"
  fi
done

if grep -qF '<!-- claudify:addons:start -->' "$ROOT/files/docs/claudify.md" \
  && grep -qF '<!-- claudify:addons:end -->' "$ROOT/files/docs/claudify.md"; then
  pass "files/docs/claudify.md: addons marker pair"
else
  fail "files/docs/claudify.md: addons marker pair missing"
fi

# ---------------------------------------------------------------------------
# 4. Blueprint permissions — every blueprint must declare permissions.allow
#    with at least one Bash() rule
# ---------------------------------------------------------------------------
echo "==> blueprint permissions"
for blueprint in "$ROOT"/blueprints/*.yml; do
  bname="$(basename "$blueprint" .yml)"
  if grep -q '^permissions:' "$blueprint" \
    && sed -n '/^permissions:/,/^[a-z_]*:/p' "$blueprint" | grep -q -- '- "Bash('; then
    pass "$bname: permissions.allow"
  else
    fail "$bname: permissions.allow missing or empty"
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ]
