---
captured-at: 2026-06-06T12:55:55Z
captured-from: a8733b7927f2
captured-during: implementing an accepted state-consolidation proposal; the implementer (harness-reviewer wearing the implementer hat) declared the plan sound at the sanity-review step without scanning the harness for every producer/consumer of the files being retired, then discovered mid-bookend that the change was incomplete and had to re-scope
area: governance / quality-gates / personas (architect + reviewer + harness-reviewer)
status: untriaged
---

# Discipline: a subtraction is not "done" until a producer+consumer reference scan is clean

**Origin.** A consolidation proposal retired three state files and folded them into existing ones. The proposal (and the implementer's "is this plan sound?" sanity check) reasoned about the files being retired against an abstract migration mapping, but never enumerated the files that *produce* or *consume* those names in the field. A 30-second repo-wide `grep` would have immediately surfaced about nine consumers plus a fourth orphan file plus the onboarding scaffold that minted all of them. Because that scan was skipped at plan-soundness time, the work went: narrow implementation -> bookend finds it incomplete -> decision round-trip -> real scope. The under-scope was caught (the review gate worked) but only after an avoidable wasted pass.

**The pattern (generic).** Any change that REMOVES, RENAMES, or FOLDS a convention -- a filename, a rule, a state slot, a path, a flag, a tag -- has a blast radius that is invisible from the declaration of the convention. The declaration lives in a canonical spot (a persona, a CLAUDE.md tree, a README); the convention is USED and PRODUCED in many other spots. A change that updates only the declaration ships a self-contradiction: the canonical doc says "this no longer exists" while a playbook still scaffolds it and a checklist still reads it.

**The rule.** A subtraction is not designed, not implemented, and not reviewable-as-complete until a repo-wide reference scan over the retired token returns only (a) labelled migration notes and (b) deliberately-out-of-scope history. The scan is the FIRST action when planning the change (so scope is sized before any edit), and a re-run is a gate at review time (so nothing survived). "Update the declaration" is the trap; "sweep every producer and consumer" is the work.

**Why this is the symmetric partner of the forgetting question.** The orchestrator-state-consolidation change added a harness-reviewer "does this still earn its place?" lens (the REMOVE-decision side: should it exist?). This is the other half: once you decide to remove it, remove every trace, or you have not removed it -- you have forked it. Addition has always been safe-by-default in this harness; subtraction is the dangerous operation, and it has had no discipline until now.

**Proposed injection (categorical, propagates to targets).** One tight Principles/section addition to the three roles that author and review subtractions:
- **architect** (plan side): when a design removes/renames/folds a convention, the design enumerates producers + consumers and `tasks.md` carries the sweep as explicit tasks with a mechanical residual-scan signal.
- **reviewer** (target gate): a change that retires a token is incomplete until a residual scan is clean; a surviving reference in canonical-set context is a finding (sibling of the existing Absence Check).
- **harness-reviewer** (harness gate): same, explicit, paired with the Dimension-3 forgetting question.

**Evidence it is generic, not a one-off.** The same failure shape recurs whenever the harness or a target consolidates: the additive ratchet that motivated the consolidation work is itself the absence of a safe subtraction operation. Targets rename columns/endpoints/flags constantly; each is a subtraction whose consumers must be swept. This is not state-file-specific.

**Likely home.** Base persona Principles (architect/reviewer) + harness-reviewer Dimension 4, mirroring how the document-placement ground-truth discipline was propagated. Light -- three bullets, no new mechanism.
