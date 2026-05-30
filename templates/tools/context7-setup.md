# Context7 Setup -- Prompt Template

> Adapt this template when generating a setup prompt for a target project.
> Replace all `[PLACEHOLDER]` values with project-specific details.
> See also: `templates/tools/sandbox-env-provisioning.md` (only needed for the MCP fallback).

---

## What Context7 Does

Context7 provides up-to-date library documentation directly in the agent's context, eliminating manual doc searching and reducing hallucination of outdated APIs. Agents look up current API shape before writing code that uses fast-moving libraries.

- **Docs:** https://context7.com/
- **CLI package:** `ctx7` (run via `npx ctx7@latest ...`, or install globally). Requires Node.js 18+.

---

## Two Setup Modes

| Mode | Mechanism | When to use |
|------|-----------|-------------|
| **CLI + Skills** (preferred, default) | `ctx7 setup --cli --<agent>` installs an always-on docs skill + rule into the agent's user-level config (`~/.claude/skills/`, `~/.claude/CLAUDE.md` rule). The agent autonomously runs `ctx7 library` then `ctx7 docs` when it needs docs. No `.mcp.json`, no mandatory API key for doc queries. | Default for every target. Simpler, fewer moving parts, no per-project secret. |
| **MCP server** (fallback) | `.mcp.json` entry + `CONTEXT7_API_KEY` in `.env`. Documentation is served over MCP. | Only when the CLI cannot run (restricted containers without `npx`, no Node 18+) or the operator specifically wants an MCP-native tool. |

**Default to CLI + Skills.** Generate the MCP-fallback setup only when the target environment cannot run the `ctx7` CLI, or the operator explicitly asks for the MCP server.

---

## Setup Steps -- CLI + Skills (preferred)

The generated prompt should instruct the target-side agent to:

### 1. Run the setup command

Use the flag that matches the target's coding agent (`--claude` for Claude Code, `--gemini` for Gemini CLI, `--cursor`, `--opencode`):

```bash
npx ctx7@latest setup --cli --claude --yes
```

This installs:
- A docs skill into the agent's user-level skills directory (e.g. `~/.claude/skills/`) that teaches the agent to fetch docs via the `ctx7` CLI.
- An always-on rule (e.g. into `~/.claude/CLAUDE.md`) that raises the agent's trigger rate for doc lookups.

**Note (user-global install):** CLI + Skills mode installs into the agent's user-level config, not the project tree. Once run on a machine, it covers every project that agent touches. There is nothing to commit to the project repo. The setup command is idempotent -- re-running it is safe.

### 2. (Optional) Authenticate for higher rate limits

Doc queries work without login. Login (or an API key) only unlocks higher rate limits and skill generation. If the operator has a key:

```bash
npx ctx7@latest login            # interactive browser OAuth
# or, non-interactive:
export CONTEXT7_API_KEY=<value>  # personal key, same across all projects
```

Do NOT block setup on the key. Doc lookups function without it. The key value must NEVER appear in the prompt file on disk -- instruct the target-side agent to ask the operator interactively if a key is wanted.

### 3. Document Context7 in the target's CLAUDE.md

Even though the skill is user-global, add a project-level pointer so fresh sessions and new developers know Context7 is expected. Under the `## Development Tools` section (create it if absent), add:

```markdown
### Context7

Up-to-date library documentation via the `ctx7` CLI + Skills (user-global install).

The agent fetches docs autonomously: `ctx7 library <name> <query>` to resolve a
library ID, then `ctx7 docs <libraryId> <query>` to pull current documentation.
No project config -- the skill lives in the agent's user-level config.

Setup (per machine, once): `npx ctx7@latest setup --cli --claude`
Docs: https://context7.com/
```

### 4. Verify (functional smoke test)

Confirm the skill is installed and the CLI actually returns docs:

```bash
npx ctx7@latest skills list --claude          # the docs skill should appear
npx ctx7@latest library react "state hooks"   # resolves a library ID
npx ctx7@latest docs /facebook/react "useState cleanup"  # returns documentation
```

Library IDs require a leading `/` (`/facebook/react`, not `facebook/react`). Always run `ctx7 library` first -- `ctx7 docs react "..."` fails without a resolved ID.

---

## Setup Steps -- MCP server (fallback only)

Use this path ONLY when the CLI cannot run or the operator requests MCP. The generated prompt should instruct the target-side agent to:

### 1. Add Context7 to `.mcp.json`

If `.mcp.json` doesn't exist, create it. Add the Context7 server entry:

```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "x-context7-api-key": "${CONTEXT7_API_KEY}"
      }
    }
  }
}
```

Note: `${CONTEXT7_API_KEY}` uses environment variable expansion. The value is read from the project's `.env` file (see step 3). In MCP mode the key IS required.

### 2. Add Context7 subsection to CLAUDE.md

Under `## Development Tools` (create the section if it doesn't exist), add:

```markdown
### Context7

Documentation lookup via MCP. Provides up-to-date library docs in context.

Usage: Add "use context7" to prompts when current library documentation is needed.

Docs: https://context7.com/
```

### 3. Provision `CONTEXT7_API_KEY` in `.env`

Required in MCP mode (unlike CLI mode). This ensures the key is available to the MCP server, natively or in a Docker sandbox (the sandbox passthrough mechanism reads from `.env`).

1. **Check if `.env` exists** in the project root.
2. **Check if it already contains `CONTEXT7_API_KEY`:**
   ```bash
   grep -q 'CONTEXT7_API_KEY' .env 2>/dev/null && echo "already set" || echo "not found"
   ```
3. **If missing, ask the operator for the value** (get one from https://context7.com/; personal key, same across all projects).
4. **Append to `.env`:**
   ```bash
   echo "CONTEXT7_API_KEY=<value from operator>" >> .env
   ```
5. **Ensure `.env` is gitignored.** If `.gitignore` lacks `.env` patterns, append:
   ```
   # Environment secrets
   .env
   .env.*
   !.env.example
   ```

**Important:** The actual key value must NEVER appear in the prompt file on disk. Use a placeholder and instruct the target-side agent to ask the operator interactively.

### 4. Create `.env.example` (if it doesn't exist)

```
# Context7 documentation lookup (get key from https://context7.com/)
CONTEXT7_API_KEY=
```

This file IS committed to git -- it documents required variables without exposing values.

---

## Verification

### CLI + Skills mode (preferred)

- [ ] `ctx7 skills list --claude` shows the docs skill installed
- [ ] `ctx7 library <known-lib> "<query>"` returns a library ID
- [ ] `ctx7 docs /<id> "<query>"` returns documentation content (functional proof)
- [ ] Target CLAUDE.md has a Context7 subsection under Development Tools pointing at the CLI workflow
- [ ] (If higher rate limits wanted) `ctx7 whoami` confirms login OR `CONTEXT7_API_KEY` is set

### MCP mode (fallback)

- [ ] `.mcp.json` contains the `context7` entry with HTTP transport
- [ ] CLAUDE.md has a Context7 subsection under Development Tools
- [ ] `.env` contains `CONTEXT7_API_KEY=<actual value>` (not empty)
- [ ] `.env` is in `.gitignore`
- [ ] `.env.example` exists documenting the required variable
- [ ] (If in sandbox) restart the container to pick up the new `.env` value
- [ ] Functional smoke test passes (see `templates/tools/tool-detection-patterns.md`)
