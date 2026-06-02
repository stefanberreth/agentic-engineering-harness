---
captured-at: 2026-06-02T15:01:00Z
captured-from: c04003d97c24
captured-during: harness orchestrator session, operator-stated positioning correction for the public README
area: documentation, README, onboarding-positioning
status: untriaged
---

# README must position OpenSpec and Context7 as de-facto prerequisites (opt-out with good reason, not optional add-ons)

## Trigger

Operator framing 2026-06-02 (verbatim):

> "In the README, make Context7 and OpenSpec de-facto requirements. OpenSpec more so than Context7. Both can be opted out and there are good reasons for specific cases where what they deliver is replaced with something equivalent, but leaving them out entirely effectively degrades the usefulness, reliability and predictability of the AEH substantially. So much as to consider them prerequisites. If you don't know why not, you do want them."

## Context

The harness already defaults both tools to in-scope at onboarding time (per CHANGELOG entry shipped earlier in 2026: "OpenSpec and Context7 are now default in-scope during onboarding (opt-out, not opt-in)"). Onboarding playbook + tools playbook + governance criteria all enforce the default-in-scope shape. Harness-reviewer Dimension 10 audits the default.

What is NOT yet aligned: the **public-facing README**. The README's "Required infrastructure" and "Prerequisites" sections currently describe these tools as standard SDLC components within the harness's recommended setup, but do not position them with the strength the operator requires:

> "If you don't know why not, you do want them."

The README's reader is a first-time visitor / potential adopter / external contributor. They form their mental model of "what AEH actually needs to be useful" from this document. If the README treats OpenSpec and Context7 as optional add-ons or recommended-but-not-required, the reader's takeaway is "I can skip these and still get the AEH value." That takeaway is wrong -- leaving them out degrades the substrate's usefulness, reliability, and predictability substantially.

## The defect

README positioning lags the harness's actual operational stance. Onboarding enforces default-in-scope (opt-out); README hedges. Result: a first-time reader's expectations are set softer than the harness's operational reality.

## Proposed positioning (intake -- not finished copy)

The README needs to elevate OpenSpec and Context7 from "recommended tools" to "de-facto prerequisites" with these characteristics:

1. **Strong default: in.** Stated explicitly as a positioning sentence, not buried in a setup step.
2. **OpenSpec slightly stronger than Context7.** Per operator's "OpenSpec more so than Context7" framing. OpenSpec is structural substrate the harness conventions rely on (spec-traceability, change-proposal mechanism, the discipline gates the harness preaches). Context7 is library-documentation access; replaceable in principle by other mechanisms but the absence of any equivalent degrades developer + reviewer effectiveness markedly.
3. **Opt-out is documented but carries weight.** Specific cases where opting-out is legitimate: when the project has an equivalent mechanism that delivers the same value (a different spec/proposal system, a different documentation-access tool). NOT "I don't want the overhead." If the operator cannot name what they're replacing the tool with, the operator wants the tool.
4. **Default direction baked into language.** "Both ship enabled by default; opt-out requires a documented rationale" rather than "Optionally, you may install...". The framing inverts: the burden of justification falls on opting OUT, not opting IN.

Suggested README sections affected:
- The "Required infrastructure" or "Prerequisites" section at the top -- elevates both tools to the prerequisite list, with the operator's heuristic captured directly: "If you don't know why not, you do want them."
- The "Inner mechanics" section -- when describing SDLC discipline bullets, name OpenSpec as the load-bearing substrate (specs, change proposals, archive convention) and Context7 as the developer/reviewer-substrate for library-currency.
- Any "Quick start" or "Onboarding modes" section that currently lists them as optional or as offer-blocks -- align language with the default-in-scope reality.

The CHANGELOG entry that shipped the default-in-scope behaviour at onboarding can be cited from the README as evidence of the harness's operational stance.

## Out of scope (explicit)

- Changing the onboarding-time mechanism (already in place; ship-as-is).
- Removing Serena from "genuinely optional" status (Serena is codebase-dependent; the operator did NOT escalate it to prerequisite).
- Removing the opt-out path entirely. Both tools remain opt-out-with-reason, NOT mandatory.
- Promoting any other tool to prerequisite status (no other tool is in scope for this elevation).

## Suggested triage

Promote to `openspec/changes/readme-tool-prerequisites-positioning/` (or similar slug). Small surgical proposal: README copy changes + alignment with onboarding-playbook language + a CHANGELOG entry under Changed.

Pair with these existing intakes (related, not blocking):
- `harness-portability-assessment` (deferred) -- a future portability assessment may revisit whether OpenSpec / Context7 specifically should be named OR whether the harness should say "an OpenSpec-like substrate + a Context7-like library-doc surface" generically. Today, OpenSpec and Context7 are the named tools; the proposal lifts that to README.

## References

- Operator's exact framing 2026-06-02: quoted in the Trigger section above.
- CHANGELOG entry that already aligned onboarding behaviour: "OpenSpec and Context7 are now default in-scope during onboarding (opt-out, not opt-in)".
- `templates/playbooks/onboarding.md` Phase 6g -- the default-in-scope offer block.
- `templates/personas/harness-reviewer.md` Dimension 10 -- audits the default-in-scope enforcement.
- `README.md` -- the file to edit; current shape hedges; needs alignment with operational reality.
