#!/usr/bin/env bash
# validate-personas.sh — Validate structural conventions of AEH layered personas
#
# Usage:
#   ./bin/validate-personas.sh                           # base templates only
#   ./bin/validate-personas.sh /path/to/target-project   # base + overlays
#
# Exit code: 0 if all PASS (warnings ok), 1 if any FAIL

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HARNESS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE_DIR="$HARNESS_ROOT/templates/personas"
TARGET_PATH="${1:-}"

FAIL_COUNT=0
WARN_COUNT=0
PASS_COUNT=0

# Harness-internal roles: intentionally NOT layered (no §N, no extension points, no base header).
# They are never overlaid by target projects. Still checked for leakage.
HARNESS_ROLES="orchestrator.md strategist.md harness-reviewer.md"

# Project-specific identifiers that must not appear in base templates
# Each entry is a grep -i pattern
LEAKAGE_PATTERNS=(
  "a target project"
  "a target project"
  "a target project"
  "REDACTED"
  "REDACTED"
  "REDACTED"
  "Express 4\.18"
  "React 19"
  "a financial regulator"
  "a financial regulator"
)

# Supabase is checked separately — allowed in generic context, not as a hard dependency
# Note: .env.dev/.env.qa/.env.prod are generic env file conventions, not Supabase-specific
SUPABASE_LEAKAGE_PATTERNS=(
  "supabase\.co"
  "@supabase/supabase-js"
  "supabase-multi-env"
  "supabase/.env"
)

pass() {
  echo "  [PASS] $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

warn() {
  echo "  [WARN] $1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

fail() {
  echo "  [FAIL] $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

# --- Base Template Validation ---

echo "=== Base Templates ($BASE_DIR) ==="
echo ""

for filepath in "$BASE_DIR"/*.md; do
  [ -f "$filepath" ] || continue
  filename="$(basename "$filepath")"
  echo "$filename:"

  # Check if this is a harness-internal role
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
    # 1. Contains base header notice
    if grep -q "AEH Base Template" "$filepath"; then
      pass "Contains AEH Base Template header"
    else
      warn "Missing 'AEH Base Template' header notice"
    fi

    # 2. Has at least one §N numbered section
    if grep -qE '^## §' "$filepath"; then
      count=$(grep -cE '^## §' "$filepath")
      pass "Has $count numbered section(s)"
    else
      warn "No §N numbered sections found (not yet migrated to layered format)"
    fi

    # 3. Has at least one §N.PROJECT extension point
    if grep -q '\.PROJECT' "$filepath"; then
      count=$(grep -c '\.PROJECT' "$filepath")
      pass "Has $count .PROJECT extension point(s)"
    else
      warn "No .PROJECT extension points found (not yet migrated to layered format)"
    fi
  fi

  # Leakage check applies to ALL templates (harness-internal included)
  # Does NOT contain project-specific identifiers
  leakage_found=0
  for pattern in "${LEAKAGE_PATTERNS[@]}"; do
    if grep -qi "$pattern" "$filepath"; then
      fail "Contains project-specific identifier: '$pattern'"
      leakage_found=1
    fi
  done

  # Check Supabase-specific patterns (more targeted than just "Supabase")
  for pattern in "${SUPABASE_LEAKAGE_PATTERNS[@]}"; do
    if grep -qi "$pattern" "$filepath"; then
      fail "Contains project-specific Supabase reference: '$pattern'"
      leakage_found=1
    fi
  done

  if [ "$leakage_found" -eq 0 ]; then
    pass "No project-specific identifiers found"
  fi

  echo ""
done

# --- Overlay Validation ---

if [ -n "$TARGET_PATH" ]; then
  OVERLAY_DIR="$TARGET_PATH/docs/AE/personas"

  if [ ! -d "$OVERLAY_DIR" ]; then
    echo "=== Overlay Personas ($OVERLAY_DIR) ==="
    echo ""
    echo "  [WARN] Overlay directory does not exist: $OVERLAY_DIR"
    echo ""
    ((WARN_COUNT++))
  else
    echo "=== Overlay Personas ($OVERLAY_DIR) ==="
    echo ""

    for filepath in "$OVERLAY_DIR"/*.md; do
      [ -f "$filepath" ] || continue
      filename="$(basename "$filepath")"
      echo "$filename:"

      # 1. Contains Persona Header Block
      if grep -q "AEH Base:" "$filepath"; then
        pass "Contains Persona Header Block (AEH Base reference)"
      else
        warn "Missing 'AEH Base:' header reference"
      fi

      # 2. Referenced base file exists
      base_ref=$(grep 'AEH Base:' "$filepath" | head -1 | sed 's/.*AEH Base:[* ]*//' | sed 's/[`*>]//g' | xargs 2>/dev/null || true)
      if [ -n "$base_ref" ]; then
        # Resolve relative to harness root
        resolved_base="$HARNESS_ROOT/$base_ref"
        if [ -f "$resolved_base" ]; then
          pass "Referenced base file exists: $base_ref"

          # 3. Check for duplicated methodology sections
          # Extract ## headings from both files
          base_headings_file=$(mktemp)
          overlay_headings_file=$(mktemp)
          trap "rm -f '$base_headings_file' '$overlay_headings_file'" EXIT

          grep '^## ' "$resolved_base" | sed 's/^## //' > "$base_headings_file"
          grep '^## ' "$filepath" | sed 's/^## //' > "$overlay_headings_file"

          duplication_found=0
          while IFS= read -r heading; do
            [ -z "$heading" ] && continue
            # Check if this heading exists in the base
            if grep -qFx "$heading" "$base_headings_file"; then
              # Extract first 100 chars of content under this heading from both files
              # Use awk to get content between this heading and the next ## heading
              base_content=$(awk -v h="## $heading" '
                $0 == h { found=1; next }
                found && /^## / { exit }
                found { printf "%s ", $0 }
              ' "$resolved_base" | head -c 100)

              overlay_content=$(awk -v h="## $heading" '
                $0 == h { found=1; next }
                found && /^## / { exit }
                found { printf "%s ", $0 }
              ' "$filepath" | head -c 100)

              if [ -n "$base_content" ] && [ -n "$overlay_content" ]; then
                # Compare first 100 chars — if >80% similar, flag it
                # Simple approach: check if they're identical
                if [ "$base_content" = "$overlay_content" ]; then
                  fail "Likely duplicated section from base: '## $heading'"
                  duplication_found=1
                else
                  warn "Heading '## $heading' exists in both base and overlay (content differs — verify intentional override)"
                fi
              fi
            fi
          done < "$overlay_headings_file"

          if [ "$duplication_found" -eq 0 ]; then
            pass "No duplicated methodology sections detected"
          fi

          rm -f "$base_headings_file" "$overlay_headings_file"
          trap - EXIT
        else
          fail "Referenced base file NOT found: $base_ref (resolved to $resolved_base)"
        fi
      else
        if grep -q "AEH Base:" "$filepath"; then
          warn "AEH Base reference found but could not parse file path"
        fi
        # Skip duplication check if no base reference
      fi

      echo ""
    done
  fi
fi

# --- Summary ---

echo "=== Summary ==="
echo "  PASS: $PASS_COUNT"
echo "  WARN: $WARN_COUNT"
echo "  FAIL: $FAIL_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo ""
  echo "  Result: FAILED ($FAIL_COUNT failure(s))"
  exit 1
else
  echo ""
  echo "  Result: PASSED (${WARN_COUNT} warning(s))"
  exit 0
fi
