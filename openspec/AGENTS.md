# OpenSpec Close-Out Playbook (AEH harness self)

When a change proposal under `openspec/changes/<slug>/` completes its implementation and passes the harness-reviewer bookend, archive it via this mechanical sequence. The proposal stops being active when the sequence completes; the durable record is the spec deltas applied to parent specs + the archived proposal directory.

This playbook governs harness-self change proposals. Target projects that adopt OpenSpec via `templates/tools/openspec-setup.md` receive an equivalent `AGENTS.md` adapted for their tree.

## Mechanical close-out sequence

1. **Apply spec deltas to parent specs.** For each spec file the proposal updated or created (typically files under `openspec/changes/<slug>/specs/`), apply the delta to the corresponding `openspec/specs/<capability>/spec.md`. If the proposal introduces a new spec, create `openspec/specs/<new-capability>/spec.md` directly with frontmatter `since: <change-slug>` and `status: current`.

   Many harness-self proposals do not introduce a formal capability spec -- the proposal's value is process/mechanism, captured in `templates/`, `bin/`, `CLAUDE.md`, and the persona templates. For those proposals, this step is a no-op; skip to step 2.

2. **Bump parent spec metadata.** For every spec touched by the deltas, ensure frontmatter carries `last-updated-by: <change-slug>` and `updated: <ISO date>`. Specs that were not touched stay unchanged.

3. **Set proposal status: archived.** Edit the proposal's `proposal.md` frontmatter: change `status:` to `archived`, add `archived-at: <ISO timestamp>`. Tasks.md may also be touched to mark final tasks complete.

4. **Move proposal directory to archive.** `mv openspec/changes/<slug>/ openspec/changes/archive/<slug>/`. The archive preserves the full proposal history (proposal.md, design.md, tasks.md, specs/, provenance.md) as a permanent record of why the parent specs look the way they do -- or, for process/mechanism proposals, why the harness behaves the way it does.

## Commit convention

Single commit per close-out, message format:

```
openspec(close): <change-slug> -- archived

- Apply spec deltas to <capabilities-touched> (or "no spec deltas; process change")
- Bump parent spec updated dates (if applicable)
- Move proposal to openspec/changes/archive/<slug>/
```

The commit lands on `main`. No separate close-out branch; the proposal is structurally complete before close-out runs.

## Spec-frontmatter discipline

Each spec under `openspec/specs/<capability>/spec.md` carries:
- `since:` -- the change-slug that introduced this spec.
- `last-updated-by:` -- the most recent change-slug that modified this spec.
- `updated:` -- ISO date of the last modification.
- `status:` -- `draft` | `current` | `superseded` | `archived` (per `openspec/project.md` § "Status vocabulary").

These let any future reader trace a spec back to the proposal(s) that shaped it.

## Edge cases

- **Proposal blocked at logical-close.** Work complete but waiting on something external (upstream library, operator action, sibling proposal, downstream verification): keep at `status: ready-for-archive`; do NOT archive. Close-out runs only when nothing blocks. The proposal stays under `openspec/changes/<slug>/` (not archive/) until the block clears.

- **Proposal abandoned.** Work started but won't complete: set `status: abandoned`, move to `openspec/changes/archive/<slug>/` with `archived-at:` and `abandonment-reason:` in the frontmatter. Spec deltas are NOT applied (proposal didn't complete). Abandoned proposals are still archived (not deleted) -- the historical record is valuable even when work didn't ship.

- **Proposal supersedes an earlier one.** The earlier proposal's archive entry remains; the new proposal's `proposal.md` notes `supersedes: <earlier-slug>`. The earlier proposal's specs retain their `since:` value but the `last-updated-by:` advances to the superseding proposal.

- **Process/mechanism proposals with no formal capability spec.** Many harness-self proposals don't introduce specs (the value is in templates/personas/playbooks/CLAUDE.md changes). For these, steps 1-2 are no-ops; archive after steps 3-4. The proposal directory under `archive/` is the historical record.

## Harness-reviewer bookend

The harness-reviewer's standard 10-dimension review runs before close-out, not after. Close-out happens once the bookend is APPROVE / APPROVE-WITH-MINOR. If the bookend returns REQUEST-CHANGES, address the changes first, re-bookend, then close out.

## Pointer to setup-template equivalent

The canonical playbook content lives in this file for the harness-self tree. For targets that adopt OpenSpec via the harness, the same content (adapted) installs at setup time per `templates/tools/openspec-setup.md` § "Step 1". The retrofit prompt template at `templates/prompts/openspec-close-out-retrofit.md.template` brings pre-existing targets (already-installed `openspec/` without `AGENTS.md` or `changes/archive/`) up to the convention.
