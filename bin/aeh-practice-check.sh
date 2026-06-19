#!/usr/bin/env bash
# aeh-practice-check.sh -- Deterministic AEH-practice integrity checks for a target.
#
# The single chokepoint the `target-aeh-reviewer` runs IN a target to verify the
# AEH-method invariants that can be checked WITHOUT LLM judgment. Registry-driven
# and extensible: each check is a `check_<id>` function listed in CHECKS. A check
# returns 0=PASS, 1=FAIL, 2=SKIP (precondition genuinely absent), 3=WARN (a soft
# budget/advisory signal that is surfaced but does NOT fail the run), and sets
# DETAIL. Every result -- including SKIP and WARN -- is printed, so the framework
# cannot silently no-op (a skipped or warned check is surfaced, never hidden). Expensive coherence JUDGMENT
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
CHECKS="prompt-result-pairing role-activation-base overlay-header-target-side permission-scope claude-md-size"

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
WARN_COUNT=0
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

  # Optional pairing baseline cutoff. A target onboarded BEFORE the one-prompt-one-
  # report convention should not FAIL forever on history that predates it (the
  # convention is forward-looking; it does not want hundreds of fabricated reports).
  # The marker docs/AE/.prompt-pairing-since holds the first NNN to evaluate
  # (zero-padded). Prompts/results before it are excluded and the excluded span is
  # reported EXPLICITLY (never silently truncated). No marker -> evaluate all.
  local cutoff="" cutoff_num=0 excluded=0 cutoff_note=""
  local marker="$TARGET_PATH/docs/AE/.prompt-pairing-since"
  if [ -f "$marker" ]; then
    cutoff="$(tr -d '[:space:]' < "$marker" 2>/dev/null)"
    case "$cutoff" in
      '') : ;;
      *[!0-9]*) cutoff_note=" [pairing-since marker '$cutoff' is not an NNN prompt number -- ignored; evaluating all]"; cutoff="" ;;
      *) cutoff_num=1 ;;
    esac
  fi

  local orphan_prompts="" orphan_results="" n
  # prompts -> results
  for f in "$pdir"/[0-9][0-9][0-9]-*.md; do
    [ -e "$f" ] || continue
    n="$(basename "$f")"; n="${n%%-*}"
    if [ "$cutoff_num" = 1 ] && (( 10#$n < 10#$cutoff )); then excluded=$((excluded + 1)); continue; fi
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
      if [ "$cutoff_num" = 1 ] && (( 10#$n < 10#$cutoff )); then continue; fi
      local found=0
      for p in "$pdir/$n"-*.md; do [ -e "$p" ] && found=1 && break; done
      [ "$found" = 0 ] && orphan_results="$orphan_results $n"
    done
  done

  local exnote=""
  [ "$excluded" -gt 0 ] && exnote=" ($excluded historical prompt(s) before cutoff $cutoff not evaluated)"

  if [ -z "$rdirs" ]; then
    DETAIL="prompts present but no docs/AE/reports/ or docs/AE/results/ directory -- no result trail exists$exnote$cutoff_note"
    return 1
  fi
  if [ -n "$orphan_prompts" ] || [ -n "$orphan_results" ]; then
    DETAIL="unpaired prompt(s):${orphan_prompts:- none}; unpaired result(s):${orphan_results:- none}$exnote$cutoff_note"
    return 1
  fi
  DETAIL="every prompt has a paired result and vice versa$exnote$cutoff_note"
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

# permission-scope: the target's own Claude Code permission config
# (.claude/settings.json + .local) holds no DETERMINISTIC compliance violation --
# no bypass mode, no whole-filesystem-escape allow rule, no secret literal in a
# rule, and (for an AEH-managed target) a non-empty deny list. Judgment cases
# (allow-rule sprawl, whether a specific harness-isolation deny path is right) stay
# the reviewer's narrative -- this check holds only the deterministic cases. On a
# FAIL, the target-aeh-reviewer reports the exact rule change (citing
# permission-baselines.md); target-aeh-engineer applies it on approval; then this
# same check is re-run to validate (detect == confirm).
check_permission_scope() {
  local sj="$TARGET_PATH/.claude/settings.json"
  local sl="$TARGET_PATH/.claude/settings.local.json"
  local files=""
  [ -f "$sj" ] && files="$files $sj"
  [ -f "$sl" ] && files="$files $sl"
  if [ -z "$files" ]; then
    DETAIL="no .claude/settings.json or settings.local.json (target permissions not configured here)"
    return 2
  fi

  local problems=""
  # Bypass mode -- disables the permission system wholesale.
  if grep -Eq '"defaultMode"[[:space:]]*:[[:space:]]*"bypassPermissions"' $files 2>/dev/null; then
    problems="$problems; defaultMode=bypassPermissions (bypasses the permission system; baseline forbids it)"
  fi
  # Whole-filesystem escape -- an allow rule over the filesystem root.
  if grep -Eq '"(Read|Edit|Write)\((//?\*\*|/)\)"' $files 2>/dev/null; then
    problems="$problems; whole-filesystem allow rule (Read/Edit/Write of / or /**; grants access outside the project)"
  fi
  # Secret literal in a rule -- a secret keyword immediately assigned a value.
  # Whitelist well-known local-only credentials bound to a loopback host (the
  # universal local-dev database default is not a secret); the SAME literal bound
  # to a non-loopback host still flags. A spurious "possible secret" hit is the
  # worst failure mode -- it desensitises operators to the signal that matters.
  local secret_lines real_secrets
  secret_lines="$(grep -Eih '(password|passwd|secret|api[_-]?key|apikey|access[_-]?key|token)[^"]{0,24}=[^"=[:space:]]' $files 2>/dev/null || true)"
  if [ -n "$secret_lines" ]; then
    real_secrets="$(printf '%s\n' "$secret_lines" | while IFS= read -r line; do
      lc="$(printf '%s' "$line" | tr 'A-Z' 'a-z')"
      # Benign iff BOTH a loopback host AND a known local-default credential value.
      if printf '%s' "$lc" | grep -Eq '(127\.0\.0\.1|localhost)' \
         && printf '%s' "$lc" | grep -Eq '(pgpassword|postgres_password|password|passwd)=(postgres|password)'; then
        continue
      fi
      printf '%s\n' "$line"
    done)"
    if [ -n "$real_secrets" ]; then
      problems="$problems; possible secret literal in a permission rule (baseline: no secrets in settings)"
    fi
  fi
  # Deny list mandatory for an AEH-managed target (it has docs/AE/). Detection is
  # newline-tolerant: a normally pretty-printed "deny" array puts its first element
  # on the line after "[", so we collapse newlines before matching (a single-line
  # detector false-fails on every formatted config). The two-file union below
  # already covers a deny list living only in settings.local.json.
  if [ -d "$TARGET_PATH/docs/AE" ]; then
    local has_deny=0 f
    for f in $files; do
      # A "deny" key whose array is not immediately closed-empty (newline-tolerant).
      if tr '\n' ' ' < "$f" 2>/dev/null | grep -Eq '"deny"[[:space:]]*:[[:space:]]*\[[[:space:]]*"'; then has_deny=1; break; fi
    done
    [ "$has_deny" = 0 ] && problems="$problems; no non-empty deny list (baseline: deny list is mandatory -- block secrets, filesystem escape, harness isolation)"
  fi

  if [ -n "$problems" ]; then
    DETAIL="deterministic permission violation(s):${problems#; }"
    return 1
  fi
  DETAIL="no deterministic permission violation (bypass / filesystem-escape / secret-literal / missing-deny)"
  return 0
}

# claude-md-size: the target's CLAUDE.md is a router, not a manual -- it is read in
# full every session before a role/task is chosen, so size taxes every session. This
# is a SOFT budget (WARN, not FAIL): size alone is a crude signal; the real control
# is the reviewer's router-discipline judgment dimension. WARN above the budget so the
# operator notices accumulation; never block on it.
CLAUDE_MD_CHAR_BUDGET=40000
CLAUDE_MD_LINE_BUDGET=450
check_claude_md_size() {
  local f="$TARGET_PATH/CLAUDE.md"
  if [ ! -f "$f" ]; then
    DETAIL="no CLAUDE.md at target root"
    return 2
  fi
  local chars lines
  chars="$(wc -c < "$f" | tr -d ' ')"
  lines="$(wc -l < "$f" | tr -d ' ')"
  if [ "$chars" -gt "$CLAUDE_MD_CHAR_BUDGET" ] || [ "$lines" -gt "$CLAUDE_MD_LINE_BUDGET" ]; then
    DETAIL="CLAUDE.md is ${chars} chars / ${lines} lines (soft budget ${CLAUDE_MD_CHAR_BUDGET} chars / ${CLAUDE_MD_LINE_BUDGET} lines) -- apply router discipline: push role/task-specific detail to its owning home with a one-line pointer"
    return 3
  fi
  DETAIL="CLAUDE.md is ${chars} chars / ${lines} lines (within soft budget)"
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
    3) echo "  [WARN] $cid -- $DETAIL"; WARN_COUNT=$((WARN_COUNT + 1)) ;;
    *) echo "  [FAIL] $cid -- check returned unexpected code $rc (framework error)"; FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
  esac
done

echo ""
echo "=== Summary ==="
echo "  PASS: $PASS_COUNT   FAIL: $FAIL_COUNT   WARN: $WARN_COUNT   SKIP: $SKIP_COUNT   (of $ran registered)"

if [ "$PASS_COUNT" = 0 ] && [ "$FAIL_COUNT" = 0 ] && [ "$WARN_COUNT" = 0 ]; then
  echo "  NOTE: every check skipped -- nothing was actually verified for this target."
fi

[ "$FAIL_COUNT" -eq 0 ] && exit 0 || exit 1
