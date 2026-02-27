# Playbook: Tool Configuration

Configure optional development tools (OpenSpec, Context7, Serena) for a target project. Can be run at any time -- during onboarding or independently.

**Trigger:** `tools` or `tools <slug>`
**Produces:** Setup/teardown prompts in `targets/<slug>/prompts/` and updated `profile.md`.

---

## Tone Rules

Same as onboarding playbook: concise, no emoji, progress indicators, detail on demand.

**Framing rule:** OpenSpec is recommended by default for structured spec management. Context7 and Serena remain purely optional -- their absence is never a deficiency. If the user declines any tool, record it and move on -- no persuasion.

---

## Skip Gates

The user can say any of these at any time:

| Command | Effect |
|---------|--------|
| `skip <tool>` | Skip the named tool (e.g. `skip serena`) |
| `only <tool>` | Only offer the named tool, skip the rest |
| `remove <tool>` | Go directly to teardown for the named tool |
| `status` | Show current tool status table without offering changes |
| `stop` | End the playbook, save progress |

---

## Phase 1: Target Selection

```
[tools 1/5] Target Selection
```

**If slug provided with `tools <slug>`:** Validate it exists in `targets/index.md`, skip to Phase 2.

**If only one active target exists:** Use it automatically, confirm with user.

**If multiple targets exist:** List them with last-active dates, ask user to pick.

**If no targets exist:** Inform user and suggest `onboard`.

---

## Phase 2: Current State

```
[tools 2/5] Current state -- <project-name>
```

### 2a. Load Profile

Read `targets/<slug>/profile.md`. Check for an existing `## Development Tools` section.

### 2b. Run Detection

Run all detection patterns from `templates`tools`/tool-detection-patterns.md` against the target project:

1. **General MCP detection:** Read `.mcp.json`, `.claude/skills/`, `.claude/commands/`
2. **OpenSpec detection:** Direct patterns + functional equivalents
3. **Context7 detection:** Direct patterns + functional equivalents
4. **Serena detection:** Direct patterns + functional equivalents

### 2c. Present Status Table

```
[tools 2/5] Current state -- <project-name>

Tool         Status          Notes
───────────  ──────────────  ─────────────────────────────
OpenSpec     not found       ADR directory detected (docs/adr/)
Context7     configured      in .mcp.json, documented in CLAUDE.md
Serena       declined        declined on 2026-02-15
───────────  ──────────────  ─────────────────────────────
MCP config:  .mcp.json present (2 servers configured)
```

**Status values:**
- `configured` -- tool is set up and documented
- `not found` -- not detected, never offered or not yet decided
- `declined` -- user explicitly declined in a previous session
- `broken` -- config exists but is incomplete or inconsistent (e.g. in `.mcp.json` but not in CLAUDE.md)

If functional equivalents are detected, note them. This informs the user without implying they should switch.

---

## Phase 3: Offer

```
[tools 3/5] Tool options
```

For each tool, present a brief description and the current status. Offer actions based on status:

### Tool not found (never offered)

**For OpenSpec** (recommended):

```
OpenSpec -- specification-driven development (recommended)
  Manages specs and change proposals as markdown files alongside code.
  Integrates with AEH roles: analyst writes specs, architect writes designs,
  developer reads tasks, reviewer checks spec currency.
  No MCP server needed for CLI agents (Claude Code) -- specs are read directly.
  Docs: https://openspec.dev/
  [set up / not now / never for this project]
```

"not now" records a deferral -- OpenSpec is offered again on the next `tools` run. "never for this project" records a permanent decline. Both are reversible if the user explicitly asks to reconsider.

If functional equivalents were detected:

```
OpenSpec -- specification-driven development (recommended)
  Manages specs and change proposals as markdown files alongside code.
  Note: ADR directory detected at docs/adr/ -- OpenSpec complements rather
  than replaces this (ADRs track decisions, OpenSpec tracks specs and changes).
  Docs: https://openspec.dev/
  [set up / not now / never for this project]
```

**For other tools** (optional):

```
Context7 -- documentation lookup via MCP
  Provides up-to-date library docs in context.
  Docs: https://context7.com/
  [set up / skip / decline]
```

### Tool previously declined

```
Serena -- language-aware code navigation via MCP (previously declined)
  [reconsider / skip]
```

### Tool currently configured

```
Context7 -- documentation lookup via MCP (configured)
  [keep / remove]
```

### Tool broken

```
Serena -- language-aware code navigation via MCP (broken: in .mcp.json but not in CLAUDE.md)
  [repair / remove / skip]
```

**Record each decision.** `skip` means "not now, ask again next time". `decline` means "I don't want this tool, don't ask again unless I say reconsider".

Wait for the user to respond to each tool before moving to the next. If the user says `stop`, save progress and end.

---

## Phase 4: Execute

```
[tools 4/5] Generating prompts
```

For each accepted action, generate a prompt:

### Setup

1. Read the relevant setup template from `templates`tools`/<tool>-setup.md`
2. Adapt it to the target project:
   - Use the correct tech stack for Serena's `project.yml`
   - Reference the correct CLAUDE.md section locations
   - Include project-specific paths
3. Write the prompt to `targets/<slug>/prompts/NNN-setup-<tool>.md` following the standard prompt format (see CLAUDE.md > Prompt File Format)
4. If the target's prompt delivery policy is `direct`, also write to `<target-path>/docs/AE/prompts/`

### Teardown (removal)

1. Read the relevant teardown template from `templates`tools`/<tool>-teardown.md`
2. Adapt it to the target project
3. Write the prompt to `targets/<slug>/prompts/NNN-teardown-<tool>.md`
4. If `direct` delivery, also write to `<target-path>/docs/AE/prompts/`

### Repair

Generate a prompt that:
1. Reads current config state
2. Identifies what's missing or inconsistent
3. Fixes the gaps (add missing CLAUDE.md section, fix `.mcp.json` entry, etc.)
4. Uses the setup template as the reference for what "correct" looks like

### Present each prompt

```
Prompt generated: targets/<slug>/prompts/NNN-setup-openspec.md
  Action: Set up OpenSpec (directory structure + CLAUDE.md, no MCP server)
  Files affected: CLAUDE.md, openspec/ directory
```

---

## Phase 5: Record

```
[tools 5/5] Recording decisions
```

### 5a. Update profile.md

Add or update the `## Development Tools` section in `targets/<slug>/profile.md`:

```markdown
## Development Tools

| Tool | Status | Date | Notes |
|------|--------|------|-------|
| OpenSpec | configured | 2026-02-19 | Setup prompt: 004-setup-openspec.md |
| Context7 | declined | 2026-02-19 | User prefers manual doc lookup |
| Serena | not offered | | |
```

### 5b. Update decisions.md

Append tool decisions to `targets/<slug>/decisions.md`:

```markdown
### Tool Configuration (2026-02-19)

- **OpenSpec:** Set up. User wants spec management for the migration project.
- **Context7:** Declined. User prefers manual doc lookup and doesn't want API key dependency.
- **Serena:** Skipped for now. May revisit when the codebase grows.
```

### 5c. Update journal.md

Append to `targets/<slug>/journal.md` with a summary of what was done.

### 5d. Present Summary

```
[tools] Complete -- <project-name>

  OpenSpec:  setup prompt generated (004-setup-openspec.md)
  Context7:  declined (recorded)
  Serena:    skipped

  Profile updated: targets/<slug>/profile.md
```

---

## Error Handling

| Situation | Action |
|-----------|--------|
| No targets exist | Suggest `onboard` |
| Target has no profile.md | Suggest `onboard` or `health` |
| `.mcp.json` has unexpected format | Warn user, ask how to proceed |
| Serena requested but `uv` not available | Note prerequisite in the prompt, don't block |
| Context7 requested but no API key | Note in prompt that user needs to set `CONTEXT7_API_KEY` |
| User changes mind mid-playbook | Allow it -- re-offer the tool with updated options |
