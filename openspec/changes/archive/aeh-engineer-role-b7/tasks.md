# B7 tasks

Mechanical completion signal in brackets per task.

1. [x] CLAUDE.md: add canonical "Role-location self-check" signature subsection +
   session-init Step 0.
   [signal: `grep -q 'Role-location self-check' CLAUDE.md`; session-init has a "0." step]
2. [x] CLAUDE.md.template: add the target-layer "Role-location self-check"
   definition.
   [signal: `grep -q 'Role-location self-check' templates/project/CLAUDE.md.template`]
3. [x] Add `## §0. Role-location self-check` to all five engineering base
   personas.
   [signal: `grep -lc 'Role-location self-check' templates/personas/{analyst,archaeologist,architect,developer,reviewer}.md` == 5 files]
4. [x] Add the assert-IS-AEH-root Step 0 to `harness-reviewer` + `orchestrator`;
   align `aeh-engineer` + `target-aeh-*` to the canonical signature.
   [signal: each of harness-reviewer/orchestrator has a "0." location step; aeh-engineer item 5 cites the canonical signature]
5. [x] Mark `orchestrator-self-location-guard` superseded-by `aeh-engineer-role-b7`.
   [signal: `grep -q 'superseded' openspec/changes/orchestrator-self-location-guard/proposal.md`]
6. [x] CHANGELOG [Unreleased] entry.
   [signal: `grep -q 'role-location' CHANGELOG.md` (B7 entry)]
7. [x] Publication gate (`--staged` + `--message`); commit; no push.
   [signal: both gate invocations exit 0; commit landed locally]
