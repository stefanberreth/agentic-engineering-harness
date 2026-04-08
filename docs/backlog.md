# AEH Harness Backlog

Items tracked here are improvements to the harness itself — not target project work.

## Documentation

### Document the human-AEH working patterns
**Status:** pending
**Raised:** 2026-03-24

Systematically capture the practical workflow that has emerged from real usage between the human operator and AEH entities. The patterns exist and work — they just aren't written up yet.

Key workflows to document:
- **Feature development loop:** orchestrator generates prompts → developer/reviewer execute in target → operator reviews
- **QA testing loop:** operator tests in QA → developer in testing mode captures triage → operator brings triage back to orchestrator for routing → fixes or specs generated
- **Rapid fix cycle:** operator points at problem → developer fixes → commit → test again (no prompt, no review)
- **Discovery routing:** developer/reviewer logs finding → orchestrator triages to analyst/architect/developer
- **Session handoff:** how state persists between sessions via committed files (orchestrator-state, tasks, journal)

Rules: document what actually happens. Don't invent new mechanisms — everything needed already exists in the current tool set (personas, orchestrator state, triage file, discovery log, open questions, decisions).

## Governance

### Add project layout hygiene to health check playbook
**Status:** pending
**Raised:** 2026-03-24

The health check playbook (`templates/playbooks/health-check.md`) should include a structural hygiene dimension that reviews the target project's filesystem layout. Not a new mechanism — an additional check in the existing periodic review.

What to check:
- Root directory clutter (config files that can be moved to `config/`, stray files)
- Build artifact directories present but not gitignored (`dist/`, `site/`, `coverage/`, `playwright-report/`, `test-results/`)
- Log accumulation (e.g. hundreds of timestamped log files in `logs/`)
- Gitignore completeness (are generated directories excluded?)
- Directory structure matches project conventions (no orphaned directories, no purpose-free nesting)

This is a slow-moving review dimension — run quarterly or after major structural changes, not every session.

## Templates & Prompt Authoring

### Track `settings.json` baseline on clone (currently lost)
**Status:** pending
**Raised:** 2026-04-05 (from target-side retrospective on a greenfield onboarding)

The CLAUDE.md template and permission baselines ship the project's Python ML (or other archetype) baseline as `.claude/settings.local.json`, which the same templates then tell projects to gitignore. Result: on a fresh clone the carefully-designed permission baseline vanishes. New contributors start with no deny rules, no `acceptEdits` mode, no allowlist — the baseline only ever exists in the first operator's working tree.

Fix direction: establish a convention where the **baseline** lives in a tracked `.claude/settings.json` (version-controlled, shared, represents the project's intended permission posture), and `.claude/settings.local.json` remains gitignored for genuine personal overrides (machine-specific tool paths, individual preferences). Update:
- `templates/project/CLAUDE.md.template` § Permission Governance (settings-files table + rules)
- `templates/agents/claude-code/permission-baselines.md` (examples show tracked vs. local split)
- The "initial commit" prompt template(s) to include `.claude/settings.json` in the first commit

Decision needed: does this change break compatibility with existing targets that have their baseline in `.local.json`? (Grandfathering is probably fine — each target migrates on next touch.)

### Ship symlink-compatible gitignore patterns for data mounts
**Status:** pending
**Raised:** 2026-04-05

When a target project has a symlinked data mount (a symlink at the project root pointing to an external drive), the directory-form gitignore pattern (`NAME/`) does not reliably match the symlink — git may still see it as a tracked path. Foundation prompts that instruct the target to write `.gitignore` should include both forms by default (`NAME/` AND `/NAME`) when a data-mount symlink is known to exist from reconnaissance. Currently, foundation prompt authoring has to reason about it per-target, triggering in-session retries.

Fix direction:
- Update the foundation/`.gitignore` prompt authoring convention (document in the onboarding playbook § 6a or in a new `templates/tools/data-mount-handling.md`) to always include both forms when a top-level symlink was detected in reconnaissance.
- Add a reconnaissance check for top-level symlinks pointing outside the project tree, and make it a standard profile.md field.

### Add "expected environmental drift" appendix to merge-and-confirm prompts
**Status:** pending
**Raised:** 2026-04-05

Merge-and-confirm prompts (which read a file, diff against expected, and ask the operator to confirm) trigger a STOP-and-explain round every time the live file has drifted from the harness's last-reconnoitred state. In practice, certain drifts are predictable and routine:
- Claude Code adds `Bash(...)` rules to `settings.local.json` when the operator approves a command in-session
- `.sandbox-mounts` or similar local metadata files appear between reconnaissance and execution
- CLI tool availability varies (e.g. `npx openspec init` is known-dead because the package has no binary of that name)

Each of these triggered a round-trip during a recent greenfield onboarding. Collapsing them to single-step confirmations would be faster and less noisy.

Fix direction: add an "Expected drift" section to merge-and-confirm prompt templates. The target-side agent subsumes known-safe drifts automatically and notes them in the completion report, rather than stopping. Only unknown/unexpected drift triggers stop-and-ask.

Template change: update `templates/prompts/regression-check.md.template` and the playbook § "Merge-and-confirm rule" with the new pattern.

## Future Capabilities

### Enterprise process integration — Figma + BA tickets as input
**Status:** roadmap
**Raised:** 2026-03-24

Design a workflow that takes UI/UX designer Figma screens and usage flows as input alongside BA (business analyst) tickets. This links AEH into enterprise processes where design and requirements come from external tools and roles.

The intake should feed into the existing analyst → architect → developer pipeline without new personas or mechanisms. Figma screens are reference input (like screenshots). BA tickets are requirements input (like the business requirements catalogue). The gap is the handoff format and the analyst's instructions for consuming them.
