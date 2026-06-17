#!/usr/bin/env bash
# aeh-practice-check.sh -- Deterministic AEH-practice integrity checks for a target.
#
# The single chokepoint the `target-aeh-reviewer` runs IN a target to verify the
# AEH-method invariants that can be checked WITHOUT LLM judgment. Registry-driven
# and extensible: each check is a `check_<id>` function listed in CHECKS. A check
# returns 0=PASS, 1=FAIL, 2=SKIP (precondition genuinely absent), and sets DETAIL.
# Every result -- including SKIP -- is printed, so the framework cannot silently
# no-op (a skipped check is surfaced, never hidden). Expensive coherence JUDGMENT
# (does the operational skill fully reflect the system; does an encoded convention
# still match the code) is NOT here -- that is the reviewer's at the review
# cadence. This script holds only the cheap, deterministic, every-pass invariants.
#
# This is a structural-invariant gate: single chokepoint (this script) +
# completeness source-of-truth (the CHECKS registry) + no-bypass (non-zero exit on
# any FAIL) + review cadence (the target-aeh-reviewer runs it). Keep it lean and
# strictly SDLC-generic -- a bin/ script + a small registry, not a heavy mechanism.
#
# Usage:
#   ./bin/aeh-practice-check.sh [target-path]   # run all checks (default: .)
#   ./bin/aeh-practice-check.sh --list          # list registered checks and exit
#   ./bin/aeh-practice-check.sh -h | --help
#
# Exit code: 0 if no FAIL (SKIPs are surfaced, not failures); 1 if any FAIL;
#            3 on a framework error (missing check function, empty registry).

set -uo pipefail

SCRIPT_NAME="$(basename "$0")"

# --- The registry (the completeness source-of-truth) ------------------------
# To add a check: write a `check_<id>` function below and append its id here.
CHECKS="prompt-result-pairing role-activation-base overlay-header-target-side"

# --- Argument parsing -------------------------------------------------------

TARGET_PATH="."
while [ $# -gt 0 ]; do
  case "$1" in
    --list)
      echo "Registered AEH-practice checks:"
      for c in $CHECKS; do echo "  - $c"; done
      exit 0
      ;;
    -h|--help)
      sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      TARGET_PATH="$1"
      shift
      ;;
  esac
done

if [ ! -d "$TARGET_PATH" ]; then
  echo "ERROR: target path '$TARGET_PATH' is not a directory" >&2
  exit 3
fi
TARGET_PATH="$(cd "$TARGET_PATH" && pwd)"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
DETAIL=""

# --- Checks -----------------------------------------------------------------
# Each sets DETAIL and returns 0 PASS / 1 FAIL / 2 SKIP.

# prompt-result-pairing: every dispatched prompt has a paired committed result,
# and every result maps back to a prompt (one-to-one; orphans either way fail).
# Folds the prompt->result one-to-one audit-trail invariant.
check_prompt_result_pairing() {
  local pdir="$TARGET_PATH/docs/AE/prompts"
  if [ ! -d "$pdir" ]; then
    DETAIL="no docs/AE/prompts/ directory (target has no dispatched-prompt trail yet)"
    return 2
  fi
  local rdirs=""
  [ -d "$TARGET_PATH/docs/AE/reports" ] && rdirs="$rdirs $TARGET_PATH/docs/AE/reports"
  [ -d "$TARGET_PATH/docs/AE/results" ] && rdirs="$rdirs $TARGET_PATH/docs/AE/results"

  local orphan_prompts="" orphan_results="" n
  # prompts -> results
  for f in "$pdir"/[0-9][0-9][0-9]-*.md; do
    [ -e "$f" ] || continue
    n="$(basename "$f")"; n="${n%%-*}"
    local found=0
    for rd in $rdirs; do
      for r in "$rd/$n"-*.md; do [ -e "$r" ] && found=1 && break; done
      [ "$found" = 1 ] && break
    done
    [ "$found" = 0 ] && orphan_prompts="$orphan_prompts $n"
  done
  # results -> prompts
  for rd in $rdirs; do
    for r in "$rd"/[0-9][0-9][0-9]-*.md; do
      [ -e "$r" ] || continue
      n="$(basename "$r")"; n="${n%%-*}"
      local found=0
      for p in "$pdir/$n"-*.md; do [ -e "$p" ] && found=1 && break; done
      [ "$found" = 0 ] && orphan_results="$orphan_results $n"
    done
  done

  if [ -z "$rdirs" ]; then
    DETAIL="prompts present but no docs/AE/reports/ or docs/AE/results/ directory -- no result trail exists"
    return 1
  fi
  if [ -n "$orphan_prompts" ] || [ -n "$orphan_results" ]; then
    DETAIL="unpaired prompt(s):${orphan_prompts:- none}; unpaired result(s):${orphan_results:- none}"
    return 1
  fi
  DETAIL="every prompt has a paired result and vice versa"
  return 0
}

# role-activation-base: the layered-persona base set is present target-side so a
# dispatched role can load its base template from within the target tree.
check_role_activation_base() {
  local pdir="$TARGET_PATH/docs/AE/personas"
  if [ ! -d "$pdir" ]; then
    DETAIL="no docs/AE/personas/ directory (target not yet onboarded to layered personas)"
    return 2
  fi
  local base="$pdir/_base"
  if [ ! -d "$base" ]; then
    DETAIL="docs/AE/personas/ present but docs/AE/personas/_base/ missing -- roles cannot load their base templates"
    return 1
  fi
  local missing=""
  for role in analyst archaeologist architect developer reviewer; do
    [ -f "$base/$role.md" ] || missing="$missing $role"
  done
  if [ -n "$missing" ]; then
    DETAIL="missing base template(s):$missing"
    return 1
  fi
  DETAIL="docs/AE/personas/_base/ present with all five engineering base templates"
  return 0
}

# overlay-header-target-side: each overlay points its base header at a target-side
# path, never a harness path (a harness-path header is a dead reference in-target).
check_overlay_header_target_side() {
  local pdir="$TARGET_PATH/docs/AE/personas"
  if [ ! -d "$pdir" ]; then
    DETAIL="no docs/AE/personas/ directory"
    return 2
  fi
  local overlays="" bad=""
  for f in "$pdir"/*.md; do
    [ -e "$f" ] || continue
    overlays="yes"
    # The base-pointer header line (e.g. "AEH Base: docs/AE/personas/_base/<role>.md").
    local hdr
    hdr="$(grep -iE '^[*> _-]*AEH Base:' "$f" 2>/dev/null | head -1 || true)"
    [ -z "$hdr" ] && continue
    case "$hdr" in
      *templates/personas/*|*/workspace/*)
        bad="$bad $(basename "$f")"
        ;;
    esac
  done
  if [ -z "$overlays" ]; then
    DETAIL="no overlay files in docs/AE/personas/"
    return 2
  fi
  if [ -n "$bad" ]; then
    DETAIL="overlay(s) with a harness-path base header:$bad"
    return 1
  fi
  DETAIL="all overlay base headers point target-side"
  return 0
}

# --- Runner -----------------------------------------------------------------

fn_for() { echo "check_$(echo "$1" | tr '-' '_')"; }

echo "=== AEH-practice checks ($TARGET_PATH) ==="
echo ""

if [ -z "${CHECKS// /}" ]; then
  echo "ERROR: empty check registry -- nothing to verify (framework error)" >&2
  exit 3
fi

ran=0
for cid in $CHECKS; do
  fn="$(fn_for "$cid")"
  if ! declare -F "$fn" >/dev/null 2>&1; then
    echo "ERROR: registered check '$cid' has no function '$fn' (framework error)" >&2
    exit 3
  fi
  DETAIL=""
  "$fn"; rc=$?
  ran=$((ran + 1))
  case "$rc" in
    0) echo "  [PASS] $cid -- $DETAIL"; PASS_COUNT=$((PASS_COUNT + 1)) ;;
    1) echo "  [FAIL] $cid -- $DETAIL"; FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
    2) echo "  [SKIP] $cid -- $DETAIL"; SKIP_COUNT=$((SKIP_COUNT + 1)) ;;
    *) echo "  [FAIL] $cid -- check returned unexpected code $rc (framework error)"; FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
  esac
done

echo ""
echo "=== Summary ==="
echo "  PASS: $PASS_COUNT   FAIL: $FAIL_COUNT   SKIP: $SKIP_COUNT   (of $ran registered)"

if [ "$PASS_COUNT" = 0 ] && [ "$FAIL_COUNT" = 0 ]; then
  echo "  NOTE: every check skipped -- nothing was actually verified for this target."
fi

[ "$FAIL_COUNT" -eq 0 ] && exit 0 || exit 1
