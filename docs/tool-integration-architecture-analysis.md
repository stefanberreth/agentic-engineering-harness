# Architecture Analysis: Integrating OpenSpec, Context7, and Serena into the AE Harness

**Date:** 2026-02-19
**Status:** Research complete, pending decision

---

## Executive Summary

This analysis examines how three complementary tools -- OpenSpec (spec-driven development), Context7 (live library documentation), and Serena (LSP-powered code intelligence) -- could be optionally integrated into the Agentic Engineering harness's onboarding and health-check workflows. The focus is on:

- **Ease of addition/removal** during target project onboarding
- **Minimal footprint** on the target project's codebase
- **No side effects** on other projects sharing the same machine/account
- **Reversibility** -- every change can be undone cleanly

Each tool operates at a different layer and solves a different problem. None requires the others, and all three can be adopted independently.

---

## Tool Profiles

### OpenSpec -- Spec-Driven Development Workflow

| Attribute | Detail |
|-----------|--------|
| **What it does** | Manages the spec-to-code lifecycle: specs, change proposals, design docs, task lists, delta specs, archival |
| **Installation** | `npm install -g @fission-ai/openspec@latest` (machine-global CLI) |
| **Per-project init** | `openspec init --tools claude` creates `openspec/` directory + `.claude/skills/openspec-*/` |
| **MCP server?** | No (purely file-based, reads/writes markdown) |
| **Context token cost** | Skills descriptions only (~2% budget shared with all skills). Full content loads lazily on invocation. |
| **Reversibility** | `openspec uninstall` strips all managed content, deletes directories. Or manual: delete `openspec/` + `.claude/skills/openspec-*` |
| **Cross-project isolation** | Complete. All state is per-project directory. Global install provides only the CLI binary. |
| **Git footprint** | `openspec/` and `.claude/skills/openspec-*/` -- designed to be committed |

### Context7 -- Live Library Documentation Gateway

| Attribute | Detail |
|-----------|--------|
| **What it does** | Fetches up-to-date, version-specific documentation for public libraries on demand |
| **Installation** | No local install needed. Runs via `npx` (stdio) or HTTP remote transport |
| **Per-project config** | None required. User-scope is typical. |
| **MCP server?** | Yes (2 tools: `resolve-library-id`, `query-docs`) |
| **Context token cost** | ~1,500 tokens idle (2 tool definitions). ~5,000 tokens per doc fetch. Below Tool Search threshold alone. |
| **Reversibility** | `claude mcp remove context7 -s user` -- one command, zero residue |
| **Cross-project isolation** | User-scope: available everywhere. Project/local-scope: isolated to that project. |
| **Git footprint** | Zero at user scope. `.mcp.json` entry if project-scoped. |
| **Pricing** | Free: 1,000 calls/month. Pro: $7/seat/month, 5,000 calls. |

### Serena -- LSP-Powered Code Intelligence

| Attribute | Detail |
|-----------|--------|
| **What it does** | Gives Claude IDE-like capabilities: find symbol, find references, semantic rename, insert after symbol, etc. |
| **Installation** | No local install. Runs via `uvx` (requires `uv` pre-installed). |
| **Per-project config** | `.serena/project.yml` (auto-created on first use), `.serena/memories/`, `.serena/cache/` |
| **MCP server?** | Yes (50+ tools) |
| **Context token cost** | ~17,600 tokens idle. Mitigated by `ENABLE_TOOL_SEARCH=true` (loads on demand). |
| **Reversibility** | Remove MCP entry + delete `.serena/`. No system-level residue. |
| **Cross-project isolation** | Complete. Per-project `.serena/`, per-project language server instances. Only `~/.serena/serena_config.yml` is shared (defaults). |
| **Git footprint** | `.serena/project.yml` and `.serena/memories/` committed. `.serena/cache/` and `.mcp.json` gitignored. |
| **Prerequisites** | `uv` installed. Language-specific toolchains for non-auto-installed languages. |

---

## The Isolation Model: How Claude Code Scoping Works

Understanding this is critical for the harness's "no side effects" requirement.

### Three scopes for MCP servers

| Scope | Storage | Visibility | In git? |
|-------|---------|------------|---------|
| **Local** | `~/.claude.json` (keyed by project path) | Only you, only this project | No |
| **Project** | `.mcp.json` in project root | Everyone who clones the repo | Yes (intended) |
| **User** | `~/.claude.json` (global section) | Only you, all projects | No |

**Precedence:** Local > Project > User.

### Skills and commands

| Location | Scope |
|----------|-------|
| `.claude/skills/<name>/SKILL.md` | Per-project (committed) |
| `~/.claude/skills/<name>/SKILL.md` | Per-user (all projects) |
| `.claude/commands/<name>.md` | Per-project (committed) |
| `~/.claude/commands/<name>.md` | Per-user (all projects) |

### Context token budget

| Component | Loading | Cost |
|-----------|---------|------|
| CLAUDE.md files | Eager (all ancestor dirs) | Variable (keep <500 lines recommended) |
| MCP tool definitions | Eager, unless Tool Search active | 550-850 tokens per tool |
| Skill descriptions | Eager (capped at 2% of context) | Shared budget |
| Skill full content | Lazy (on invocation) | Variable |
| Tool Search tool | Replaces eager MCP defs | ~500 tokens flat |

**Tool Search** activates automatically when MCP tool definitions exceed 10% of context window. With Serena's 50+ tools (~17.6k tokens), this threshold is easily hit, so Tool Search will activate. Context7's 2 tools alone won't trigger it.

---

## Integration Architecture Options

### Option A: User-Level Ambient (Zero Project Footprint)

**Strategy:** Install Context7 and Serena at user scope. Do not install OpenSpec. Nothing touches the target project.

```
User machine (~/.claude.json):
  context7 → user scope, HTTP transport
  serena   → user scope, --project-from-cwd

Target project:
  (no changes)
```

**Pros:**
- Absolute zero footprint on target projects
- Nothing to commit, nothing to gitignore
- Instant availability across all projects
- Trivially reversible: `claude mcp remove -s user`

**Cons:**
- Serena's `--project-from-cwd` means it auto-activates for every project. Language server errors in projects without the right toolchain.
- Context7 token overhead (~1,500) applies to every session, even non-code ones (this harness!)
- No OpenSpec (its value requires per-project state)
- Team members don't benefit -- it's personal only
- Serena creates `.serena/` on first use even without explicit init

**Verdict:** Good for personal productivity. Not suitable for systematic harness-driven onboarding because it can't be part of a reproducible setup.

---

### Option B: Project-Scoped Opt-In (Harness-Managed)

**Strategy:** The harness offers each tool as an optional onboarding step. Configuration is added to the target project via prompts/deliverables, using the harness's existing prompt delivery mechanism.

```
Harness produces:
  targets/<slug>/deliverables/mcp.json        # Serena + Context7 config
  targets/<slug>/deliverables/gitignore-patch  # .serena/cache/, .mcp.json
  targets/<slug>/prompts/NNN-setup-serena.md   # Prompt for target-side Claude
  targets/<slug>/prompts/NNN-setup-openspec.md # Prompt for target-side Claude
  targets/<slug>/prompts/NNN-setup-context7.md # Prompt for target-side Claude

Target project (after prompt execution):
  .mcp.json                         # Serena (+ optionally Context7)
  .serena/project.yml               # Auto-created
  .serena/memories/                  # Auto-created
  .gitignore                        # Updated: .serena/cache/
  openspec/                         # If OpenSpec chosen
  .claude/skills/openspec-*/        # If OpenSpec chosen
```

**Pros:**
- Fully reproducible -- harness generates exact prompts
- Each tool is independently optional
- Configuration is version-controlled in the target project
- Team members benefit (project-scoped = shared)
- Fits the existing harness workflow (deliverables + prompts)
- Health checks can verify tool setup integrity

**Cons:**
- Modifies target project files (but only config/tooling, not application code)
- `.mcp.json` may contain machine-specific paths (Serena's `--project` flag)
- Requires target project to accept `.mcp.json` and `.serena/` in their repo
- OpenSpec creates a visible `openspec/` directory at project root

**Verdict:** Best fit for the harness's model. Aligns with the deliverables + prompts pattern. Requires the human to opt in per tool.

---

### Option C: Local-Scope Stealth (Personal Per-Project)

**Strategy:** Use Claude Code's `local` scope for MCP servers. No files in the target project repo. Serena's `.serena/` is gitignored.

```
User machine (~/.claude.json, keyed by project path):
  serena   → local scope for /path/to/project
  context7 → user scope (global)

Target project:
  .gitignore     # Updated: .serena/, .mcp.json (if not already)
  .serena/       # Created by Serena but gitignored
```

**Pros:**
- Nothing committed to the target repo (except .gitignore update)
- Per-project control without affecting other projects
- Context7 at user scope is sensible (it's project-agnostic)
- Serena's `.serena/` exists but is invisible to git

**Cons:**
- Not reproducible for team members -- each person must configure locally
- Harness can't verify setup via health checks (config isn't in the repo)
- OpenSpec can't work this way -- it needs committed specs to be useful
- Local scope config is in `~/.claude.json` which is fragile (one file, many projects)

**Verdict:** Good middle ground for individual developers who want tool support without repo changes. Not suitable for systematic team onboarding.

---

### Option D: Hybrid (Recommended)

**Strategy:** Layer the tools based on their nature:

| Tool | Scope | Rationale |
|------|-------|-----------|
| **Context7** | User scope, HTTP transport | Project-agnostic. Negligible token cost. One-time setup per developer. |
| **Serena** | Local scope per project | Needs per-project language config. Heavy token cost. Don't force on all projects. |
| **OpenSpec** | Project scope (committed) | Only useful if specs are version-controlled. Requires team buy-in. |

```
Phase 1: Developer setup (one-time, harness documents but doesn't automate)
  claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp

Phase 2: Per-project onboarding (harness generates prompts)
  Optional: Serena setup prompt → local MCP + .serena/ + .gitignore patch
  Optional: OpenSpec setup prompt → openspec init + skills

Phase 3: Health check verification
  Context7: present? (check user MCP list)
  Serena: configured for this project? (check .serena/project.yml or local MCP)
  OpenSpec: initialized? (check openspec/ directory, specs freshness)
```

---

## Detailed Integration Concerns

### 1. OpenSpec + AE Harness: Overlap and Complementarity

OpenSpec and this harness both produce structured specifications, but at different levels:

| Concern | AE Harness | OpenSpec |
|---------|-----------|----------|
| **Scope** | Transforms a project's agentic configuration | Manages spec-to-code lifecycle for features |
| **Specs describe** | Personas, governance, process | Application behavior, requirements |
| **Change tracking** | `targets/<slug>/tasks.md`, journal | `openspec/changes/<name>/` with proposals, designs, delta specs |
| **Who executes** | Human pastes prompts to target-side Claude | Target-side Claude follows `/opsx:*` commands |

**They are complementary, not competing.** The harness could:
- Include OpenSpec setup as a transformation deliverable
- Use OpenSpec's spec structure to verify that the Architect persona's output conforms to spec conventions
- Health-check OpenSpec's spec freshness (are specs drifting from implementation?)

**Potential friction:**
- OpenSpec creates `openspec/AGENTS.md` at project root. If the harness also delivers an `AGENTS.md`, there's a file ownership conflict. Resolution: the harness should detect existing `AGENTS.md` and merge rather than overwrite.
- OpenSpec's directory name `openspec/` is hardcoded (issue #581 open). Cannot be moved under `docs/` or renamed.
- OpenSpec injects skills into `.claude/skills/`. The harness doesn't currently manage skills, but should be aware they exist when assessing a project.

### 2. Serena: The Token Budget Question

Serena's 50+ tools create ~17.6k tokens of overhead. This is the biggest cost consideration.

**Mitigation strategies:**

| Strategy | Effect | Trade-off |
|----------|--------|-----------|
| `ENABLE_TOOL_SEARCH=true` | Defers tool loading, ~500 token flat cost | Agent may miss relevant tools occasionally |
| `excluded_tools` in `.serena/project.yml` | Reduces registered tools | Requires knowing which tools you don't need |
| `--context claude-code` flag | Disables tools that duplicate Claude Code built-ins | Already recommended in their docs |
| Local scope (not project) | Only loads when you're in that project | Team members don't get it automatically |
| Don't use Serena for non-code sessions | Zero cost when not configured | Requires per-project awareness |

**Recommendation for the harness:** Always use `--context claude-code` and recommend `ENABLE_TOOL_SEARCH=true`. Document that Serena is most valuable for projects with:
- Large codebases where grep-based symbol finding is expensive
- Strongly-typed languages where LSP shines (C#, TypeScript, Go, Rust, Java)
- Frequent refactoring (rename symbol, find references)

### 3. Context7: Minimal Cost, Maximum Convenience

Context7 is the easiest integration:
- 2 tools, ~1,500 tokens idle
- User-scope works everywhere
- Free tier (1,000 calls/month) is generous for most workflows
- HTTP transport means no Node.js dependency, no subprocess

**The only question is: user scope or per-project?**

User scope is the right default. Context7 is project-agnostic -- it fetches library docs regardless of which project you're in. There's no reason to configure it per-project unless a team wants to standardize on it (in which case, `.mcp.json` with `${CONTEXT7_API_KEY}` env var).

### 4. Failure Modes and Graceful Degradation

| Tool | Failure mode | Impact | Recovery |
|------|-------------|--------|----------|
| **OpenSpec** | `openspec` CLI not installed globally | Skills reference non-existent commands | `npm install -g @fission-ai/openspec@latest` |
| **OpenSpec** | Specs drift from implementation | `/opsx:verify` catches it | Run verify, update specs or code |
| **Context7** | API rate limit hit (1,000/month free) | Doc fetches fail with rate limit error | Wait for reset, upgrade to Pro, or work without |
| **Context7** | HTTP endpoint down | Tool invocation errors | Claude falls back to training data (graceful enough) |
| **Serena** | Language server not found | Symbol tools fail for that language | Install language server or remove language from project.yml |
| **Serena** | Slow LS init (>4s in stdio mode) | MCP connection timeout | Switch to streamable-http transport |
| **Serena** | `uv` not installed | Serena can't start at all | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| **Serena** | 17.6k token overhead fills context | Reduced working context | Enable Tool Search, exclude unused tools |

None of these failures are destructive. The worst case is "tool doesn't work, Claude falls back to its built-in capabilities." No data loss, no code corruption.

---

## Reversibility Summary

| Tool | Add | Remove | Residue |
|------|-----|--------|---------|
| **Context7 (user)** | `claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp` | `claude mcp remove context7 -s user` | None |
| **Context7 (project)** | Entry in `.mcp.json` | Remove entry, delete `.mcp.json` if empty | None |
| **Serena (local)** | `claude mcp add --scope local serena -- uvx ...` | `claude mcp remove serena` + `rm -rf .serena/` | None |
| **Serena (project)** | Entry in `.mcp.json` + `.serena/` auto-created | Remove entry + `rm -rf .serena/` + revert `.gitignore` | None |
| **OpenSpec** | `openspec init --tools claude` | `openspec uninstall` | None (strips managed blocks, deletes dirs) |

Every tool can be fully removed with 1-2 commands and zero residual state.

---

## Recommendations for the AE Harness

### 1. Add tool assessment to onboarding

During Phase 1 (Assessment), the harness should check:
- Is `openspec/` present? What specs exist? Are they current?
- Is `.serena/` present? What languages are configured?
- Is `.mcp.json` present? What servers are configured?
- Are there existing `.claude/skills/` or `.claude/commands/`?

This informs whether to offer tool setup during transformation.

### 2. Offer tools as optional transformation steps

After the core transformation (CLAUDE.md, personas, governance), offer:

> "Would you like to set up any of these optional development tools?"
> - **OpenSpec** -- Spec-driven development workflow (adds `openspec/` + skills)
> - **Serena** -- LSP-powered code intelligence (adds `.serena/` + MCP config)
> - **Context7** -- Live library documentation (user-level MCP, no project changes)

Each choice generates its own prompt in `targets/<slug>/prompts/`.

### 3. Add tool checks to health-check playbook

The `/health` playbook should include:
- **OpenSpec health:** Are specs present? When was the last change archived? Are any changes stale (open >30 days)? Run `/opsx:verify` equivalent check.
- **Serena health:** Is `.serena/project.yml` current with declared languages? Is cache populated? Any language server errors in recent sessions?
- **Context7 health:** Is it configured? What scope? Is the API key valid? Approaching rate limits?

### 4. Document prerequisites in target profile

The target's `profile.md` should record:
```yaml
## Development Tools
- openspec: installed | not installed | declined
- serena: configured (local|project) | not configured | declined
- context7: configured (user|project) | not configured | declined
- prerequisites_met:
    uv: yes | no
    node: yes | no (version)
    language_servers: [list of confirmed working]
```

### 5. Never force tools

All three tools are optional. The harness should:
- Present them with clear cost/benefit explanations
- Record the decision in `targets/<slug>/decisions.md`
- Never assume a tool is present in subsequent prompts unless confirmed
- Generate removal prompts alongside setup prompts (always offer the exit)

### 6. Handle the `.mcp.json` question carefully

`.mcp.json` is the trickiest file:
- It often contains machine-specific paths (Serena's `--project` absolute path)
- It may already exist with other MCP servers
- Committing it shares config but may break on other machines
- Not committing it means manual per-developer setup

**Recommendation:** For Serena, prefer local scope (no `.mcp.json` needed). For Context7, prefer user scope (no `.mcp.json` needed). Only use `.mcp.json` for team-wide tools that are truly project-specific and use environment variable expansion for all paths and keys.

---

## Decision Matrix: When to Recommend Each Tool

| Signal in target project | Recommend |
|--------------------------|-----------|
| Large codebase (>50 files), strongly-typed language | Serena |
| Uses many third-party libraries, frequently looks up API docs | Context7 |
| Feature development is ad-hoc, no spec discipline | OpenSpec |
| Small codebase, scripting language, solo developer | Context7 only (maybe) |
| Already has spec/RFC process (ADRs, design docs) | OpenSpec (natural fit) |
| Team uses JetBrains IDEs | Serena (JetBrains plugin path) |
| CI/CD heavy, minimal local dev | Context7 only |
| Agentic development maturity: low | Start with OpenSpec (adds structure) |
| Agentic development maturity: medium | Add Serena (improves efficiency) |
| Agentic development maturity: high | All three if desired |

---

## Sources

### OpenSpec
- [Fission-AI/OpenSpec GitHub](https://github.com/Fission-AI/OpenSpec)
- [OpenSpec v1.0.0 Release ("The OPSX Release")](https://github.com/Fission-AI/OpenSpec/releases/tag/v1.0.0)
- [Customization Guide](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md)
- [Migration Guide (v0.x to v1.0)](https://github.com/Fission-AI/OpenSpec/blob/main/docs/migration-guide.md)
- [Issue #581: Configurable directory name](https://github.com/Fission-AI/OpenSpec/issues/581)
- [OpenSpec Skills Repo](https://github.com/partme-ai/openspec-skills)
- [openspec.dev](https://openspec.dev/)

### Context7
- [upstash/context7 GitHub](https://github.com/upstash/context7)
- [Context7 Pricing](https://context7.com/plans)
- [Context7 Free Tier Changes (Dev Genius)](https://blog.devgenius.io/context7-quietly-slashed-its-free-tier-by-92-16fa05ddce03)

### Serena
- [oraios/serena GitHub](https://github.com/oraios/serena)
- [Serena Documentation](https://oraios.github.io/serena)
- [Programming Language Support](https://oraios.github.io/serena/01-about/020_programming-languages.html)
- [Configuration Docs](https://oraios.github.io/serena/02-usage/050_configuration.html)
- [Token-efficient tool handling (Issue #802)](https://github.com/oraios/serena/issues/802)
- [SSE mode for slow LS (Issue #900)](https://github.com/oraios/serena/issues/900)

### Claude Code Platform
- [MCP Documentation](https://code.claude.com/docs/en/mcp)
- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Settings Documentation](https://code.claude.com/docs/en/settings)
- [Cost Management](https://code.claude.com/docs/en/costs)
- [Tool Search Feature](https://www.atcyrus.com/stories/mcp-tool-search-claude-code-context-pollution-guide)
- [MCP Context Bloat Reduction](https://medium.com/@joe.njenga/claude-code-just-cut-mcp-context-bloat-by-46-9-51k-tokens-down-to-8-5k-with-new-tool-search-ddf9e905f734)
