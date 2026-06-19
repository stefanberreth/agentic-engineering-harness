# B1 tasks

Mechanical completion signal in brackets per task.

1. [x] Create `templates/personas/aeh-engineer.md` covering the three duty
   families + the four folded items.
   [signal: file exists; `grep -c '^##' templates/personas/aeh-engineer.md` >= 6]
2. [x] Wire `CLAUDE.md`: valid-roles set, banner roster, structure tree,
   AEH-vs-Target taxonomy subsection, `aeh-engineer` role description, re-own
   publication-gate + harness-capture-triage + Harness-Maintenance-Discipline to
   `aeh-engineer`.
   [signal: `grep -c 'aeh-engineer' CLAUDE.md` >= 6; no "Owner: orchestrator" on the publication-gate rule]
3. [x] Add the role-taxonomy principle to `openspec/project.md`.
   [signal: `grep -q 'Role taxonomy' openspec/project.md`]
4. [x] Add `aeh-engineer.md` to `HARNESS_ROLES` in `bin/validate-personas.sh`.
   [signal: `grep -q 'aeh-engineer.md' bin/validate-personas.sh`]
5. [x] Add the AEH Engineer to the `README.md` roles table; mark Harness Reviewer
   detect-only.
   [signal: `grep -q 'AEH Engineer' README.md`]
6. [x] Subtract harness-maintenance from `templates/personas/orchestrator.md`
   (publication gate, review intermediaries, capture-triage side, propagation
   authoring, template-editing principle, harness-CHANGELOG mention); leave the
   universal capture right.
   [signal: residual scan -- orchestrator has no "## Publication Gate", no
   "## Review Intermediaries", no "### Triage-side behaviour"]
7. [x] CHANGELOG [Unreleased] entry.
   [signal: `grep -q 'aeh-engineer' CHANGELOG.md`]
8. [x] Publication gate passes (`--staged` + `--message`); commit; do NOT push.
   [signal: both validator invocations exit 0; commit landed on the local harness repo]
9. [ ] Harness-reviewer bookend before any push (deferred to the whole-rebuild
   publication-readiness sweep -- B1 does not push).
   [signal: harness-reviewer APPROVE/APPROVE-WITH-MINOR covering the rebuild surface]
