# Archived OpenSpec Change Proposals (AEH harness self)

Completed (and abandoned) OpenSpec change proposals live here, one directory per proposal.

Archived proposals are permanent historical records. They document why the harness behaves the way it does -- the proposal-authoring decisions that shaped current templates, personas, playbooks, governance, scripts, and process rules.

## Layout

```
openspec/changes/archive/
├── README.md                            # this file
├── <archived-slug>/                     # one directory per archived proposal
│   ├── proposal.md                      # frontmatter status: archived
│   ├── design.md                        # if the original proposal had one
│   ├── tasks.md                         # implementation task list (typically marked complete)
│   ├── specs/                           # spec deltas applied during close-out (if any)
│   └── provenance.md                    # if the original proposal had one
└── ...
```

## Why archived proposals are preserved

- **Spec traceability.** Each spec under `openspec/specs/` carries `since:` and `last-updated-by:` pointing to change-slugs; without the archive, those references would dangle.
- **Decision history.** The archive records why a mechanism was added, what alternatives were considered, what trade-offs were accepted.
- **Pattern reuse.** Future proposals frequently reference archived proposals as precedent or counter-example.

## Archive vs delete

Abandoned proposals (work started but won't complete) are archived with `status: abandoned`, not deleted. The historical record is valuable even when work didn't ship.

## Close-out flow

See `openspec/AGENTS.md` for the mechanical close-out sequence that moves a completed proposal here.
