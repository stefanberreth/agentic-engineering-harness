# AEH Canonical Specs

This directory holds canonical capability specs for the Agentic Engineering Harness.

**Intentionally empty at OpenSpec adoption time.** The corpus grows organically as change proposals under `openspec/changes/` archive: each archived proposal that introduces or modifies a capability writes its spec delta into this tree.

There is no planned retrofit of existing harness capability into specs. Older capability (everything that predates OpenSpec adoption) is documented in `templates/`, `bin/`, `CLAUDE.md`, `README.md`, and the harness-reviewer persona's dimensions. Those documents remain authoritative for pre-adoption capability; specs become authoritative going forward as the corpus grows.

If a future need arises to backfill specs for pre-adoption capability (for example, to make a particular capability formally version-able under OpenSpec), that backfill is itself an OpenSpec change proposal.

## Spec file conventions

- Each spec lives in a subdirectory: `openspec/specs/<capability-slug>/spec.md`.
- Frontmatter carries `status` (`draft` | `current` | `superseded` | `archived`), `since` (proposal slug that introduced it), `last-updated-by` (proposal slug that last modified it).
- Specs describe capability that EXISTS in the harness, not future intent. Forward-looking language belongs in active change proposals, not in canonical specs.
- Specs are target-detail-free (see `openspec/project.md` § "Authoring discipline").

## Cross-references

- Active proposals: `openspec/changes/`
- Archived proposals: `openspec/changes/archive/` (created on first archive)
- Project conventions: `openspec/project.md`
