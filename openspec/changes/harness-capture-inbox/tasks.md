---
slug: harness-capture-inbox
---

# Tasks: Harness Capture Inbox

Ordered tasks with mechanical completion signals.

## Phase 1: Inbox directory + format

### Task 1: Create `openspec/changes/_intake/` with README
- New directory.
- `README.md` inside it documents the file format (filename convention, frontmatter, body shape), the atomic write protocol, the two landing points (`_intake/` vs `BACKLOG.md`), and the triage flow.
- **Mechanical signal:** `test -f openspec/changes/_intake/README.md` returns zero; the README mentions both landing points by name.

### Task 2: Gitignore temp files
- Add `openspec/changes/_intake/.tmp.*` to harness `.gitignore` so atomic-write temp files cannot accidentally commit if a write is interrupted.
- **Mechanical signal:** `git check-ignore openspec/changes/_intake/.tmp.test.md` returns the matched ignore line.

## Phase 2: Orchestrator persona update

### Task 3: Capture-side behaviour in orchestrator persona template
- `templates/personas/orchestrator.md`: new section "Harness Capture (proactive identification, operator-gated)".
- Section content: when to identify a candidate, the always-ask confirmation prompt (never silent), the two-landing-point decision (target-detail-free -> `_intake/`; target context -> BACKLOG), the atomic write protocol (write `.tmp.<name>`, rename), filename convention with hostname suffix, frontmatter schema.
- Includes a worked example showing the orchestrator surfacing a candidate, the operator confirming, and the resulting file content.
- **Mechanical signal:** `grep -c "Harness Capture" templates/personas/orchestrator.md` returns >= 1; `grep -c "never capture silently\|never silent" templates/personas/orchestrator.md` returns >= 1.

### Task 4: Triage-side behaviour in orchestrator persona template
- Same file. Either as a new subsection of the Harness Capture section or alongside the existing session-init flow.
- Content: session-init scan of `openspec/changes/_intake/` for `status: untriaged`, banner-area surfacing of the count, the triage walk on operator request (promote / defer / reject outcomes), commit discipline (publication gate before commit, harness-reviewer bookend before push).
- **Mechanical signal:** `grep -c "openspec/changes/_intake" templates/personas/orchestrator.md` returns >= 2 (once for capture-side, once for triage-side).

## Phase 3: CLAUDE.md registration

### Task 5: Register the pattern in CLAUDE.md
- Add a bullet under "Harness Maintenance Discipline" key-rules block describing the inbox and pointing to the orchestrator persona section + the inbox README for full detail.
- Update the Project Structure tree to include `openspec/changes/_intake/`.
- **Mechanical signal:** `grep -c "_intake" CLAUDE.md` returns >= 2 (key-rules entry + structure tree).

## Phase 4: CHANGELOG

### Task 6: CHANGELOG entry
- Under [Unreleased] Added: summary of the inbox mechanism, the two landing points, the capture-side and triage-side behaviours, and the inaugural use note.
- **Mechanical signal:** `grep -c "capture inbox\|_intake" CHANGELOG.md` returns >= 1 in an Unreleased entry.

## Phase 5: Inaugural use (worked example)

### Task 7: Drop the 4-state response-end-state vocabulary capture into the new inbox
- The 4-state vocabulary insight (DONE | DECISION-NEEDED | MONITORING-BACKGROUND | PAUSED-ON-YOUR-WORK) supersedes the existing 3-state convention recorded in operator memory.
- Write the capture file to `openspec/changes/_intake/` following the new format.
- Demonstrates the mechanism end-to-end on its first real piece of content.
- **Mechanical signal:** `ls openspec/changes/_intake/*end-state*.md` returns at least one match.

### Task 8: Triage the inaugural capture into its own OpenSpec change proposal
- Promote the capture into `openspec/changes/orchestrator-end-state-vocabulary-v2/`.
- `proposal.md` + `tasks.md`. (Design.md optional for trivial vocabulary change.)
- Move the inbox file into the new change directory as `provenance.md`, or update its frontmatter to `status: promoted` with `promoted-to: orchestrator-end-state-vocabulary-v2`.
- Implement the change: orchestrator persona template's Report-Back discipline section updated from 3-state to 4-state; operator memory file `feedback_orchestrator_response_end_state.md` updated.
- CHANGELOG entry for the vocabulary change.
- **Mechanical signal:** `openspec/changes/orchestrator-end-state-vocabulary-v2/proposal.md` exists; `grep -c "MONITORING-BACKGROUND\|PAUSED-ON-YOUR-WORK" templates/personas/orchestrator.md` returns >= 2.

## Phase 6: Archive

### Task 9: Archive this proposal
- Once Tasks 1-8 are complete and the harness-reviewer bookend has passed, move `openspec/changes/harness-capture-inbox/` to `openspec/changes/archive/harness-capture-inbox/`.
- No formal capability spec is introduced; the mechanism lives in the orchestrator persona template, CLAUDE.md, and the inbox README.
- **Mechanical signal:** `test -d openspec/changes/archive/harness-capture-inbox` returns zero.

## Notes for the implementer

- Tasks 1, 2, 5, 6 are mechanical; bundle in a single commit.
- Tasks 3, 4 (orchestrator persona edits) are the substantive work; commit separately for reviewability.
- Tasks 7, 8 land in the same commit as the demonstration; the 4-state vocabulary change ships alongside the mechanism so the inaugural use is real, not theatrical.
- Publication gate (`bin/validate-personas.sh --staged` + `--message`) before every commit.
- Harness-reviewer bookend before push: Dimension 1 (target-detail leakage in `_intake/` files), Dimension 3 (CLAUDE.md and CHANGELOG currency), Dimension 4 (orchestrator persona consistency with the new sections).
