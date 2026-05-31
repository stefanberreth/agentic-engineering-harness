#!/usr/bin/env bash
# resolve-target-owner.sh -- read / write / compare the per-target ownership marker
#
# Per-target ownership marker prevents silent cross-container contamination
# when multiple AEH containers bind-mount the same harness directory and each
# runs an orchestrator session for a different target. The marker file at
# targets/<slug>/.owner-container records the hostname + Claude session id
# of the most recent container to write to that target's workspace.
#
# Marker format (shell-sourceable key=value):
#   hostname=<container HOSTNAME>
#   session-id=<Claude session UUID if known, or 'unknown'>
#   last-touched=<ISO 8601 UTC timestamp>
#
# Usage:
#   bin/resolve-target-owner.sh --read <slug>          # echo marker contents (or nothing if absent)
#   bin/resolve-target-owner.sh --write <slug> [sid]   # write/update marker for current container
#   bin/resolve-target-owner.sh --check <slug>         # exit 0 if owner matches current hostname,
#                                                      # exit 1 if owner differs (peer container),
#                                                      # exit 2 if marker absent
#   bin/resolve-target-owner.sh --hostname <slug>      # echo just the owner hostname (or nothing)
#
# The marker file is gitignored at the targets-repo level (per-container ephemera;
# not durable state). See openspec/changes/harness-cross-container-isolation/.

set -u

usage() {
  cat >&2 <<'EOF'
Usage:
  bin/resolve-target-owner.sh --read <slug>
  bin/resolve-target-owner.sh --write <slug> [session-id]
  bin/resolve-target-owner.sh --check <slug>
  bin/resolve-target-owner.sh --hostname <slug>
EOF
  exit 64
}

[[ $# -lt 2 ]] && usage

CMD="$1"
SLUG="$2"
MARKER="targets/${SLUG}/.owner-container"
CURRENT_HOST="${HOSTNAME:-unknown}"

case "$CMD" in
  --read)
    if [[ -f "$MARKER" ]]; then cat "$MARKER"; fi
    ;;
  --hostname)
    if [[ -f "$MARKER" ]]; then grep '^hostname=' "$MARKER" 2>/dev/null | head -1 | cut -d= -f2-; fi
    ;;
  --write)
    SID="${3:-unknown}"
    TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    mkdir -p "targets/${SLUG}"
    {
      echo "hostname=${CURRENT_HOST}"
      echo "session-id=${SID}"
      echo "last-touched=${TS}"
    } > "$MARKER"
    ;;
  --check)
    if [[ ! -f "$MARKER" ]]; then
      exit 2
    fi
    OWNER=$(grep '^hostname=' "$MARKER" 2>/dev/null | head -1 | cut -d= -f2-)
    if [[ "$OWNER" == "$CURRENT_HOST" ]]; then
      exit 0
    else
      exit 1
    fi
    ;;
  *)
    usage
    ;;
esac
