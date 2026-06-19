#!/usr/bin/env bash
# test-aeh-practice-check.sh -- regression fixtures for aeh-practice-check.sh.
#
# Lean, self-contained: builds throwaway target trees under a tmp dir, runs the
# real check script against each, and asserts the verdict for ONE named check
# (other checks SKIP/clean in a minimal fixture and are ignored). Covers the
# false-positive / retroactive-FAIL classes fixed in
# practice-check-false-positive-fixes plus their must-still-FAIL counterparts.
#
# Usage: ./bin/test-aeh-practice-check.sh   (exit 0 = all assertions pass)

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
CHECK="$HERE/aeh-practice-check.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAILS=0

# assert_check <target> <check-id> <want PASS|FAIL|SKIP> <label> [needle-in-detail]
assert_check() {
  local target="$1" id="$2" want="$3" label="$4" needle="${5:-}"
  local out line got
  out="$("$CHECK" "$target" 2>&1)"
  line="$(printf '%s\n' "$out" | grep -E "\] $id --" | head -1)"
  case "$line" in
    *"[PASS] $id"*) got=PASS ;;
    *"[FAIL] $id"*) got=FAIL ;;
    *"[SKIP] $id"*) got=SKIP ;;
    *"[WARN] $id"*) got=WARN ;;
    *) got=MISSING ;;
  esac
  if [ "$got" != "$want" ]; then
    echo "  FAIL $label -- $id got $got, want $want"; echo "       $line"; FAILS=$((FAILS + 1)); return
  fi
  if [ -n "$needle" ] && ! printf '%s' "$line" | grep -qF "$needle"; then
    echo "  FAIL $label -- $id $got but detail missing '$needle'"; echo "       $line"; FAILS=$((FAILS + 1)); return
  fi
  echo "  ok   $label -- $id -> $got"
}

mk_settings() { mkdir -p "$1/.claude" "$1/docs/AE"; cat > "$1/.claude/$2"; }

# --- Fixture 1: pretty-printed multi-line deny array (first element on next line)
F1="$TMP/f1-multiline-deny"
mk_settings "$F1" settings.local.json <<'JSON'
{
  "permissions": {
    "allow": [
      "Bash(ls:*)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./secrets/**)"
    ]
  }
}
JSON
assert_check "$F1" permission-scope PASS "multi-line deny array is detected"

# --- Fixture 2a: well-known local-dev credential bound to loopback (benign)
F2A="$TMP/f2a-loopback-cred"
mk_settings "$F2A" settings.json <<'JSON'
{
  "permissions": {
    "allow": [
      "Bash(PGPASSWORD=postgres psql -h 127.0.0.1 -p 54322 -U postgres)"
    ],
    "deny": [ "Read(./.env)" ]
  }
}
JSON
assert_check "$F2A" permission-scope PASS "loopback local-dev credential is not flagged"

# --- Fixture 2b: SAME literal bound to a non-loopback host (must still FAIL)
F2B="$TMP/f2b-remote-cred"
mk_settings "$F2B" settings.json <<'JSON'
{
  "permissions": {
    "allow": [
      "Bash(PGPASSWORD=postgres psql -h db.example.com -p 5432 -U postgres)"
    ],
    "deny": [ "Read(./.env)" ]
  }
}
JSON
assert_check "$F2B" permission-scope FAIL "non-loopback credential still flags" "secret literal"

# --- Fixture 3: pre-cutoff unpaired history, with and without a marker
F3="$TMP/f3-pairing"
mkdir -p "$F3/docs/AE/prompts" "$F3/docs/AE/reports"
: > "$F3/docs/AE/prompts/001-alpha.md"
: > "$F3/docs/AE/prompts/002-beta.md"
: > "$F3/docs/AE/prompts/003-gamma.md"
: > "$F3/docs/AE/reports/003-gamma-report.md"
# 3b first: no marker -> 001,002 are orphans -> FAIL
assert_check "$F3" prompt-result-pairing FAIL "no cutoff marker -> historical orphans FAIL"
# 3a: marker at 003 -> only 003 evaluated -> PASS + explicit excluded-span note
printf '003\n' > "$F3/docs/AE/.prompt-pairing-since"
assert_check "$F3" prompt-result-pairing PASS "cutoff marker excludes pre-cutoff history" "before cutoff 003"

# --- Fixture 4: CLAUDE.md size budget (router discipline) -- WARN over, PASS under
F4="$TMP/f4-claude-md-size"
mkdir -p "$F4/docs/AE"
# under budget
printf '# CLAUDE.md\n\nA lean router.\n' > "$F4/CLAUDE.md"
assert_check "$F4" claude-md-size PASS "lean CLAUDE.md within budget"
# over the line budget (>450 lines) -> WARN, not FAIL
{ echo "# CLAUDE.md"; for i in $(seq 1 600); do echo "- rule line $i"; done; } > "$F4/CLAUDE.md"
assert_check "$F4" claude-md-size WARN "oversized CLAUDE.md WARNs (does not FAIL)"

echo ""
if [ "$FAILS" -eq 0 ]; then
  echo "ALL FIXTURES PASS"
  exit 0
fi
echo "$FAILS FIXTURE ASSERTION(S) FAILED"
exit 1
