# Tasks: Relocate the harness capture inbox to private (tracked)

Executed in the 2026-06-17 session. Cross-repo migration + live-surface rewire. No formal spec deltas.

## 1. Move inbox + backlog to the private repo  [done]
- `mv openspec/changes/_intake targets/_harness-private/intake`; `mv BACKLOG.md targets/_harness-private/BACKLOG.md`.
- Stage ONLY `_harness-private/` in the private `targets` repo (the repo had 524 pre-existing dirty files -- untouched); commit.
- **Signal:** private repo has `_harness-private/intake/` + `BACKLOG.md` committed; public working tree has no `openspec/changes/_intake/`.

## 2. Remove inbox from public HEAD  [done]
- `git add -A openspec/changes/_intake` stages the 34 tracked deletions (24 untracked floaters simply leave the working tree).
- **Signal:** `git ls-files openspec/changes/_intake` returns nothing after commit.

## 3. Rewire the live instruction surface (approach A)  [done]
- `templates/personas/orchestrator.md`: single private landing; atomic-write path; triage + session-init scan paths; promotion provenance-sanitization gate; reject path.
- `CLAUDE.md`: capture-inbox rule (private), authoring-discipline scratchpad list, structure tree (`_intake` removed from public tree, `_harness-private/` added under `targets/`), authoritative relocation note.
- `openspec/project.md`: authoring-discipline scratchpad references.
- `.gitignore`: guard `openspec/changes/_intake/` against recreation in public.
- **Signal:** no stale `openspec/changes/_intake/` PATH ref in the live surface except the deliberate guard + relocation note.

## 4. Authoritative relocation note  [done]
- One note (CLAUDE.md) reinterprets every historical `_intake/` citation as the relocated private inbox; archived proposals + CHANGELOG history left intact.
- **Signal:** note present; no archived/historical records rewritten.

## 5. CHANGELOG + publication gate + commit  [done]
- CHANGELOG [Unreleased] entry; `bin/validate-personas.sh --staged` + `--message` clean; commit public repo (local only, no push).
- **Signal:** validator exits 0; both repos committed; nothing pushed.
