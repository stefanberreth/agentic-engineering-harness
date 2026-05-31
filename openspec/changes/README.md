# AEH Active Change Proposals

Active OpenSpec change proposals for the Agentic Engineering Harness live here, one directory per proposal.

## Proposal lifecycle

1. **Propose** -- create `openspec/changes/<slug>/proposal.md` describing what, why, scope, and out-of-scope. Status `proposed`.
2. **Design** (when non-trivial) -- add `design.md` covering mechanism, alternatives considered, trade-offs, migration. Status moves to `accepted` after maintainer review.
3. **Implement** -- add `tasks.md` with ordered tasks and mechanical completion signals. Status `in-progress`.
4. **Review** -- harness-reviewer bookend before push (Dimension 1 covers `openspec/**` target-detail leakage; other dimensions apply as relevant).
5. **Archive** -- when implementation is complete and merged, move to `openspec/changes/archive/<slug>/` and apply any spec deltas to `openspec/specs/`. Status `archived`.

## Slug convention

`<area>-<short-descriptor>` -- e.g. `harness-cross-container-isolation`, `validator-message-mode`, `playbook-onboarding-greenfield-shortcircuit`. Slugs are lowercase, hyphen-separated, stable for the proposal's life (renaming requires explicit decision noted in the proposal).

## File conventions

- `proposal.md` -- mandatory. What + why + scope + out-of-scope + acceptance criteria.
- `design.md` -- recommended for non-trivial proposals. Mechanism, alternatives, trade-offs, migration plan.
- `tasks.md` -- mandatory before implementation starts. Ordered tasks, each with a mechanical completion signal (no UI-subjective gates).
- `specs/` -- mandatory if the proposal introduces or modifies a capability. Holds the spec delta that lands in `openspec/specs/` on archive.

All files in this tree are public; see `openspec/project.md` § "Authoring discipline" for the target-detail-free rule.
