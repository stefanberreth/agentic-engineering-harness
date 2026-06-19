---
slug: harness-update-propagation-signal
---

# Tasks: Harness Update Propagation Signal

## Task 1: profile.md schema extension
- Add `harness-sync-sha:` field to the greenfield profile.md template in `templates/playbooks/onboarding.md` (Phase 3e block).
- Add `harness-sync-sha:` to the brownfield profile.md schema description (same file, Phase 3 "profile.md must include" block).
- **Signal:** `grep -c "harness-sync-sha" templates/playbooks/onboarding.md` returns >= 2.

## Task 2: Orchestrator persona session-init step
- `templates/personas/orchestrator.md` "Before You Start": add a new step (after the `_intake/` scan, step 4) that reads the marker, computes the commit range, and surfaces the signal. Renumber subsequent steps.
- Add a new H2 section "Harness Update Propagation Signal" with the full detection + interpretation-gate discipline.
- **Signal:** `grep -c "harness-sync-sha" templates/personas/orchestrator.md` returns >= 2.

## Task 3: Harness-reviewer pass discipline
- Extend `templates/personas/harness-reviewer.md` with a "Propagation-Impact Assessment Mode" subsection describing how harness-reviewer processes a commit range when invoked via the orchestrator's `review changes` flow.
- Output shape: structured retrofit-action list with reason / effort / side-effects per action.
- **Signal:** `grep -c "Propagation-Impact Assessment\|propagation-impact" templates/personas/harness-reviewer.md` returns >= 1.

## Task 4: Onboarding playbook writes initial marker
- Update `templates/playbooks/onboarding.md` Phase 3e (greenfield) and the equivalent brownfield section: when writing initial `profile.md`, seed `harness-sync-sha:` with `$(git -C /workspace/aeh rev-parse HEAD)`.
- **Signal:** `grep -c "rev-parse HEAD" templates/playbooks/onboarding.md` returns >= 1.

## Task 5: Health-check verifies marker
- Update `templates/playbooks/health-check.md`: add a check item verifying `harness-sync-sha:` is present and non-empty in `profile.md`. Missing = LOW finding with remediation note ("seed via one-shot retrofit prompt to enable update detection").
- **Signal:** `grep -c "harness-sync-sha" templates/playbooks/health-check.md` returns >= 1.

## Task 6: Seed-marker retrofit prompt template
- Create `templates/prompts/seed-harness-sync-marker.md.template`: a small target-side prompt that reads harness HEAD and writes the SHA into the target's profile.md.
- **Signal:** file exists.

## Task 7: CLAUDE.md registration
- Add a bullet under "Harness Maintenance Discipline" key-rules describing the propagation signal and pointing to the orchestrator persona section + the seed-marker retrofit template.
- **Signal:** `grep -c "harness-sync-sha\|propagation signal" CLAUDE.md` returns >= 1.

## Task 8: CHANGELOG entry
- Under [Unreleased] Added: summary of the mechanism, the harness-reviewer-pass interpretation gate, the operator-gated discipline.
- **Signal:** `grep -c "propagation signal\|harness-sync-sha" CHANGELOG.md` returns >= 1 in an Unreleased entry.

## Task 9: Archive after implementation
- Move `openspec/changes/harness-update-propagation-signal/` to `openspec/changes/archive/harness-update-propagation-signal/` once Tasks 1-8 and harness-reviewer bookend complete.
- **Signal:** `test -d openspec/changes/archive/harness-update-propagation-signal` returns zero.
