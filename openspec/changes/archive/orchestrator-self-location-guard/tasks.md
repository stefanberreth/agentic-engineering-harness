# Tasks: Orchestrator session-init self-location guard

Ordered. Process/mechanism change -- no formal spec deltas. Each task carries a mechanical signal.

## 1. CLAUDE.md -- Step 0 self-location assertion

- Add a Step 0 to "On first message of every session", ahead of the persona-marker read / banner sequence: assert the cwd resolves (walking up) to an AEH root with the three-part signature (`targets/index.md` present AND `templates/personas/` present AND local `CLAUDE.md` declares the AEH mission). On failure, STOP and emit a loud operator-facing message naming the target-tree cause and the switch-and-reload fix.
- **Signal:** `grep -ci 'self-location\|harness root\|targets/index.md' CLAUDE.md` >= 1 within the session-init section AND the existing four numbered session-init steps remain present.

## 2. Orchestrator persona -- matching Step 0

- Add a session-init Step 0 ahead of the triage scan (around the "On session-init, after the standard banner" / triage-side behaviour area) that re-asserts the same self-location signature and cross-references the CLAUDE.md check (no divergent logic).
- **Signal:** `grep -ci 'self-location\|harness root' templates/personas/orchestrator.md` >= 1.

## 3. Consistency check

- The CLAUDE.md and persona statements describe one check; the persona points at CLAUDE.md rather than restating a different signature.
- **Signal:** manual read confirms one rule, two sites, no divergence.

## 4. CHANGELOG entry

- Add to `CHANGELOG.md` [Unreleased] Added.
- **Signal:** `grep -ci 'self-location' CHANGELOG.md` >= 1.

## 5. Bookend + publication gate + commit

- Run `bin/validate-personas.sh` (full + `--staged` + `--message`). Block on FAIL.
- Harness-reviewer bookend before any push. Single commit; local only; operator authorizes push.
- **Signal:** validator exits 0; `git log --oneline -1` references the slug.
