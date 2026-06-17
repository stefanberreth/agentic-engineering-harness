#!/usr/bin/env bash
# validate-personas.sh -- Validate structural conventions + scan for target-detail leakage.
#
# Usage:
#   ./bin/validate-personas.sh                              # base templates + broad leak scan
#   ./bin/validate-personas.sh /path/to/target-project      # adds overlay validation
#   ./bin/validate-personas.sh --message "<commit-msg>"     # scan a commit message string only
#   ./bin/validate-personas.sh --staged                     # scan currently-staged files only
#
# Blocklist source: bin/.leakage-patterns (gitignored, local-only). One pattern per line.
# Blank lines and lines starting with `#` are ignored. Patterns are grep -iE regexes.
# A tracked example with placeholder patterns lives at bin/.leakage-patterns.example.
#
# Exit code: 0 if all PASS (warnings ok), 1 if any FAIL.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HARNESS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE_DIR="$HARNESS_ROOT/templates/personas"
PATTERN_FILE="$SCRIPT_DIR/.leakage-patterns"
PATTERN_EXAMPLE="$SCRIPT_DIR/.leakage-patterns.example"

# --- Argument parsing -------------------------------------------------------

MODE="full"          # full | message | staged
MESSAGE_TEXT=""
TARGET_PATH=""

while [ $# -gt 0 ]; do
  case "$1" in
    --message)
      MODE="message"
      shift
      MESSAGE_TEXT="${1:-}"
      shift || true
      ;;
    --staged)
      MODE="staged"
      shift
      ;;
    -h|--help)
      sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      TARGET_PATH="$1"
      shift
      ;;
  esac
done

FAIL_COUNT=0
WARN_COUNT=0
PASS_COUNT=0

pass() { echo "  [PASS] $1"; PASS_COUNT=$((PASS_COUNT + 1)); }
warn() { echo "  [WARN] $1"; WARN_COUNT=$((WARN_COUNT + 1)); }
fail() { echo "  [FAIL] $1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

# --- Load blocklist ---------------------------------------------------------

LEAKAGE_PATTERNS=()
if [ -f "$PATTERN_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    # Strip leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [ -z "$line" ] && continue
    case "$line" in
      \#*) continue ;;
    esac
    LEAKAGE_PATTERNS+=("$line")
  done < "$PATTERN_FILE"
fi

if [ "${#LEAKAGE_PATTERNS[@]}" -eq 0 ]; then
  echo "=== Leakage Blocklist ==="
  if [ -f "$PATTERN_FILE" ]; then
    warn "Blocklist file $PATTERN_FILE exists but contains no active patterns."
  else
    warn "No blocklist file at $PATTERN_FILE. Copy $PATTERN_EXAMPLE to .leakage-patterns and populate."
  fi
  echo ""
fi

# Scan a single file or a string of text for any blocklist hit.
# Args: <label> <file-or-"-"> [stdin-text-if-dash]
scan_text() {
  local label="$1" source="$2" text="${3:-}"
  local hits=0
  local pattern
  for pattern in "${LEAKAGE_PATTERNS[@]}"; do
    if [ "$source" = "-" ]; then
      if printf '%s' "$text" | grep -qiE -- "$pattern"; then
        fail "$label: matches blocklist pattern '$pattern'"
        hits=$((hits + 1))
      fi
    else
      if grep -qiE -- "$pattern" "$source" 2>/dev/null; then
        fail "$label: matches blocklist pattern '$pattern'"
        hits=$((hits + 1))
      fi
    fi
  done
  return $hits
}

# --- Mode: --message --------------------------------------------------------

if [ "$MODE" = "message" ]; then
  echo "=== Commit Message Scan ==="
  echo ""
  if [ -z "$MESSAGE_TEXT" ]; then
    warn "No message provided (use --message \"<text>\")"
  else
    if scan_text "commit-message" "-" "$MESSAGE_TEXT"; then
      pass "Commit message clean"
    fi
  fi
  echo ""
  echo "=== Summary ==="
  echo "  PASS: $PASS_COUNT"
  echo "  WARN: $WARN_COUNT"
  echo "  FAIL: $FAIL_COUNT"
  [ "$FAIL_COUNT" -gt 0 ] && exit 1 || exit 0
fi

# --- Mode: --staged ---------------------------------------------------------

if [ "$MODE" = "staged" ]; then
  echo "=== Staged Files Scan ==="
  echo ""
  # Names of files staged for commit
  STAGED=$(git -C "$HARNESS_ROOT" diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
  if [ -z "$STAGED" ]; then
    warn "No staged files."
  else
    any_hit=0
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      [ -f "$HARNESS_ROOT/$f" ] || continue
      if ! scan_text "$f" "$HARNESS_ROOT/$f"; then
        any_hit=1
      fi
    done <<< "$STAGED"
    [ "$any_hit" -eq 0 ] && pass "All staged files clean"
  fi
  echo ""
  echo "=== Summary ==="
  echo "  PASS: $PASS_COUNT"
  echo "  WARN: $WARN_COUNT"
  echo "  FAIL: $FAIL_COUNT"
  [ "$FAIL_COUNT" -gt 0 ] && exit 1 || exit 0
fi

# --- Full mode: structural checks + broad leak scan -------------------------

# Harness-internal roles: intentionally NOT layered.
HARNESS_ROLES="orchestrator.md strategist.md harness-reviewer.md aeh-engineer.md"

echo "=== Base Templates ($BASE_DIR) ==="
echo ""

for filepath in "$BASE_DIR"/*.md; do
  [ -f "$filepath" ] || continue
  filename="$(basename "$filepath")"
  echo "$filename:"

  is_harness_role=0
  for hr in $HARNESS_ROLES; do
    if [ "$filename" = "$hr" ]; then
      is_harness_role=1
      break
    fi
  done

  if [ "$is_harness_role" -eq 1 ]; then
    pass "Harness-internal role (not subject to layered convention)"
  else
    if grep -q "AEH Base Template" "$filepath"; then
      pass "Contains AEH Base Template header"
    else
      warn "Missing 'AEH Base Template' header notice"
    fi

    if grep -qE '^## §' "$filepath"; then
      count=$(grep -cE '^## §' "$filepath")
      pass "Has $count numbered section(s)"
    else
      warn "No numbered sections found (not yet migrated to layered format)"
    fi

    if grep -q '\.PROJECT' "$filepath"; then
      count=$(grep -c '\.PROJECT' "$filepath")
      pass "Has $count .PROJECT extension point(s)"
    else
      warn "No .PROJECT extension points found (not yet migrated to layered format)"
    fi
  fi

  if [ "${#LEAKAGE_PATTERNS[@]}" -gt 0 ]; then
    if scan_text "$filename" "$filepath"; then
      pass "No blocklist patterns matched"
    fi
  fi
  echo ""
done

# --- Broad scan: CHANGELOG, README, docs/, templates/ -----------------------

if [ "${#LEAKAGE_PATTERNS[@]}" -gt 0 ]; then
  echo "=== Broad Leak Scan (CHANGELOG, README, docs/, templates/) ==="
  echo ""

  SCAN_TARGETS=()
  [ -f "$HARNESS_ROOT/CHANGELOG.md" ] && SCAN_TARGETS+=("$HARNESS_ROOT/CHANGELOG.md")
  [ -f "$HARNESS_ROOT/README.md" ]    && SCAN_TARGETS+=("$HARNESS_ROOT/README.md")
  [ -f "$HARNESS_ROOT/CLAUDE.md" ]    && SCAN_TARGETS+=("$HARNESS_ROOT/CLAUDE.md")

  # Add docs/ and templates/ files (text only; skip images and binaries).
  # Restricted to git-tracked files so locally-kept (gitignored) planning docs
  # are not flagged -- the rule is "no leakage in PUBLIC tree".
  if git -C "$HARNESS_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      case "$f" in
        docs/*|templates/*)
          case "$f" in
            *.md|*.sh|*.template|*.txt) SCAN_TARGETS+=("$HARNESS_ROOT/$f") ;;
          esac
          ;;
      esac
    done < <(git -C "$HARNESS_ROOT" ls-files 'docs/*' 'templates/*' 2>/dev/null)
  fi

  scan_hits=0
  for f in "${SCAN_TARGETS[@]}"; do
    rel="${f#$HARNESS_ROOT/}"
    if ! scan_text "$rel" "$f"; then
      scan_hits=1
    fi
  done
  [ "$scan_hits" -eq 0 ] && pass "Broad scan clean (${#SCAN_TARGETS[@]} files)"
  echo ""
fi

# --- Overlay validation (optional) -----------------------------------------

if [ -n "$TARGET_PATH" ]; then
  OVERLAY_DIR="$TARGET_PATH/docs/AE/personas"

  if [ ! -d "$OVERLAY_DIR" ]; then
    echo "=== Overlay Personas ($OVERLAY_DIR) ==="
    echo ""
    warn "Overlay directory does not exist: $OVERLAY_DIR"
    echo ""
  else
    echo "=== Overlay Personas ($OVERLAY_DIR) ==="
    echo ""
    for filepath in "$OVERLAY_DIR"/*.md; do
      [ -f "$filepath" ] || continue
      filename="$(basename "$filepath")"
      echo "$filename:"

      if grep -q "AEH Base:" "$filepath"; then
        pass "Contains Persona Header Block (AEH Base reference)"
      else
        warn "Missing 'AEH Base:' header reference"
      fi

      base_ref=$(grep 'AEH Base:' "$filepath" | head -1 | sed 's/.*AEH Base:[* ]*//' | sed 's/[`*>]//g' | xargs 2>/dev/null || true)
      if [ -n "$base_ref" ]; then
        resolved_base="$HARNESS_ROOT/$base_ref"
        if [ -f "$resolved_base" ]; then
          pass "Referenced base file exists: $base_ref"
        else
          fail "Referenced base file NOT found: $base_ref (resolved to $resolved_base)"
        fi
      fi
      echo ""
    done
  fi
fi

# --- Summary ----------------------------------------------------------------

echo "=== Summary ==="
echo "  PASS: $PASS_COUNT"
echo "  WARN: $WARN_COUNT"
echo "  FAIL: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "  Result: FAILED ($FAIL_COUNT failure(s))"
  exit 1
else
  echo "  Result: PASSED ($WARN_COUNT warning(s))"
  exit 0
fi
