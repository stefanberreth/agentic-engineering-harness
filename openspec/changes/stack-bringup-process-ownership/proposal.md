---
slug: stack-bringup-process-ownership
status: proposed
since: 2026-06-16
---

# Stack-bringup must prove process ownership, not trust port-liveness

## What

Harden the harness's stack-bringup / runtime-smoke guidance so an agent cannot eyeball or regression-check a STALE build and report it green. Two non-portable assumptions are removed and replaced with portable, ownership-proving validation:

1. **Teardown by-PID, never assume `pkill`.** Some containers ship only `ss` (no `pkill`/`lsof`/`fuser`); a `pkill -f ...` teardown step then silently no-ops (exit 127) and the box is never cleaned. Guidance must tear down by-PID via whatever the container has, then assert ports are clear.
2. **Port-liveness is not process-ownership.** An HTTP 200 / open port proves *something* is answering, not that the stack you just launched is the one answering -- a stale prior-session server can keep serving the expected port while the new launch crashed on port-in-use. Guidance must validate that the launched PID matches the listener, scan the launch log for crash markers, and detect silent port-bumps before declaring green.

Concretely:

- Update `templates/prompts/regression-check.md.template` section 4 (Runtime Smoke Test) so the smoke test proves process-ownership: capture the launched PID, assert it owns the listening port, scan the launch log for crash markers, and detect a port-bump -- rather than trusting `curl http://localhost:[PORT]`.
- Add the same teardown-by-PID + prove-ownership guidance to the onboarding and health-check playbook stack-bringup steps where they exist.
- Recommend promoting recurring stack-bringup from prose steps to a hardened per-target script/skill, because the load-bearing validation is procedural and a markdown instruction cannot prevent the false-green. A proven target-side implementation of exactly this shape exists and is the reference model for what the target-side script/skill should do (capture-PID + ownership-assert + log-scan + port-bump-detect + portable teardown).

## Why

A target eyeball-capture stack-bringup silently no-op'd its "kill stale servers" step in a sandbox lacking `pkill`. The freshly-launched stack then crashed on a port-in-use error while the stale prior-session server kept answering HTTP 200 on the expected port -- a false-green the agent caught only by reading the launch log, not from the curl checks. This is a CORRECTNESS failure (eyeballing the wrong build), not a cosmetic one, and it is baked into harness guidance that says `pkill -f ...` for teardown and treats an open port as proof of a healthy launch.

The fix is portable and self-contained: prove ownership at the single chokepoint where the stack is declared up, using whatever process tools the container actually has.

## Scope

In scope:

- `templates/prompts/regression-check.md.template` section 4: replace port-liveness-trust smoke test with a process-ownership-proving sequence (capture PID, assert PID owns the port, scan launch log for crash markers, detect port-bump), and a portable teardown note (do not assume `pkill`; do not assume `.env` is greppable; do not hardcode a health path -- a DB-gated `/health` may 503 while a lighter liveness endpoint is the right probe).
- Onboarding + health-check playbook stack-bringup steps (where present): same teardown-by-PID + prove-ownership guidance.
- A recommendation (not a mandate) to promote recurring stack-bringup to a hardened per-target script/skill, naming the ownership checks the script must perform.
- CHANGELOG [Unreleased] entry.

Out of scope:

- Shipping a concrete `bin/` stack-bringup script in the harness. The validation is per-target (commands and ports vary); the harness prescribes the checks and recommends the target build the script. Tool-agnostic core stays tool-agnostic.
- The orchestrator-side memory rule already exists (`feedback_stack_bringup_prove_process_ownership`); this proposal propagates the same discipline into the harness templates/playbooks, it does not restate the memory.

## Acceptance criteria

1. `regression-check.md.template` section 4 proves process-ownership (PID-owns-port + launch-log crash-scan + port-bump detection) and no longer treats a bare `curl` 200 as sufficient proof of a healthy launch.
2. The template's teardown guidance does not assume `pkill`/`lsof`/`fuser`; it tears down by-PID with a portable fallback and asserts ports clear.
3. The template notes the two adjacent traps: do not hardcode a health path (DB-gated `/health` may 503), do not assume `.env` is greppable (read key-by-key programmatically).
4. Onboarding + health-check stack-bringup steps (where present) carry the same teardown-by-PID + prove-ownership guidance, or a pointer to it.
5. The promote-to-script/skill recommendation names the ownership checks the script must perform.
6. CHANGELOG [Unreleased] entry present.

## References

- Provenance: `provenance.md` (intake capture 2026-06-15-1205).
- Orchestrator-side memory rule propagated here: `feedback_stack_bringup_prove_process_ownership`.
- Deterministic-invariant framing: `_intake/2026-06-05-1847-structural-invariant-gate-pattern-*` (prove-it-holds-at-runtime layer).
