# Tasks: Subtraction-completeness discipline

Ordered. Process/mechanism change -- no formal spec deltas. Each task carries a mechanical signal.

## 1. architect §8 Principles -- plan-time subtraction discipline

- Add a Principles bullet: a design that removes/renames/folds a convention enumerates producers + consumers; `tasks.md` carries the sweep as explicit tasks with a residual-scan completion signal.
- **Signal:** `grep -ci 'subtraction\|removes/renames/folds\|sweep.*consumer' templates/personas/architect.md` >= 1 within §8 Principles.

## 2. reviewer -- residual-scan-clean completion rule + Absence Check tie-in

- Add a Principles bullet: a change that retires a token is incomplete until a residual scan over that token is clean (only labelled migration notes + out-of-scope history remain); a surviving reference in canonical-set context is a finding.
- Add a one-line tie-in to the Absence Check dimension (the inverse blind spot: references that should be gone but are not).
- **Signal:** `grep -ci 'residual scan\|retires.*token\|removed but still referenced\|subtraction' templates/personas/reviewer.md` >= 1.

## 3. harness-reviewer Dimension 4 -- explicit subtraction check

- Add a Dimension 4 bullet: for any harness change that retires/renames/folds a convention, confirm a repo-wide residual scan is clean and every consumer was swept; pair it explicitly with the Dimension-3 forgetting question (decide-to-remove vs remove-completely).
- **Signal:** `grep -ci 'residual scan\|subtraction\|swept' templates/personas/harness-reviewer.md` >= 1 within Dimension 4.

## 4. Consistency check

- The three additions state one discipline in three role-appropriate framings; no contradiction.
- **Signal:** manual read confirms consistent wording.

## 5. CHANGELOG entry

- Add to `CHANGELOG.md` [Unreleased] Added.
- **Signal:** `grep -ci 'subtraction-completeness\|subtraction completeness' CHANGELOG.md` >= 1.

## 6. Bookend + publication gate + commit

- Run `bin/validate-personas.sh` (full + --staged + --message). Block on FAIL.
- Single commit, decoupled from `orchestrator-state-consolidation` (lesson: do not bundle distinct changes). Local only; no push.
- **Signal:** validator exits 0; `git log --oneline -1` references the slug.
