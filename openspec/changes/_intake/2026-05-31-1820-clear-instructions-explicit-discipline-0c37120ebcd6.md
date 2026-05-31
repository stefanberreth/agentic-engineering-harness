---
captured-at: 2026-05-31T18:20:00Z
captured-from: 0c37120ebcd6
captured-during: harness session, operator correction after the orchestrator applied /clear discipline inconsistently across consecutive paste handoffs
area: orchestrator-persona
status: untriaged
---

# Paste handoffs must carry explicit /clear-or-not declaration with reason

**Trigger:** During a multi-paste retrofit arc, the orchestrator authored three consecutive paste handoffs (v1, v2, v3) with inconsistent treatment of /clear guidance: v1 included `/clear` as a precondition step, v2 contained a half-mention ("`/clear` not needed if you've already cleared between v1 halt and now"), v3 omitted /clear guidance entirely. Operator caught the inconsistency and named the discipline gap: the orchestrator persona has the calibration logic internally (clear when continuity hurts, preserve otherwise) but does not mandate that the decision be made VISIBLE to the operator above the paste. Result: the operator is left guessing per-paste whether to clear or not.

**Insight:** The discipline already exists in operator memory (`feedback_clear_context_on_role_switch.md`: /clear discipline -- recommend ONLY when continuity hurts; default preserve) and in `feedback_handoff_step_order.md` (preconditions always appear ABOVE the paste line). What is missing is a HARD RULE in the orchestrator persona template that every paste handoff must carry an explicit /clear-or-not statement with one-line reason, before the paste block. The operator should never have to infer the orchestrator's clear/preserve judgment from context.

The default stays "preserve" -- clearing reflexively defeats the point, because many prompt sequences benefit from carried-over context (halt-resolution back to the same role, small follow-ups in the same task, etc.). The rule is about making the (default-preserve, sometimes-clear) judgment legible, not about clearing more often.

**Suggested change:**

- Update `templates/personas/orchestrator.md` § "Paste-Handoff /clear Discipline" (or fold into the broader handoff-format section) with a hard rule: every paste handoff produced by the orchestrator carries an explicit /clear-or-not statement with one-line reason, positioned ABOVE the paste block (consistent with the existing precondition-above-paste rule from `feedback_handoff_step_order.md`).
- Include a small calibration matrix inline in the persona template (also useful to operators reading the persona):

| Situation | /clear default |
|---|---|
| Different role from last paste (e.g. orchestrator -> developer) | /clear recommended |
| Different domain / unrelated task | /clear recommended |
| Large unrelated task that would push context unnecessarily | /clear recommended |
| Halt-resolution returning to same role + same task | NEVER /clear (continuity is the whole point) |
| Small follow-up to a just-completed task in same role | NO /clear (continuity helps) |
| Long break across days, same role + same task | Operator's judgment; preserve unless context feels stale |

- The rule applies to BOTH cases (recommend clear AND recommend preserve). Silent omission is the failure mode; "no /clear -- continuity helps" is just as valid an output as "/clear -- role switch."
- Cross-reference the existing operator memory entries so the persona update doesn't duplicate the rule but operationalises its surfacing.

**Memory updates:**

`feedback_clear_context_on_role_switch.md` may benefit from a short addition noting the explicit-statement-above-paste rule -- not because the memory was wrong, but because applying the rule internally without surfacing it visibly was the actual failure mode in this session. One-line addition: "Always state the /clear-or-not call explicitly above the paste block, with reason. Silent omission is the failure mode even when the internal call is correct."

No other memory changes needed; the underlying discipline is unchanged.
