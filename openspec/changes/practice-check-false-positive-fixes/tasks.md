# Tasks: practice-check-false-positive-fixes

Ordered; each task carries a mechanical completion signal.

1. **Newline-tolerant deny-list detection.** In `check_permission_scope`, replace the
   single-physical-line deny detector with a newline-tolerant one (normalise the file
   content before matching, or parse JSON when a parser is available with a grep
   fallback). Keep the existing two-file union.
   - Signal: a fixture config with a pretty-printed multi-line `"deny"` array (first
     element on the next line) yields PASS (no "no non-empty deny list").

2. **Loopback dev-credential whitelist in the secret-literal detector.** Add a
   whitelist for well-known local-only credential patterns bound to a loopback host
   (`127.0.0.1` / `localhost`); leave the non-loopback case flagging.
   - Signal: a fixture allow rule with a loopback-bound local dev credential yields no
     secret-literal hit; the same literal bound to a non-loopback host still FAILs.

3. **Optional pairing baseline cutoff.** In `check_prompt_result_pairing`, honour an
   optional `docs/AE/.prompt-pairing-since` marker (first NNN or ISO date). Evaluate
   only prompts at/after the cutoff; print "N historical prompt(s) before cutoff X not
   evaluated"; no marker -> evaluate all (unchanged).
   - Signal: a fixture target with unpaired pre-cutoff prompts + a marker yields PASS
     plus the excluded-span line; the same target with no marker yields the prior FAIL.

4. **Regression fixtures.** Add one fixture per class (multi-line deny list; loopback
   dev credential; pre-cutoff unpaired history) under the check's test harness.
   - Signal: running the fixtures asserts the corrected verdict for each.

5. **Document the cutoff marker lifecycle.** Note where the marker is seeded (onboarding
   = first prompt; legacy refresh/retrofit = prompt number at adoption) in the check's
   header comment and the relevant role/seed reference. If no existing seed template
   fits, record a one-line follow-on rather than expanding scope here.
   - Signal: the marker's seeding is documented; pre-fix expected-FAIL adjudication note
     removed or superseded.

6. **CHANGELOG + gate.** [Unreleased] entry; `bin/validate-personas.sh --staged` and
   `--message` pass; harness-reviewer bookend before push.
   - Signal: validator exits 0; reviewer PASS/WARN; single commit; no push.
