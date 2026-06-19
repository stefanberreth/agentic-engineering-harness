---
captured-at: 2026-05-31T11:45:00Z
captured-from: 0c37120ebcd6
captured-during: harness session, conversational refinement of orchestrator response end-states
area: orchestrator-persona
status: untriaged
---

# Response end-state vocabulary: expand from 3-state to 4-state

**Trigger:** Operator conversation surfaced that the current 3-state end-state vocabulary (DONE | DECISION-NEEDED | NEXT-STEP-CLEAR) does not cleanly cover two adjacent operator-experience states that occur regularly during multi-session work: (a) a chain wrapper or wakeup is ticking off-screen and the operator can walk away, and (b) the operator has off-screen work to produce a result for, and the orchestrator is idle waiting for that result. Both were being collapsed into DONE-with-a-note, losing useful signal about who owns the next move and whether the clock is ticking.

**Insight:** The operator wants the closing-state label to communicate two things every time: (1) is the clock ticking somewhere, and (2) on whose side. The existing three states cover the "no clock ticking" cases adequately (DONE = nothing pending; DECISION-NEEDED = blocked on operator choice), but conflate two distinct "clock-ticking" cases. Splitting them into MONITORING-BACKGROUND (clock ticking on the orchestrator's side -- chain wrapper, scheduled wakeup, autonomous loop running) and PAUSED-ON-YOUR-WORK (clock ticking on the operator's side -- off-screen action like manual auth, side work, anything where the orchestrator is idle until the operator returns with a result) gives the operator unambiguous walk-away signal and unambiguous ownership signal in one label.

The semantic distinction between DECISION-NEEDED and PAUSED-ON-YOUR-WORK is important: DECISION-NEEDED needs a *choice* from the operator; PAUSED-ON-YOUR-WORK needs a *result* the operator produces off-screen. Different operator actions; different "what happens next" expectations.

**Suggested change:**
- Update the orchestrator persona template's Report-Back / response end-state convention from the current 3-state vocabulary to the new 4-state vocabulary: `DONE | DECISION-NEEDED | MONITORING-BACKGROUND | PAUSED-ON-YOUR-WORK`.
- Include a one-line definition for each state in the template so the discipline is self-documenting.
- Provide examples or rule-of-thumb guidance for the DECISION-NEEDED vs PAUSED-ON-YOUR-WORK distinction (choice vs result).

**Memory updates:**
- `feedback_orchestrator_response_end_state.md` -- currently states: "Every orchestrator response ends in DONE | DECISION-NEEDED | NEXT-STEP-CLEAR. No other states." Supersede with the 4-state vocabulary; replace NEXT-STEP-CLEAR (which conflated the two ticking-clock cases) with MONITORING-BACKGROUND and PAUSED-ON-YOUR-WORK; carry forward the "no other states" discipline.
