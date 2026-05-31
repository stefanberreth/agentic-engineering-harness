# OpenSpec Setup -- Prompt Template

> Adapt this template when generating a setup prompt for a target project.
> Replace all `[PLACEHOLDER]` values with project-specific details.

---

## What OpenSpec Does

Specification-driven development. OpenSpec manages specs and change proposals as structured markdown documents alongside your code.

- **Docs:** https://openspec.dev/

---

## OpenSpec for Claude Code = a directory convention

For Claude Code (and any CLI agent with direct filesystem access), OpenSpec is fundamentally two directories plus a CLAUDE.md section. The agent reads/writes markdown in `openspec/specs/` and `openspec/changes/` directly. There is no daemon, no server, no required toolchain. Setup is complete when the directories exist and CLAUDE.md tells the agent the convention.

**Do NOT introduce Node, npm, npx, or the OpenSpec CLI as part of AEH setup.** They are not required and surfacing them confuses operators who reasonably ask "do I need to install Node for this?" The answer is no.

The OpenSpec CLI (`npx openspec ...`) and the OpenSpec MCP server (`openspec-mcp`) exist for other use cases (sandboxed agents without filesystem access, CLI-based spec validation by humans). Neither is part of an AEH-driven Claude Code setup. If the operator later wants the CLI for their own reasons -- e.g. running `openspec validate` manually -- they can install Node then; that decision is independent of AEH onboarding.

---

## Setup Steps

The generated prompt should instruct the target-side Claude to:

### 1. Create OpenSpec directory structure

```
openspec/
├── AGENTS.md             # Close-out playbook (canonical mechanical close-out flow)
├── specs/                # Specification documents
└── changes/              # Change proposals
    └── archive/          # Archived (completed) change proposals; preserved as history
```

Add a `.gitkeep` to `specs/`, `changes/`, and `changes/archive/` so the directories are tracked before the first spec or proposal is written.

The `AGENTS.md` file carries the close-out playbook -- the canonical mechanical sequence for archiving a completed change proposal. Without this convention installed, the project would hit the "no close-out playbook" wall the first time a change proposal completes. Install at setup time so the proposal-closing side is wired in alongside the proposal-authoring side.

**AGENTS.md content (write this file verbatim):**

```markdown
# OpenSpec Close-Out Playbook (this project)

When a change proposal under `openspec/changes/<slug>/` completes its implementation and passes review, archive it via this mechanical sequence. The proposal stops being active when the sequence completes; the durable record is the spec deltas applied to parent specs + the archived proposal directory.

## Mechanical close-out sequence

1. **Apply spec deltas to parent specs.** For each spec file the proposal updated or created (typically files under `openspec/changes/<slug>/specs/`), apply the delta to the corresponding `openspec/specs/<capability>/spec.md`. Bump the parent spec's frontmatter `last-updated-by: <change-slug>` and `updated: <ISO date>` (or equivalent). If the proposal introduces a new spec, create `openspec/specs/<new-capability>/spec.md` directly with `since: <change-slug>`.

2. **Bump parent spec metadata.** For every spec touched by the deltas, ensure frontmatter carries `last-updated-by:` pointing to this change-slug and `updated:` set to today.

3. **Set proposal status: archived.** Edit the proposal's `proposal.md` frontmatter: change `status:` to `archived`, add `archived-at: <ISO timestamp>`.

4. **Move proposal directory to archive.** `mv openspec/changes/<slug>/ openspec/changes/archive/<slug>/`. The archive preserves the full proposal history (proposal.md, design.md, tasks.md, specs/, provenance.md if any) as a permanent record of why the parent specs look the way they do.

## Commit convention

Single commit per close-out, message format:

```
openspec(close): <change-slug> -- archived

- Apply spec deltas to <capabilities-touched>
- Bump parent spec updated dates
- Move proposal to openspec/changes/archive/<slug>/
```

## Spec-frontmatter discipline

Each spec under `openspec/specs/<capability>/spec.md` carries:
- `since:` -- the change-slug that introduced this spec.
- `last-updated-by:` -- the most recent change-slug that modified this spec.
- `updated:` -- ISO date of the last modification.

These let any future reader trace a spec back to the proposal(s) that shaped it.

## Edge cases

- **Proposal blocked at logical-close** (work complete but waiting on something external -- upstream library, operator action, sibling proposal): keep at `status: ready-for-archive`; do NOT archive. Close-out runs only when nothing blocks.
- **Proposal abandoned** (work started but won't complete): set `status: abandoned`, move to `openspec/changes/archive/<slug>/` with `archived-at:` and `abandonment-reason:` in the frontmatter. Spec deltas are NOT applied (proposal didn't complete).
- **Proposal supersedes an earlier one**: the earlier proposal's archive entry remains; the new proposal's `proposal.md` notes `supersedes: <earlier-slug>`. The earlier proposal's specs retain their `since:` but the `last-updated-by:` advances to the superseding proposal.
```

### 2. Add OpenSpec subsection to CLAUDE.md

Under the `## Development Tools` section (create the section if it doesn't exist), add:

```markdown
### OpenSpec

Specification-driven development. Specs live in `openspec/specs/`, change proposals in `openspec/changes/`.

Read spec files directly -- no MCP server, no CLI required. Create new specs by writing markdown files to the appropriate directory.

Docs: https://openspec.dev/
```

### 3. Add to `.gitignore` (if needed)

No `.gitignore` changes needed -- OpenSpec files are intended to be version-controlled.

---

## Appendix: MCP Server Setup (sandboxed environments only)

> This appendix is NOT part of the AEH-generated setup prompt. It exists only for the rare case where the target agent has no filesystem access (hosted playgrounds, certain web UIs). For Claude Code and other CLI agents, do not include any of this in the generated prompt.

Add the OpenSpec server entry to `.mcp.json`:

```json
{
  "mcpServers": {
    "openspec": {
      "command": "npx",
      "args": ["-y", "openspec-mcp"]
    }
  }
}
```

Add MCP tool references to the CLAUDE.md subsection:

```markdown
Key commands (available as MCP tools):
- `create_spec` -- create a new specification document
- `propose_change` -- propose a change to an existing spec
- `list_specs` -- list all specifications
```

---

## Role Integration

OpenSpec integrates with the four AEH personas. The generated prompt should explain these conventions so the target-side agent understands the workflow:

| Role | Reads | Writes |
|------|-------|--------|
| **Analyst** | Existing specs in `openspec/specs/` | New specs; change proposals (`openspec/changes/<slug>/proposal.md`) |
| **Architect** | Specs + change proposals | `design.md`, `tasks.md`, and spec deltas within change proposals |
| **Developer** | Specs for context; `tasks.md` for work items | Applies spec deltas to `openspec/specs/` after implementation |
| **Reviewer** | Specs + change proposals | Flags spec drift, verifies deltas were applied |

### Example spec frontmatter

```yaml
---
id: user-auth
title: User Authentication
status: active
created: 2026-02-27
updated: 2026-02-27
---
```

Valid `status` values: `draft`, `active`, `deprecated`.

### Example change proposal structure

```
openspec/changes/add-oauth-support/
├── proposal.md      # What is changing and why (analyst)
├── design.md        # Architecture and decisions (architect)
├── tasks.md         # Ordered implementation tasks (architect)
└── spec-deltas.md   # Changes to apply to parent spec (architect)
```

### Graceful Degradation

If OpenSpec is removed from a project (directories deleted), the AEH personas automatically fall back to `requirements.md` / `spec.md` conventions. No persona changes needed -- each persona checks for the presence of `openspec/specs/` and adapts. The Specification Management section in CLAUDE.md can be deleted when OpenSpec is removed.

---

## Verification

After setup, verify:
- [ ] `openspec/specs/` directory exists
- [ ] `openspec/changes/` directory exists
- [ ] CLAUDE.md has a Specification Management section (and/or OpenSpec subsection under Development Tools)
- [ ] (Sandboxed environments only) `.mcp.json` contains the `openspec` entry and server connects
