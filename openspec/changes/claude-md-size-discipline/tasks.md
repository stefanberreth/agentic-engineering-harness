---
slug: claude-md-size-discipline
---

# Tasks

## Task 1: Inventory CLAUDE.md by section + size
- Produce a short table: section heading, current char count, extraction candidacy (yes / no / partial), proposed reference doc filename.
- Land as `docs/claude-md-inventory-2026-06-01.private.md` (working artefact, gitignored) -- not a tracked deliverable.
- **Signal:** inventory exists; extraction candidates identified.

## Task 2: Decide reference-doc directory path
- Operator chooses: `docs/harness-rules/` / `docs/harness-discipline/` / other.
- Captured in `decisions.md` (this proposal directory).
- **Signal:** path decision recorded.

## Task 3: Author reference docs per extracted topic
- One file per topic identified in Task 1. Initial list per scope: cross-container-isolation, capture-inbox, propagation-signal, openspec-self-dogfooding, openspec-target-detail-free-discipline, publication-gate-and-review-intermediaries, gitignore-vs-untrack.
- Each reference doc: short H1 + 1-2 paragraph rationale + mechanism detail + relevant cross-references back to CLAUDE.md and template files.
- **Signal:** every extracted CLAUDE.md bullet has a reference doc.

## Task 4: Rewrite CLAUDE.md bullets
- Each extracted bullet becomes: `- **Topic.** One-sentence rule. Detail: <pointer-to-reference-doc>.`
- Preserve rule semantics; do NOT rewrite or rephrase the rule sentence.
- **Signal:** word-diff of CLAUDE.md shows rule sentences preserved; rationale paragraphs gone; pointers present.

## Task 5: Coordinate with harness-role-execution-context-discipline
- That proposal adds an Execution context column to the roles list; coordinate the edits so both land cleanly in one commit (or sequence them: roles-table edit first, slim second).
- **Signal:** no merge conflict between the two proposals' CLAUDE.md edits.

## Task 6: Confirm size + harness-reviewer pass
- `wc -c CLAUDE.md` reports < 30k (target; firm < 35k).
- Harness-reviewer ran; pointer-resolution dimension passes; no rule semantics regressions.
- **Signal:** size in range + reviewer PASS.

## Task 7: Pointer-resolution check in harness-reviewer
- Add a dimension entry: "every CLAUDE.md `Detail: <pointer>` line resolves to an existing file."
- **Signal:** dimension entry committed.

## Task 8: CHANGELOG + archive
- CHANGELOG entry under [Unreleased] Changed.
- Archive proposal post-bookend.
