---
slug: harness-cross-container-isolation
status: archived
archived-at: 2026-06-19T19:18:24Z
since: 2026-05-31
---

# Harness Cross-Container Isolation

## What

Make the harness safe to run as parallel Claude Code sessions from separate Docker containers that bind-mount the same host harness directory. Today, parallel orchestrator sessions in different containers can silently contaminate each other's state through shared files in the bind-mounted tree.

## Why

When two or more AEH containers bind-mount the same host harness directory (one container per target project, each running its own orchestrator session), several shared files become contamination vectors:

1. **Per-target workspace ownership is unenforced.** Any container with the harness bind-mounted can read and write any `targets/<slug>/` workspace, with no signal that it is operating on the wrong target. Sessions can orient from a peer container's most recent writes to `targets/index.md` and confidently conclude their target is the peer's, then write prompts, state files, and commits into a workspace they should not be touching. The failure mode is silent contamination only caught by operator pattern-matching.

2. **Scheduled-tasks lockfile is global.** `/.claude/scheduled_tasks.lock` is a single shared file holding `{sessionId, pid, procStart, acquiredAt}` owned by Claude Code's scheduler (the `/loop`, `/schedule`, and `ScheduleWakeup` mechanism). Two containers running scheduled routines will collide on this lock; the pid/procStart inside it are container-local but the file path is shared. The current per-hostname persona-marker fix (`.claude/persona.$HOSTNAME` via `bin/resolve-persona-marker.sh`) is the right pattern to extend here.

3. **Per-project permission allowlist accumulates cross-container entries.** `/.claude/settings.local.json` is owned by Claude Code itself and shared across containers that mount the same project directory. The file accumulates permission grants from every container that touches the harness, including grants that reference paths only valid in one container (host-side macOS paths granted by a native session, visible-but-unusable in a sibling linux container). The path is not (currently) configurable per-host by harness-side code.

4. **Legacy `.claude/persona` marker.** The pre-per-hostname single marker file still exists alongside the four `persona.<hostname>` markers introduced by the resolver. Gitignored, but stale -- a candidate for one-shot cleanup.

5. **Future-risk: shared `~/.claude/projects/` bind-mounts.** Today, `~/.claude/` is container-private (on each container's VM disk). Claude Code's session transcript JSONLs, history, file-history, and project memory live there and are NOT a contamination vector in the current setup. The directory inside it is named by encoded-cwd; if any operator ever bind-mounts `~/.claude/projects/` host-to-container for cross-container session resume, both containers' sessions land in the same encoded-cwd directory and transcript JSONLs would interleave. The current setup is safe; this is a sharp edge worth a documentation warning.

## Scope

In scope:
- Per-`targets/<slug>/` ownership marker (hostname + Claude session id) with startup check
- Hostname-tagged journal entry convention
- Per-hostname scheduled-tasks lockfile (mirror of the persona-marker pattern)
- Legacy `.claude/persona` cleanup
- Documentation of the shared-mount contamination model + the `~/.claude/projects/` future-risk note
- One-shot migration mechanism that seeds ownership markers on existing `targets/<slug>/` directories on first contact
- Update to harness-reviewer / health-check to surface stale ownership

Out of scope:
- `.claude/settings.local.json` per-host scoping. The file path is owned by Claude Code itself and not configurable by harness-side code. Best addressed via an upstream feature request; this proposal documents the limitation and recommends one of (a) accept + document, (b) periodic janitor script stripping host-specific entries, (c) upstream issue. The choice is deferred to a follow-up proposal once the upstream channel is engaged.
- Multi-contributor governance (issue templates, PR templates, CONTRIBUTING.md expansion for adoption). Deferred until the first external PR is in flight; designing for an imagined contributor profile before evidence arrives risks building the wrong thing.
- Conversion of `~/.claude/` to a per-container volume in the harness's recommended container setup. Already true in the reference setup; the proposal only adds a documentation note for adopters running non-default container configurations.

## Acceptance criteria

1. **Targets workspace ownership** is enforceable: every `targets/<slug>/` carries an ownership marker file recording the last container that wrote to it (hostname + Claude session id + timestamp). Orchestrator session-init reads it; on mismatch with the current container, the orchestrator surfaces the divergence to the operator before continuing. On genuine ambiguity (no marker, or marker indicates a peer container), the orchestrator prompts the operator to confirm the target -- smart by default, ask when unclear.
2. **Journal entries are container-attributable**: hostname is part of every journal entry header so retrospective inspection can tell which container made which entry.
3. **Scheduled-tasks lockfile is per-host**: parallel containers do not collide on `scheduled_tasks.lock`. Mechanism mirrors the persona-marker resolver pattern.
4. **Legacy single persona marker is removed** from the working tree (one-shot operator action; the file is already gitignored).
5. **Migration is documented**: existing target workspaces gain ownership markers on first orchestrator contact under the new mechanism, without requiring a manual sweep.
6. **Contamination model is documented in CLAUDE.md**: a "Cross-container caveats" or equivalent section names the shared-mount surfaces, the per-host fixes applied, the unfixed `settings.local.json` limitation, and the `~/.claude/projects/` future-risk note.
7. **Harness-reviewer / health-check surfaces stale ownership**: a target whose ownership marker has not been touched in a long time, or whose hostname differs from the current container, is surfaced as a finding rather than silently consumed.

## Out-of-scope acknowledgements

- This proposal does NOT address the `.claude/settings.local.json` accumulation problem at mechanism level. The limitation is documented; remediation is a follow-up proposal contingent on upstream channel engagement.
- This proposal does NOT establish a multi-contributor governance pattern. That decision is deferred to the moment the first external pull request arrives, so the design is informed by real contribution shape rather than speculation.

## References

- Existing partial fix: `bin/resolve-persona-marker.sh` (per-hostname persona markers; pattern to extend).
- Existing publication-gate infrastructure: `bin/validate-personas.sh --staged` + `--message` modes.
- Related rule in CLAUDE.md: "Harness Maintenance Discipline" key-rules block, particularly the gitignore and review-intermediary rules.
