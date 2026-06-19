---
captured-at: 2026-05-31T15:30:00Z
captured-from: 0c37120ebcd6
captured-during: harness session relaying an insight surfaced by a peer AEH orchestrator session while authoring a target-side close-out prompt under the newly-shipped close-out convention
area: template
status: untriaged
---

# OpenSpec close-out playbook must preserve verification-status semantics

**Trigger:** A peer AEH orchestrator session authoring the first real target-side close-out under the just-shipped canonical close-out convention (the harness's new `openspec/AGENTS.md` template) noticed that naive application of the four-step mechanical sequence would silently promote design intent into verified-ground-truth status for any spec system that carries a verification-status field on spec sections. The peer added two guards in its target-adapted close-out playbook before dispatch and flagged the gap upward as a harness-template-lift candidate.

**Insight:** The canonical close-out playbook (introduced in the same change as the harness-self `openspec/AGENTS.md` and the setup-template scaffold) says: "apply spec deltas to parent specs -> bump parent `last-updated-by:` + `updated:` -> set proposal `status: archived` -> move to archive." The first step is the load-bearing one and currently has no guidance for spec systems where individual spec sections carry verification-status frontmatter or markers asserting whether the section has been verified against the live system (a discipline encouraged by the archaeologist persona's `[verified]` / `[unverified]` tagging guidance, and adopted by some projects as a structured frontmatter field).

Under the naive close-out mechanism, applying a delta to a section that was previously marked verified would silently transfer the verified status to the new content -- which the close-out has NOT re-verified. The close-out would *appear* to verify something it did not, undermining the entire point of having verification-status discipline.

The peer's guards:

1. Verification-status fields stay untouched by close-out. Only `updated:` and `last-updated-by:` bump. The close-out does not re-verify the live system, so it must not claim it did.
2. Each applied section carries a provenance marker on its new content: "reflects design intent, not yet [archaeologist-]re-verified against the live system." The next archaeologist or verification pass picks this up and explicitly re-verifies (or doesn't), then can promote the verification status when warranted.

This is the right discipline for any spec system that distinguishes design intent from verified ground truth -- common in projects with a real-system / live-NUC / production-data verification step that is materially more expensive than authoring the spec.

**Suggested change:**

- Update the canonical close-out playbook (`openspec/AGENTS.md` at harness root + the AGENTS.md template embedded in `templates/tools/openspec-setup.md` Step 1 content) to add a "Verification-status preservation" subsection covering both guards.
- Make the discipline conditional: applies to spec systems that carry verification-status frontmatter or markers; no-op for systems that don't. The setup template's AGENTS.md content currently does not anticipate verification-status fields; the addition should explain the discipline and let target adopters apply it when their spec convention warrants.
- The retrofit prompt at `templates/prompts/openspec-close-out-retrofit.md.template` should also carry the discipline so pre-existing targets retrofitting close-out get the verification-preservation guards by default.
- Cross-reference: the archaeologist persona (`templates/personas/archaeologist.md`) is the natural source-of-truth for the verification-status discipline. The close-out playbook should reference it as the source of the convention rather than re-inventing it.

**Memory updates:** none specifically; this is a template/playbook refinement that lives in `openspec/AGENTS.md` + the setup-template + retrofit-prompt. After the change ships, the harness-self dogfooded `openspec/AGENTS.md` carries the discipline; targets adopting OpenSpec via the setup template inherit it.
