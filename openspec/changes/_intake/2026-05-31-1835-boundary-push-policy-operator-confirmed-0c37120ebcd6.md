---
captured-at: 2026-05-31T18:35:00Z
captured-from: 0c37120ebcd6
captured-during: harness session, operator directive about boundary-completion push automation conditional on per-target git policy
area: orchestrator-persona
status: untriaged
---

# Boundary-completion push: operator-confirmed policy at onboarding + per-target enforcement

**Trigger:** Operator directive during a target-update arc: when an orchestrator-authored target prompt closes an implementation boundary fully-reviewed and green-lit, include `git push` IN the prompt itself rather than leaving it as an operator-manual step. Eliminates a manual step that adds friction without protective value when the push thrashing concern doesn't apply. Operator immediately added: this preference is highly environment-dependent -- "many non-me people will be working with this in a very different environment with very different git policies." Captured for triage with both halves: the mechanism + the onboarding question.

**Insight:** The discipline of "push in the boundary-closing prompt" is correct for some target environments and wrong for others. Three rough environment classes:

- **Solo-developer, pre-customer-data, push-freely-OK:** push at boundary belongs IN the prompt. No collaborators to thrash; no QA pipeline to stall; no PR workflow to bypass. Eliminating the operator-manual step is pure friction reduction.
- **Multi-developer, push-via-PR-only, branch-protected, or CI-thrashing-sensitive:** push must NEVER be in an orchestrator-authored prompt. Push is a deliberate operator action that opens a PR, requests review, triggers expensive CI, or merges main with the right approvals. Auto-pushing from a prompt would bypass policy or cause harm.
- **Hybrid / regulated / per-branch-policy:** depends on which branch, which environment, what is being pushed. Likely operator-manual by default, with explicit case-by-case overrides.

The current harness has no signal for which class a target falls into. Default behaviour today is operator-manual push (defensive, works for all classes but adds friction for the solo-dev class). The right shape is to elicit the preference at onboarding and record it as a per-target field; orchestrator-authored prompts then honour the field.

The mechanism + onboarding question must land together. Adding the field without onboarding elicitation just shifts the friction (operator has to discover and set the field manually). Adding the onboarding question without the mechanism (or vice versa) leaves a half-built discipline.

**Suggested change:**

- Add a new field to the target `profile.md` schema: `boundary-push-policy:` with documented values:
  - `in-prompt` -- orchestrator-authored boundary-closing prompts include `git push` as the final step
  - `operator-manual` -- prompts never include push; operator pushes deliberately (default for any target where the answer is unclear)
  - `never-from-prompt` -- push is forbidden from orchestrator-authored prompts; operator+human review+merge is the only path (strong-policy environments)
  - `other` -- free-text describing the project's specific policy; orchestrator defaults to `operator-manual` behaviour with the rationale surfaced in every boundary handoff
- Update `templates/playbooks/onboarding.md` Phase 3e (greenfield profile creation) and the brownfield profile schema to elicit this preference. Suggested prompt structure (operator-facing):

  > "When a target prompt closes an implementation boundary fully reviewed and green-lit, who pushes?
  > (a) prompt includes push -- best for solo-dev, pre-customer-data, push-freely-OK
  > (b) operator pushes manually -- safe default; works for any environment
  > (c) never auto-push from a prompt -- strong-policy environments (PR-mandatory, branch-protected, regulated)
  > (d) other -- describe your policy
  >
  > Default: `operator-manual` if unsure. Reversible at any time via tools playbook."

- Update `templates/personas/orchestrator.md` § "Prompt-Write-Then-Handoff" (or wherever boundary-prompt authoring lives) to read the `boundary-push-policy:` field and honour it:
  - `in-prompt`: prompt includes `git push` at the end of the final step.
  - `operator-manual` (default): prompt does NOT include push; handoff says "push when ready" or equivalent.
  - `never-from-prompt`: prompt explicitly notes push is operator-only; orchestrator never authors a push-bearing handoff.
  - `other`: defaults to `operator-manual` behaviour; surfaces the recorded rationale above the paste block so the operator sees it.
- Update `templates/playbooks/health-check.md` to verify `boundary-push-policy:` is present and non-empty in profile.md. Missing = LOW finding ("seed via tools playbook or by adding the field directly to profile.md").
- The orchestrator persona's boundary-prompt-authoring section should also include a one-line check the persona runs every time it authors a boundary-closing prompt: "did I read the boundary-push-policy and apply it correctly?" The check is internal but matters because the default failure mode (silent wrong-policy push from an orchestrator that forgot to check) would be a real PR/CI/policy violation in non-solo environments.

**Memory updates:**

`feedback_push_in_boundary_prompts.md` (current operator memory) becomes provisional / operator-context-only and is superseded by the per-target field once the mechanism lands. The current operator's solo-dev preference will be recorded on solo-dev targets' `profile.md` as instances of the new field, including the target that prompted this capture.

The memory entry can stay as operator-context after the mechanism lands -- it documents the operator's general preference across solo-dev targets, useful when onboarding NEW solo-dev targets to suggest the right default.

**Out of scope (explicit):**

- Branch-protection enforcement, mergeability checks, automated PR creation. The `boundary-push-policy:` field is about whether the orchestrator authors a `git push` step at all; further policy enforcement lives in the project's CI / VCS server config, not in AEH.
- Per-branch policy granularity (e.g. "push to develop is in-prompt, push to main is operator-manual"). Single per-target field for the first version; refine if real-world use surfaces the need.
- Auto-detection of environment class (heuristics like "is there only one git author? then suggest solo-dev"). Onboarding asks the operator directly; no heuristic.
