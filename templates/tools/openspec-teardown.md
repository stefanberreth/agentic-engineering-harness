# OpenSpec Teardown -- Prompt Template

> Adapt this template when generating a removal prompt for a target project.

---

## What Gets Removed

- OpenSpec entry from `.mcp.json`
- OpenSpec skills from `.claude/skills/`
- OpenSpec subsection from CLAUDE.md

## What Gets Preserved

- `openspec/specs/` -- specification documents (user data, not config)
- `openspec/changes/` -- change proposals (user data, not config)

The user may choose to delete these manually, but the teardown prompt should not remove them by default.

---

## Teardown Steps

The generated prompt should instruct the target-side Claude to:

### 1. Remove OpenSpec from `.mcp.json`

Remove the `openspec` entry from the `mcpServers` object. If `.mcp.json` becomes empty (`"mcpServers": {}`), delete the file.

### 2. Remove OpenSpec skills

Delete any files matching `.claude/skills/openspec-*`.

### 3. Remove OpenSpec subsection from CLAUDE.md

Remove the `### OpenSpec` subsection from the `## Development Tools` section. If the Development Tools section has no remaining subsections, remove the section.

---

## Verification

After teardown, verify:
- [ ] `.mcp.json` no longer references `openspec` (or file is deleted)
- [ ] No files matching `.claude/skills/openspec-*` exist
- [ ] CLAUDE.md no longer mentions OpenSpec in Development Tools
- [ ] `openspec/specs/` and `openspec/changes/` are still present (preserved)
