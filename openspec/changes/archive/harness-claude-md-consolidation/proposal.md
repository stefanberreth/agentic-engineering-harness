---
slug: harness-claude-md-consolidation
status: archived
since: 2026-06-21
archived-at: 2026-06-21
---

# Harness CLAUDE.md consolidation round (under the size budget)

## What

Run the consolidation round that `claude-md-size-discipline` parked. That change
shipped the PREVENT (the "CLAUDE.md is a router, not a manual" principle) and
DETECT (the `claude-md-size` WARN check) halves but explicitly deferred the FIX --
the actual file-wide compression -- to "a maintainer consolidation round." This is
that round, applied to the harness's own `CLAUDE.md`.

The harness `CLAUDE.md` grew from ~39.8k chars (2026-06-16) to ~53.9k (now) --
+14k, +35%, almost entirely the `aeh-engineer-role` role-architecture refactor
landing in Session Init and the taxonomy/isolation sections. It now trips Claude
Code's native 40k performance warning, taxing every session in every container.

Apply the router principle to itself: keep every RULE inline, demote reference,
duplication, and rationale-that-lives-elsewhere to one-line resolvable pointers.
No rule is dropped.

## Why

The always-loaded instruction file is read in full by every session before it
knows its role or task, so every kilobyte taxes every session and degrades the
very orchestrator windows now driving target upgrades. The router principle exists
precisely to bound this; the harness must practice what it preaches. The biggest
bloat is reference and duplication, not rules:

- The **Project Structure** section (7.6k) is a full annotated file tree that
  duplicates "What This Project Contains" and every file's own header, and had
  already drifted (stale annotations). No session needs the complete tree before
  it knows its role -- it is reference.
- **Working Rules** (9.7k) carry paragraph-length rationale and worked examples
  whose full form already lives in the owning persona/home.
- **Session Init** (15k) restates per-role descriptions the taxonomy + "role
  info" + the persona files already hold, and carries a ~1.4k harness-reviewer
  "do not re-flag" note that belongs as a pointer.

## Scope

In scope (harness `CLAUDE.md` only):
- Replace the full **Project Structure** file tree with a compact pointer to
  "What This Project Contains" + the per-target layout section + README; augment
  "What This Project Contains" to cover the few top-level dirs it omitted so it
  fully carries the orientation load.
- Compress the longest **Working Rules** bullets to rule + resolvable pointer
  (rationale/examples demoted to their homes); keep every rule sentence.
- Tighten **Session Init**: the settled-exception orchestrator-state-filename note
  -> one-line pointer; the per-role description paragraphs -> their one-line forms
  (the taxonomy + persona files are the home); trim duplicated taxonomy prose.
- CHANGELOG [Unreleased] entry.

Out of scope:
- `templates/project/CLAUDE.md.template` (the TARGET template) -- a separate file
  with its own budget; touching it now would churn the in-flight target upgrades
  that read it. Follow-on.
- The role-location self-check three-part signature -- F2 deliberately keeps the
  full signature inline in `CLAUDE.md`; NOT compressed here.
- Any rule removal. This is demote-rationale-to-pointer, not subtract-rules.

## Acceptance criteria

- Harness `CLAUDE.md` is under the 40k native warning; target the 30k soft budget
  as far as the F2-mandated inline signature allows (state the residual honestly
  if 30k is not reachable without revisiting F2).
- Every rule that was inline before is still discoverable: either inline, or as a
  one-line bullet with a RESOLVABLE pointer to its home (no orphaned pointers).
- No target-detail leakage; ASCII-only; publication gate PASS.
- harness-reviewer bookend confirms subtraction-completeness (no load-bearing rule
  silently lost) before close-out.
