# Tasks: Retrospective elicitation convention

Ordered. Process/persona change -- no formal spec deltas. Each task carries a mechanical signal.

## 1. architect base template -- Design Retrospective subsection

- Add a "Design Retrospective" subsection (target base template), simplicity-focused, mirroring the developer's §7 format; route output to `docs/AE/reports/design-<slug>-retrospective.md`. No reference to the orchestrator (cross-layer).
- **Signal:** `grep -ci 'Design Retrospective\|radically simpler\|simpler in hindsight' templates/personas/architect.md` >= 1.

## 2. orchestrator role -- explicit elicitation responsibility

- Add a Principle (+ behaviour note) that the orchestrator elicits hindsight retrospectives by building the ask, with the simplicity framing, into the report-back of substantive prompts -- not relying on the target persona's own end-of-task retrospective to fire.
- **Signal:** `grep -ci 'elicit.*retrospective\|retrospective.*report-back\|simpler in hindsight' templates/personas/orchestrator.md` >= 1.

## 3. Layer-cleanliness check

- architect addition references no harness-only construct (orchestrator, Dimension-N, harness-reviewer); orchestrator addition's references to architect/developer retrospectives are about the target agents it dispatches.
- **Signal:** manual diff read; `git diff` of architect addition contains no `orchestrator`/`harness-reviewer`.

## 4. CHANGELOG + intake annotation

- CHANGELOG [Unreleased] Added entry.
- Annotate the originating `_intake` capture: items 1-2 triaged into this proposal; items 3-5 remain.
- **Signal:** `grep -ci 'retrospective elicitation\|Design Retrospective' CHANGELOG.md` >= 1; intake file carries a triage note.

## 5. Bookend + publication gate + commit

- `bin/validate-personas.sh` full + `--staged` + `--message`. Block on FAIL. ASCII-only check on additions.
- Single commit, decoupled from the other two changes this session. Local only; no push.
- **Signal:** validator exits 0; `git log --oneline -1` references the slug.
