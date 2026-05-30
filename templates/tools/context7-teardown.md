# Context7 Teardown -- Prompt Template

> Adapt this template when generating a removal prompt for a target project.
> Teardown depends on which mode was installed (CLI + Skills or MCP). Check
> `profile.md` and the target's CLAUDE.md to determine which applies.

---

## What Gets Removed

**CLI + Skills mode (preferred install):**
- The docs skill from the agent's user-level skills directory (`~/.claude/skills/`)
- The always-on Context7 rule from the agent's user-level rule file (`~/.claude/CLAUDE.md`)
- The Context7 subsection from the target's CLAUDE.md

**MCP mode (fallback install):**
- Context7 entry from `.mcp.json`
- Context7 subsection from CLAUDE.md
- (Optionally) `CONTEXT7_API_KEY` from `.env` if no other tool uses it

## Residual State

CLI + Skills mode is user-global: removing it affects every project on the machine, not just this target. Confirm with the operator before tearing down a user-global install. MCP mode has no local state beyond the configuration entry and the `.env` key.

---

## Teardown Steps -- CLI + Skills mode

The generated prompt should instruct the target-side agent to:

### 1. Remove the docs skill and rule

```bash
npx ctx7@latest skills list --claude     # identify the installed docs skill name
npx ctx7@latest skills remove <skill> --claude
```

If the CLI offers no clean removal for the always-on rule, instruct the agent to manually delete the Context7 rule block from `~/.claude/CLAUDE.md`.

### 2. Remove the Context7 subsection from the target's CLAUDE.md

Remove the `### Context7` subsection from `## Development Tools`. If the section has no remaining subsections, remove the section.

---

## Teardown Steps -- MCP mode

The generated prompt should instruct the target-side agent to:

### 1. Remove Context7 from `.mcp.json`

Remove the `context7` entry from the `mcpServers` object. If `.mcp.json` becomes empty (`"mcpServers": {}`), delete the file.

### 2. Remove Context7 subsection from CLAUDE.md

Remove the `### Context7` subsection from `## Development Tools`. If the section has no remaining subsections, remove it.

### 3. (Optional) Remove `CONTEXT7_API_KEY` from `.env`

Only if no other tool uses the key. Leave `.env.example` documentation in place unless the operator wants it gone.

---

## Verification

**CLI + Skills mode:**
- [ ] `ctx7 skills list --claude` no longer lists the docs skill
- [ ] The Context7 rule block is gone from `~/.claude/CLAUDE.md`
- [ ] Target CLAUDE.md no longer mentions Context7 in Development Tools

**MCP mode:**
- [ ] `.mcp.json` no longer references `context7` (or file is deleted)
- [ ] CLAUDE.md no longer mentions Context7 in Development Tools
