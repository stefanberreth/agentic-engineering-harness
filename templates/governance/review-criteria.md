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
| **Conciseness**: Under 15-20k tokens (doesn't waste context budget) | | |
| **Currency**: Reflects the current state of the project, not a stale snapshot | | |

### Signs of a good CLAUDE.md
- A new team member (human or AI) can go from zero to productive by reading it.
- Commands are copy-pasteable and work.
- It says what NOT to do, not just what to do.
- It evolves with the project (has been updated recently).

### Common problems
- Stale build commands that don't work.
- Missing or wrong test commands.
- No mention of branch strategy or commit conventions.
- Too long (>20k tokens) -- eating context budget.
- Too short -- just a project name and nothing else.

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

## 4. Governance & Process Quality

| Criterion | Score | Notes |
|---|---|---|
| **Review process**: Clear workflow for review cycles | | |
| **Feedback loop**: Retrospectives feed back into spec revisions | | |
| **Human-in-the-loop**: Clear decision points where the human must approve | | |
| **Recovery process**: What to do when things go wrong is documented | | |
| **Restartability**: Any session can be killed and work resumed from files on disk | | |
| **Progress tracking**: Task status is tracked in committed files, not just chat history | | |

---

## Overall Assessment

| Aspect | Rating | Priority |
|---|---|---|
| CLAUDE.md | | |
| Persona prompts | | |
| Specification | | |
| Governance & process | | |

**Top recommendations:**
1. [Most impactful improvement]
2. [Second priority]
3. [Third priority]

**Next review date:** [When should this assessment be repeated?]
