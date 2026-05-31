---
captured-at: 2026-05-31T12:30:00Z
captured-from: 0c37120ebcd6
captured-during: harness session synthesising an operator-relayed finding from a peer target-orchestrator session
area: template
status: untriaged
---

# OpenSpec close-out / archive convention missing from harness setup

**Trigger:** A target-orchestrator session attempted to close out a structurally complete OpenSpec change proposal. The reviewer flagged that the target project has no `openspec/AGENTS.md` close-out playbook and no `openspec/changes/archive/` directory; the standard OpenSpec close-out convention could not be applied because the convention was never wired into the project. The target orchestrator's instinct was correct: this is not a target oversight but a missing harness-level convention. The target adopted whatever the harness setup template established.

**Insight:** The harness ships `templates/tools/openspec-setup.md` (and `openspec-teardown.md`) which covers the *proposal-authoring* side of the OpenSpec lifecycle (creating `openspec/`, `openspec/specs/`, `openspec/changes/`, optionally `openspec/project.md`). It does not establish the *proposal-closing* side: no `openspec/AGENTS.md` close-out playbook, no `openspec/changes/archive/` directory at setup time, no documented flow for applying deltas to parent specs and bumping their updated date, no convention for setting a completed proposal's `status: archived`.

Every target that adopts OpenSpec via the harness inherits this gap. The first time a target completes a change proposal, the operator is forced to either (a) invent an ad-hoc close-out convention (which then becomes that target's convention going forward, with per-target divergence accumulating across the portfolio), or (b) pause indefinitely at the logical-close point and wait for someone to establish the convention. Neither is acceptable for a harness whose central organising substrate is OpenSpec.

The harness-self `openspec/` adoption (just landed this week) has the same gap as a meta-issue: `openspec/changes/README.md` mentions archive in the lifecycle section but does not document a close-out playbook, and `openspec/changes/archive/` does not yet exist (it would only be created on first archive). The harness should dogfood the convention it ships to targets.

**Suggested change:**
- Extend `templates/tools/openspec-setup.md` to scaffold `openspec/AGENTS.md` (or equivalent close-out playbook document) and `openspec/changes/archive/` (with README) at setup time, so every target that adopts OpenSpec gets the close-out side wired in alongside the authoring side.
- Document the close-out flow in the new AGENTS.md (or in the existing setup template, embedded): when a change proposal completes its work, apply spec deltas to parent specs, bump parent `updated:` date, set proposal `status: archived`, move proposal directory to `openspec/changes/archive/<slug>/`. Capture the mechanical sequence so any orchestrator role can execute it consistently.
- Update `templates/tools/openspec-teardown.md` to preserve archived proposals as history (they document why current specs look the way they do); clarify what teardown removes vs preserves.
- Apply the same convention to the harness-self `openspec/` tree: add a close-out section to `openspec/changes/README.md` (or create `openspec/AGENTS.md`), create `openspec/changes/archive/` with a placeholder README. Dogfooding completes the loop -- the harness's own first proposal close-out will exercise the convention.

**Memory updates:** None specifically; this is a template/playbook update. After the change ships, any operator memory about "what to do when a change proposal completes" may want a short pointer to the new convention.
