---
slug: openspec-closeout-verification-status-preservation
status: proposed
since: 2026-05-31
provenance: openspec/changes/openspec-closeout-verification-status-preservation/provenance.md
---

# OpenSpec Close-Out: Verification-Status Preservation

## What

Extend the canonical close-out playbook (`openspec/AGENTS.md`, the embedded AGENTS.md content in `templates/tools/openspec-setup.md` Step 1, and `templates/prompts/openspec-close-out-retrofit.md.template`) with a "Verification-Status Preservation" discipline that prevents close-out from silently promoting design intent to verified-ground-truth for spec systems that distinguish the two.

## Why

The canonical close-out playbook says: "apply spec deltas to parent specs -> bump parent `last-updated-by:` + `updated:` -> set proposal `status: archived` -> move to archive/". The first step is load-bearing. As currently written, it has no guidance for spec systems where individual spec sections carry verification-status frontmatter or markers asserting whether the section has been verified against the live system -- a discipline encouraged by the archaeologist persona's `[verified]` / `[unverified]` tagging guidance and adopted by some projects as a structured frontmatter field (e.g. `archaeologist_verified: <ISO date>`).

Naive close-out would silently transfer verified status to new content the close-out has NOT re-verified. The close-out would appear to verify something it didn't, undermining the verification-status discipline's whole point. This was caught and worked around locally by a peer AEH orchestrator session in the first real exercise of the convention; the workaround is the right shape but belongs in the canonical playbook, not in per-target adapted copies.

## Scope

In scope:
- Add a "Verification-Status Preservation" subsection to `openspec/AGENTS.md` (harness-self) immediately after the "Mechanical close-out sequence" subsection.
- Mirror the addition into the AGENTS.md content embedded in `templates/tools/openspec-setup.md` Step 1, so new targets adopting OpenSpec via the setup template carry the discipline from day one.
- Add the same content to `templates/prompts/openspec-close-out-retrofit.md.template` so pre-existing targets retrofitting close-out get the verification-preservation guards as part of the retrofit.
- Cross-reference `templates/personas/archaeologist.md` as the canonical source of the verification convention.
- The discipline is conditional: applies only to spec systems that carry verification-status frontmatter or markers; no-op for systems that don't.
- CHANGELOG entry.

Out of scope:
- Mandating a specific verification-status field name. Different projects use different conventions; the discipline applies to whatever convention the project uses.
- Tooling to detect verification-status fields automatically and apply the guards without operator awareness. Operator + close-out playbook + reviewer is the right loop.
- Changing the archaeologist persona's existing verification discipline. This proposal references that discipline as the source-of-truth; it does not modify it.

## Acceptance criteria

1. `openspec/AGENTS.md` carries a "Verification-Status Preservation" subsection covering the two guards (preserve verification-status fields untouched; add provenance markers to applied sections).
2. `templates/tools/openspec-setup.md` Step 1 embedded AGENTS.md content carries the same subsection.
3. `templates/prompts/openspec-close-out-retrofit.md.template` carries the guards in its close-out walking step.
4. All three locations cross-reference `templates/personas/archaeologist.md` as the verification convention source.
5. CHANGELOG entry under [Unreleased] Changed.
6. Captured at `openspec/changes/_intake/2026-05-31-1530-closeout-preserves-verification-status-0c37120ebcd6.md` -- inbox file moved to `status: promoted` with `promoted-to: openspec-closeout-verification-status-preservation`.

## References

- Provenance: `provenance.md` in this directory.
- Inbox capture: `openspec/changes/_intake/2026-05-31-1530-closeout-preserves-verification-status-0c37120ebcd6.md`.
- Source convention: `templates/personas/archaeologist.md` (verification-status discipline).
- Parent proposal: `openspec/changes/openspec-close-out-convention/` (the convention this refines).
