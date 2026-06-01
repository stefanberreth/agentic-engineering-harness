---
slug: boundary-push-policy
status: proposed
since: 2026-06-01
intake: openspec/changes/_intake/2026-05-31-1835-boundary-push-policy-operator-confirmed-0c37120ebcd6.md
---

# Boundary-push policy: per-target field + onboarding elicitation

## What

Add a per-target `boundary-push-policy:` field to `profile.md` with documented values, elicit it at onboarding, and update the orchestrator persona to read and honour it when authoring boundary-closing prompts. Health-check verifies presence.

## Why

When an orchestrator-authored target prompt closes an implementation boundary fully reviewed and green-lit, the right behaviour for `git push` is environment-dependent:

- **Solo-developer, pre-customer-data:** push at boundary belongs IN the prompt -- friction reduction with no protective value lost.
- **Multi-developer, PR-mandatory, branch-protected, CI-thrashing-sensitive:** push must NEVER be in an orchestrator-authored prompt -- bypasses policy.
- **Hybrid / regulated:** depends on branch, environment, payload -- operator-manual default with explicit overrides.

The current harness has no signal for which class a target falls into. Default behaviour is operator-manual (defensive, works for all classes, but adds friction for solo-dev). The right shape: elicit at onboarding, record per-target, orchestrator honours.

The mechanism + onboarding question must land together. Adding the field without elicitation just shifts friction. Adding elicitation without the mechanism leaves a half-built discipline.

## Scope

In scope:
- `profile.md` schema: new field `boundary-push-policy:` with values `in-prompt`, `operator-manual` (default), `never-from-prompt`, `other` (free-text + falls back to `operator-manual` behaviour with rationale surfaced above each boundary handoff).
- `templates/playbooks/onboarding.md` Phase 3e (greenfield) + brownfield profile schema: elicit the policy with the four-option block from the intake.
- `templates/personas/orchestrator.md` boundary-prompt-authoring guidance: read field, apply per value, run internal self-check before authoring any boundary-closing handoff.
- `templates/playbooks/health-check.md`: verify `boundary-push-policy:` present and non-empty. Missing = LOW finding.
- Operator memory `feedback_push_in_boundary_prompts` becomes operator-context-only after this lands (operator updates memory; out of scope here).
- CHANGELOG entry under [Unreleased] Added.

Out of scope:
- Branch-protection / mergeability checks / auto-PR creation. The field governs whether the orchestrator authors `git push` at all; downstream enforcement lives in CI/VCS config.
- Per-branch granularity (single per-target field for v1).
- Auto-detection heuristics for environment class.

## Acceptance criteria

1. `profile.md` schema documents the field + values.
2. Onboarding playbook elicits the field on both greenfield and brownfield paths.
3. Orchestrator persona reads + honours the field; self-check named.
4. Health-check verifies presence.
5. CHANGELOG entry landed.
6. Intake capture status updated to promoted.

## References

- Intake: `openspec/changes/_intake/2026-05-31-1835-boundary-push-policy-operator-confirmed-0c37120ebcd6.md`
- Memory: `feedback_push_in_boundary_prompts` (becomes operator-context-only after this lands)
- Pairs with: `openspec/changes/reviewer-prompt-commit-step/` (commit vs push are separate concerns; reviewer commits; boundary-push optionally pushes per policy)
