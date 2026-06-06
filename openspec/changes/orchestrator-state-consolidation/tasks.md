# Tasks: Orchestrator state consolidation + context-disposability gate

Ordered. Each task carries a mechanical completion signal.

## 1. Update orchestrator.md State Initialisation + Principles

- Reduce the canonical-filename set: remove `decisions.md`, `open-questions.md`, `review-history.md` from the "eleven canonical filenames" allowlist in Principles (it becomes the reduced set; update the count in prose).
- Add a `## Open Questions` section to the state-file format template under "State Initialisation".
- Document the journal tagging convention (`[DECISION]`, `[REVIEW]`, `[SESSION]`, `[GATE]`) where the state model is described.
- **Signal:** `grep -c 'decisions.md\|open-questions.md\|review-history.md' templates/personas/orchestrator.md` returns 0 in the canonical-set/allowlist context (legacy mentions only inside the migration/retrofit note are allowed and labelled as such); `grep '## Open Questions' templates/personas/orchestrator.md` matches.

## 2. Add the Pre-clear reconciliation subsection to orchestrator.md

- New subsection near "State Initialisation": the reconstruct-and-diff procedure (design.md section 4), the delta-log line format, and the "fix the slot, not just the instance" rule.
- **Signal:** `grep -i 'pre-clear reconciliation' templates/personas/orchestrator.md` matches; the subsection contains the literal `pre-clear delta:` log-line format.

## 3. Update CLAUDE.md Target Project Workspace Structure

- Update the `targets/<slug>/` file listing to the reduced canonical set; add a one-line note that decisions/review-history live as tagged journal entries and open-questions live in the dashboard.
- **Signal:** the `targets/<slug>/` tree in CLAUDE.md no longer lists `decisions.md`, `open-questions.md`, `review-history.md` as separate files; `diff` of the file-set described in CLAUDE.md vs orchestrator.md State Initialisation shows no divergence.
- **Signal:** `wc -c CLAUDE.md` does not increase past the 40k limit (consolidation must not re-inflate CLAUDE.md).

## 4. Add the forgetting question to harness-reviewer

- Add the "still earns its place" question to Dimension 3 (Documentation Currency) of `templates/personas/harness-reviewer.md`.
- **Signal:** `grep -i 'earn its place\|earns its place\|dead wood' templates/personas/harness-reviewer.md` matches within Dimension 3.

## 5. Before/after function table (acceptance proof)

- Add a short before/after function-preservation table to the CHANGELOG entry or a one-paragraph note in this proposal directory confirming each retired file's function has a destination.
- **Signal:** the migration mapping table in design.md section 3 has a row for every retired file, and each row names a destination + lookup mechanism. (Already present; this task verifies no retired file is unmapped.)

## 6. Retrofit prompt template for existing targets

- Create `templates/prompts/migrate-state-satellites.md.template`: instructs a harness session to fold a target's `decisions.md` / `open-questions.md` / `review-history.md` into journal tags + dashboard section, then remove the satellite files. Target-detail-free, ASCII-only.
- **Signal:** file exists at `templates/prompts/migrate-state-satellites.md.template` and references only generic placeholders (`<slug>`).

## 7. CHANGELOG entry

- Add to `CHANGELOG.md` [Unreleased] Changed: orchestrator state consolidation + pre-clear reconciliation gate + harness-reviewer forgetting question.
- **Signal:** `grep -i 'state consolidation\|pre-clear' CHANGELOG.md` matches under [Unreleased].

## 8. Harness-reviewer bookend + publication gate

- Run the harness-reviewer 10-dimension pass over the changed files (Dimension 1 mandatory).
- Run `bin/validate-personas.sh --staged` and `--message` before commit.
- **Signal:** harness-reviewer verdict is APPROVE / APPROVE-WITH-MINOR; validator exits 0 on staged content and message.

## 9. Update project structure tree + commit

- Verify CLAUDE.md / README.md / CHANGELOG.md / project structure tree are current.
- Single commit (no AI attribution; ASCII-only message).
- **Signal:** `git status` clean post-commit; commit message references the slug.

## Close-out (after implementation + bookend)

- This is a process/mechanism proposal touching personas + CLAUDE.md + templates; it may introduce a small capability spec for "orchestrator state model" under `openspec/specs/` if the maintainer wants the canonical set spec'd. Decide at close-out. If no spec, steps 1-2 of the close-out playbook are no-ops; archive after status flip + move.
