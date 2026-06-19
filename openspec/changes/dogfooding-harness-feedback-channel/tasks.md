# Tasks: dogfooding-harness-feedback-channel

Ordered; each task carries a mechanical completion signal.

1. **Prompt-file format + templates.** Add the "Harness feedback (dogfooding)" framing
   block and the `HARNESS FEEDBACK` report-back field to `CLAUDE.md` "Prompt File Format"
   and the dispatched-prompt templates (AEH-practice / retrofit / propagation at minimum).
   Include: artifacts-under-test framing; the "did not land flawlessly" classes; keep
   separate from target findings; STOP-if-blocked; "none -- landed as written" is valid.
   - Signal: a dispatched-prompt template contains the block + the named report-back field.

2. **target-orchestrator harvest discipline.** Add a standing step: scan every
   report-back's `HARNESS FEEDBACK` field; operator-gated capture of any harness-level
   signal via the existing Harness Capture protocol; "this exercise is also dogfooding"
   lens.
   - Signal: `templates/personas/target-orchestrator.md` carries the harvest-and-capture
     discipline referencing the existing capture protocol.

3. **target-aeh-reviewer dimension.** Name a "dogfooding feedback" detection dimension.
   - Signal: `templates/personas/target-aeh-reviewer.md` lists the dimension.

4. **CHANGELOG + gate.** [Unreleased] entry; `bin/validate-personas.sh --staged` and
   `--message` pass; harness-reviewer bookend before push.
   - Signal: validator exits 0; reviewer PASS/WARN; single commit; no push.
