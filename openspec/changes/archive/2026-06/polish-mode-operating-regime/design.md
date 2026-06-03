---
slug: polish-mode-operating-regime
---

# Design: Polish Mode operating regime

## Mechanism

### Activation

Operator says a recognised activation phrase that names: (a) the regime ("polish mode"), (b) the surface ("waitlist UI" / "questionnaire copy" / "admin users page"), (c) the change-slug context if known. Examples:

- "polish mode on for waitlist UI"
- "tactical iteration on questionnaire copy"
- "start a polish session on the admin users page"

Orchestrator instantiates `templates/prompts/polish-mode.md.template` filling the surface name + change-slug + in-scope route list. Operator pastes into target session.

### Posture

The target developer adopts the Polish Mode posture for the session duration. Differences from default spec-first developer:

- Live dialogue allowed (operator types observations + screenshots + console pastes; developer applies immediately).
- No halt-for-spec-clarification on tactical items.
- Two-bucket triage: every operator input categorised as IMMEDIATE-FIX or DEFERRED-TRIAGE; bucket announced in chat.
- Scope boundary enforced by developer (substantive requests halt the mode).

### Scope boundary

IN:

- Copy text (headlines, body, labels, button text, microcopy, error messages on touched surfaces).
- Layout micro-adjustments (padding, spacing, alignment, typography weight/size within existing scale).
- Token swaps within existing token set (colour token A -> colour token B).
- Minor UX wording (CTA verb changes, label clarifications).
- Screenshot-driven visual tuning.
- Test wording updates to match changed copy (assertions stay the same; only the expected text changes).

OUT:

- API shape changes, data-model changes, schema changes.
- New tests' substantive assertions (new test files covering new behaviour).
- New dependencies.
- New files outside the touched surface.
- Anything that changes acceptance criteria of the active change-slug.
- Security boundary changes.
- New tokens (use existing token set; missing tokens -> DEFERRED-TRIAGE).

### Two-bucket triage

For each operator observation:

- **IMMEDIATE-FIX:** developer announces "IMMEDIATE-FIX: <action>", applies the change, reports diff verbatim, operator verifies via vite HMR / browser reload.
- **DEFERRED-TRIAGE:** developer announces "DEFERRED-TRIAGE: <reason for not fixing now>", captures the item in `docs/AE/reports/polish-<surface>-<YYYY-MM-DD>/deferred-items.md` (created at first capture). Entry includes operator's exact words, bucket-out reason, suggested routing (analyst / architect / which change-slug).

Operator may override either way ("defer that"; "actually polish that anyway"). The developer's announcement is the trigger for operator override.

### Exit ceremony

Operator says "exit polish mode" / "polish complete" / "lock it down".

1. Stop live dialogue. No further changes accepted.
2. **Polish-session log** at `docs/AE/reports/polish-<surface>-<YYYY-MM-DD>/session-log.md`:
   - Summary of surfaces touched.
   - IMMEDIATE-FIX items (operator intent paraphrased + files touched + diff summary).
   - DEFERRED-TRIAGE items (linked or inline).
   - Open questions surfaced.
   - Token-set audit (any token added = scope violation; ideally zero).
3. **OpenSpec record** (decision tree):
   - If polish touched a single active change-slug -> amend that CP's `design.md` revision history (new vN+1 entry) plus a new "Sec X polish YYYY-MM-DD" subsection listing copy/layout/token deltas if non-trivial.
   - If polish touched multiple change-slugs OR is genuinely standalone -> open new `<surface>-polish-<YYYY-MM-DD>` change-slug with minimal proposal/design/tasks reflecting what landed.
4. **Local verification:**
   - `npm test` -- full suite green.
   - `tsc --noEmit` -- clean.
   - `eslint .` -- 0 errors, no new warnings.
   - `git status` -- clean for tracked files after staging.
5. **Lightweight reviewer self-check** (per the polish-pass criterion -- NOT a full review-criteria pass):
   - Scope did not creep into substantive change.
   - No test regression.
   - Tokens-only (no hex literals introduced).
   - Diff scope fully covered by session log + openspec record.
   - Commit messages clean.
6. **Batch commit + push:**
   - Single commit (or small natural splits) with: source diffs + session log + openspec record.
   - Commit message: `polish(<slug>): <surface> polish pass [change:<slug>]` (natural splits with similar prefix).
   - `git push origin main`.
   - Monitor CI through `deploy_QA`. On green: report; on fail: halt + surface.

### Automatic exit conditions

Mode exits automatically (no operator-typed "exit") if:

- A substantive change is attempted (scope violation that operator doesn't override into DEFERRED-TRIAGE). Developer falls back to spec-first; orchestrator routes to analyst / architect / etc.
- Session ends (Claude exits, host reboot). Reactivation requires fresh activation phrase.

## Polish-pass review criterion (lighter than full review-criteria)

A polish-mode commit does NOT go through the full reviewer 10-dimension walk. The lightweight criterion:

| Check | Pass condition |
|---|---|
| Scope no-creep | Diff stays within: copy, layout, tokens, microcopy, test wording (matching changed copy). No source-logic changes, no new files outside touched surface, no new deps. |
| No regression | `npm test` green; `tsc --noEmit` clean; `eslint .` 0 errors. |
| Tokens-only | `grep` for hex literals (`#[0-9a-fA-F]{3,6}`) introduced in the diff returns 0. |
| Audit trail coverage | Every diff hunk is accounted for in the session log or openspec record. No silent changes. |
| Commit hygiene | Conventional commits, ASCII, no AI attribution, message references `[change:<slug>]`. |

The developer runs this self-check at exit; the operator is the eyeball reviewer (already validated in real time during Phase 2). If the lightweight check fails, the commit doesn't ship.

## Alternatives considered

1. **Don't codify polish mode; let operators bypass spec-first informally.** Rejected: creates undocumented drift, no audit trail, no scope boundary, no safety net for substantive change slipping in.

2. **Polish mode as a degraded developer persona (no separate regime).** Rejected: conflates default and polish posture; developer loses the spec-first guardrails by default. Better to keep default strict and have polish as an explicit opt-in.

3. **Polish mode without two-bucket triage (just "apply everything immediately, defer nothing").** Rejected: substantive issues surface during polish sessions; without the DEFERRED-TRIAGE bucket, they either get hidden (scope creep) or break the session flow. The triage IS the discipline.

4. **Polish mode with full reviewer pass at exit.** Rejected: defeats the friction-reduction goal. The lightweight polish-pass review is sufficient because the operator was the live eyeball reviewer throughout.

## Migration

- Existing targets: pick up the regime at the next `refresh-base-personas` cycle (the existing harness-side template -> target `docs/AE/personas/_base/` mechanism). No new retrofit prompt.
- New targets: ship with polish mode capability from onboarding day one.
- The first target session exercising the regime ran 2026-06-03 alongside the persona-template updates landing in the same session. Subsequent targets get the regime through normal propagation.
