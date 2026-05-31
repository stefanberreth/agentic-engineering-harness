---
slug: harness-update-propagation-signal
status: proposed
since: 2026-05-31
provenance: openspec/changes/harness-update-propagation-signal/provenance.md
---

# Harness Update Propagation Signal

## What

Add a marker file convention and a session-init detection step so any AEH orchestrator session (target-side or harness-side) detects when the upstream harness has advanced beyond its last sync, surfaces a one-line signal in the post-banner area, and offers a harness-reviewer pass as the interpretation gate. The mechanism is a *signal only* -- interpretation (what to apply, partial vs full, defer vs retrofit) is a session-level operator + orchestrator + harness-reviewer decision, not codified in the mechanism.

## Why

Today the harness's relationship to target trees is: harness ships updates (templates, scaffolds, conventions); targets carry snapshots (`docs/AE/personas/_base/`, scaffolded `openspec/`, tool configs) frozen at the moment of onboarding or last refresh. The bind-mount makes harness files instantly visible to every container, but it does not make the staleness of the target's snapshots visible to the target's orchestrator. So a target session runs against a frozen-in-time copy of harness behaviour with no in-band awareness that the upstream has moved.

The separation of duties matters: codifying the interpretation logic (auto-retrofit prompts, dependency analysis, "this change touches your snapshots, this one doesn't") would over-engineer the mechanism into a propagation engine. The right shape is a signal plus rich context (commit log + CHANGELOG diff) plus an offered harness-reviewer pass; humans plus the orchestrator do the rest.

This mirrors the harness capture inbox symmetrically. Inbox surfaces upstream-relevant insights from targets *to* the harness for triage. Sync-marker surfaces upstream changes from the harness *to* targets for interpretation. Both are filesystem-mediated, both surface at session-init, both are operator-gated, both deliberately stop short of automation.

## Scope

In scope:
- Add `harness-sync-sha:` field to `profile.md` template (greenfield + brownfield onboarding) carrying the harness commit SHA at last sync.
- Extend orchestrator persona session-init: after the inbox scan, read the target's `harness-sync-sha` field; if present and behind harness HEAD, surface `"Harness has advanced N commits since last sync. Say 'review changes' to run a harness-reviewer pass that scopes local impact."`.
- On operator `review changes`: invoke harness-reviewer in a focused mode that reads the commit range and CHANGELOG diff, identifies which target-snapshotted files / scaffolds / conventions are affected, and proposes a set of local retrofit actions (with explicit "no action needed" being a valid output).
- On operator approval of a retrofit action, the orchestrator (or harness-reviewer's output) drives the actual application; on completion, the marker bumps to harness HEAD (or to the SHA the retrofit covered).
- Update onboarding playbook to write `harness-sync-sha:` at onboarding time (= harness HEAD at that moment).
- Update health-check playbook to flag missing `harness-sync-sha` as a finding (operator should seed it via a one-shot retrofit before next harness-update detection works).
- Document the mechanism in CLAUDE.md (Harness Maintenance Discipline) and in the orchestrator persona.

Out of scope:
- Auto-application of retrofits. Every retrofit is operator-gated.
- Diff-classification heuristics in the persona ("does this commit touch target snapshots?"). That judgment lives in harness-reviewer's analysis pass, not in the persona's session-init code path.
- Partial-state machinery beyond "marker is at SHA X, anything after X is fresh." If the operator applies some retrofits but not others, the marker simply moves to the SHA that covers all applied retrofits.
- Cross-target propagation orchestration. Each target's marker is independent; the harness session does not orchestrate fleet-wide updates.

## Acceptance criteria

1. **Marker convention in place**: `profile.md` template (greenfield + brownfield) carries a `harness-sync-sha:` field; new targets onboarded after this change ship with the field populated.
2. **Session-init detection live**: orchestrator persona's "Before You Start" section includes a step (after the inbox scan) that reads the marker, computes the harness-commit-range, and surfaces the signal if the range is non-empty.
3. **Harness-reviewer pass available**: the persona's offered command (`review changes` or equivalent) triggers a harness-reviewer assessment of the harness diff against the target's local state, producing a retrofit-action list (or "no action needed").
4. **Onboarding writes initial marker**: greenfield + brownfield onboarding flows seed `harness-sync-sha:` at onboarding time.
5. **Health-check verifies marker presence**: a missing or empty `harness-sync-sha:` field on an existing target is a finding (operator can seed retroactively).
6. **Documentation**: CLAUDE.md Harness Maintenance Discipline key-rules block names the mechanism; orchestrator persona has the full discipline.
7. **First verified propagation**: an existing target (e.g. the one whose `tier-ingestion-strategy` proposal is paused at logical-close) successfully detects the harness has advanced, runs the harness-reviewer pass, and adopts (or declines) retrofits with the marker bumping correctly.

## References

- Provenance: `provenance.md` in this directory.
- Inbox capture that originated the proposal: `openspec/changes/_intake/2026-05-31-1300-harness-update-propagation-signal-0c37120ebcd6.md` (status: promoted-to this proposal).
- Sibling proposal: `openspec/changes/openspec-close-out-convention/` (related; the close-out convention is the first concrete retrofit that the propagation signal will surface for existing targets).
- Symmetric mechanism: `openspec/changes/harness-capture-inbox/` (captures flow upstream; this proposal handles updates flowing downstream).
