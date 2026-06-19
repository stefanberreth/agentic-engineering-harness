# B5 tasks

Mechanical completion signal in brackets per task.

1. [x] `git mv` orchestrator.md -> target-orchestrator.md; update title; update
   `HARNESS_ROLES`.
   [signal: `test -f templates/personas/target-orchestrator.md`; `grep -q target-orchestrator.md bin/validate-personas.sh`]
2. [x] Rename the role token + capitalized role-name prose across the live surface
   (CLAUDE.md, README.md, openspec/project.md, personas, playbooks, governance,
   project template, permission-baselines, prompt templates, hooks, bin).
   [signal: residual scan returns only target-orchestrator + kept artifact filenames]
3. [x] Rename role compounds in prose (-authored/-session/-generated/-side/
   -persona/-managed); keep orchestrator-state / orchestrator-batch-regime
   filenames.
   [signal: no bare `orchestrator-(authored|session|generated|side|persona|managed)`]
4. [x] Marker-value back-compat note in CLAUDE.md.
   [signal: `grep -q 'Marker-value back-compat' CLAUDE.md`]
5. [x] Fold: relabel the four retrofit templates freestyle; Step 0 = no marker
   write; align refresh set to five engineering personas.
   [signal: `grep -c 'orchestrator (target-side)' templates/prompts/*.template` == 0]
6. [x] CHANGELOG [Unreleased] entry.
   [signal: `grep -q 'target-orchestrator' CHANGELOG.md` (B5 entry)]
7. [x] Validator passes; publication gate (`--staged` + `--message`); commit; no push.
   [signal: validator exit 0; both gate invocations exit 0; commit landed locally]
