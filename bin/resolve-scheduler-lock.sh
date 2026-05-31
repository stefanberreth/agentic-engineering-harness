#!/usr/bin/env bash
# resolve-scheduler-lock.sh -- echo the correct scheduled_tasks lockfile path for this environment
#
# Mirror of bin/resolve-persona-marker.sh. The Claude Code scheduler (used by /loop,
# /schedule, ScheduleWakeup) writes a lockfile at .claude/scheduled_tasks.lock. When two
# AEH containers bind-mount the same harness directory, they race / stomp the single
# shared lockfile. This resolver gives each container its own per-hostname lockfile path.
#
# Behaviour:
# - Container + non-trivial $HOSTNAME: echoes .claude/scheduled_tasks.lock.${HOSTNAME}
# - Otherwise: echoes .claude/scheduled_tasks.lock (legacy single-file behaviour)
#
# Caveat: this only helps if the Claude Code scheduler honours an environment-variable
# or wrapper that redirects its lockfile path. If the scheduler hardcodes the legacy
# path, this resolver is informational only (used by docs + health-check + future
# wrapper code) until upstream supports redirection. See openspec/changes/
# harness-cross-container-isolation/ for the upstream-issue plan.
#
# Usage:
#   LOCK=$(bin/resolve-scheduler-lock.sh)
#   echo "$LOCK"
#
# Opportunistic stale-lock cleanup: per-hostname lockfiles untouched >24h are removed
# (handles container-rebuild churn).

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

# Stale-lock cleanup: per-hostname lockfiles untouched >24h.
find .claude -maxdepth 1 -name 'scheduled_tasks.lock.*' -type f -mmin +1440 -delete 2>/dev/null || true

if in_container && [[ -n "${HOSTNAME:-}" && "${HOSTNAME}" != "localhost" ]]; then
  echo ".claude/scheduled_tasks.lock.${HOSTNAME}"
else
  echo ".claude/scheduled_tasks.lock"
fi
