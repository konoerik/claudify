#!/usr/bin/env bash
# claudify audit — evaluate a project against claudify conventions
# Usage: bash /path/to/claudify/audit.sh [target-dir]
# Exit code: 0 = clean, 1 = issues found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"

if [[ ! -d "$TARGET" ]]; then
  echo "Error: directory '$TARGET' does not exist." >&2
  exit 2
fi

TARGET="$(cd "$TARGET" && pwd)"

# --- Color output (disabled if not a TTY) ---

if [[ -t 1 ]]; then
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  GREEN='\033[0;32m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  RED='' YELLOW='' GREEN='' BOLD='' RESET=''
fi

# --- Counters ---

ERRORS=0
WARNINGS=0

# --- Helpers ---

ok()   { echo -e "  ${GREEN}✓${RESET}  $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET}  $1"; ((WARNINGS++)) || true; }
fail() { echo -e "  ${RED}✗${RESET}  $1"; ((ERRORS++)) || true; }

section() { echo -e "\n${BOLD}$1${RESET}"; }

has_section() {
  local file="$1" heading="$2"
  grep -q "^## ${heading}" "$file" 2>/dev/null
}

# --- Report header ---

echo -e "${BOLD}claudify audit${RESET}: $TARGET"

# ────────────────────────────────────────────
section "Core files"
# ────────────────────────────────────────────

for file in CLAUDE.md CONTEXT.md PLAN.md ARCHITECTURE.md; do
  if [[ -f "$TARGET/$file" ]]; then
    ok "$file"
  else
    fail "$file missing  →  cp '$SCRIPT_DIR/files/docs/$file' '$TARGET/$file'"
  fi
done

if [[ -f "$TARGET/ROADMAP.md" ]]; then
  ok "ROADMAP.md"
else
  warn "ROADMAP.md missing (optional)  →  cp '$SCRIPT_DIR/files/docs/ROADMAP.md' '$TARGET/ROADMAP.md'"
fi

# ────────────────────────────────────────────
section "Naming violations"
# ────────────────────────────────────────────

DISALLOWED=(BACKLOG.md TASKS.md TODO.md TODOS.md TASK.md)
FOUND_VIOLATIONS=false

for name in "${DISALLOWED[@]}"; do
  if [[ -f "$TARGET/$name" ]]; then
    fail "$name exists  →  merge contents into PLAN.md ## Backlog, then delete"
    FOUND_VIOLATIONS=true
  fi
done

if [[ "$FOUND_VIOLATIONS" == false ]]; then
  ok "No non-canonical doc files found"
fi

# ────────────────────────────────────────────
section "File structure"
# ────────────────────────────────────────────

# PLAN.md sections
if [[ -f "$TARGET/PLAN.md" ]]; then
  for heading in Active Backlog Done; do
    if has_section "$TARGET/PLAN.md" "$heading"; then
      ok "PLAN.md has ## $heading"
    else
      fail "PLAN.md missing ## $heading section"
    fi
  done
fi

# ARCHITECTURE.md sections
if [[ -f "$TARGET/ARCHITECTURE.md" ]]; then
  if has_section "$TARGET/ARCHITECTURE.md" "Quick Reference"; then
    ok "ARCHITECTURE.md has ## Quick Reference"
  else
    warn "ARCHITECTURE.md missing ## Quick Reference  →  add a short summary of stack and constraints at the top"
  fi
fi

# CLAUDE.md context loading block
if [[ -f "$TARGET/CLAUDE.md" ]]; then
  if grep -q "Context Loading" "$TARGET/CLAUDE.md" 2>/dev/null; then
    ok "CLAUDE.md has Context Loading section"
  else
    warn "CLAUDE.md missing Context Loading section  →  add load rules (see claudify template)"
  fi
fi

# CONTEXT.md sentinel
if [[ -f "$TARGET/CONTEXT.md" ]]; then
  if grep -q "wrapped:" "$TARGET/CONTEXT.md" 2>/dev/null; then
    ok "CONTEXT.md has /wrap sentinel"
  else
    warn "CONTEXT.md has no /wrap sentinel  →  run /wrap at end of a session to initialize it"
  fi
fi

# ────────────────────────────────────────────
section "Hooks"
# ────────────────────────────────────────────

HOOKS=(
  "stop/session-wrap.sh"
  "pre-tool-use/guard-naming.sh"
)

for dest_rel in "${HOOKS[@]}"; do
  src_file="$(basename "$dest_rel")"
  dest="$TARGET/.claude/hooks/$dest_rel"
  if [[ -f "$dest" ]]; then
    ok "$dest_rel"
  else
    fail "$dest_rel missing  →  cp '$SCRIPT_DIR/files/hooks/$src_file' '$dest' && chmod +x '$dest'"
  fi
done

# ────────────────────────────────────────────
section "Commands"
# ────────────────────────────────────────────

COMMANDS=(plan.md wrap.md decide.md arch.md ship.md standup.md migrate.md)

for cmd in "${COMMANDS[@]}"; do
  dest="$TARGET/.claude/commands/$cmd"
  if [[ -f "$dest" ]]; then
    ok "$cmd"
  else
    fail "$cmd missing  →  cp '$SCRIPT_DIR/files/commands/$cmd' '$dest'"
  fi
done

# ────────────────────────────────────────────
section "Summary"
# ────────────────────────────────────────────

echo ""
if [[ "$ERRORS" -eq 0 && "$WARNINGS" -eq 0 ]]; then
  echo -e "  ${GREEN}${BOLD}All checks passed.${RESET}"
  exit 0
fi

[[ "$ERRORS" -gt 0 ]]   && echo -e "  ${RED}${BOLD}$ERRORS error(s)${RESET}"
[[ "$WARNINGS" -gt 0 ]] && echo -e "  ${YELLOW}${BOLD}$WARNINGS warning(s)${RESET}"

if [[ "$ERRORS" -gt 0 ]]; then
  echo ""
  echo "  Tip: many errors can be fixed by applying the blueprint."
  echo "  Open Claude Code in the target project and say:"
  echo "    \"Read and apply $SCRIPT_DIR/blueprints/generic.yml to this project.\""
  exit 1
fi

exit 0
