---
captured-at: 2026-06-03T09:30:00Z
captured-from: d8f5c433cd8c
captured-during: harness orchestrator session, conversational refinement of document-authoring discipline
area: cross-persona-discipline
status: promoted
promoted-to: archive/2026-06/document-placement-ground-truth-scan-discipline
promoted-at: 2026-06-03T10:00:00Z
archived-at: 2026-06-03T10:30:00Z
---

# Ground-truth scan before writing any new document (RESPECT / CONSOLIDATE / ESTABLISH)

**Trigger:** Orchestrator-authored prompt directed a target session to write a new local-dev runbook at a guessed location without scanning the existing docs structure first. Operator pushed back: a scattered mess of locations is exactly what should be prevented. Ground-truth scan revealed an existing canonical home for that content class was already wired into the project's mkdocs nav -- just stale (drifted facts that needed reconciliation, not a parallel file). The right action was UPDATE IN PLACE + anti-scatter pointer pass over duplicates. The first version of the prompt would have created a parallel file, defeating single-source-of-truth.

**Insight:** The harness has multiple roles that produce documents (analyst, architect, developer, reviewer, archaeologist, orchestrator, harness-reviewer). None of the current persona templates encode a "scan before scatter" discipline. They each carry a narrow rule for THEIR own canonical output (e.g. archaeologist baseline specs at `openspec/specs/baseline-*.md`; developer retrospectives at `docs/AE/reports/`), but no general principle prevents creating a NEW doc in a NEW location when an existing convention already exists for the content class. The anti-pattern is concrete: scattered duplicates across `docs/`, `docs/AE/`, `openspec/`, `targets/`, project root -- each written once, found never.

The discipline has three branches that should be made explicit so role-holders know what to DO, not just what to avoid:

- **(a) RESPECT** -- existing convention exists for this content class; write at the location it dictates and follow its format.
- **(b) CONSOLIDATE** -- pre-existing material on the same topic exists; update IT in place; convert any duplicates into one-line pointers.
- **(c) ESTABLISH** -- no convention exists; pick a defensible location, wire into docs/mkdocs nav, write pointers from `CLAUDE.md` / relevant persona overlays / related runbooks so future role-holders discover it.

The reviewer should treat "new doc in a fresh location with no ground-truth scan evidence" as a Dimension-1 / hygiene finding to be flagged in review. The harness-reviewer should perform the analogous check across the public harness repo.

**Suggested change (incremental):**

1. `CLAUDE.md` Working Rules: add a bullet codifying the RESPECT / CONSOLIDATE / ESTABLISH discipline. (Implemented 2026-06-03 same session as capture.)
2. Base persona templates for content-producing roles -- add a one-bullet principle in the Principles section pointing at the same discipline. Implemented 2026-06-03 same session:
   - `templates/personas/developer.md`
   - `templates/personas/analyst.md`
   - `templates/personas/architect.md`
   - `templates/personas/reviewer.md` (includes reviewer-as-enforcer clause)
   Pending triage:
   - `templates/personas/archaeologist.md`
   - `templates/personas/orchestrator.md` (also authors state files and journal entries)
   - `templates/personas/harness-reviewer.md` (mirrors reviewer-as-enforcer for the harness repo)
3. `templates/governance/review-criteria.md`: add an explicit check for placement-discipline if a hygiene dimension exists.
4. Target propagation rides on the existing base-persona refresh mechanism (`templates/prompts/refresh-base-personas.md.template`). No separate retrofit prompt needed.

**Open questions for triage:**
- Should the rule extend to non-markdown artefacts (scripts, configs, fixtures, schema files)? Likely scope to markdown / docs for now; revisit if reviewer flags non-doc scatter.
- Should each persona's bullet include persona-specific scan commands (`grep -ril <topic> docs/`, `ls openspec/specs/`)? Probable answer: scan locations are persona-specific; generic shell commands would be inaccurate. Each persona's bullet names the locations relevant to its content class.

**Memory updates:** none. The rule is harness-discipline, not operator-feedback-driven.

**Related captures:**
- The base-persona-refresh-all-personas capture -- the propagation mechanism this rule rides on.
- The clear-instructions-explicit-discipline capture -- adjacent "make implicit discipline explicit" theme.
