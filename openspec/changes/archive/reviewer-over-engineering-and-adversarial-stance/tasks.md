# Tasks: Reviewer over-engineering dimension + adversarial stance + retrospective simplicity sharpening

Ordered. Persona change -- no formal spec deltas. Each task carries a mechanical signal.

## 1. Over-engineering dimension (item 4)

- Add the "Over-Engineering & LLM-Typical Waste" dimension to `reviewer.md` §2 with the LLM-waste pattern list + non-blocking-by-default / blocking-on-real-surface rule; add `over_engineering` to the verdict-category enum; add a mirror Principles bullet.
- **Signal:** `grep -c 'Over-Engineering & LLM-Typical Waste\|over_engineering' templates/personas/reviewer.md` >= 2.

## 2. Elite-adversarial characterisation (item 5)

- Reframe `reviewer.md` "What You Are" as an elite, adversarial reviewer (adversarial toward the artifact, not the author; with taste).
- **Signal:** `grep -ci 'adversarial' templates/personas/reviewer.md` >= 1 in "What You Are".

## 3. Retrospective simplicity sharpening (item 3 -- assessed, then applied)

- Assessment: existing dev §7 + reviewer Retrospective-Evaluation guidance is sound -> sharpen, do not rewrite. Add the explicit "could this have been substantially simpler?" question to developer §7; add the surface-and-route bullet to reviewer Retrospective Evaluation.
- **Signal:** `grep -ci 'substantially simpler' templates/personas/developer.md` >= 1; reviewer Retrospective Evaluation references simplicity.

## 4. Registration (addition-completeness hygiene)

- `harness-reviewer.md` Dimension 6 reviewer-structural-dimensions list registers the over-engineering dimension + adversarial stance.
- **Signal:** `grep -ci 'Over-Engineering\|adversarial' templates/personas/harness-reviewer.md` >= 1.

## 5. CHANGELOG + close intake

- CHANGELOG [Unreleased] Added entry; set the `_intake` capture `status: triaged` with all 5 items dispositioned.
- **Signal:** intake frontmatter `status: triaged`.

## 6. Bookend + publication gate + commit

- `bin/validate-personas.sh` full + `--staged` + `--message`. ASCII-only on additions. Single decoupled commit; local only, no push.
- **Signal:** validator exits 0; commit references the slug.
