---
slug: practice-check-false-positive-fixes
status: ready-for-archive
since: 2026-06-19
---

# aeh-practice-check.sh: eliminate two false-positive classes + one retroactive-FAIL class

## What

Three correctness fixes to `bin/aeh-practice-check.sh` (the deterministic AEH-practice
check registry, delivered into a target at `docs/AE/bin/` and run by
`target-aeh-reviewer`). All three were observed on the FIRST real-target run of the
recently-shipped checks; each turns a clean, correctly-configured target red.

1. **`permission-scope` -- deny-list detection is layout-fragile.** The deny-array
   detector requires the first array element to sit on the same physical line as the
   opening `[`. A normally-formatted (pretty-printed) `"deny"` array puts the first
   element on the next line, so the check reports "no non-empty deny list" on a
   target that has a substantial deny list. Make detection newline-tolerant.

2. **`permission-scope` -- secret-literal detector flags benign loopback dev
   credentials.** The secret-literal pattern matches a well-known local-development
   credential (the universal local database default) bound to a loopback host.
   This is the standard local-dev default, not a secret. Whitelist well-known
   local-only credentials bound to a loopback host (`127.0.0.1` / `localhost`);
   keep flagging the same literal when it targets a non-loopback host.

3. **`prompt-result-pairing` -- no baseline cutoff; FAILs forever on any target
   onboarded before the pairing convention existed.** The check scans ALL
   historical `docs/AE/prompts/NNN-*.md` against the result trail with no date/number
   floor. A target that predates the one-prompt-one-report convention has many
   unpaired historical prompts and cannot clear the FAIL without retroactively
   fabricating reports -- which the convention explicitly does not want. Add an
   optional, explicitly-reported pairing baseline cutoff.

## Why

A deterministic compliance check that false-positives on normal formatting, on
standard local-dev credentials, or on pre-convention history erodes operator trust
in the whole check the first time a real operator runs it. The secret-literal
false positive is the worst failure mode: a spurious "possible secret" hit
desensitises operators to the one signal that actually matters. The
`prompt-result-pairing` retroactive FAIL is guaranteed-red on exactly the targets
the propagation/health flow most wants a clean signal from (established targets
absorbing an upgrade), which trains operators to ignore the FAIL -- defeating the
check. Deterministic checks earn their authority by being right; these three make
them wrong on correct configs.

## Scope

In scope:
- `permission-scope`: deny-list detection tolerant of newlines between `[` and the
  first array element (normalise whitespace/newlines before matching, or a
  multi-line-aware pattern; JSON-parse with graceful fallback if a parser is
  available). The existing union of `settings.json` + `settings.local.json` is
  already correct and is retained.
- `permission-scope`: secret-literal detector whitelists well-known local-only
  credential patterns bound to a loopback host; still flags the same literal against
  a non-loopback host.
- `prompt-result-pairing`: honour an optional cutoff marker (e.g.
  `docs/AE/.prompt-pairing-since` holding the first NNN or an ISO date). The check
  evaluates only prompts at/after the cutoff and reports the excluded historical
  span explicitly ("N historical prompts before cutoff X not evaluated") -- no
  silent truncation. When no marker exists, behaviour is unchanged (evaluate all).
- Regression fixtures: a pretty-printed multi-line deny list; a loopback dev-credential
  allow rule; a pre-cutoff target with unpaired history + a marker. Each fixture
  asserts the corrected verdict.
- Seeding the cutoff marker (onboarding = first prompt; legacy-target refresh/retrofit
  = the prompt number current at adoption) is documented as the marker's lifecycle;
  the actual seed-prompt wiring is noted as a follow-on if it does not already fit
  an existing seed template.

Out of scope:
- Changing the judgment-vs-deterministic split of `permission-scope` (sprawl etc.
  stay the reviewer's narrative).
- Any new check. This is correctness-only on existing checks.
- A full JSON schema validator for settings files (graceful parse-if-available,
  grep fallback, is sufficient).

## Acceptance criteria

1. `permission-scope` PASSes on a config whose deny array is pretty-printed across
   multiple lines (first element on the line after `[`).
2. `permission-scope` does NOT flag a well-known local-only credential bound to a
   loopback host, and STILL flags the same literal bound to a non-loopback host.
3. `prompt-result-pairing` with a cutoff marker evaluates only at/after-cutoff
   prompts and prints the excluded-span line; with no marker, behaviour is unchanged.
4. A regression fixture exists for each of the three classes and asserts the
   corrected verdict.
5. Validator + publication gate pass; lands as its own commit; no push.

## References

- The check framework these extend: `openspec/changes/aeh-engineer-role-b4/`.
- The two checks themselves: shipped under F3 (`prompt-result-pairing`) and F5
  (`permission-scope`).
- Provenance: private intake captures (2026-06-19), surfaced on the first real-target
  run of these checks during a harness-update propagation pass; sanitized at promotion.
