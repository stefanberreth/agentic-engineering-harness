# F2 tasks

Mechanical completion signal in brackets per task.

1. [x] Thin §0 in the five engineering base personas to a one-line pointer.
   [signal: no "signature: `targets/index.md`" enumeration in templates/personas/{analyst,archaeologist,architect,developer,reviewer}.md]
2. [x] Thin the R2 location self-check in target-aeh-reviewer + target-aeh-engineer.
   [signal: those two files contain "Role-location self-check" pointer, not the enumeration]
3. [x] Thin the Step-0 check in harness-reviewer + target-orchestrator + aeh-engineer.
   [signal: those three contain a pointer to `CLAUDE.md` § "Role-location self-check", not the enumeration]
4. [x] Update the CLAUDE.md sync note to describe the two-places-plus-pointers shape.
   [signal: `grep -q 'exactly TWO places' CLAUDE.md`]
5. [x] Signature enumeration appears in exactly two files.
   [signal: `grep -rl 'declaring the AEH' CLAUDE.md templates/` returns only CLAUDE.md + templates/project/CLAUDE.md.template]
6. [x] CHANGELOG entry; validator + publication gate; commit; no push.
   [signal: validator exit 0; gate exit 0; commit landed]
