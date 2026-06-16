# Tasks: Claude-code cost observability

Ordered. Adds a `claude-code` agent-knowledge doc + an optional convention -- no formal spec deltas. Each task carries a mechanical signal.

## 1. Ground-truth scan (document placement)

- Confirm `templates/agents/claude-code/` is the right home and `templates/agents/README.md` is the index to wire into (it is, by the `permissions.md` precedent). RESPECT the existing convention.
- **Signal:** `ls templates/agents/claude-code/` lists existing runtime docs; placement decision recorded in the commit body.

## 2. cost-observability.md

- Write `templates/agents/claude-code/cost-observability.md`: transcript JSONL location; usage fields (`input`/`output`/`cache-read`/`cache-write`); built-in `/cost`; `ccusage` (reference, MIT, npx); model price model; Docker `~/.claude` invisibility caveat; explicit do-not-reimplement / do-not-vendor stance.
- **Signal:** file exists; `grep -ci 'ccusage\|do not reimplement\|cache-read' templates/agents/claude-code/cost-observability.md` >= 1.

## 3. Optional scorecard field

- Add an OPTIONAL cost field to the orchestrator Outcome Scorecard (`orchestrator-state.md` convention in the persona), clearly marked optional, agnostic capture, reading guidance pointing at the claude-code doc.
- **Signal:** `grep -ci 'cost' templates/personas/orchestrator.md` reflects an optional-scorecard mention.

## 4. Agnostic efficiency-practice note

- Fold a short agnostic note (screenshot re-tokenisation until `/clear`; long-context cache-read; ingest-then-`/clear`, prefer text dumps, batch screenshots) into the relevant playbook(s)/persona(s).
- **Signal:** `grep -rci 're-tokenis\|ingest-then\|batch screenshots\|cache-read' templates/playbooks/ templates/personas/` >= 1.

## 5. Wire into the agent-knowledge index

- Add the new doc to `templates/agents/README.md` so it is discoverable.
- **Signal:** `grep -ci 'cost-observability' templates/agents/README.md` >= 1.

## 6. CHANGELOG entry

- Add to `CHANGELOG.md` [Unreleased] Added.
- **Signal:** `grep -ci 'cost' CHANGELOG.md` reflects the new entry.

## 7. Bookend + publication gate + commit

- Run `bin/validate-personas.sh` (full + `--staged` + `--message`). Block on FAIL.
- Harness-reviewer bookend before any push. Single commit; local only; operator authorizes push.
- **Signal:** validator exits 0; `git log --oneline -1` references the slug.
