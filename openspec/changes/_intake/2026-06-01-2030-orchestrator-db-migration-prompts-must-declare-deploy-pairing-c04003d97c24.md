---
captured-at: 2026-06-01T20:30:30Z
captured-from: c04003d97c24
captured-during: harness orchestrator session, immediately after a live PROD incident where the orchestrator-authored DB migration prompt (334) was sequenced without considering code-deploy pairing, taking PROD down between migration-apply and code-deploy
area: orchestrator-persona, prompt-authoring-discipline
status: untriaged
---

# Orchestrator-authored DB-migration prompts must declare deploy-pairing posture (expand-contract / lockstep / contract-after-deploy)

## Trigger

The orchestrator (this session, 2026-06-01) authored a sequence of prompts to test the PROD deployment pipeline:
- 333 archaeologist: PROD deploy mechanics + readiness assessment.
- 334 developer: apply 37 pending migrations to PROD via the manual runner.
- 335 developer: bootstrap PROD admin.
- 336 deferred: rollback rehearsal.

334 applied a breaking `RENAME TABLE profiles -> users` to PROD ahead of the code deploy. The live PROD app was still running the old build (`2220885539`) that queries `profiles`. Result: PROD went down for every user (not just the admin-login concern 335 was meant to address) between the 334 migration-apply and the eventual 336-equivalent deploy of the new code.

Recovery: deploy the new build (`2568125371` / commit `25939e2`) which knows about `users`. App-DB realigned. Outage interval: between the 334 apply and the recovery deploy.

The orchestrator (me, harness-side) had access to the archaeologist's Section 5 forecast which named one specific failure mode (deploy_PROD healthcheck fail when code expects `users` against a 37-behind PROD). It did NOT name the inverse failure mode (schema change ahead of deploy taking the LIVE app down for users querying the old schema). Both failure modes are real; the forecast covered one direction; reality bit us with the other.

## The defect (orchestrator-template gap)

The orchestrator persona currently has discipline for:
- Mission ownership, role boundaries, end-state vocabulary, paste-handoff format, chain composition, push-verification, etc.

It does NOT have explicit discipline for sequencing DB-state changes vs code-deploy changes. When the orchestrator authors a prompt that modifies PROD database state (schema migration, data migration, structural rename, column DROP, table TRUNCATE on tables with reads/writes from running code), it must reason about:

1. **Deploy-pairing posture.** Three classes:
   - **expand-only:** Migration adds-and-coexists. Old code keeps working (queries old tables/columns). New code uses new. Safe to apply ahead of code deploy; both code versions coexist during the deploy window. Examples: ADD COLUMN, CREATE TABLE, CREATE INDEX, additive constraint with default.
   - **lockstep:** Migration + code deploy must land atomically (same pipeline run, same maintenance window). Breaking schema change with no compat surface. Examples: RENAME TABLE/COLUMN, DROP COLUMN currently-read-by-running-code, ALTER COLUMN TYPE incompat with running code.
   - **contract-after-deploy:** Code already runs against the post-migration shape (deployed earlier in an expand-only phase). Migration removes the old surface. Safe to apply when running code no longer reads/writes the old surface. Examples: DROP COLUMN that the previous expand phase made unread, DROP legacy table after the new one took over.

2. **Current running-code state.** What does origin/main + the currently-deployed build assume about the schema? Is the running build the same as origin/main, or behind?

3. **Pre-customer affordances.** Pre-customer-data / basic-auth-shielded PROD permits looser pairing because no real users observe downtime. Still, the discipline should be the same shape -- pre-customer is the operator-learning window for the pattern.

## Proposed rule (orchestrator persona)

Insert a new section or sub-section in `templates/personas/orchestrator.md`:

> **DB-state-change Prompts: Deploy-Pairing Posture.** When the orchestrator authors a prompt that modifies PROD (or any environment with running code reading/writing the affected tables), the prompt must explicitly declare its deploy-pairing posture:
>
> - `expand-only` -- safe to apply ahead of code deploy; both code versions coexist
> - `lockstep` -- migration + deploy land atomically (same pipeline run / paired prompts in one chain / coordinated boundary)
> - `contract-after-deploy` -- runs against a schema the deployed code already supports
>
> The orchestrator does NOT author a `lockstep` migration as a stand-alone prompt. It either bundles the deploy into the same prompt, OR dispatches the migration and deploy as a paired chain with explicit ordering, OR refuses to author the prompt and asks the operator how they want to pair.
>
> The orchestrator NEVER dispatches a DB-state-change prompt without naming the posture explicitly in the prompt's context-for-operator block. "I forgot to consider deploy pairing" is exactly the failure mode this rule prevents.

## Memory + cross-references

- Discovery-log entry in the target this incident hit: documents the symptom + the architect-routable follow-up ("codify expand-contract or migrate/deploy sequencing gate"). This intake is the harness-orchestrator-side mirror: the lesson is about how the orchestrator AUTHORS prompts, not about the project's CI pipeline shape.
- Pairs with future architect proposal on expand-contract migration discipline (target-side; CP `prod-deploy-readiness-2026-05` Task 5).
- Pairs with `feedback_closure_prompts_verify_pipeline` (post-push verification) -- both rules govern the orchestrator's discipline around production-affecting prompts.
- Archaeologist persona enhancements intake (2026-06-01-1931) has a related point: Section 5 forecasts must "rank failure modes by likelihood" and could be extended to "enumerate failure modes across all deploy-orderings, not just one direction."

## Out of scope (explicit)

- Implementation of the project's expand-contract CI gating. That's the target architect's concern.
- Auto-detection of migration shape (parsing SQL to classify expand-vs-lockstep). The rule is operator-confirmed posture in the prompt; mechanical detection is a separate (lower-priority) enhancement.
- Retroactive amendment of past migration prompts -- past lessons are captured; future prompts honour the rule.

## Suggested triage

Promote to `openspec/changes/orchestrator-db-migration-deploy-pairing-discipline/` (or similar slug). Implementation: a single section addition to `templates/personas/orchestrator.md`, plus a one-line addition to the harness-reviewer's persona-audit checks ("DB-state-change prompts declare deploy-pairing posture").

This is HIGH-value -- the orchestrator-template lesson is concrete, the failure mode is operator-lived, the fix is small and surgical.
