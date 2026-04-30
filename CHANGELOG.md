# Changelog

All notable changes to AEH (Agentic Engineering Harness) are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). This project does not yet use semantic versioning -- versions are sequential milestones (v0.1, v0.2, etc.) reflecting capability growth.

Target-project-specific work (prompts, deliverables, assessments, journal entries) is NOT tracked here. That work lives in `targets/<project>/` and is tracked per-project in `tasks.md` and `journal.md`.

---

## [Unreleased]

### Changed
- **README rewrite -- governance reframing + flexibility framing + essence over mechanism** (`README.md` 342 -> ~135 lines net). Repositions AEH from "Agentic Engineering Harness" to "Agentic Engineering Governance Harness" (G as clarifier, not a rename). Lead-in describes AEH as "a working starting point ... designed to be molded toward the specific practices of your team, department, or company." New top sections do the work: "Why a governance harness" (the problem AI agents create that this addresses, in plain prose), "What you get out of the box" (six default capabilities), "How you bend it" (six dimensions of amendability). Drops show-and-tell (no named downstream projects, no specific iteration counts) and drops implementation-mechanism trivia (no halt-sentinel names, no specific cadence numbers in body text, no extension-point section names, no overlay file paths in body, no wrapper internals). What junior engineers get excited about lives in the deeper docs; the README is for someone landing on the GitLab repo deciding within 60 seconds whether AEH is for them. Voice: PostgreSQL/ripgrep/Vault README, not marketing landing page.

### Added
- **ASCII-only output rule** (`CLAUDE.md` Working Rules section, new bullet after "No target project details in harness files") -- all generated content uses plain ASCII characters: response prose, markdown tables, prompt files, wrapper scripts, state files, commit messages, deliverables. No Greek letters, arrows, comparison glyphs, checkmarks, em/en dashes, ellipsis glyphs, smart quotes. Substitutions specified inline (`->` not Unicode arrow, `>=` not Unicode operator, `[x]`/`OK`/`PASS` not Unicode marks, `--` or `-` not Unicode dash, etc.). Reason: terminal and shell safety -- Unicode breaks in some terminal emulators, complicates `grep`/`sed`/`awk` pipelines, fragile under shell escaping, awkward in file names, gets mangled in copy-paste. Applies to all roles. Exception: do not ASCII-fy existing files unprompted; rule governs new content.
- **Orchestrator Mission Ownership doctrine** (`templates/personas/orchestrator.md` new §"Mission Ownership — Do Not Deflect", inserted after §"Role Boundaries — Do Not Cross") -- consolidates the operator/orchestrator authority boundary that was previously scattered across multiple sections. Codifies five ownership domains (pathfinding to the objective, task-list evolution, end-to-end prompt-output review, obstacle navigation, tooling/orchestration fabric including chain wrapper scripts). Names the **non-deflection rule** ("do, then report" as default; "ask, then do" only in enumerated cases) and provides explicit ALWAYS-ASK / DON'T-ASK lists for orchestrator actions. Adds a hard rule on **operational visibility** — every in-scope action surfaced in the response that follows it; silent state edits / file creates / script launches / commits are violations even when individually in-scope; operator stays in complete operational awareness without being required to micromanage. Lifted from real-world delivery where wrapper-script ownership (already present in §Multi-prompt chain orchestration as a narrow rule) was being deflected to the operator, surfacing the gap that the broader doctrine was implicit-only.
- **Persona marker Docker-awareness** (`bin/resolve-persona-marker.sh`) -- backward-compatible enhancement to the `.claude/persona` session-state convention. Resolver detects whether the session runs inside a Docker / container environment (via `/.dockerenv` or `/proc/*/cgroup` grep for `docker|containerd|lxc|kubepods`); if so AND `$HOSTNAME` is set to a non-trivial value, the marker resolves to `.claude/persona.$HOSTNAME` — giving each container its own marker when multiple AEH orchestrator sessions bind-mount the same harness directory. Otherwise falls back to `.claude/persona` unchanged (single-directory-no-Docker setups see no change). Includes opportunistic stale-marker cleanup: per-hostname markers untouched for >30 days are removed on each resolver call, so container-rebuild churn doesn't accumulate cruft. CLAUDE.md session-init + orchestrator persona Step 0 block updated to route through the helper. `.gitignore` extended to `.claude/persona.*` pattern.

### Changed
- **Harness-reviewer scope clarified vs AEH health-check** (`templates/personas/harness-reviewer.md` new "Scope clarification" section near top) -- explicit disambiguation between two review concerns that were running in parallel without a clean boundary. Harness Reviewer: reviews the generic harness layer (templates, personas, playbooks, governance) + surfaces lift candidates from target delivery. Health-check playbook: reviews a target project's AEH adoption depth (level, correctness, completeness, accuracy, tool health, coverage gaps per project phase). They share some signal sources but are not substitutes. Operators wanting to audit a target's adoption route to the health-check playbook; operators wanting to mature the generic harness invoke this persona. Resolves practical confusion surfaced during 2026-04-24 cross-project uplift work.
- **Orchestrator chain-launch authority formalised** (`templates/personas/orchestrator.md` §Multi-prompt Multi-role Chain Orchestration) -- orchestrator PROPOSES chain composition; operator AUTHORISES launch. Non-negotiable authority split. Autonomy is about the chain running without mid-chain operator interaction, NOT about the orchestrator launching multi-hour chains unilaterally. Proposal shape specified: scope + confidence rationale + halt conditions tuned for the chain + expected wall-clock + success-evidence description. Plus proactive-surfacing guidance (raise chain opportunities briefly in next-steps conversation, same cadence as writing the next prompt after a report) and trajectory-of-growth discipline (initial chains short + mechanically gated + high-confidence; grow chain ambition as per-project success data accumulates; skipping the confidence-building stage is an anti-pattern).

### Added
- **Orchestrator integration-verification gate between developer batch and reviewer** (`templates/personas/orchestrator.md` §Multi-prompt Multi-role Chain Orchestration → Integration-verification gate) -- distinct from both pre-flight readiness (pre-launch) and per-task mechanical gates (mid-chain). Fires AFTER a developer batch completes and BEFORE the reviewer prompt runs, arbitrating at real-integration level (real DB, real service wiring, real end-to-end test surface) that per-task unit tests intentionally mock away for speed. Shape: reset/provision clean environment → run real-integration suite → capture evidence → halt on failure (shortens feedback loop on integration bugs) or proceed to reviewer on pass. When-to-use / when-not-to-use criteria documented. Lifted from a second AEH project where this gate on first exercise caught 5 real integration bugs across two change-proposals that per-task unit tests had let through.
- **Orchestrator pre-dispatch hygiene gate** (`templates/personas/orchestrator.md` §Multi-prompt Multi-role Chain Orchestration → Pre-dispatch hygiene gate) -- cheap check the orchestrator runs BEFORE dispatching a prompt that opens a new forward change proposal. Verifies main-branch CI green, working tree clean, no unmerged long-running migrations blocking next CP's work. If red, halt CP dispatch and route to correction/cleanup first. Prevents cascading failure across CPs. Non-blocking waiver available when the forward CP is itself a CI-fix (operator override legitimate but audit-worthy). Lifted from a real AEH project delivery where skipping this check led to a CP dev batch diagnosing upstream issues rather than delivering its own scope.
- **Orchestrator PROMPT-COMPLETE sentinel requirement** (`templates/personas/orchestrator.md` §Generate Next Action → Report-Back discipline) -- every generated target-side prompt MUST end its Report Back section with `PROMPT COMPLETE — <identifier>` as the final line, after the wall-clock field. One line, canonical identifier matches prompt name. Load-bearing parse target for autonomous chain wrappers scanning session JSONL streams for clean-completion signal; without it, wrappers can't distinguish genuine completion from final-sounding text that didn't actually finish. Scope: all role-bound target-side prompts + interactive review prompts; orchestrator-session prompts and freestyle shell kickoffs skip the sentinel (not chain-consumed). The Wall-clock discipline subsection was renamed to Report-Back discipline to cover both conventions jointly. Lifted from informal usage across multiple AEH projects where the sentinel had become de-facto standard without being codified.
- **Harness-reviewer extended scan sources for lift-candidate surveillance** (`templates/personas/harness-reviewer.md` §Gather Evidence) -- when a harness-review's purpose includes surfacing lift candidates (patterns in a target project that belong in generic templates), the scan extends beyond harness templates + feedback memory to include: harness-side `targets/<slug>/decisions.md` and `targets/<slug>/review-history.md`, target-side `docs/AE/decisions.md`, `docs/AE/reports/`, and any existing `targets/<slug>/session-learning-report-*.md` artefacts. Many generic process rules live ONLY in these target-side files — they were decided during delivery, never promoted to a generic template. Scanning them surfaces lift candidates that feedback-memory + persona-template review alone misses. Instrumentation improvement flagged during a real harness-review pass.
- **Orchestrator multi-prompt multi-role chain orchestration** (`templates/personas/orchestrator.md` §Autonomous loop → Multi-prompt Multi-role Chain Orchestration) -- distinct from the single-prompt autonomous loop; covers proactive composition discipline for multi-prompt chains that string several prompts (potentially across multiple roles) into one autonomous wall-clock window. Names seven orchestrator responsibilities (identify / scope / pre-flight / guardrail / execute via wrapper / monitor / post-chain verdict); documents two proven chain shapes (same-role batch vs cross-role); enumerates chain-composition heuristics (when to chain, when not); catalogues halt conditions (non-zero exit, zero commits, reviewer ≠ PASS/WARN, CHAIN_HALT sentinel, mtime idle, wall-clock cap, scope-guard violation); preserves the orchestrator scope-guard that composition and monitoring are its lane, not engineering work. New `§CHAIN.PROJECT` extension point for project-specific wrapper scripts and halt sentinels. Lifted from real-world session-learnings driving autonomous chains that span hours of wall-clock with operator disengaged — done right, gives 8–15 hours of equivalent work per night; done wrong, amplifies failure across the same window.
- **Analyst two intake paths** (`templates/personas/analyst.md` §7b) -- distinguishes Path 1 (heavyweight operator-authored BA-REQ documents arriving at `docs/aeh-analyst-intake/` or equivalent, digested by the analyst with authority to reject / refine / decompose / defer / flag) from Path 2 (mid-session-surfaced horizontals emerging during analyst or architect sessions, captured in the session's orchestrator handoff and queued with an activation trigger; shaped from session context + candidate-consumer evidence when activated, no operator-authored BA-REQ expected). Names why the distinction matters — asking the operator to produce a BA-REQ for every mid-session horizontal is disproportionate. New `§7b.PROJECT` extension point for project-specific intake directory paths and filename conventions.
- **Reviewer visual-regression signal-quality ranking** (`templates/personas/reviewer.md` §2 Review Dimensions) -- new guidance for UI-heavy projects gating visual regressions. Ranks signal sources by reliability: (1) operator eyeball on screenshot pair — authoritative, slowest; (2) pixel-diff against baseline — high false-positive rate on colour/anti-aliasing shifts; (3) sentinel-SSIM on key regions — tighter than pixel-diff but catalogue-maintenance-sensitive; (4) DOM-skeleton diff — last resort, NOT reliable as arbitration (bundler artefacts like Vite `@import` merge produce large non-regression diffs). Gating rule: reviewers cannot issue PASS on DOM-skeleton diff alone; escalate to operator for visual confirmation. Flags three common anti-patterns (tests-pass-therefore-visual-OK, DOM-match-therefore-no-regression, elaborate-automation-before-signal-validation). Lifted from a real-world incident where an elaborate DOM-diff visual regression harness produced 38 "regressions" that were all Vite bundling noise.
- **Architect chain-safe task specification** (`templates/personas/architect.md` §4a) -- new section defining six mandatory conditions for tasks intended to feed an autonomous developer chain: (1) every task declares a mechanical completion signal (unit/integration test or testable CLI assertion, no UI-subjective gates), (2) test file paths named per task, (3) gates composable with the project's deterministic gate harness, (4) scope-bounded file-pattern allowlists per task, (5) per-task commit-message format declared with `[change:<slug>]` tag + task reference, (6) no latent UI dependencies in chain-bound tasks. `tasks.md` is structured as Section A (chain-safe backend) + Section B (operator-eyeball UI) with clear when-to-apply / when-NOT-to-apply guidance. Lifted to the generic architect template from a 2026-04 session-learning during real-world autonomous-chain launches, where the absence of this discipline at the architect phase propagated as noise into the dev chain. New `§4a.PROJECT` extension point for project-specific gate-harness details.
- **Orchestrator autonomous-chain pre-flight readiness check** (`templates/personas/orchestrator.md` §Autonomous loop) -- mandatory gate before any autonomous chain launch. Pre-flight verifies the chain's gate infrastructure actually executes the assertions `tasks.md` specifies, that synthetic state (fixtures, storage states, test DB seed, stub servers) is ready, and that chain halt conditions fire as designed (probe-and-revert pattern). Non-negotiable: skipping is a discipline failure. Time budget 5–15 min synchronous operator-in-loop. Halt trigger: if any pre-flight check fails, chain does NOT launch; correction prompt issued first. Lifted from a real-world incident where an autonomous chain ran 2.5h against a measurement harness that could not observe real application state — chain halted correctly but wall-clock was burned before the operator could intervene.
- **Orchestrator wall-clock discipline** (`templates/personas/orchestrator.md` §4 Generate Next Action) -- every generated prompt MUST include a wall-clock field in its Report Back section (`Wall-clock: <start ISO> → <end ISO> = <duration>`). Calibration data is lost without this. Additionally: estimates for interactive prompts (where operator must be in loop) distinguish *active interactive time* (quoted in estimates) from *elapsed wall-clock* (reported but not treated as calibration signal — it includes operator availability gaps). New calibration heuristic table covering analyst capture-mode, interactive question-review, deep-dive architecture-introduction, architect design, developer single-surface fix, developer scaffold, reviewer midpoint, reviewer boundary. Orchestrator re-calibrates against measured data from target report-backs rather than defaulting to human-time intuitions.
- **Architect commit-body minimum expectation** (`templates/personas/architect.md` §7) -- when landing multiple commits per proposal (typical pattern: design.md + tasks.md + specs/), each commit body must contain at least a one-paragraph summary distinct from the subject line. Per-commit-type body expectations defined (design.md summarises architectural approach; tasks.md summarises chain-safe count + UI-deferred count + migration-ordering; specs/ enumerates which baselines were delta'd and why). Prevents the subject-only / empty-body commits that degrade history readability even when §0.5 tag-traceability passes. Applies to any multi-commit landing, not just architect output.

- **Layered persona architecture** -- personas split into two files: base templates (`templates/personas/<role>.md`) with generic methodology and `§.PROJECT` extension points, and project overlays (`docs/AE/personas/<role>.md` in the target project) with project-specific configuration. Base templates use numbered sections (`§1`, `§2`, etc.) and named extension points (`§1.PROJECT`, `§HR.PROJECT`, `§ENV.PROJECT`). Overlays carry a Persona Header Block referencing their base template with explicit precedence rules. This separation allows methodology improvements to flow to all projects without rewriting overlays.
- **Archaeologist persona** (`templates/personas/archaeologist.md`) -- fifth engineering role that runs upstream of the Analyst → Architect → Developer → Reviewer loop. Investigates existing codebases and produces OpenSpec baseline specs (`status: baseline`) with `[verified]`/`[unverified]` tags on factual claims. Three-phase investigation methodology: structural mapping (parallel, fast), cross-referencing and judgment (parallel, capable), synthesis and verification (main context). Includes reconciliation mode for periodic re-verification.
- **Persona validation script** (`bin/validate-personas.sh`) -- checks base templates for AEH Base Template header, numbered sections, `.PROJECT` extension points, and project-specific content leakage. When given a target project path, also validates overlay files for Persona Header Block presence and base template references.
- **Autonomous loop capability** -- reviewer persona gains autonomous mode section: JSON verdict schema, deterministic gate execution before qualitative review, re-review protocol with iteration tracking and escalation to BLOCK after 3 persistent failures. Orchestrator persona gains autonomous loop mode: programmatic developer→gates→reviewer cycle, iteration tracking, escalation policy, batch execution commands, and monitor commands for reading loop state.
- **Loop driver template** (`templates/scripts/loop-driver.sh.template`) -- shell script template for the developer→gates→reviewer automation loop. Handles iteration caps, gate result parsing, reviewer verdict parsing, escalation, and state file management.
- **Orchestrator state schema extensions** -- orchestrator state template gains Active Loop State section (mode, iteration tracking, gate/reviewer results) and Escalation Policy section (iteration caps, gate failure rules, BLOCK handling, crash recovery).

### Changed
- **Architect §5 (Specification Document) re-framed as legacy fallback** -- prior content describing a flat `spec.md` with Overview / Architecture / Stack / Cross-Cutting / Implementation / Risks / Glossary sections was the pre-OpenSpec convention. §7 OpenSpec Integration is now authoritative (design.md + tasks.md + specs/ inside the change proposal directory). §5 retained as a minimal fallback for the rare pre-OpenSpec project, with explicit recommendation to adopt OpenSpec via the tools playbook before the project grows. Internal contradiction between §5 and §7 resolved.
- **README: codify the "proposal is the single instruction set" principle** -- the OpenSpec section gains an explicit articulation of the pivotal linkage that makes the AEH loop function: the analyst's `proposal.md` serves as both the architect's brief AND the reviewer's checklist, with acceptance criteria acting directly as the review checklist rather than living in a separate instructions doc. "The rigour of the proposal IS the quality of every downstream handoff." Previously implicit in persona methodology but never stated as the load-bearing principle it is.
- **Reviewer persona: enterprise-grade upgrade** -- six additions to the code reviewer base template, driven by real-world observation that reviews were being skipped and by research into agentic review best practices: (1) **Absence Check** dimension -- new dimension after Correctness that specifically checks for what's MISSING (error handling, input validation, auth, logging, resource cleanup) in new code, compensating for LLMs' structural blind spot of evaluating present code but not noticing absent code; (2) **Cross-Module Impact strengthened** from "proportional scan, non-blocking" to mandatory caller grep with broken callers as BLOCKING; (3) **Dependency Health** dimension -- verifies new imports resolve to real packages (anti-hallucination), checks for known CVEs, license compatibility, and necessity; (4) **Performance Anti-patterns** dimension -- systematised from web-only to all projects (N+1, unbounded collections, missing pagination, sync I/O in async, unnecessary materialisation); (5) **Evidence requirement** for all verdicts -- every PASS and FAIL must cite specific lines, grep results, or test output; dimensions without evidence are SKIPPED not PASS; this is the single strongest anti-rubber-stamp measure; (6) **Review Starting Point Rotation** -- reviewer varies entry point across reviews (tests, API, data layer, config, error paths) to prevent pattern-matching complacency, noted in report header.
- **Orchestrator: structural reviewer cadence enforcement** -- the orchestrator now has a hard, non-discretionary rule for reviewer scheduling: before generating any non-reviewer prompt, check `last_reviewed_task` vs `current_task` in the state file; if the gap >= 5 (Regime 1) or the task is last-in-phase (either regime), the next prompt MUST be a reviewer prompt with no exceptions. This replaces the previous implicit "generate a review when appropriate" approach that led to reviews being skipped. Additionally: (a) new Review Tracking section in the state file schema (`last_reviewed_task`, `review_cadence`, `reviews_completed`, `reviews_with_corrections`, `current_gap`); (b) phase exit prerequisite requiring reviewer PASS/WARN with corrections before sign-off; (c) review-debt proactive monitoring flag; (d) catch-up review enforcement if cadence was violated (e.g. due to context loss).
- **Orchestrator execution regimes** -- Operating Modes rewritten to define two explicit regimes: (1) Prompt-by-prompt (default, with reviewer pass every 5 tasks) and (2) Batch execution + phase-boundary review (self-chaining developer prompts per phase, reviewer batch pass at boundaries, correction prompts for HIGH findings before next phase). Both regimes include formal reviewer gates — the difference is granularity. Switchover prompt template at `templates/prompts/orchestrator-batch-regime.md`. Operator activates batch regime by saying "batch mode" or pasting the switchover template.
- **Orchestrator prompt verbosity calibration** -- new "Prompt Verbosity Calibration" subsection under §4 (Generate Next Action). Detailed prompts for phase starts, role switches, and complex prerequisites; lean prompts for mid-phase sequential tasks that reference `docs/AE/tasks.md` directly instead of the orchestrator paraphrasing the architect's spec. Prevents spec drift between orchestrator's understanding and the authoritative task file. Lean prompts retain persona loading, pre-flight, TDD, verify, commit, and report structure.
- **Orchestrator continuous improvement principle** -- new "Improve the templates, not just the memory" principle. When the orchestrator discovers a pattern that improves performance or efficiency, it must propose an update to the relevant AEH template for operator approval, not just save to local memory. Local memory is session-scoped; template improvements survive agent replacement.
- **Role-bound prompts now self-activate the role** -- orchestrator persona updated. Every handover prompt that invokes a persona begins with a "Step 0 — Activate the &lt;role&gt; role (self-contained)" block that writes `.claude/persona`, declares the session role-active, and loads the two persona files (base + overlay). The operator no longer needs to say `switch` or pick a role out of band; pasting the execute line is sufficient. Handoff protocol updated to drop the manual `switch` step and name the role inline instead. Freestyle/no-role prompts (harness setup) skip Step 0.
- **Orchestrator persona gains "Role Boundaries — Do Not Cross" section** -- explicit scope discipline preventing the orchestrator from slipping into analyst/architect/developer/reviewer work. Codifies that the orchestrator notes existence and routes target-project domain documents to the appropriate role rather than summarising, interpreting, or extracting content from them; that harness `open-questions.md` holds only harness-layer questions; and that domain/architectural content does not belong in harness artifacts. Includes a concrete "could this sentence be wrong in a way that requires domain knowledge to notice?" test and examples of content that fails/passes it. Added corresponding "Stay in manager lane" principle.
- **Onboarding playbook updated for layered personas** -- Phase 2 role mapping includes archaeologist. Phase 5 plan examples show overlay scaffolding instead of monolithic persona creation. Phase 6 §6a rewritten to describe layered persona convention: overlay header block format, `§.PROJECT` extension point population, five-role scaffolding, and merge-from-existing workflow. Phase 7 orchestrator tip mentions five-role model and two-file loading.
- **CLAUDE.md.template updated** -- role list expanded to 5 (added archaeologist), persona loading section rewritten for two-file convention (base template + project overlay with precedence rules), workflow section lists all five engineering roles.
- **Orchestrator persona updated** -- describes five-role model, layered persona loading convention with two-file instruction format in all handover prompts, Archaeologist invocation criteria (onboarding, major unspecified area, periodic reconciliation, operator request), project onboarding workflow (scaffold → boundaries → archaeologist → review → loop).
- **Harness reviewer updated** -- Dimension 4 (Template & Persona Consistency) gains layered persona checks: base template structure, extension points, no project-specific content, overlay header block validation, methodology duplication detection. References `bin/validate-personas.sh` for deterministic checking. Gains Archaeologist Baseline Specs sub-check.
- **Analyst persona updated** -- Multi-Agent Analysis section removed and replaced with Archaeologist cross-reference. Reverse-engineering mode removed (Archaeologist's responsibility). All four engineering base templates gain `§.PROJECT` extension points and base header notices.
- **Architect persona updated** -- §2 Technology Decisions marked as skippable when overlay provides `[SKIP]` with fixed constraints. Eight principles preserved including "write to workspace, not memory".
- **README.md rewritten** -- reflects five-role model, layered persona architecture, baseline specs, validation script, updated project structure tree, and current filesystem state.
- **CLAUDE.md project structure tree updated** -- adds `bin/validate-personas.sh`, `templates/personas/archaeologist.md`, `templates/scripts/`.

---

## [v0.7] - 2026-03-13 -- OpenSpec Integration & Role Maturity

OpenSpec becomes the recommended specification management layer with deep integration into all four personas. New orchestrator role manages prompt pipelines across sessions. Personas gain real-world hardening: scope escalation prevention, discovery logging, test coverage enforcement, database security checks. Sandbox environment provisioning enables MCP servers in Docker containers.

### Added
- **OpenSpec role integration** -- OpenSpec promoted from optional tool to recommended spec management layer, integrated into the four-persona workflow. Each persona template (`analyst.md`, `architect.md`, `developer.md`, `reviewer.md`) gains a "Spec Management" section handling both OpenSpec-present and OpenSpec-absent scenarios. Orchestrator gains "Spec-Aware Routing" for change-proposal-based pipeline tracking. CLAUDE.md template gains a "Specification Management" section above Key Files. Onboarding playbook Phase 6g offers OpenSpec setup with opt-out. Tools playbook presents OpenSpec as recommended-by-default. OpenSpec setup template enhanced with role integration table, example frontmatter, change proposal structure, and graceful degradation documentation. README updated to reflect OpenSpec as recommended specification management.
- **OpenSpec specification quality governance** -- governance layer now evaluates OpenSpec document quality, not just tool plumbing. Review criteria gains Section 3a (7 criteria for spec quality, conditional on `openspec/specs/` presence). Assessment checklist gains items 9.4-9.7 (frontmatter validity, staleness, abandoned proposals, testable acceptance criteria). Health-check gains Phase 3j (spec inventory, frontmatter audit, staleness detection, abandoned proposals, spec-code drift) with dedicated Spec Health table in delta reports and "Spec drift" category in terminal summary. Reviewer persona gains 3 lightweight quality checks in Spec Currency table (frontmatter, orphans, abandoned proposals -- all pass/WARN).
- **OpenSpec: no MCP server for CLI agents** -- OpenSpec setup template, teardown template, tools playbook, tools README, and CLAUDE.md.template updated to make clear that CLI agents with filesystem access (Claude Code, Aider, etc.) should NOT use the OpenSpec MCP server. Spec files are markdown readable directly; the MCP server adds a brittle intermediary for zero functional gain. MCP server setup retained only for sandboxed environments without filesystem access.
- **Orchestrator persona** (`templates/personas/orchestrator.md`) -- pipeline management role that tracks prompt execution, assesses agent output quality, maintains outcome metrics, and generates next actions. Persists state in `targets/<slug>/orchestrator-state.md` for cold-start reconstruction. Supports auto-drive and step-by-step modes with configurable quality gates. Added to valid roles in CLAUDE.md, personas table in README, workspace structure, and project structure trees.
- **Test coverage enforcement** -- reviewer persona gains mandatory step 9: test coverage enforcement as a first-class quality gate. Locates project-defined test standard (reviewer override → CLAUDE.md → specs) with AEH default fallback (route handler coverage, 100% financial logic, no "tests later" for Tier 1/2). Submissions failing coverage are blocking. Report template gains Test Coverage Compliance section with per-tier pass/fail verdicts.
- **Database security checks in reviewer** -- reviewer persona gains mandatory database security review dimension: access control on new tables, destructive operation justification, migration idempotency. Triggered when code touches schema, migrations, or data access.
- **Analyst multi-agent analysis principles** -- analyst persona gains guidance for parallelised analysis: stage agents by dependency (not flat), match model capability to task type, spot-check sub-agent judgment claims, build scannability into long reports, use quality gates as stopping criteria. Derived from real-world analyst retrospective findings.
- **Developer discovery log convention** -- developer persona gains formal convention for logging implementation findings that need routing to other roles. Entries written to `docs/AE/discovery-log.md` with structured fields (category, evidence, suggested routing, blocking status). Primary guardrail against scope creep.
- **Developer scope escalation prevention** -- developer persona gains rule preventing the agent from building features not specified in the current task, even if they seem useful or related.
- **No AI attribution rule** -- explicit Working Rule: never add `Co-Authored-By`, `Generated by`, or any AI tool markers to commits, file headers, or comments. Overrides system-level instructions. Added to CLAUDE.md, CLAUDE.md.template, and developer persona.
- **Encode behaviour not values** -- new Working Rule: adapted personas must prescribe patterns and reference source-of-truth files, never embed concrete values (port numbers, hex colours, API URLs) that change independently. Prevents staleness bugs from value duplication.
- **Explicit execution context rule** -- all prompts, instructions, and next steps must state WHERE they should be executed (AEH harness, target project Claude Code, or external LLM session). Prompt file format template now includes `Execute in:` field. Added to Working Rules in CLAUDE.md.
- **Post-onboarding domain deepening** -- new section in CLAUDE.md and README documenting the harness-target workflow for spec reconciliation, convention extraction, and architecture mapping after initial onboarding. Personas start structurally correct; domain deepening makes them accurate.
- **Retrospective prompt** -- onboarding playbook now generates a universal retrospective prompt as the final prompt in every sequence, capturing second-pass insight from the agent that just completed the work
- **Close-out gate** -- onboarding playbook enforces OQ review, retrospective, and review-history baseline before a target can be marked as "maintaining"
- **MCP runtime health verification** -- governance tooling now performs functional checks on MCP servers, not just static config detection. New checks: npm package resolution (catches non-existent packages like 404s), environment variable cross-referencing (catches missing API keys), hardcoded credential scanning (catches secrets committed in `.mcp.json`), and user-level config conflict detection (catches `~/.claude.json` shadows). Detection patterns in `templates/tools/tool-detection-patterns.md`, assessment checklist items 9.9-9.12, review criteria Section 5 verification method, and health-check Phase 3h functional verification with expanded tool health reporting table.
- **MCP functional smoke tests** -- tool detection patterns gain functional smoke test commands for each MCP server type (OpenSpec, Context7, Serena). Used by health check tool verification and reviewer tool health dimension.
- **Sandbox environment provisioning** -- new mechanism (`templates/tools/sandbox-env-provisioning.md`) for provisioning API keys and environment variables into Docker sandbox containers via `.env` files. Onboarding playbook step 6h generates `.env`/`.env.example` for MCP servers requiring API keys. Context7 setup template updated with `.env` flow.

### Changed
- **Consolidated AEH defaults** -- `_ai/` directory convention removed from templates in favour of `docs/AE/` as the standard location for todo, reports, and discovery log. Assessment checklist, CLAUDE.md template, and onboarding playbook updated.
- README workflow section rewritten as concrete two-session diagram with numbered steps
- README separates harness-internal roles (Orchestrator, Harness Reviewer) from target project personas

---

## [v0.6] - 2026-02-27 -- Governance & Permissions

Agent permission governance becomes a first-class subsystem: schema reference, detection patterns, recommended baselines, and mandatory review integration. Structural hygiene auditing catches agent-generated filesystem clutter. Harness Reviewer persona enables self-review of the harness itself.

### Added
- **Agent permission governance** -- new `templates/agents/` directory for agent-specific reference knowledge, starting with Claude Code
- `templates/agents/README.md` -- explains agents vs tools vs governance, lists known agents
- `templates/agents/claude-code/permissions.md` -- full schema reference, file precedence, rule syntax, anti-pattern catalogue (CRITICAL→LOW), remediation patterns
- `templates/agents/claude-code/permission-detection-patterns.md` -- glob/grep patterns for auditing permission configs (secrets, bypass mode, filesystem escape, sprawl, stale rules, harness isolation breach)
- `templates/agents/claude-code/permission-baselines.md` -- three recommended configs (solo/team/open-source) as embeddable JSON blocks with rationale
- Assessment checklist **Category 10: Agent Permission Governance** -- 9 items covering settings hygiene, secrets, deny lists, sprawl, filesystem scope, and file separation
- Review criteria **Rubric 6: Agent Permission Quality** -- 6 criteria with signs of good governance and common problems
- **Mandatory permission review in reviewer persona** -- every review pass must include a Permission Health section in `comments.md`, never silently skipped
- **Harness isolation check** -- CRITICAL detection pattern verifying target agent cannot read from the AEH harness directory (AP-04)
- **Review history file** (`targets/<project>/review-history.md`) -- append-only longitudinal findings log for pattern detection across assessments, always includes permission snapshot
- Health-check **Phase 3h: Permission Health Check** -- reads settings files, runs detection patterns, compares against baseline
- Health-check **permission drift** as delta report category with dedicated Permission Health section in report format
- Onboarding Phase 2b step 9: permission file detection in reconnaissance search strategy
- Onboarding Phase 2c: "Permissions" line in summary output format
- `CLAUDE.md.template`: Permission Governance section with settings file documentation, baseline reference, and maintenance rules
- **Structural hygiene audit** -- new assessment checklist items 8.9 (directory internal organisation) and 8.10 (agent-generated detritus detection). Reviewer persona gains mandatory "Structural Hygiene" review dimension (step 5) that catches filesystem clutter regardless of baseline. Health-check playbook gains step 3g: independent structural scan that applies fresh engineering judgment, not baseline comparison. Addresses the pattern where LLM agents create files prolifically and walk away.
- **Harness Reviewer persona** (`templates/personas/harness-reviewer.md`) -- dedicated self-review role for the harness itself, checking 7 dimensions: target detail leakage, prompt self-containment, documentation currency, template & persona consistency, isolation boundary integrity, governance completeness, and public-facing quality. Added to valid roles in CLAUDE.md, personas table in README, and project structure trees.
- **Target detail leakage enforcement** -- "no target details in harness files" rule added to Working Rules, covers git commit messages, references harness-reviewer as systematic enforcement mechanism
- **Git history cleaned** -- removed target-identifying details from commit messages and historical file content using git-filter-repo

### Changed
- Assessment checklist now has 10 categories (was 9)
- Review criteria now has 6 rubrics (was 5), plus "Agent permissions" row in Overall Assessment table
- Health-check remediation option 3 includes permission fixes
- Health-check Phase 5 references permission baselines for drift remediation
- Health-check phase completion appends to `review-history.md` (append-only longitudinal record)
- Onboarding Phase 3e workspace creation includes `review-history.md`
- CLAUDE.md project structure tree includes `templates/agents/` and `review-history.md`
- README project structure tree includes `templates/agents/`

### Fixed
- Removed slash prefix from natural language commands throughout templates (`/switch` → `switch`, `/health` → `health`). These are keyword triggers recognised from CLAUDE.md, not CLI slash commands.
- Orchestrator driving instructions now require role specification in every instruction
- Orchestrator role routing rule added for correct persona switching

---

## [v0.5] - 2026-02-20 -- Tool Integration & Open Source

### Added
- **AGPL-3.0 license** with `LICENSE-FAQ.md` clarifying that AEH output (personas, prompts, CLAUDE.md sections) belongs to the user and is unencumbered
- **CONTRIBUTING.md** -- prompt-first contribution model (submit the LLM prompt that produces the change, not just the diff), BDFL maintenance model, clear expectations for response times and scope
- Community infrastructure: Discord + GitLab Issues, sponsor links (GitHub Sponsors, Polar.sh)
- License badge in README
- **Post-transformation regression check** (`templates/prompts/regression-check.md.template`) -- verifies builds, import integrity, config path references, and runtime behaviour after structural transformations. Auto-generated as the final prompt in every onboarding sequence. Also triggered in health-check remediation when fix prompts move or rename files.
- `templates/prompts/` directory for reusable prompt templates
- Onboarding Phase 6d generates a regression check prompt adapted to the target project
- Health-check Phase 5 generates a regression check when remediation moves files
- **Tool integration system** for optional MCP server management (OpenSpec, Context7, Serena)
- `templates/tools/` directory with setup and teardown prompt templates for each tool
- `templates/tools/README.md` -- overview and design principles for the tool integration system
- `templates/tools/tool-detection-patterns.md` -- glob/grep patterns for detecting tools and functional equivalents
- `templates/tools/openspec-setup.md` / `openspec-teardown.md` -- OpenSpec MCP server configuration
- `templates/tools/context7-setup.md` / `context7-teardown.md` -- Context7 MCP server configuration
- `templates/tools/serena-setup.md` / `serena-teardown.md` -- Serena MCP server configuration
- `tools` playbook (`templates/playbooks/tools.md`) -- 5-phase workflow for tool detection, offering, setup/teardown, and recording
- Assessment checklist Category 8: "Project Layout & Naming Hygiene" -- directory structure, file naming, redundant/misplaced/obsolete files, documentation taxonomy
- Assessment checklist Category 9: "Development Tooling (Optional)" -- informational only, never penalises absence (renumbered from 8)
- Review criteria Rubric 5: "Tool Integration Quality (Optional)" -- scored only when tools are actively configured
- Health-check step 3g: Tool Health Check -- verifies configured tools are still present, documented, and consistent
- Health-check tool drift category in delta reports
- Onboarding Phase 2b: MCP and tool detection patterns in reconnaissance search strategy
- Onboarding Phase 6d: informational mention of `tools` after harness setup
- `CLAUDE.md.template`: optional "Development Tools" section with subsection templates for all three tools

### Fixed
- Session init now requires user confirmation before adopting a carried-over persona. Previously, a role persisted from the last session was adopted silently. Updated in harness CLAUDE.md and `CLAUDE.md.template`.

### Changed
- README expanded with Community, Supporting AEH, and License sections
- Onboarding Phase 2b detection targets table expanded with MCP, tool, and spec management rows
- Health-check Phase 4 delta report includes tool drift as a category
- Health-check Phase 5 remediation option 3 now includes tool repair
- CLAUDE.md playbooks table and role commands table include `tools`
- CLAUDE.md project structure tree updated with `templates/tools/` and `tools.md` playbook
- README updated with tool integration in features list, workflow diagram, project structure, and current status
- **Nested private repo for `targets/`** -- recommended setup for keeping private target workspaces versioned independently from the public harness repo
- CLAUDE.md documents dual-repo commit/push rules, detection, and proactive setup offering
- Onboarding Phase 3e offers nested repo setup during first workspace creation
- README documents the pattern under "Managing Target Workspace History"
- `docs/screenshots/` convention for transient human-Claude screenshot exchange (gitignored, timestamp-based)

### Removed
- `.gitlab-ci.yml` -- CI guard for target data leaks was non-functional without runners (GitLab Free tier). The `.gitignore` + nested repo structure provides sufficient protection.

---

## [v0.4] - 2026-02-17

### Added
- Strategist persona template (`templates/personas/strategist.md`) for upstream business/strategic decision support in external LLM sessions
- Maturity model in README (5 levels from assessment-only to strategic layer)
- "Who Is This For", "Quick Start", and "Current Status" sections in README
- CHANGELOG.md
- Harness Maintenance Discipline section in CLAUDE.md
- CLAUDE.md section ordering checks: assessment checklist item 2.8, review criteria "Section ordering" criterion, health-check step 3e, onboarding Phase 3b note
- Specialist prompt collection step in onboarding playbook (Phase 2d): asks users for domain-specific prompts they've been pasting manually, merges them into persona adaptations
- Domain expertise adaptation guidance in generic reviewer template, with worked example reference

### Changed
- README rewritten for public audience (cleaner structure, less internal jargon)
- Project abbreviated as AEH throughout public-facing docs
- Persona count updated from "four" to "four engineering + optional strategist" across CLAUDE.md, README, onboarding playbook
- Onboarding playbook Phase 7: light strategist mention in handoff
- `role info` output now includes strategist as optional external role
- `CLAUDE.md.template`: session init added as second section (after Project Overview), with note that section ordering matters

### Fixed
- `CLAUDE.md.template` had no session init section at all -- added it in the correct position (top of file)
- `targets/*/` now gitignored -- private project data no longer pushed to remote. Only `targets/index.md` (empty registry template) is tracked.
- Strategist template updated to two-document model: stable role definition + frequently-regenerated project knowledge briefing. Includes staleness guidance.

## [v0.3] - 2026-02-17

### Added
- Onboarding playbook (`templates/playbooks/onboarding.md`) -- 7-phase guided workflow with skip gates and re-onboarding detection
- Health-check playbook (`templates/playbooks/health-check.md`) -- recurring compliance checks with delta reports
- Assessment-implementation boundary in CLAUDE.md: onboarding never touches application code
- Merge-and-confirm rule for prompts that modify existing instruction files
- Session init and role selection (persona persistence, 3-line banner, `switch`, `role info`, `ignore role`)
- `onboard` and `health` natural language commands with playbook references

### Changed
- README updated with playbook workflow and new principles

## [v0.2] - 2026-02-15

### Added
- Two-Claude Model: harness reads and plans, target executes
- Target project isolation rule (hard boundary, one narrow exception for prompt delivery)
- `targets/` workspace structure with per-project directories
- `targets/index.md` as orientation entry point
- Prompt file format (self-contained, numbered, ordered)
- Five transformation phases: assessment, planning, implementing, reviewing, maintaining
- Direct prompt delivery policy (per-project opt-in)

### Changed
- Replaced `logs/` with `targets/` as canonical per-project state location

## [v0.1] - 2026-02-15

### Added
- Initial persona templates: Analyst, Architect, Developer, Reviewer
- Project templates: `CLAUDE.md.template`, `agents.md.template`
- Governance criteria: assessment checklist, review criteria
- Structured reference from "How I Tamed Claude" (NDC London 2026)
- CLAUDE.md with mission, working rules, and project structure
- README with problem statement, solution, and core principles
