---
slug: harness-capture-inbox
status: archived
archived-at: 2026-06-19T19:18:24Z
since: 2026-05-31
amended-by: intake-private-relocation (2026-06-17)
---

> AMENDED 2026-06-17 by `intake-private-relocation`: the inbox relocated from public
> `openspec/changes/_intake/` to the PRIVATE `targets/_harness-private/intake/` (tracked,
> never published), and the two-landing-points (public `_intake` vs untracked `BACKLOG.md`)
> collapsed into one private landing. The mechanism below is otherwise intact; read paths
> here as the relocated private inbox. The public/private boundary is now enforced at
> promotion, not at capture.

# Harness Capture Inbox

## What

A filesystem-mediated intake mechanism that lets any orchestrator session — including ones running in separate Docker containers for different target projects — capture harness-level insights as small structured files in a known directory, where a future harness orchestrator session detects them on the shared bind-mount and triages them into proper OpenSpec change proposals. No operator paste-shuttle between sessions.

## Why

The harness is operated from parallel Claude Code sessions in separate containers, all bind-mounting the same host harness directory. During target work, the conversation regularly produces insights that belong at the harness level (refinements to persona templates, gaps in playbooks, new patterns worth generalising). Today these insights have no robust capture path:

- Telling the operator to copy text from one session and paste into another is friction-heavy and forgettable.
- Asking the operator to remember which file to write to in which directory pushes harness-discipline cognition onto the operator.
- BACKLOG.md (the maintainer's private triage scratchpad) works for the maintainer's own captures from harness sessions but is invisible to and write-disabled from target sessions per the isolation rule.

The shared bind-mount is the natural channel. An orchestrator in any container that has the harness mounted can write a capture file to a known location; any harness orchestrator session sees the file instantly. Captures flow into the OpenSpec review pipeline through deliberate maintainer triage, not through operator shuttling.

This also keeps the discipline coherent with external contribution: when external pull requests eventually arrive through GitLab (or a future GitHub mirror), they enter through the platform's native PR/Issue mechanism. The maintainer triages by drafting an OpenSpec change proposal. Same destination as inbox captures, different entry point. No second intake discipline to maintain.

## Scope

In scope:
- New directory `openspec/changes/_intake/` (underscore prefix sorts visually distinct from real change slugs) with a README describing the pattern.
- Capture file format: filename `YYYY-MM-DD-HHMM-<short-tag>-<HOSTNAME>.md` (hostname suffix prevents cross-container collision); YAML frontmatter (`captured-at`, `captured-from`, `captured-during`, `area`, `status: untriaged | promoted | deferred | rejected`); body with five standard fields (Area, Trigger, Insight, Suggested change, Memory updates).
- Two landing points (deliberate, complementary):
  - **`openspec/changes/_intake/`** (tracked, public): hygiene-disciplined captures fit for public review. Target-detail-free per the existing OpenSpec authoring discipline.
  - **`BACKLOG.md`** (untracked, private): captures that need target context to motivate, or that the maintainer wants to triage further before public exposure. Existing behaviour, unchanged; the inbox is additive.
- Orchestrator persona update teaching two behaviours:
  - **Capture-side** (any orchestrator session, including target sessions where the orchestrator role is active): the orchestrator proactively identifies harness-level insights emerging in conversation and prompts the operator to capture, but **always asks before writing — never captures silently**. On operator confirmation (or on explicit operator instruction like "capture this for the harness"), write a capture file to `openspec/changes/_intake/` via atomic write-then-rename. The asymmetry is deliberate: proactive identification reduces operator cognitive load (the orchestrator notices the candidate); the confirmation gate prevents inbox noise and ensures the operator retains editorial control over what enters the public review pipeline.
  - **Triage-side** (harness orchestrator session): on session-init, scan `openspec/changes/_intake/` for files with `status: untriaged`; surface the count in the post-banner summary; on operator request, walk each capture and either promote it to a proper `openspec/changes/<slug>/` proposal, defer it (status update only), or reject it (delete or move to an archive subdir).
- Atomic write-then-rename convention so a reader session never sees a half-written file.
- CLAUDE.md registration of the pattern under "Harness Maintenance Discipline".
- CHANGELOG entry under [Unreleased] Added.

Out of scope:
- Capture from external contributors. External entry stays through GitLab/GitHub PRs and Issues; the maintainer triages externally-sourced ideas into the inbox or directly into proposals during their normal review flow. No PR-template capture-file ingest; standard PRs go through standard review.
- GitHub mirroring / publishing decision. Currently GitLab-hosted; cross-platform publishing is a separate future concern.
- Automatic promotion (capture -> proposal without operator review). Triage is deliberately operator-mediated; the inbox is a queue, not a pipeline.
- Cross-container session attribution beyond hostname suffix (no session UUIDs in filenames). Filename collision is the only problem solved here; full attribution lives in frontmatter.

## Acceptance criteria

1. **Directory exists**: `openspec/changes/_intake/` is created with a README that documents the file format, the triage flow, and the relationship to BACKLOG.md.
2. **Format is documented and uniform**: any orchestrator session writing a capture produces a file with the same frontmatter shape and the same five-field body structure, regardless of which container it ran in.
3. **Atomic write semantics**: orchestrator-persona instructions specify write-to-temp-then-rename so cross-container readers never observe a half-written capture file.
4. **Filename collision is prevented**: hostname suffix in filename means two captures at the same minute on the same topic from different containers cannot overwrite each other.
5. **Triage flow is documented and operator-driven**: the harness orchestrator persona's session-init step scans for untriaged captures and surfaces the count; on operator request, triages each into promote / defer / reject with clear outcomes for each path.
6. **Two landing points are distinguished**: orchestrator persona instructions name when to write to `openspec/changes/_intake/` (target-detail-free, fit for public review) versus when to write to `BACKLOG.md` (carries target context, maintainer-private). Decision is at capture time.
7. **Inaugural use lands**: the 4-state response-end-state vocabulary capture (received in this session via operator paste) is dropped into the new inbox as the first capture file, then triaged into its own OpenSpec change proposal as a worked example demonstrating the mechanism end-to-end.

## References

- Existing publication-gate infrastructure: `bin/validate-personas.sh --staged` + `--message`. Catches target-detail leakage in `openspec/changes/_intake/` files automatically (same scanning surface as the rest of `openspec/**`).
- Existing per-hostname pattern: `bin/resolve-persona-marker.sh` (template for filename-collision avoidance under shared bind-mounts).
- Sibling proposal: `openspec/changes/harness-cross-container-isolation/` (the broader shared-mount contamination work; this proposal addresses one positive use of the shared mount — capture transport — while the sibling addresses contamination avoidance).
- Relevant memory: `feedback_orchestrator_response_end_state.md` (current 3-state vocabulary that the inaugural capture supersedes).
