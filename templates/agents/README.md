# Agent-Specific Knowledge

This directory contains reference knowledge for specific coding agents -- the runtimes that execute agentic engineering workflows in target projects.

## Why This Is Separate from Tools and Governance

AEH distinguishes three concerns:

| Concern | Location | Examples |
|---------|----------|----------|
| **Agent knowledge** | `templates/agents/<agent>/` | Permission schemas, config file locations, detection patterns, recommended baselines |
| **Tool knowledge** | `templates/tools/` | MCP server setup/teardown, detection patterns for OpenSpec/Context7/Serena |
| **Governance criteria** | `templates/governance/` | Agent-agnostic evaluation rubrics (assessment checklist, review criteria) |

**Agents are runtimes** -- they control what actions an LLM can take, where it can read/write, and what permissions it has. Claude Code, Cursor, Windsurf, Cline, Aider, and Codex are all agents with different permission models, config locations, and governance surfaces.

**Tools are plugins** -- MCP servers, language servers, and other capabilities that agents can use. A tool has the same behaviour regardless of which agent invokes it.

**Governance criteria are agent-agnostic** -- the assessment checklist and review criteria evaluate whether a project is well-structured for agentic engineering, regardless of which agent runs the workflow. Agent-specific checks (e.g. "are Claude Code permissions properly configured?") reference the knowledge in this directory but are scored by the governance rubrics.

## Known Agents

| Agent | Directory | Status |
|-------|-----------|--------|
| Claude Code | `claude-code/` | Active -- permission schema, detection patterns, baselines |
| Cursor | -- | Planned |
| Windsurf | -- | Planned |
| Cline | -- | Planned |
| Aider | -- | Planned |
| Codex | -- | Planned |

Each agent directory contains:
- **Permission/config reference** -- schema, file locations, precedence rules
- **Detection patterns** -- glob/grep patterns for auditing the agent's config
- **Baselines** -- recommended configurations by project archetype

When a new agent is added, create its directory with the same three-file structure and update this README.
