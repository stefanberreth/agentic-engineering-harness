# B3 tasks

Mechanical completion signal in brackets per task.

1. [x] Create `templates/personas/target-aeh-reviewer.md` (DETECT, target-applied,
   with Propagation-Impact Assessment Mode + location self-check + routing).
   [signal: file exists; `grep -q 'Propagation-Impact Assessment Mode' templates/personas/target-aeh-reviewer.md`]
2. [x] Create `templates/personas/target-aeh-engineer.md` (REMEDIATE,
   target-applied, fenced, with the operational-skill currency-gate machinery +
   location self-check).
   [signal: file exists; `grep -q 'currency gate' templates/personas/target-aeh-engineer.md`]
3. [x] Fold the per-target operational-skill + two-tier currency gate convention
   across both roles; queue the Tier-1 hook template.
   [signal: `grep -q 'Tier 1' templates/personas/target-aeh-engineer.md` and `grep -q 'Tier 2' templates/personas/target-aeh-reviewer.md`]
4. [x] Add both files to `bin/validate-personas.sh` single-file exemption list.
   [signal: `grep -q 'target-aeh-reviewer.md' bin/validate-personas.sh`]
5. [x] Repoint the orchestrator "review changes" gate + seed template + CLAUDE.md
   propagation lines to dispatch `target-aeh-reviewer` (not harness-reviewer).
   [signal: no "harness-reviewer pass" in orchestrator.md / seed template / CLAUDE.md propagation lines]
6. [x] Update CLAUDE.md taxonomy (pair now exists), CLAUDE.md structure tree,
   README roles table.
   [signal: `grep -q 'target-aeh-reviewer' README.md CLAUDE.md`]
7. [x] CHANGELOG [Unreleased] entry.
   [signal: `grep -q 'target-aeh' CHANGELOG.md`]
8. [x] Validator passes; publication gate (`--staged` + `--message`); commit; no push.
   [signal: validator exit 0; both gate invocations exit 0; commit landed locally]
