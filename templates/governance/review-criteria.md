# Quality Criteria for Agentic Configuration Files

Use this rubric to evaluate the quality of the agentic engineering files in a target project. Each file type has its own criteria. Score each criterion as:

- **Good** -- meets the standard, no action needed
- **Adequate** -- works but could be improved
- **Poor** -- needs significant revision
- **Missing** -- does not exist

---

## 1. CLAUDE.md Quality

| Criterion | Score | Notes |
|---|---|---|
| **Completeness**: Contains build, test, lint, and run commands | | |
| **Accuracy**: All documented commands actually work | | |
| **Code style**: References or defines code style rules | | |
| **Architecture**: Describes or links to architecture docs | | |
| **Workflow**: Documents the expected development workflow | | |
| **Context management**: Includes guidance on token limits and session management | | |
| **Orientation**: A fresh Claude session reading only this file can understand the project | | |
| **Section ordering**: Session-critical instructions (session init, persona selection, safety rules) appear in the first 50 lines | | |
| **Conciseness**: Under 15-20k tokens (doesn't waste context budget) | | |
| **Currency**: Reflects the current state of the project, not a stale snapshot | | |

### Signs of a good CLAUDE.md
- A new team member (human or AI) can go from zero to productive by reading it.
- Commands are copy-pasteable and work.
- It says what NOT to do, not just what to do.
- It evolves with the project (has been updated recently).
- Session init instructions are near the top -- LLMs give more weight to early content in long files.

### Common problems
- Stale build commands that don't work.
- Missing or wrong test commands.
- No mention of branch strategy or commit conventions.
- Too long (>20k tokens) -- eating context budget.
- Too short -- just a project name and nothing else.
- **Session init buried deep**: instructions for banner display, persona loading, or first-message behaviour placed after hundreds of lines of project rules. LLMs reliably follow early instructions; late instructions in long files are often ignored.

---

## 2. System Prompt (Persona) Quality

| Criterion | Score | Notes |
|---|---|---|
| **Role clarity**: The persona knows what it is and what it is NOT | | |
| **Scope boundaries**: Clear handoff points to other personas | | |
| **Process definition**: Step-by-step instructions for the persona's workflow | | |
| **Output specification**: Defines exactly what artifact(s) the persona produces | | |
| **Project specificity**: References the actual tech stack, not generic placeholders | | |
| **Principle guidance**: Includes decision-making principles for ambiguous situations | | |
| **Error handling**: Tells the persona what to do when stuck or uncertain | | |
| **Tone**: Professional, specific, actionable -- not vague or aspirational | | |
| **Banner-persona alignment**: Every role listed in CLAUDE.md session banner has a matching persona file | | |

### Signs of a good system prompt
- You can give it to a different LLM and get similar behaviour.
- It prevents common failure modes (scope creep, guessing, silent assumptions).
- It produces consistent output format across sessions.
- It tells the persona when to stop and hand off.

### Common problems
- Too vague: "Write good code" (what does "good" mean here?).
- Too rigid: Prescribes solutions instead of principles.
- Scope bleed: The developer prompt includes architectural decisions.
- No error path: Doesn't say what to do when things go wrong.
- Not project-specific: Generic template that wasn't adapted.
- **Advertised but missing**: Session banner offers roles that have no persona file. This creates a broken user experience -- selecting the role loads nothing.

---

## 3. Specification (spec.md) Quality

| Criterion | Score | Notes |
|---|---|---|
| **Traceability**: Every spec item traces back to a requirement | | |
| **Task granularity**: Tasks are branch-sized (implementable in one session) | | |
| **Acceptance criteria**: Every task has testable acceptance criteria | | |
| **Dependency clarity**: Task ordering and dependencies are explicit | | |
| **Technology decisions**: Stack choices are documented with rationale | | |
| **Architectural diagrams**: System structure is described (text or visual) | | |
| **API contracts**: Interfaces between components are defined | | |
| **Resumability**: A developer starting fresh can pick up any task | | |

### Signs of a good spec
- A developer can implement a task without asking clarifying questions.
- Tasks don't have hidden dependencies on each other.
- The spec has been revised based on implementation feedback (it's a living document).

### Common problems
- Tasks too large (multi-day, multi-branch scope).
- Vague acceptance criteria ("it should work well").
- Missing error handling specifications.
- No revision history (unknown whether it's current).

---

## 3a. OpenSpec Specification Quality (Conditional)

> Only score this rubric when `openspec/specs/` exists in the target project. If the project uses a different spec format (e.g. a single `spec.md`), Section 3 applies instead. If both exist, score both.

| Criterion | Score | Notes |
|---|---|---|
| **Frontmatter completeness**: Every spec file has `id`, `title`, `status`, `created`, and `updated` fields | | |
| **Spec currency**: `updated` dates reflect reality; no active specs with dates >90 days stale | | |
| **Acceptance criteria quality**: Acceptance criteria are testable and specific (not "it should work well") | | |
| **Change proposal hygiene**: Active proposals have all required files; no abandoned proposals (proposal.md without design.md/tasks.md) | | |
| **Spec-code traceability**: Implementations reference spec IDs in commits or code; specs reference code paths where implemented | | |
| **Orphan detection**: No active specs for features that were never built; no significant features without specs | | |
| **Evolution evidence**: Specs revise over time; change proposals exist; version history is visible | | |

### Signs of good OpenSpec usage
- Specs and code tell the same story -- you can trace from requirement to spec to implementation.
- Change proposals are the normal mechanism for spec evolution, not ad-hoc edits.
- Stale or superseded specs are marked with appropriate status, not left as `active`.
- Frontmatter is consistent and machine-parseable across all spec files.

### Common problems
- Specs written during planning but never updated as implementation revealed differences.
- Missing frontmatter fields (especially `updated`) making it impossible to detect staleness.
- Abandoned change proposals: `proposal.md` exists but was never completed or rejected.
- Active specs for features that were descoped or never started (orphans that mislead agents).
- No traceability: code has no reference to spec IDs, specs have no reference to code paths.
- Acceptance criteria that are subjective ("user-friendly", "performant") rather than testable.

---

## 4. Governance & Process Quality

| Criterion | Score | Notes |
|---|---|---|
| **Review process**: Clear workflow for review cycles | | |
| **Reviewer cadence**: Mandatory reviewer passes every 5 tasks or at phase boundaries; cadence tracked in orchestrator-state.md | | |
| **Review quality**: Reviewer enforces evidence-based verdicts (line citations, grep results, not vague approvals); checks 15 dimensions including absence, dependency health, and performance | | |
| **Feedback loop**: Retrospectives feed back into spec revisions | | |
| **Human-in-the-loop**: Clear decision points where the human must approve | | |
| **Recovery process**: What to do when things go wrong is documented | | |
| **Restartability**: Any session can be killed and work resumed from files on disk | | |
| **Progress tracking**: Task status is tracked in committed files, not just chat history | | |

---

## 5. Tool Integration Quality (Optional)

> Only score this rubric if the project has actively configured development tools (OpenSpec, Context7, Serena, other MCP servers, or CLI-based doc tools). If no tools are configured, skip this section entirely. Note: Context7 in its preferred CLI + Skills mode is user-global and has no `.mcp.json` entry -- score it via the functional smoke test (`ctx7 library` then `ctx7 docs` returning content), not by config inspection.

| Criterion | Score | Notes |
|---|---|---|
| **Config accuracy**: `.mcp.json` entries are valid and servers can connect | | |
| **Documentation**: Each configured tool has a subsection in CLAUDE.md under Development Tools | | |
| **Scope appropriateness**: Tools match the project's needs (e.g. Serena for large codebases, not 5-file scripts) | | |
| **Consistency**: All configured tools follow the same documentation pattern in CLAUDE.md | | |
| **Maintainability**: Tool configs reference correct tech stack (Serena's `project.yml` matches actual languages) | | |
| **Reversibility**: Setup was done via harness prompts and can be undone via teardown prompts | | |

### Verification method

When scoring **Config accuracy**, perform these checks for each server in `.mcp.json`:

1. **Package resolution** (npx-based servers): Run `npm view <package> version 2>&1`. A 404 means the package does not exist -- the server is broken regardless of other config. Score: **Poor** if any package fails.
2. **Environment variable presence**: Extract all `${VAR}` references from `.mcp.json`. Cross-check each against `.env`, `.env.local`, `.env.development`. Missing variables mean the server will fail or degrade at runtime. Score: **Adequate** if documented but not in `.env*`; **Poor** if undocumented and missing.
3. **Credential pattern scan**: Grep `.mcp.json` for common secret prefixes (`sk-`, `ctx7sk-`, `sbp_`, `ghp_`, `xoxb-`, `eyJ`) and any 32+ character alphanumeric strings not wrapped in `${...}`. Any match is a hardcoded credential. Score: **Poor** (security issue).
4. **User-level config conflicts**: Check `~/.claude.json` for `mcpServers` entries scoped to the project path. Duplicates or conflicts cause confusing runtime behaviour. Score: **Adequate** if present but harmless; **Poor** if conflicting.

See `templates/tools/tool-detection-patterns.md` § "MCP Health Verification Patterns" for detailed detection patterns.

### Common problems
- Tool in `.mcp.json` but not documented in CLAUDE.md (invisible to new sessions)
- Serena's `project.yml` references a language server for a language the project no longer uses
- Context7 declared `configured` but the functional smoke test (`ctx7 library` then `ctx7 docs`) was never run or fails -- a claim without proof
- Context7 MCP fallback configured but `CONTEXT7_API_KEY` never set (silent failure); note the preferred CLI + Skills mode needs no key for doc queries
- Tool configured during onboarding but never actually used -- dead config weight
- Multiple overlapping tools for the same function (e.g. Serena + Sourcegraph)
- **Non-existent npm package** in npx-based MCP entry (server fails on every invocation, error only visible in `/mcp` diagnostics)
- **Missing environment variables** for MCP servers that require API keys or config (server starts but returns errors)
- **Hardcoded credentials** in `.mcp.json` (secrets committed to version control)
- **User-level config shadows project config** (`~/.claude.json` has MCP entries that duplicate or conflict with `.mcp.json`)

---

## 6. Agent Permission Quality

> Score this rubric for any project that has Claude Code settings files (`.claude/settings.json` or `.claude/settings.local.json`). If no settings files exist, note their absence as a finding rather than skipping the rubric -- unmanaged permissions are a governance gap.

| Criterion | Score | Notes |
|---|---|---|
| **No secrets**: Permission rules contain no passwords, API keys, tokens, or credentials | | |
| **Deny list health**: Deny list exists and blocks sensitive files (`.env`, credentials, SSH keys, `*.pem`, `*.key`) and destructive commands | | |
| **Allow list hygiene**: Allow rules use consolidated wildcards, not sprawled individual entries (threshold: 50+ = concern, 100+ = critical) | | |
| **Scope appropriateness**: `defaultMode` matches project risk profile; filesystem access doesn't extend beyond project root | | |
| **Currency**: Permission rules reference paths and tools that currently exist (no stale entries) | | |
| **File separation**: Shared settings (`.claude/settings.json`) version-controlled; local settings (`.claude/settings.local.json`) gitignored | | |

### Signs of good permission governance
- Deny list is intentionally constructed (not empty or default)
- Allow list has been reviewed and consolidated at least once
- `defaultMode` was a conscious choice, not the default left unchanged
- No secrets have ever appeared in settings files (check git history)
- Filesystem scope is enforced -- agent cannot read outside the project

### Common problems
- Empty deny list -- nothing is forbidden, agent can do anything it's allowed to by default mode
- Secrets embedded in Bash rules (e.g. `PGPASSWORD=... psql`)
- 100+ allow rules accumulated through "yes, don't ask again" clicks
- `bypassPermissions` mode enabled (all safety prompts disabled)
- Broad filesystem access: `Read` or `Write` with no path constraints
- `.claude/settings.local.json` committed to git (personal overrides shared with team)
- No gitignore entry for local settings

---

## Overall Assessment

| Aspect | Rating | Priority |
|---|---|---|
| CLAUDE.md | | |
| Persona prompts | | |
| Specification | | |
| Governance & process | | |
| Tool integration (if applicable) | | |
| Agent permissions | | |

**Top recommendations:**
1. [Most impactful improvement]
2. [Second priority]
3. [Third priority]

**Next review date:** [When should this assessment be repeated?]
