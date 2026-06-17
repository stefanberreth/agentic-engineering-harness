#!/usr/bin/env bash
# resolve-persona-marker.sh — echo the correct .claude/persona marker path for this environment
#
# Behaviour:
# - If running inside a Docker/container environment AND $HOSTNAME is set to a non-trivial value:
#   echoes .claude/persona.${HOSTNAME} (per-container marker)
# - Otherwise:
#   echoes .claude/persona (unchanged legacy behaviour for single-directory-no-Docker setups)
#
# Rationale: parallel AEH target-orchestrator sessions running in separate Docker containers that
# bind-mount the same /workspace/aeh/ otherwise race/stomp a single .claude/persona file.
# Docker provides per-container $HOSTNAME by default, giving us a free identity discriminator.
# Non-Docker users see no change.
#
# Usage (from Step 0 blocks, session init, etc.):
#   MARKER=$(bin/resolve-persona-marker.sh)
#   echo "$role" > "$MARKER"
#   cat "$MARKER"
#
# Side effect: opportunistic stale-marker cleanup. Per-hostname markers untouched for >30 days
# are removed (handles container-rebuild churn where hostnames change). Errors suppressed.

set -u

in_container() {
  [[ -e /.dockerenv ]] && return 0
  if [[ -r /proc/1/cgroup ]]; then
    grep -qE 'docker|containerd|lxc|kubepods' /proc/1/cgroup 2>/dev/null && return 0
  fi
  if [[ -r /proc/self/cgroup ]]; then
    grep -qE 'docker|containerd|lxc|kubepods' /proc/self/cgroup 2>/dev/null && return 0
  fi
  return 1
}

# Opportunistic stale-marker cleanup — remove per-hostname markers untouched >30 days.
# Non-fatal if the .claude/ directory doesn't exist yet.
find .claude -maxdepth 1 -name 'persona.*' -type f -mtime +30 -delete 2>/dev/null || true

if in_container && [[ -n "${HOSTNAME:-}" && "${HOSTNAME}" != "localhost" ]]; then
  echo ".claude/persona.${HOSTNAME}"
else
  echo ".claude/persona"
fi
