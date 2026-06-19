---
slug: harness-cross-container-isolation
---

# Design: Harness Cross-Container Isolation

## Context

The harness is designed to run as a Claude Code session inside a Docker container. The typical setup bind-mounts the host harness directory into the container at a known path so the maintainer's local working tree is the source of truth, and the container is interchangeable. The harness has matured to support parallel operation -- one container per target project, each running its own orchestrator session, all bind-mounting the same host harness directory.

Parallel operation surfaces shared-state issues invisible to the single-container case. A read-only audit performed against `/proc/mounts` and the contents of the bind-mounted `.claude/` directory established:

- `~/.claude/` is on the container's own VM disk in the reference setup; Claude Code's session/transcript/memory state is container-private and is NOT a contamination vector.
- The bind-mounted `.claude/` in the harness tree contains Claude-Code-managed files that ARE shared: `scheduled_tasks.lock`, `settings.local.json`, and legacy `persona`.
- The `targets/` private nested repo contains entirely shared per-target workspaces with no ownership signal.

The existing per-hostname persona-marker fix (`bin/resolve-persona-marker.sh`, marker at `.claude/persona.$HOSTNAME` with opportunistic stale-marker cleanup) is the right pattern to extend to other shared files.

## Mechanism

### 1. Per-target workspace ownership

Each `targets/<slug>/` gains an ownership marker file at `targets/<slug>/.owner-container`. Format:

```
hostname=<container HOSTNAME>
session-id=<Claude Code session UUID, when available>
last-touched=<ISO 8601 timestamp>
```

The marker is updated by the orchestrator on every session that performs a write to the workspace (state files, journal entries, prompt generation, deliverable production). It is git-ignored at the targets-repo level (it is per-container ephemera, not durable state).

Session-init reads `targets/<slug>/.owner-container` after determining the active target:

- If absent -> mark this container as the owner and proceed.
- If hostname matches current container -> silent proceed.
- If hostname differs -> surface to the operator: "This target was last touched by container `<peer-hostname>` at `<timestamp>`. Continue as owner-of-record from this container? (yes / no / inspect)".

For session-init flows where the active target is itself ambiguous (no target nominated, multiple plausible candidates, ownership markers point in different directions), the orchestrator asks the operator to confirm the target before touching any workspace files. Default to smart inference where possible; ask when unclear -- the cost of an unintended cross-target write is higher than the cost of one confirmation question.

### 2. Hostname-tagged journal entries

Journal entries in `targets/<slug>/journal.md` carry a hostname tag in their header line. Convention:

```
## YYYY-MM-DD HH:MM container=<HOSTNAME> session=<uuid-prefix>
```

This is purely an audit trail; the journal stays human-readable. Retrospective inspection can tell which container made which entry without forensic git work.

### 3. Per-host scheduled-tasks lockfile

Add `bin/resolve-scheduler-lock.sh` mirroring the persona-marker resolver pattern:

- Single-directory-no-Docker setup: lockfile is `.claude/scheduled_tasks.lock` (unchanged legacy).
- Docker/container setup with a non-trivial `$HOSTNAME`: lockfile is `.claude/scheduled_tasks.lock.$HOSTNAME`.
- Opportunistic stale-lock cleanup of per-host locks untouched for > 24h.

Caveat: this requires the Claude Code scheduler to honour an environment variable or wrapper that redirects its lockfile path. If the scheduler hardcodes `.claude/scheduled_tasks.lock`, the resolver script alone is insufficient and an upstream change is needed; in that case the proposal lands the resolver, gitignore the per-host variants, document the limitation, and file an upstream issue. The task list captures this branch.

### 4. Legacy `.claude/persona` cleanup

The pre-per-hostname single marker file at `.claude/persona` is gitignored (covered by `.claude/persona` and `.claude/persona.*` entries in the harness `.gitignore`). It is harmless given the resolver but stale. One-shot removal: operator deletes the file; resolver continues to work via the per-hostname markers.

### 5. Documentation

A new "Cross-container caveats" subsection in CLAUDE.md (or under "Harness Maintenance Discipline") covers:

- The shared-mount surfaces and which ones are fixed by per-host mechanisms.
- The unfixed `settings.local.json` accumulation problem with the three options for follow-up.
- The `~/.claude/projects/` future-risk note (current setup safe; risk only materialises if an adopter bind-mounts `~/.claude/projects/` host-to-container).
- Pointer to `bin/resolve-persona-marker.sh` and `bin/resolve-scheduler-lock.sh` as the canonical per-host resolvers.

### 6. Migration

No backfill is needed. The first orchestrator session that touches each existing `targets/<slug>/` workspace under the new mechanism writes the ownership marker on first contact (treating absent-marker as "this container claims ownership"). The orchestrator persona's session-init flow is updated to perform this seeding step. Operator action required: none.

### 7. Harness-reviewer / health-check enforcement

- Harness-reviewer: add a check that every `targets/<slug>/` has an ownership marker after onboarding completes (target health, not harness health -- so this actually lives in the health-check playbook, see below).
- Health-check playbook: a new check verifies the target's ownership marker hostname matches the current container; on mismatch, surface as a MEDIUM finding ("this target was last touched by a different container; verify intended ownership before continuing work").

## Alternatives considered

**A. Move `.claude/` itself to per-container storage.** Rejected. Breaks the "harness config lives with the harness" principle; per-hostname suffixes on individual files achieve the same isolation with less disruption and preserve the bind-mount model.

**B. Lock the entire `targets/` directory with a single global ownership marker per container.** Rejected. The granularity is wrong -- the operator wants to run different targets from different containers, so the natural ownership unit is per-target, not per-targets-tree.

**C. Add a startup interactive picker for the active target unconditionally.** Rejected as the default. Forces friction on the 95% case (operator knows which target they are on) to prevent the 5% case (genuine ambiguity). Better: prompt only when ownership signals indicate ambiguity. Smart by default, ask when unclear -- consistent with the broader harness preference for cheap-when-unambiguous, careful-when-ambiguous behaviour.

**D. Container-level locking on `targets/<slug>/`.** Rejected as over-engineering. Soft ownership markers + operator confirmation handle the realistic failure mode; hard locking would prevent legitimate cross-container takeover (e.g. operator moves a target's primary session from container A to container B).

## Trade-offs

- **Ownership markers add a small per-target file.** Acceptable; gitignored at the targets-repo level, invisible in normal use.
- **Hostname-tagged journal headers slightly change the journal format.** Acceptable; backwards-compatible (older entries without the tag stay readable, new entries carry the tag).
- **Scheduler-lockfile redirection may need an upstream change.** Documented in the task list as a branch; if upstream is unavailable, the proposal still lands documentation and the resolver script, with the scheduler limitation captured.

## Migration risk

Low. No state schema changes; markers are added on first contact; existing journal entries remain valid; per-host scheduler locks are additive. The only operator-visible change is the new confirmation prompt on cross-container ambiguity, which is the desired behaviour.
