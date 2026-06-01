---
captured-at: 2026-05-31T17:48:18Z
captured-from: 77c32eea48bc
captured-during: autonomous chain reviewer step tripped a zero-commit halt guard
area: template
status: promoted
promoted-to: reviewer-prompt-commit-step
promoted-at: 2026-06-01T11:30:00Z
---

# Reviewer prompts in autonomous chains must carry an explicit commit step

**Trigger:** A reviewer-checkpoint prompt in an autonomous chain wrote its verdict
report to disk and reported PASS, but did not commit it. The chain wrapper's
zero-commit halt guard fired on the reviewer step -- a false halt on a clean PASS,
because the step legitimately produced a file but no commit.

**Insight:** When a chain wrapper enforces a "zero commits from a step = halt"
condition (a standard halt-catalogue guard), every step in that chain MUST land at
least one commit. A reviewer step that only writes a report to the working tree
satisfies its review duty but trips the guard. The review verdict also belongs in
the audit trail as a commit regardless of the guard. The reviewer persona / prompt
templates and the chain-composition guidance describe writing the review file but
do not consistently make the follow-on commit a mandatory, explicit step -- so a
chain-composed reviewer prompt can omit it and halt the chain on a success.

**Suggested change:**
- Reviewer persona template: make "commit the review report on main" an explicit
  mandatory step of the review-output section, not implied.
- Chain-composition guidance (orchestrator persona, multi-prompt chain section):
  note that any step under a zero-commit halt guard must produce a commit; a
  reviewer/doc step that only writes a file will false-halt the chain.
- Halt-condition catalogue entry for "zero commits": note the reviewer-step caveat
  so chain authors design the reviewer prompt to commit.

**Memory updates:** relates to `feedback_closure_prompts_verify_pipeline` and the
orchestrator chain halt-condition catalogue; no existing feedback file supersedes.
