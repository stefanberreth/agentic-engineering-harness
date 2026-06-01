---
captured-at: 2026-06-01T11:14:22Z
captured-from: c04003d97c24
captured-during: <solo-dev-target> retrofit dispatch (Stream A) -- first real exercise of seed-harness-sync-marker / refresh-base-personas / openspec-close-out-retrofit templates
area: orchestrator-persona, retrofit-prompt-templates, role-architecture-docs
status: promoted
promoted-to: harness-role-execution-context-discipline
promoted-at: 2026-06-01T11:30:00Z
---

# Target-side "orchestrator" role label in retrofit prompts is architecturally muddied

## Trigger

Operator challenged the role choice during Stream A dispatch: "Why do we switch to the orchestrator in the target project claude-code? Normally the orchestrator of a project runs in the AEH project directory context and hands over through writing prompts to the target's subdirectory and direct delivery copy to their project directory. Now you are telling the target directory to assume an orchestrator role that was never intended to be run in the target project context."

Operator's mental model -- and the model that actually matches the orchestrator's function -- is that the orchestrator is a harness-side coordination role. Pipeline management, prompt authorship, gate enforcement, state file at `targets/<slug>/orchestrator-state.md` (harness-side path). Target sessions run engineering roles (analyst/archaeologist/architect/developer/reviewer) or freestyle. There is no orchestrator-state for a target session to manage.

## The defect

Three harness retrofit prompt templates declare `Role: orchestrator (target-side)` in their headers and instruct Step 0 to write `orchestrator` to the persona marker:
- `templates/prompts/seed-harness-sync-marker.md.template`
- `templates/prompts/refresh-base-personas.md.template`
- `templates/prompts/openspec-close-out-retrofit.md.template`

(And by propagation, the generated prompts 326 / 327 / 328 / future retrofits that copy from these templates.)

Functionally these prompts do mechanical file operations + a single commit -- no coordination authority involved. The role label "orchestrator" is the wrong fit; it muddies the architectural meaning of the orchestrator role by suggesting it can run target-side, contradicting:

- The orchestrator persona itself, whose state, scope, and authority are harness-side.
- The clean handoff model the harness preaches: harness orchestrator writes prompts -> target sessions execute under engineering roles.

The persona / role specifications loaded at session-init do NOT explicitly state "orchestrator is harness-side only." The operator's reasonable expectation is that this should be defined and unambiguous in the persona docs, not left as an open question to the agent at run-time.

## Functional impact (what actually ran)

For <solo-dev-target> Stream A on 2026-06-01: minimal behavioural impact. The target sessions for 328 and 327 loaded the orchestrator base persona via the layered-load mechanism (which had just been placed in `_base/`), executed the fully self-contained mechanical Steps 1-5, committed locally, reported. The role label didn't change what was done because the prompt text was already complete; the persona definition's authority/scope sections were ignored because no coordination work was attempted.

But the harness now has muddied role architecture documented as canonical in three shipped templates, and an operator-visible inconsistency.

## Insight (where the fix likely lands)

1. **Retrofit prompt templates: drop the orchestrator role.** Three options, in order of preference:
   - **Freestyle (no role).** These are mechanical operator-authored maintenance scripts; no persona constraints apply. Step 0 explicitly clears the persona marker and suppresses the banner. Cleanest fit.
   - **A new `aeh-maintenance` role** dedicated to AEH-infrastructure tasks running target-side (scaffold placements, scaffold refreshes, scaffold migrations). Heavier-weight but explicit.
   - **`developer` role.** Touches files, commits, but loads a persona that frames itself around feature implementation -- semantically off.
   Recommendation: freestyle for one-shot mechanical retrofits. Reserve `aeh-maintenance` only if a recurring class of target-side maintenance roles emerges that benefits from shared persona constraints.

2. **Role-architecture clarification in CLAUDE.md and the orchestrator persona.** Explicitly state each role's intended execution context (harness-side / target-side / external LLM). Today this is implicit and inferrable; that's not good enough -- the operator caught the contradiction at the first real exercise. Candidate locations:
   - `CLAUDE.md` § "Session Init and Role Selection" -- add an "Execution context" column to the roles list.
   - `templates/personas/orchestrator.md` § "Scope" -- one explicit sentence: orchestrator runs harness-side, manages a target via prompts; orchestrator never runs target-side.
   - Symmetric one-liners in `analyst.md`, `archaeologist.md`, `architect.md`, `developer.md`, `reviewer.md` -- all target-side; the harness orchestrator never enters their context.
   - `harness-reviewer.md` -- harness-side.
   - `strategist.md` -- external LLM (already documented; lift to a standard "Execution context" pattern).

3. **Retrofit-template authoring discipline.** When a future retrofit template is authored, the role-label choice should be a deliberate decision, not a copy-paste from prior templates. Add a one-liner to the harness-reviewer's checks: "retrofit prompt templates declare a role appropriate to their target-side execution context."

## Scope of the fix

This proposal addresses both the immediate template defect (three files) AND the underlying documentation gap (role execution context made explicit in CLAUDE.md + personas). The latter is the load-bearing prevention: without it, the next retrofit-template author repeats the same mistake.

Pair with the related insight (operator-stated 2026-06-01): "There should be no BAU verbatim prompt copies of the shape you printed to me above" -- every multi-step instruction goes to a file. This is already canonical for target-side prompts (`feedback_prompts_to_files_not_paste_blocks`, `feedback_handoff_format_strict`) but the harness-self orchestrator session lacks an established prompt-file convention. Candidate location: harness-self orchestrator kickoff prompts live under `openspec/changes/<slug>/kickoff.md` when they kick off a specific OpenSpec change; ad-hoc harness-self briefs live at a new `prompts/` directory in the harness repo root (or under the OpenSpec change dir if scoped). This is itself a Stream B candidate, not part of the present capture, but flagged here as adjacent.

## Suggested triage

Promote to `openspec/changes/retrofit-template-role-discipline/` (or similar slug) alongside the `claude-md-size-discipline` proposal being authored in Stream B. The two fit naturally together as a "harness role + scope hygiene" pair.
