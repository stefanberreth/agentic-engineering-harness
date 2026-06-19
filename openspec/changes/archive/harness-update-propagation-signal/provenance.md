---
captured-at: 2026-05-31T13:00:00Z
captured-from: 0c37120ebcd6
captured-during: harness session conversation following the openspec close-out capture; operator asked how harness updates actually reach existing target trees
area: orchestrator-persona
status: untriaged
---

# Harness update propagation signal (target-side stale-detection)

**Trigger:** Conversation surfaced that there is no in-session signal telling a target's orchestrator that the harness has advanced since the target's snapshots were last refreshed. Operator must remember to run health-check, or notice drift symptomatically. The discussion arose after the openspec close-out capture, where a target session's paste explained that the operator would need to "re-run the relevant openspec-setup steps or apply a small harness-handed prompt" once the close-out convention ships -- exposing that there is no general staleness-signal mechanism today.

**Insight:** The harness's relationship to target trees today is: harness ships updates (templates, scaffolds, conventions); targets carry snapshots (`docs/AE/personas/_base/`, scaffolded `openspec/`, tool configs) frozen at the moment of onboarding or last refresh. The bind-mount makes harness files instantly visible to every container, but it does not make the *staleness of the target's snapshots* visible to the target's orchestrator. So a target session runs against a frozen-in-time copy of harness behaviour with no in-band awareness that the upstream has moved.

The right shape, per operator direction, is a clean separation of duties:

- **Mechanism's job (codified):** maintain a marker per target that records the harness commit SHA at last sync; on every orchestrator session-init, compare the marker to harness HEAD; if different, surface the commit log and CHANGELOG diff for the range. The mechanism is *just the signal* -- rich enough to support interpretation, not opinionated about what to do with it.
- **Operator + orchestrator's job (not codified):** decide what to apply to this target's local snapshots, whether partial updates make sense, what to defer. This is a session-level conversation between the operator and the orchestrator in front of them, informed by the rich diff signal. Different targets can reasonably make different choices about how aggressively to track upstream.

This separation matters: codifying the interpretation logic (auto-retrofit prompts, dependency analysis, "this change touches your snapshots, this one doesn't") would over-engineer the mechanism into a propagation engine, which is exactly the wrong shape. A signal plus rich context is enough; humans plus the orchestrator do the rest.

The mirror to the harness capture inbox is clean and intentional: inbox surfaces upstream-relevant insights from targets *to* the harness for triage; sync-marker surfaces upstream changes from the harness *to* targets for interpretation. Both are filesystem-mediated, both surface at session-init, both are operator-gated, both deliberately stop short of automation. Symmetric mechanism, half a screen of orchestrator-persona behaviour per side.

**Suggested change:**

- Add a sync marker to each target tree: either a standalone file `docs/AE/.harness-sync-sha` (single 40-char string) or a `harness-sync-sha:` field in `docs/AE/profile.md`. Choose at design time; both work.
- Extend orchestrator persona session-init step (target-side and harness-side both apply): after the inbox scan, read the target's marker SHA; run `git -C <harness-path> log <marker>..HEAD --oneline` and (if non-empty) `git -C <harness-path> diff <marker>..HEAD -- CHANGELOG.md`. If the range is non-empty, surface in the post-banner area: "Harness has advanced N commits since last sync. Say 'review changes' to see the CHANGELOG diff."
- The signal stops there. No retrofit prompt generation, no scope analysis, no "what to apply" logic in the persona template. On operator request, orchestrator pastes the CHANGELOG slice and commit titles, then the operator + orchestrator decide together what (if anything) to retrofit.
- Update onboarding playbook to write the initial marker (= harness HEAD at onboarding time).
- Update health-check playbook to verify marker presence (missing marker = finding) and to support an explicit "bump marker" operation when the operator confirms the target is in sync after a manual review.
- Add the marker file path (or the profile.md field schema) to the harness's documented target-tree structure.
- For partial updates -- if the operator decides "I've applied changes through SHA X but not SHA Y" -- the marker simply moves to X, leaving Y onwards visible on the next session-init. No special partial-state machinery needed; the marker naturally represents "everything through here is interpreted, everything after is fresh."

**Memory updates:** none specifically; this is a mechanism that lives in the orchestrator persona template and onboarding/health-check playbooks. Operator memory about "how to handle harness updates" can point at the surfaced signal flow once the mechanism ships.
