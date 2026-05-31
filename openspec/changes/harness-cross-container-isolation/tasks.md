---
slug: harness-cross-container-isolation
---

# Tasks: Harness Cross-Container Isolation

Ordered tasks for implementing the proposal. Each task carries a mechanical completion signal -- no UI-subjective gates.

## Phase 1: Ownership marker mechanism

### Task 1: Define ownership-marker file format and helper
- Add `bin/resolve-target-owner.sh` (mirrors `bin/resolve-persona-marker.sh` pattern): functions for read-marker, write-marker, compare-against-current.
- Marker file path: `targets/<slug>/.owner-container`.
- Marker format: shell-sourceable key=value lines (`hostname=`, `session-id=`, `last-touched=`).
- **Mechanical signal:** `bin/resolve-target-owner.sh --help` prints usage; `bin/resolve-target-owner.sh write <slug>` creates a valid marker file readable by `--read <slug>`.

### Task 2: Gitignore ownership markers in the targets repo
- Add `.owner-container` to the targets-repo `.gitignore` (a one-line append).
- **Mechanical signal:** for any existing target slug `<slug>`, running `git -C targets/ check-ignore <slug>/.owner-container` reports the file as ignored. The implementer substitutes a real slug at run time; no slug appears in this tracked file.

### Task 3: Update orchestrator persona session-init flow
- `templates/personas/orchestrator.md`: insert "Cross-container ownership check" subsection in the session-init flow, after the active-target resolution step.
- The subsection specifies: read marker via the helper; if absent -> claim; if matches -> silent proceed; if differs -> ask operator (yes / no / inspect); on ambiguous target resolution, ask operator before touching workspace.
- **Mechanical signal:** `grep -c "Cross-container ownership check" templates/personas/orchestrator.md` returns >= 1.

## Phase 2: Journal hostname tagging

### Task 4: Journal entry header convention update
- Update `templates/personas/orchestrator.md` journal-entry section: header format includes `container=<HOSTNAME> session=<uuid-prefix>`.
- Update `CLAUDE.md` if it references journal format.
- **Mechanical signal:** Journal entry example in the orchestrator template literally contains the strings `container=` and `session=`.

## Phase 3: Scheduler lockfile

### Task 5: Author `bin/resolve-scheduler-lock.sh`
- Mirror the persona-marker resolver pattern: per-hostname lockfile when `$HOSTNAME` is non-trivial; legacy single file otherwise.
- Opportunistic stale-lock cleanup of per-host locks > 24h old.
- **Mechanical signal:** `bin/resolve-scheduler-lock.sh` prints a path; the path includes `$HOSTNAME` when running in a container, otherwise the legacy form.

### Task 6: Verify whether scheduler honours redirection
- Determine experimentally (or via the scheduler docs / source) whether the Claude Code scheduler can be pointed at a non-default lockfile via environment variable, wrapper, or config.
- **Mechanical signal:** A brief note added to `openspec/changes/harness-cross-container-isolation/design.md` (or a new `verification-notes.md` in the change dir) records the answer.

### Task 7: Branch on Task 6 outcome
- **If redirection is supported:** wire the resolver into the scheduler invocation path. Update gitignore for per-host lockfiles. Mechanical signal: running `/loop` or a scheduled task creates a file at the resolver's per-host path.
- **If redirection is NOT supported:** keep the resolver script, gitignore the per-host filenames anyway (defensive), document the limitation in the cross-container caveats section, and file an upstream issue. Mechanical signal: an issue URL recorded in `openspec/changes/harness-cross-container-isolation/upstream-issues.md`.

## Phase 4: Legacy cleanup and documentation

### Task 8: Remove legacy `.claude/persona` from working tree
- Operator action: `rm -f .claude/persona`.
- **Mechanical signal:** `test -e .claude/persona` returns non-zero.

### Task 9: CLAUDE.md cross-container caveats section
- Add a "Cross-container caveats" subsection to CLAUDE.md (under "Harness Maintenance Discipline" or as its own H2).
- Cover: shared-mount surfaces (per-target workspaces, scheduler lock, settings.local.json, legacy persona marker); per-host resolvers (`bin/resolve-persona-marker.sh`, `bin/resolve-target-owner.sh`, `bin/resolve-scheduler-lock.sh`); the unfixed `settings.local.json` limitation with the three follow-up options; the `~/.claude/projects/` future-risk note.
- **Mechanical signal:** `grep -c "Cross-container caveats" CLAUDE.md` returns >= 1; section names all three resolvers.

### Task 10: Update `.gitignore` entries
- Ensure harness `.gitignore` covers any new per-host artefacts introduced by this change (scheduler lock variants if applicable).
- **Mechanical signal:** `git status --short` after a representative orchestrator session shows no untracked per-host files.

## Phase 5: Detection in reviewer / health-check

### Task 11: Health-check playbook ownership-marker check
- `templates/playbooks/health-check.md`: new check item verifying the target's ownership marker exists and its hostname matches the current container.
- Severity: MEDIUM on mismatch (surface for operator decision, do not block).
- **Mechanical signal:** `grep -c "ownership marker" templates/playbooks/health-check.md` returns >= 1.

### Task 12: Update harness-reviewer to verify documentation completeness
- `templates/personas/harness-reviewer.md`: add a check under Dimension 5 (Isolation Boundary Integrity) or Dimension 3 (Documentation Currency) that the cross-container caveats section exists and names the three resolvers.
- **Mechanical signal:** `grep -c "cross-container caveats" templates/personas/harness-reviewer.md` returns >= 1 (case-insensitive).

## Phase 6: CHANGELOG and archive

### Task 13: CHANGELOG entry
- Add an entry under [Unreleased] / Added (or Security if the framing favours that) summarising the change.
- **Mechanical signal:** `grep -c "cross-container" CHANGELOG.md` returns >= 1 in an Unreleased entry.

### Task 14: Archive the proposal
- Move `openspec/changes/harness-cross-container-isolation/` to `openspec/changes/archive/harness-cross-container-isolation/` once Tasks 1-13 are complete and the harness-reviewer bookend has passed.
- Apply spec deltas (this proposal does not introduce a formal capability spec; the change is process and mechanism, captured in CLAUDE.md and the resolver scripts -- no `openspec/specs/` writes).
- **Mechanical signal:** `test -d openspec/changes/archive/harness-cross-container-isolation` returns zero; `test -d openspec/changes/harness-cross-container-isolation` returns non-zero.

## Notes for the implementer

- Tasks 1, 3, 5 are independent and can land in any order. Task 2 depends on Task 1's marker filename. Tasks 8-12 are documentation and cleanup; bundle in a single commit if convenient.
- Per the harness's "commit freely, push at boundaries" discipline: commit each completed task individually; push at the end of Phase 4 (caveats documented) and again after Phase 5 (detection wired).
- Run the publication gate (`bin/validate-personas.sh --staged` + `--message`) before every commit.
- The full change should pass the harness-reviewer bookend before archive. Dimension 1 (target-detail leakage), Dimension 3 (documentation currency), Dimension 5 (isolation boundary integrity) are the most relevant dimensions.
