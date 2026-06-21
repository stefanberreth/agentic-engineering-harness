# Tasks -- harness-claude-md-consolidation

1. **Replace the Project Structure file tree with a pointer** + augment "What This
   Project Contains" to carry the orientation load.
   - Signal: no ASCII file-tree under `## Project Structure`; "What This Project
     Contains" names bin/openspec/playbooks/prompts/hooks/tools.
   - DONE.

2. **Collapse the per-target workspace file tree into its prose summary.**
   - Signal: no ASCII tree under "Target Project Workspace Structure".
   - DONE.

3. **Compress Session Init duplication:** per-role description paragraphs -> one-line
   forms; settled-exception note -> pointer to the f4 archive; stale taxonomy
   parenthetical removed.
   - Signal: the three role paragraphs are bullets; the settled-exception note is
     one line pointing at `openspec/changes/archive/aeh-engineer-role-f4/`.
   - DONE.

4. **Compress the longest Working Rules** (ground-truth-scan, CLAUDE.md-router,
   ASCII-only, no-target-details, execution-context, encode-behaviour, onboarding,
   assess-before-prescribing, prompt-handoff) to rule + resolvable pointer; keep
   every rule sentence.
   - Signal: each rule still present; rationale demoted.
   - DONE.

5. **Compress isolation/artifact prose** (CRITICAL RULE reasons, DOES/NEVER lists,
   Artifact Output Rule, Direct Delivery why/opt-out, bootstrap exception).
   - DONE.

6. **Verify:** all load-bearing invariants present; all pointers resolve; ASCII
   clean (new content); under the 40k native warning.
   - Signal: `wc -c CLAUDE.md` < 40000; invariant grep clean.
   - DONE (38,709 chars; -28% from 53,874).

7. **CHANGELOG [Unreleased] entry.** DONE.

8. **Gates:** publication gate (`--staged` + `--message`) PASS; harness-reviewer
   bookend APPROVE / APPROVE-WITH-MINOR before close-out.

Residual: the 30k soft budget is not reached this round -- the F2-mandated inline
role-location three-part signature (~3k, deliberately kept in CLAUDE.md) plus the
load-bearing session-init/banner content set a practical floor near 38k without
revisiting F2. Under the 40k native warning with ~1.3k margin. Further reduction
would need an F2 revisit (out of scope) or a target-CLAUDE.md-template follow-on.
