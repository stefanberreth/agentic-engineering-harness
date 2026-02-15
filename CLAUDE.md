# Agentic Engineering Harness -- Project Instructions

## Mission

This project is a **meta-engineering harness**. It does not implement software. It develops, tests, maintains and refines the plans, templates, persona definitions, governance criteria and process documentation needed to transform any existing software development project into a mature agentic engineering setup -- one where Claude Code (or similar agents) can be started, stopped and restarted at any point in the lifecycle without losing coherence or going off-piste.

## What This Project Contains

- **Persona templates** (`templates/personas/`) -- system prompt files for the four core roles: Analyst, Architect, Developer, Reviewer. These are generic but principled starting points.
- **Project templates** (`templates/project/`) -- scaffold files (`CLAUDE.md`, `agents.md`, governance checklists) to be adapted for target projects.
- **Governance criteria** (`templates/governance/`) -- assessment checklists and quality rubrics for evaluating and evolving the agentic configuration of a target project.
- **Reference documentation** (`docs/`) -- source material, transcripts and curated resources.

## How This Project Is Used

1. Check out this repository **alongside** an existing software development project.
2. Start Claude Code **in this project** first.
3. Claude will work with the user to identify the target project, assess its current state, and produce a transformation plan.
4. The deliverables are configuration files, persona prompts, governance docs and process instructions -- **copied or adapted into the target project**.
5. This project itself evolves: templates get refined, governance criteria get sharpened, new patterns get documented.

## Working Rules

- **Never write application code.** This project produces markdown, configuration, process documentation, and prompt engineering artifacts only.
- **Always ask which target project** the user wants to transform before generating any artifacts.
- **Assess before prescribing.** Read the target project's existing structure, README, CI config, test setup, and any existing `CLAUDE.md` or `.claude/` directory before proposing changes.
- **Favour incremental transformation.** Don't propose a 50-file overhaul. Identify the highest-value first step (usually `CLAUDE.md` + one persona) and iterate.
- **Respect existing conventions.** If the target project uses specific branching strategies, test frameworks, or CI pipelines, encode those into the generated artifacts rather than replacing them.
- **Track transformation state.** When working on a target project transformation, maintain a `transformation-log.md` in this project under `logs/<project-name>/` documenting what was done, what was deferred, and what needs revisiting.
- **Templates are starting points, not gospel.** Always adapt persona prompts and governance criteria to the target project's language, framework, team size and maturity.

## Context Management

- This is a documentation-heavy project. Context fills up fast when reading target projects.
- Prefer short, focused sessions: one assessment, one persona, one governance review per session.
- Before exiting, update `logs/<project-name>/transformation-log.md` with progress.
- On fresh start, read this file, then `logs/<project-name>/transformation-log.md` for the active target.

## Key Commands

```bash
# Start a session for this harness project
claude

# Start with a specific persona (for target project work)
claude --system-prompt-file templates/personas/analyst.md
claude --system-prompt-file templates/personas/architect.md
claude --system-prompt-file templates/personas/developer.md
claude --system-prompt-file templates/personas/reviewer.md
```

## Project Structure

```
.
├── CLAUDE.md                          # This file
├── README.md                          # Mission statement and evolution log
├── templates/
│   ├── personas/
│   │   ├── analyst.md                 # Requirements gathering persona
│   │   ├── architect.md               # Solution design persona
│   │   ├── developer.md               # Implementation persona
│   │   └── reviewer.md                # Code review persona
│   ├── project/
│   │   ├── CLAUDE.md.template         # Template for target project CLAUDE.md
│   │   └── agents.md.template         # Cross-tool agent config template
│   └── governance/
│       ├── assessment-checklist.md    # Evaluate a project's agentic readiness
│       └── review-criteria.md         # Quality rubric for agentic config files
├── docs/
│   ├── how-i-tamed-claude-ndc-london-2026.md
│   ├── raw transcript.txt
│   └── Screenshot 2026-02-15 at 15.17.33.png
└── logs/
    └── <project-name>/
        └── transformation-log.md      # Per-project transformation journal
```

## On First Contact With a New User Session

When Claude starts in this project, it should:

1. Greet the user and state the mission briefly.
2. Ask: "Which project would you like to transform, or would you like to work on the harness itself?"
3. If transforming a target project:
   a. Ask for the path to the target project.
   b. Read its top-level structure, README, and any existing agentic config.
   c. Run the assessment checklist (`templates/governance/assessment-checklist.md`).
   d. Present findings and propose a transformation plan.
   e. Proceed incrementally with user approval at each step.
4. If working on the harness itself:
   a. Ask what aspect to improve (templates, governance, docs, process).
   b. Work on it, commit when the user is satisfied.
