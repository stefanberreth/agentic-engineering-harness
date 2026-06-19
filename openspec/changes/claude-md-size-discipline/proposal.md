---
slug: claude-md-size-discipline
status: ready-for-archive
since: 2026-06-01
reconcile-with: orchestrator-state-consolidation, harness-maintainer-role-charter
absorbs: claude-md-router-discipline-anti-bloat (intake 2026-06-19), claude-md-uplift-whole-block-diff (intake 2026-06-19)
sibling: dispatched-artifact-in-target-hygiene
---

# CLAUDE.md router discipline + size discipline (slim via pointer-to-home)

## Consolidation resolution (2026-06-19) -- supersedes the 2026-06-06 parked note

This proposal was PARKED for "the harness-maintainer's first consolidation round."
That round is now running (the `aeh-engineer` role exists and is doing it). This note
resolves the parked fork and absorbs two same-family 2026-06-19 intake captures. The
original proposal text is preserved below; this section is the controlling scope.

**Mechanism fork -- RESOLVED.** Adopt **in-place compression to existing pointers** as
the mechanism; **drop the new `docs/harness-rules/` tree.** The 2026-06-06 pass already
proved in-place compression works (it cleared the runtime warning with no new tree), and
a new parallel tree cuts against the same single-source-of-truth invariant this proposal
now enforces. Extraction targets a rule's EXISTING owning home (its persona / playbook /
openspec spec / docs reference), not a new bespoke tree. The `<30k` figure becomes a soft
budget, not a hard gate (size alone is a crude signal; see below).

**Candidate correction (F2 interaction).** The capture listed "the full role-location
3-part signature" as a compression candidate. It is NOT: F2 settled that the full
signature lives in exactly TWO canonical places (the harness `CLAUDE.md` + the target
template) BY DESIGN -- the fence forbids a target-facing persona citing the harness
`CLAUDE.md`, so the signature cannot collapse to a single pointer. The role-location
signature is therefore deliberately RETAINED in `CLAUDE.md`; compressing it would
re-break F2. The safe, high-value candidate is the aeh-engineer-only Harness Maintenance
Discipline section (already fully mirrored in the `aeh-engineer` persona) + the
cross-container / propagation bullets within it.

**Reframe -- "CLAUDE.md is a router, not a manual."** The discriminating test is NOT
length but: *does every session need this BEFORE it knows its role/task?* If yes it stays
inline (cutting it hurts reliability: isolation/fence, ASCII-only, no-AI-attribution, the
capture principle, session-init / role-selection). If no, it is extractable to its owning
revision-controlled home with a one-line resolvable pointer. The harness already uses the
pointer pattern unevenly (whole role-specific sections are still inlined -- e.g. the full
Harness Maintenance Discipline is `aeh-engineer`-only; the full role-location 3-part
signature; cross-container + propagation mechanics partly duplicated despite persona
pointers existing). Those are the first extraction candidates.

**Reliability is preserved by HOW you extract, not by avoiding extraction.** The hazard is
orphaning a rule somewhere nothing reads. The safe move is a triple --
**extract-to-home -> wire a RESOLVABLE pointer -> confirm the consumer role/playbook
actually loads it.** This is the same single-source-of-truth + resolvable-pointer +
consumer-loads-it invariant that the dangling-harness-path findings (the sibling
`dispatched-artifact-in-target-hygiene`) are the DUAL of: that proposal owns
pointer-that-does-not-resolve; this one owns content-that-should-be-a-pointer. One family,
checks in both directions.

**Absorbed: whole-block-diff retrofit scoping.** CLAUDE.md sections are interdependent
(session-init especially: banner flow, dispatch handling, role-location, role-loading).
Aligning one section while leaving siblings stale produces a CONTRADICTION, not just an
incompleteness -- worse than doing nothing. So: when an uplift/retrofit touches a CLAUDE.md
region (harness CLAUDE.md OR a target CLAUDE.md), scope the change to the whole affected
BLOCK diffed against the canonical template, applied in ONE pass -- not section-by-section
across prompts. This is the correct authoring AND aligning granularity for both layers and
binds the `target-orchestrator` / propagation-refresh retrofit path.

**Durable bits retained from the original:** the bullet-shape discipline
(`- **Topic.** One-sentence rule. Detail: <pointer>.`) and the harness-reviewer
pointer-resolution check (every `Detail:` pointer resolves). Both stay.

**Added scope (the absorbed captures' contributions) -- see Scope below for the full list:**
a router-vs-manual governance principle + the universal-pre-role-vs-role/task-specific
authoring test; a deterministic size-budget WARN check, symmetric (harness-side
harness-reviewer + target-side `bin/aeh-practice-check.sh`); a reviewer JUDGMENT dimension
("is each section universal-pre-role, or should it be a pointer?"); the extract-wire-confirm
habit; symmetric application to the target CLAUDE.md template; the whole-block-diff retrofit
rule.

---

> NOTE (2026-06-19): the "## What", original "## Scope" and original "## Acceptance
> criteria" below are the PRESERVED original. The "Consolidation resolution (2026-06-19)"
> section at the top is controlling where they differ (mechanism = in-place compression to
> existing homes, NOT a new `docs/harness-rules/` tree; `<30k` is a soft budget, not a hard
> gate). The current operative scope + acceptance are restated in "## Scope (2026-06-19
> consolidation -- controlling)" and "## Acceptance criteria (2026-06-19 -- controlling)".

## What

Slim `CLAUDE.md` from 42.5k chars / 434 lines to under 30k chars by extracting long-form rationale paragraphs from Harness Maintenance Discipline bullets and similar prose-heavy sections into dedicated reference files (proposed location: `docs/harness-rules/<topic>.md`). CLAUDE.md retains the rule as a one-liner + pointer; rationale, mechanism detail, and historical motivation move to the reference doc.

## Why

CLAUDE.md grew organically as the harness shipped capture-inbox, propagation-signal, cross-container-isolation, OpenSpec self-dogfooding, openspec-authoring-target-detail-free, and other substantial discipline updates. Each landed a multi-sentence rationale paragraph in the always-loaded Harness Maintenance Discipline list. The runtime now warns at 40k chars (CLAUDE.md is 42.5k as of 2026-06-01). Beyond the runtime warning, the per-session token cost compounds across every session and target.

The fix is NOT removing rules. CLAUDE.md must still answer "what rule applies here?" without the operator or agent following pointers for the rule itself. But the WHY / HOW / past-incident-context belongs in a reference doc that the agent reads only when needed (or that the operator reads as auditable rationale).

This proposal codifies the discipline: every CLAUDE.md bullet stays as `- **Topic.** One-sentence rule. Detail: <pointer>.` shape. New rules must conform.

## Scope

In scope:
- Inventory CLAUDE.md sections by size; identify extraction candidates (>200-char paragraphs in rule bullets).
- New `docs/harness-rules/` directory (path TBD at authoring; alternatives considered: `docs/harness-discipline/`, `docs/discipline/`).
- Reference doc per extracted topic. Candidate extractions:
  - Cross-container isolation (mechanism detail + per-host scheduler lock semantics + future-risk note).
  - Harness capture inbox (filesystem-mediated mechanism + atomic write pattern + triage flow).
  - Harness update propagation signal (mechanism + handshake + retrofit-action vocabulary).
  - OpenSpec self-dogfooding (project.md / AGENTS.md / archive convention).
  - OpenSpec authoring target-detail-free discipline (paraphrase-class leakage; harness-reviewer Dimension 1).
  - Publication Gate + review intermediary discipline.
  - gitignore != untrack reminder.
- Rewrite each CLAUDE.md bullet to one-liner + pointer.
- Harness-reviewer dimension: pointer-resolution check (every CLAUDE.md `Detail:` pointer resolves to an existing file).
- CHANGELOG entry under [Unreleased] Changed.

Out of scope:
- Rewriting CLAUDE.md from scratch (preserve structure; surgical slim only).
- Removing rules or changing rule semantics.
- Touching role / persona definitions (separate proposals: `harness-role-execution-context-discipline`, `orchestrator-manage-dont-do`).
- Compressing the Working Rules section (those are already terse; the bloat is in Harness Maintenance Discipline).

## Acceptance criteria

1. CLAUDE.md is < 30k chars (target; firm cap 35k; warning if > 40k re-introduced).
2. `docs/harness-rules/` (or chosen path) holds reference docs per extracted topic.
3. Every extracted bullet in CLAUDE.md follows `- **Topic.** One-sentence rule. Detail: <pointer>.` shape.
4. No rule semantics changed; harness-reviewer can audit by comparing pre/post bullets for rule-content match (the rule sentence in post should be present verbatim or in equivalent meaning in the pre version).
5. Pointer-resolution check landed in harness-reviewer.
6. CHANGELOG entry.

## Scope (2026-06-19 consolidation -- controlling)

In scope:
- **Govern (prevent):** add a "CLAUDE.md is a router, not a manual" governance principle +
  a soft size budget; encode the universal-pre-role-vs-role/task-specific authoring test
  (analog of the existing ground-truth-scan-before-new-doc rule) so every authoring role
  applies it. Applies to BOTH the harness CLAUDE.md and the target CLAUDE.md template.
- **Compress in place (fix):** extract role/task-specific inlined content to its EXISTING
  owning home (persona / playbook / openspec spec / docs reference) via
  extract-to-home -> wire-a-resolvable-pointer -> confirm-the-consumer-loads-it. NO new
  `docs/harness-rules/` tree. First candidate (built): the aeh-engineer-only Harness
  Maintenance Discipline section (already fully mirrored in the `aeh-engineer` persona),
  compressed in place to one-sentence-rule + pointer bullet shape, including the
  cross-container + propagation bullets. The role-location 3-part signature is NOT a
  candidate -- F2 deliberately keeps it in CLAUDE.md (see the candidate-correction note
  above).
- **Retain durable bits:** the `- **Topic.** One-sentence rule. Detail: <pointer>.`
  bullet-shape discipline for future rules; the harness-reviewer pointer-resolution check.
- **Detect:** (1) a deterministic CLAUDE.md size/line-budget WARN check -- harness-side in
  the harness-reviewer flow AND target-side in `bin/aeh-practice-check.sh` (run by
  target-aeh-reviewer); (2) a reviewer JUDGMENT dimension "CLAUDE.md router discipline: is
  each section universal-pre-role, or should it be a pointer?" (size alone is crude; the
  real signal is inlined role/task-specific content). Symmetric: harness CLAUDE.md ->
  harness-reviewer detect / aeh-engineer fix; target CLAUDE.md -> target-aeh-reviewer
  detect / target-aeh-engineer fix.
- **Whole-block-diff retrofit scoping:** when an uplift/retrofit touches a CLAUDE.md
  region, scope it to the whole affected BLOCK diffed against the canonical template,
  applied in ONE pass (binds the target-orchestrator / propagation-refresh path).
- CHANGELOG entry.

Out of scope:
- A new parallel docs tree (explicitly dropped).
- Removing rules or changing rule semantics (compression preserves the rule sentence).
- The pointer-that-does-not-resolve direction of the invariant (sibling
  `dispatched-artifact-in-target-hygiene`).
- A hard size GATE that blocks on length alone (budget is a WARN; the judgment dimension
  is the real control).

## Acceptance criteria (2026-06-19 -- controlling)

1. The "router not manual" principle + the universal-pre-role authoring test are present in
   the harness governance surface and applied to the target CLAUDE.md template.
2. The named first-candidate sections are compressed in place to a one-line rule + a
   RESOLVABLE pointer to an existing home; the consumer that needs each is confirmed to
   load it. No new `docs/harness-rules/` tree is created.
3. The bullet-shape discipline and the harness-reviewer pointer-resolution check are in
   place.
4. A deterministic CLAUDE.md size-budget WARN check exists harness-side AND target-side; a
   reviewer router-discipline JUDGMENT dimension exists, symmetric across both layers.
5. The whole-block-diff retrofit-scoping rule binds the CLAUDE.md alignment/refresh path.
6. No rule semantics changed (pre/post rule-sentence match auditable); CHANGELOG entry;
   validator + publication gate pass; harness-reviewer bookend.

## References

- Intake: this proposal is harness-self-surfaced (no inbox capture); the runtime warning + operator instruction 2026-06-01 are the trigger.
- Related: `openspec/changes/harness-role-execution-context-discipline/` (adds Execution context column to CLAUDE.md roles list -- coordinate edits).
- Related: future harness-reviewer enhancement to enforce the `Detail: <pointer>` shape.
