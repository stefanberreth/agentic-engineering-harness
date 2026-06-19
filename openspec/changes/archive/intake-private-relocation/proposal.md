---
slug: intake-private-relocation
status: archived
archived-at: 2026-06-19T18:47:51Z
accepted-at: 2026-06-17
accepted-by: operator (approved in full; migration executed same session)
since: 2026-06-17
amends: harness-capture-inbox
---

# Relocate the harness capture inbox from public to private (tracked)

## What

Move the harness capture inbox out of the public harness repo and into the private `targets` repo:

- The inbox relocates from public `openspec/changes/_intake/` to private `targets/_harness-private/intake/` (tracked in the `targets` repo, whose remote is private; never published).
- `BACKLOG.md` (was untracked at the public root) moves to `targets/_harness-private/BACKLOG.md` -- now TRACKED in the private repo, as a looser maintainer scratchpad.
- The former two-landing-points design (public `_intake` for target-detail-free captures vs untracked private `BACKLOG.md`) is retired and collapsed into ONE private landing. Because the inbox is private, target context is permitted in a capture and there is no public-vs-private decision at capture time.
- The public/private boundary is enforced at PROMOTION: a capture becomes a PUBLIC `openspec/changes/<slug>/` proposal authored target-detail-free, with a provenance-sanitization gate (never copy a target-laden private capture verbatim into a public proposal; record a sanitized note or a pointer to the private capture filename).
- Public history is left as-is (no `git filter-repo` rewrite): the ~14 intake files already on the public remote are clean (0 blocklist hits), and rewriting a published repo's history is disruptive for downstream consumers. Intake simply stops appearing in the public HEAD going forward (`git rm` + commit -- a fresh clone's working tree no longer contains it; history retains it).

## Why

Two principles converged:

1. **Nothing load-bearing should be untracked.** The inbox had 57 files of which 24 were *floating* (untracked, not even gitignored) -- load-bearing capture content tracked by nothing, lost on a volume wipe, and a `git add -A` hazard. `BACKLOG.md` was untracked by both repos. The operator's rule: everything load-bearing is tracked and revision-controlled.
2. **Intake should not be public.** Intake routinely carries (or risks carrying) target context; the "target-detail-free public `_intake`" discipline proved fragile (target-named floaters had accumulated). Rather than police every capture for public-safety at write time, make the whole inbox private+tracked and enforce the public boundary once, at promotion. A private remote already exists (the `targets` repo), so this is pragmatic and immediate.

## Scope

In scope (executed this session):

- Move `openspec/changes/_intake/` (all files incl. README + a stray target-named subdir) and `BACKLOG.md` into `targets/_harness-private/`; commit in the private repo.
- `git rm` the inbox from the public repo HEAD.
- Rewire the live instruction surface (approach A): `CLAUDE.md` (capture-inbox rule + authoring-discipline + structure tree), `templates/personas/orchestrator.md` (Harness Capture section: single private landing, atomic-write path, triage paths, promotion provenance-sanitization gate, session-init scan path), `openspec/project.md` (authoring discipline), `.gitignore` (guard the old public path), CHANGELOG.
- One authoritative relocation note (in CLAUDE.md) so every `openspec/changes/_intake/` path cited in existing/archived proposals or CHANGELOG history resolves to the relocated private inbox -- WITHOUT rewriting ~30 historical/archived records (that would falsify history for no gain).

Out of scope:

- History rewrite (declined -- see What).
- Editing archived proposals / CHANGELOG history line-by-line (covered by the single authoritative relocation note instead).
- A dedicated maintainer-facing private repo for intake (the likely long-term home if the audience grows beyond a handful of consumers; deferred deliberately -- the `targets`-repo home is pragmatic, revertible, and has full history/tracking, so a future move elsewhere is cheap).
- The orchestrator -> aeh-engineer ownership split (the capture/triage logic currently lives in `orchestrator.md`; it moves to `aeh-engineer` under `aeh-engineer-role` build change B1 -- this proposal only relocates the PATHS, which B1 then carries over already-correct).

## Acceptance criteria

1. The inbox + `BACKLOG.md` live tracked under `targets/_harness-private/`; the private repo has them committed.
2. The public repo HEAD no longer contains `openspec/changes/_intake/`; `.gitignore` guards the old path against recreation.
3. No stale `openspec/changes/_intake/` PATH reference remains in the live instruction surface (the only surviving mentions are the deliberate guard + relocation note).
4. The capture flow is single-landing + private, with the promotion-time provenance-sanitization gate documented in `orchestrator.md` and `CLAUDE.md`.
5. The authoritative relocation note covers historical references without rewriting archived records.
6. CHANGELOG [Unreleased] entry present.

## References

- Amends: `harness-capture-inbox` (the original public-inbox mechanism).
- Owner of the inbox going forward: `aeh-engineer` (per `aeh-engineer-role`); capture stays universal (any session writes).
- Operator decision thread: 2026-06-16/17 (private+tracked; leave public history; pragmatic `targets`-repo home; long-term dedicated-repo deferred).
