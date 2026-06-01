---
captured-at: 2026-06-01T19:31:51Z
captured-from: c04003d97c24
captured-during: target archaeologist self-critique session after the prod-deploy mechanics + readiness assessment job; operator asked "what would you have done better that should go into the AEH archaeologist instructions"
area: persona-template, archaeologist
status: untriaged
---

# Archaeologist persona template enhancements -- seven points from prod-deploy-mechanics-assessment self-critique

## Trigger

A target archaeologist session, immediately after delivering a substantial readiness-and-forecast assessment (prod-deploy mechanics + admin-seeding + reversion + press-button-now forecast), was asked by the operator to reflect on what should go into the GENERIC AEH archaeologist base template (`templates/personas/archaeologist.md`) -- not the project overlay. The session produced a structured seven-point self-critique, then offered to draft precise insertion text. This intake captures the seven points verbatim for harness-side triage + potential implementation.

The self-critique is unusually high-signal because (a) it came immediately post-delivery while the gaps were still fresh, (b) it traces each gap to the template's current shape rather than the project specifics, (c) the session validated one of its critiques live by checking whether a local audit log it had relied on inference for was actually readable (the read got denied; the lesson stood).

## The seven proposed enhancements (verbatim from the archaeologist self-critique)

### 1. Forecast / readiness mode is missing

> The base template knows two modes: produce baseline specs (§3) and reconciliation (§4). Both document current state. But ~40% of this job's value was in Section 5: "what happens if you press the button" -- a forecast, not a description. The template has no doctrine for it, so the discipline was improvised. It should name a third mode with its own rules: a forecast must (a) trace to a concrete first point of contact between the change and current state, (b) rank failure modes by likelihood, (c) separate certain mechanism-claims from inferred-quantity-claims.

**Proposed insertion point:** new mode section alongside §3 (baseline) and §4 (reconciliation), e.g. §5 "Readiness / Forecast Mode".

### 2. Absence-as-evidence is under-developed and carried half the findings

> The template is built around documenting what exists (§2a is all extraction-of-present-things). But my highest-value findings were absences: no `migrate_prod:` job, no `prod-rollback.sh`, no runbooks, no DOWN scripts. Absence is harder than presence -- you can't grep for what isn't there, you have to know what should be. The technique that worked: read the plan (the CP tasks.md), enumerate every intended artefact, then verify each one's existence and completion state. That "checklist-driven absence verification against intended design" should be an explicit Phase-2 method. Verified absence is a first-class finding, equal to a divergence.

**Proposed insertion point:** new Phase-2 method "Checklist-driven absence verification": derive the expected-artefact list from plan / design / spec documents, verify each one's presence and completion state, capture verified-absent as a finding equal in weight to divergence.

### 3. "Document reality not intent" needs a sharper edge: plan-vs-reality, not just docs-vs-reality

> The template's divergence section (§3.5) is about docs vs code. The trap that nearly caught me was subtler: a design doc described migrate_prod in step-by-step detail (§3.2 step 8), and the operator believed it ran -- but it was never built and the CP is still `status: proposed`. A design/proposal is a promise, not a fact. The template should state plainly: a `status: proposed|draft` artefact, or any design doc, describes intent -- verify completion state (task checkboxes, artefact presence, actual CI config) before treating a designed thing as existing. This is exactly where the operator's mental model was wrong, which is the most expensive place to be wrong.

**Proposed insertion point:** §3.5 (divergence section) gains a subsection on plan-vs-reality vs docs-vs-reality. Rule: any artefact with `status: proposed|draft|in-flight` describes intent; the archaeologist must verify completion state before reporting it as fact.

### 4. Operator's stated assumptions should be named as falsifiable hypotheses

> The prompt handed me the operator's belief ("confirm the migration step runs against PROD"). The single most valuable act was refuting it. The template treats the operator only as the person who "defines scope" -- it never says surface the operator's explicit and implicit assumptions and try to falsify each one; a refuted operator assumption is the highest-value finding type. For assessment work especially, the deliverable's worth is concentrated there.

**Proposed insertion point:** a working-method bullet near the top: "Surface the operator's explicit and implicit assumptions as falsifiable hypotheses; treat a refuted assumption as the highest-value finding class."

### 5. Exploit local history / audit trails before falling back to inference

> My load-bearing number -- "PROD is ~37 behind" -- I left as `[unverified]` inference from a 2026-03-23 diff, when a cheaper truth source existed in-repo: a checksum-chained audit log of every relevant invocation would have shown whether anyone ever ran the migration command against PROD. I cited that the audit log exists but didn't mine it. The template's §2b ("live data before static files") should add: before tagging a claim `[unverified]`, check whether a local trail -- audit logs, git history of the specific file, CI run history -- can convert it to verified cheaply. Inference is the last resort, not the first.

**Proposed insertion point:** §2b ("live data before static files") gains a clause: "Before tagging any claim `[unverified]`, exhaust the cheap-conversion routes: project-local audit logs, git history of the specific file, CI run history, server-side ledgers. Inference is the last resort, not the first." The session named this as the one critique it would genuinely have done better in retrospect.

### 6. Match orchestration to breadth

> §2a pushes parallel fan-out for Phase 1. But this answer lived in ~6 files (.gitlab-ci.yml, health check, tasks.md, bootstrap script, the compose file, the design). Direct reading by the synthesizing context beat delegation -- fan-out has real overhead and dilutes the cross-referencing that produced the key insight. The template should say fan-out is for genuinely broad sweeps; for a handful-of-load-bearing-files assessment, read them yourself.

**Proposed insertion point:** §2a (orchestration) gains a sizing rule: "Parallel fan-out is for genuinely broad sweeps (dozens of files, multiple subdirectories). For a handful-of-load-bearing-files assessment (~ < 10 files), direct reading by the synthesizing context produces better cross-referencing and faster delivery. Choose the orchestration shape that matches the breadth, not by default."

### 7. Calibrate recommendations to be robust to the unverifiable

> I structured §6 so the recommendation holds even if the "37" is wrong ("the mechanism findings hold regardless of the count"). The template only offers `[unverified]` tagging; it should add the next step -- separate conclusions that are robust-to-uncertainty from those that are contingent on an unverified claim, and say which is which. That's far more actionable for downstream roles than a bare tag.

**Proposed insertion point:** the recommendation / report-shape section. Rule: "For each conclusion that depends on an `[unverified]` claim, state explicitly whether the conclusion is robust to the uncertainty (mechanism finding -- holds regardless) or contingent (specific count / specific value -- shifts if the claim is wrong). Robust vs contingent labelling makes downstream role decisions actionable."

## Session's own prioritisation

The session named #2 / #3 (verify intent vs reality; treat absence and plan-promises as findings) and #5 (mine local trails before inferring) as the highest-value of the seven. Triage may want to follow that ordering: #2 + #3 + #5 as the core proposal; #1 / #4 / #6 / #7 as a follow-on or bundled in.

## Suggested triage

Promote to `openspec/changes/archaeologist-persona-enhancements/` (or similar slug). Pair the seven enhancements as one proposal; the archaeologist persona template is the single edit surface for all of them. Tasks.md decomposes by which §-section of the template each enhancement modifies.

The session offered to draft precise insertion text for each enhancement. That offer is high-value -- the session has the freshest possible context. Capture the offer by either:
- (a) routing a follow-on prompt back to the same target session asking for the seven insertion blocks, written to a target-tree report file (since target sessions cannot write to `/workspace/aeh/`); the harness orchestrator then transcribes from the report into the template edits, OR
- (b) accepting the insertion text in a chat handoff if the harness session and target session converse, OR
- (c) deferring -- the harness-side implementer derives the insertion text from this intake's seven proposed-insertion-point notes.

Operator decides at triage time.

## Verbatim source

The seven points above are quoted from a target archaeologist session immediately post-delivery of a substantial assessment job. The session's full reflection (with its self-validation attempt on point #5, declined by the harness Bash gate) is captured in this intake; the substance is preserved verbatim because the wording is unusually crisp and any paraphrase would weaken it.
