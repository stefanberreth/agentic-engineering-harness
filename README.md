<div align="center">
<img src="https://gitlab.com/stefanberreth/agentic-engineering-harness/-/raw/main/docs/Images/AEH-Round.png" alt="AEH" width="120">
</div>

# AEH -- Agentic Engineering Governance Harness

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2)](https://discord.gg/qnKVnJEuQz)
[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B)](https://ko-fi.com/stefanberreth)

## What is this?

AEH is a governance harness for software work driven by AI coding agents. It puts the work inside an engineering shape -- separated roles, spec-first changes, closed-loop quality gates, explicit handoffs -- so the work stays auditable, restartable, and amendable across sessions, days, and teammates.

<div align="center">
<img src="https://gitlab.com/stefanberreth/agentic-engineering-harness/-/raw/main/docs/Images/Screenshot%202026-05-04%20at%2015.04.37.png" alt="AEH role architecture: an operator works through the orchestrator, which routes work to analyst, architect, developer, and reviewer; the team produces specifications and code that compose the final product." width="780">
</div>

## Who is this for?

It is for operators and teams whose work has to meet **mature, enterprise-grade SDLC needs, principles, and requirements**: review gates that are not bypassable, change records you can audit a year later, regression safety on a long-lived codebase, division of concerns across roles that actually do different things, and the ability to pause and resume cleanly.

This is a different problem than what democratised AI app builders solve. That category -- single-shot AI tools that produce a working app from a prompt -- gives you a rapid path from idea to a running thing, accessible to non-engineers, and is the right shape when speed of first artefact is what matters. It is not the right shape when you are building software that has to be reviewed, regression-tested, audited, handed off across teammates, and operated under real-world stress for months or years. To anyone who has shipped serious software in a team, the difference is obvious. To anyone being told that AI magic now means you can fire your engineering function, it may need spelling out: the two are not the same job.

Currently developed with Claude Code; the persona templates work with any LLM-based coding agent.

## What AEH is not

- Not a framework or library -- no install, no dependencies, no build step
- Not language- or stack-specific -- base templates are project-agnostic; overlays carry the specifics
- Not an implementation tool -- it produces the configuration, documentation, and prompts that drive implementation
- Not Claude-exclusive -- currently developed with Claude Code; the persona templates work with any LLM-based coding agent
- Not a SaaS product -- open source, AGPL-3.0, side project

## Why this exists

AI coding agents produce code at a rate human review does not naturally keep up with. Without structure, that work is hard to audit, hard to course-correct, and hard to hand off across people or sessions. AEH addresses that by giving the work an engineering shape -- the same separation of concerns that makes human teams effective. An analyst clarifies requirements, an architect chooses a design, a developer implements, a reviewer gates the result. Each role has its own focus and its own constraints, and the work moves through them in a way that produces the complete documentation of a specification-first-driven software project reliably and consistently.

The outcome is that AI work becomes governable. You can stop it, resume it, audit it, hand it off, and trust that the parts you have not personally watched were nonetheless reviewed.

<div align="center">
<img src="https://gitlab.com/stefanberreth/agentic-engineering-harness/-/raw/main/docs/Images/Screenshot%202026-05-04%20at%2015.12.55.png" alt="End-to-end flow: an operator drives the agentic engineering harness, which produces source changes that flow through GitLab (revision control and CI/CD) into deployment and documentation publishing, ending in a live product and a stakeholder-readable docs portal." width="780">
</div>

## Inner mechanics

The discipline AEH installs is an engineering pattern experienced teams will recognise:

- **Spec-first.** Every change starts with a written proposal: requirements, scope, acceptance criteria. The proposal is the single instruction set for everything downstream -- it briefs the architect, anchors the developer, and is the reviewer's checklist.
- **Specifications managed as artefacts.** AEH uses [OpenSpec](https://openspec.dev/) as the substrate -- specifications live as markdown files alongside code, change proposals are directories under version control, completed proposals archive into a dated history. No service to run; CLI agents read and write the files directly.
- **Closed-loop quality gating.** Each role's output is checked against the proposal before the next role takes it forward. The reviewer's spec-traceability check is structural, not advisory: code without a governing change proposal does not pass.
- **Test-driven implementation.** Developers write the test before the change, watch it fail, write the change, watch it pass. Standard TDD; AEH's contribution is enforcing that the test references the spec it validates.
- **Current library documentation, not training-data recall.** AEH bakes [context7](https://context7.com/) into the persona templates so agents check current API shape on fast-moving libraries instead of recalling stale training data.
- **Restartable persistent state.** Every persistent fact lives in committed files. Kill any session at any time; the next picks up cleanly. Switch machines, change models, take a break, come back.
- **Evolve-the-system.** When a review finds something critical, the correction adds a guardrail (a test surface, a reviewer check, a convention) so the same class of issue does not recur. Each fix tightens the system rather than just patching a symptom.

AEH ships a known-good default arrangement of these patterns, ready to drive a real change end-to-end on day one, molded to your team's specifics through project overlays.

**On the relationship to Jira and agile workflows.** OpenSpec terminology overlaps cleanly with what most teams already use: a change proposal maps to an epic, the tasks file maps to subtasks, the change slug maps to the ticket id, the reviewer's PASS / WARN / FAIL / BLOCK maps to workflow transitions, and the archive directory maps to the "done" status. What OpenSpec does not do, and is not trying to: sprint planning, velocity tracking, stakeholder visibility for non-engineers, time tracking, cross-team dependency coordination. Those remain Jira's strengths. The reason filesystem-and-version-control suits an agentic-coding-dominant workflow is that agents read and write the spec directly, with no API auth surface inside the agent runtime, and the spec diffs alongside the code in the same PR. If you bring Jira in, the natural integration points are: use the Jira ticket id as the change slug, sync at proposal-open and archive-close, optionally mirror verdicts to workflow transitions. Critically, integrating Jira does not mechanically change the AEH workflow -- proposal.md remains the single instruction set, agents still read it from disk, and the Jira layer is metadata for stakeholder visibility, not a source-of-truth migration.

## The roles

AEH defines five engineering roles plus three coordinating ones. Each role is a methodology template -- a set of instructions an agent loads to take that role for a session. Each role has a generic base template (ships with AEH) plus a project-specific overlay (lives in your project, encodes your conventions, hard boundaries, and domain knowledge). The base is a working default; the overlay is where the harness becomes yours.

| Role | Scope | Key discipline |
|---|---|---|
| **Archaeologist** | Investigates an existing codebase; produces verified baseline specifications. Runs upstream of the main loop on brownfield projects. | Documents what exists, not what should exist. Tags claims as verified or unverified. |
| **Analyst** | Gathers requirements; writes change proposals with acceptance criteria. | The proposal is the single instruction set for the change; primary output is always a specification artefact. |
| **Architect** | Designs the solution; breaks it into ordered tasks; verifies library APIs against current documentation before writing examples. | Design and tasks live inside the change proposal; tasks are the developer's authoritative source. |
| **Developer** | Test-driven implementation against the architect's tasks. | No code without a governing spec. Spec references in tests. Change-slug references in commits. |
| **Reviewer** | Quality gate against proposal + design + spec deltas. | Spec traceability check is blocking and runs first; missing spec is automatic FAIL. Evidence required for every verdict. |

The coordinating roles:

| Role | Where it runs | Job |
|---|---|---|
| **Orchestrator** | In the harness session | Team manager. Picks who runs next, holds the reviewer cadence, refuses to dispatch out-of-spec work, owns chain composition, tracks state across sessions. |
| **Strategist** | In any LLM chat (browser is fine; not necessarily a coding-agent runtime) | Optional external strategic advisor; runs higher-level conversations on priorities and direction without needing project-code access. |
| **Harness Reviewer** | In the harness session | Self-review of AEH itself across review dimensions (template consistency, isolation boundary, leak detection); separate from project-level reviewing. |

The standard engineering loop is **Analyst -> Architect -> Developer -> Reviewer**, with the Archaeologist running upstream on existing codebases and the Strategist available externally when you want a higher-level conversation. Each prompt names its role and its governing spec. Each role's report carries a verdict -- **PASS / WARN / FAIL / BLOCK** -- with evidence, written to files. The Orchestrator reads the report, decides the next move (advance to the next role, generate a correction prompt, escalate to the operator), and writes the next prompt. Verdicts and reasoning are auditable after the fact because the reports and decisions are committed alongside the code they govern. Humans can review, other agents can review, future sessions can replay. Nothing important is in chat alone.

<div align="center">
<img src="https://gitlab.com/stefanberreth/agentic-engineering-harness/-/raw/main/docs/Images/Screenshot%202026-05-04%20at%2015.04.52.png" alt="The prompt-execution loop: the orchestrator issues a mandate, the agent executes against the workspace (text, code, files), returns a report, and the orchestrator decides whether to correct and iterate or advance." width="720">
</div>

Two sessions, two scopes. The harness session manages the pipeline (state, prompts, cadence, chain composition). Your project's own session executes the prompts and modifies the code. Most teams keep them separate for the audit trail and predictable permission boundaries; collapsing them works too where the audit trail is not a priority. The default keeps them separate.

## Operation modes

Three modes along a spectrum:

- **Conversational.** You dialogue with any role mid-session for investigations, decisions, and document edits before anything commits. Useful for exploring a domain, debating a design choice, or refining a proposal interactively before dispatch.
- **Operator-paced.** You read each generated prompt, paste it into the role's session, watch the result, then decide the next move. This is where review happens -- you can dialogue with the role on the prompt before pasting, edit the prompt file directly, or amend it after a partial run. The orchestrator drives the pipeline but the operator approves and shapes each step. Default for sensitive or first-of-its-kind work.
- **Autonomous chained.** A wrapper invokes prompts back-to-back with halt conditions. You step away. The chain handles implementation, test runs, and end-to-end browser-based testing where the project requires it. On clean completion you get a morning-readable summary; on halt the wrapper writes a diagnostic the orchestrator picks up next session. Default for established patterns where the discipline is proven.

The choice is per-change, per-phase, per-project. Mix freely.

## Onboarding modes

Two starting points, same destination.

**Greenfield.** AEH installs the agentic structure before the first commit. The project never knows life without governance. Skip the assessment and the baseline-spec extraction; jump from scaffolding into steady-state operation.

**Brownfield.** AEH reads what your existing project has, runs an assessment across multiple categories, produces a ranked report (CRITICAL / HIGH / MEDIUM / LOW), and scaffolds the agentic structure without modifying code. An optional Archaeologist pass extracts baseline specifications from the existing implementation so subsequent work has verified ground truth to build against.

Either way, the on-ramp is incremental. You can pause between any two stages while other work intervenes:

| On-ramp | What you do | Effort |
|---|---|---|
| Assessment | Read-only audit of an existing project; ranked report | 15 min |
| Scaffolding | Set up role overlays + spec substrate | 1 session |
| Catch-up loop | Address what assessment surfaced via the reviewer-implementer cycle | 1-2 sessions |
| Domain deepening | Extract baseline specs + tune roles to your domain (skip on greenfield) | 1 session |
| Steady state | Every change flows through the pipeline | Ongoing |

Onboarding is where you lay the foundation and start molding the harness to your project. The persona overlays carry your team's conventions, your hard boundaries (security, regulatory, performance), and your domain knowledge. The base templates ship as a known-good default; the overlays are where the harness adapts to how you actually work.

## Required infrastructure

AEH governs the work, and while it adds instruction guardrails into the persona definitions to keep every agentic role inside their lane, it does not protect you from your AI taking rogue actions that are within reach of your coding agent and can cause harm. It is your job to create a safe agentic coding environment. If you are a seasoned technologist, you will know exactly what this means. If you kinda know but don't have the muscle memory to set up a safe development environment, ask your AI to help you, or ask a human who does know and is willing to help. Briefly: if you get what the following means, do it first; if not, find help to guide you.

An agent running with permission to edit your code, run tests, push commits, and call external APIs is operationally serious. Run agents in dedicated, isolated, ephemeral development sandboxes (dev-containers, throwaway VMs, scoped Docker contexts) where the blast radius of an unexpected agent action is bounded.

This is not part of AEH. It is one of several control-in-depth layers AEH assumes you have independently. AEH provides governance, traceability, and review discipline; sandboxing provides the safety boundary; your CI/CD provides the deploy gate; your secrets management provides credential isolation. You want all of them.

## Prerequisites

You need those to be in place or at hand before getting started:

- **A coding-agent runtime.** Claude Code (or an equivalent LLM coding-agent CLI) installed and authenticated.
- **Source-control access.** Git installed locally; access credentials for your remote -- GitHub, GitLab, Bitbucket, or self-hosted -- via SSH key or personal access token, depending on your setup.
- **A context7 API key.** Register at [context7.com](https://context7.com/) and have the key available for AEH to wire into the agent's MCP configuration during onboarding. Free tier is sufficient for most projects.
- **OpenSpec.** No key required. AEH scaffolds the directory structure during onboarding; OpenSpec is filesystem-only.
- **Optional, project-specific.** Database access, deploy targets, secret stores, ticketing systems -- these live in your project's normal environment, not in AEH onboarding.

A deeper environment-setup and first-onboarding guide is on the roadmap; for now this list is the orientation.

## Quick start

```bash
git clone https://gitlab.com/stefanberreth/agentic-engineering-harness.git
cd agentic-engineering-harness
claude
```

Then say `onboard /path/to/your/project`. The harness reads your project, runs the assessment, produces the ranked report, generates a transformation plan, and scaffolds the agentic structure. The assessment is read-only; nothing in your project changes without your explicit consent.

## Where things live

### In your project (after AEH onboarding)

- `CLAUDE.md` -- Claude-Code-specific instructions for your project's session
- `AGENTS.md` -- cross-tool agent config (read by other coding-agent runtimes too)
- `docs/AE/personas/<role>.md` -- your project-specific overlays for each role; encode conventions, hard boundaries, domain knowledge
- `docs/AE/prompts/` -- the handover point: AEH writes prompts here, your project's session reads and executes them
- `docs/AE/reports/` -- target-side reports (verdicts, halt reports, retrospectives)
- `docs/AE/reviews/` -- reviewer outputs
- `openspec/project.md` -- project conventions (slug naming, status vocabulary)
- `openspec/specs/baseline-*.md` -- verified ground truth from the Archaeologist
- `openspec/specs/<id>.md` -- stable specs (archived from completed change proposals)
- `openspec/changes/<slug>/` -- active change proposals (proposal.md, design.md, tasks.md, specs/)
- `openspec/changes/archive/<YYYY-MM>/<slug>/` -- completed change proposals, dated history

### In this harness repo

- `CLAUDE.md` -- harness session instructions
- `templates/personas/` -- base role templates (engineering + coordinating)
- `templates/governance/` -- assessment checklist + reviewer quality rubric
- `templates/playbooks/` -- onboarding, health, tool configuration
- `targets/index.md` -- registry of projects under AEH governance
- `docs/` -- reference material, talk transcript, deeper specs

## Documentation portal (optional but recommended)

The structured markdown AEH produces -- change proposals, design docs, reports, reviews, ADRs, persona overlays, baseline specifications -- is naturally suited to a static documentation portal. The recommended setup uses [MkDocs](https://www.mkdocs.org/) with the [Material theme](https://squidfunk.github.io/mkdocs-material/), built on every push and published via your project's CI/CD pipeline.

What you get: a navigable, searchable, stakeholder-readable portal of the project's specifications, design decisions, review history, and policy documents -- generated from the same files agents read and write during normal work. No duplication of effort; the portal is a rendered view of the source-of-truth files in the repo.

What it requires:

- Python 3.x with `mkdocs` and `mkdocs-material` (`pip install mkdocs mkdocs-material`)
- An `mkdocs.yml` configuration at the repo root, with the navigation tree mapped to your `docs/` and `openspec/` directories
- A CI/CD job that runs `mkdocs build` on every push to main and publishes the output to your hosting target
- Optional: plugins for mermaid diagrams, broken-link checking, and a build-time mirror of `openspec/specs/` and `openspec/changes/archive/` into `docs/` so the portal renders specifications and historical change proposals alongside the rest of the docs tree

Where it becomes available:

- **GitLab Pages**: `https://<group>.gitlab.io/<project>/` once the CI job's `pages` artifact lands. Custom domain via DNS CNAME.
- **GitHub Pages**: `https://<user>.github.io/<project>/` via a GitHub Actions workflow that builds and publishes.
- **Self-hosted**: any static-site host (S3 + CloudFront, Netlify, Cloudflare Pages, your own nginx) -- `mkdocs build` produces a `site/` directory of plain HTML.

This is not part of AEH itself; AEH does not currently scaffold the MkDocs setup. It is the recommended publishing layer on top of the structured documentation AEH already produces -- a practical way to give stakeholders, future engineers, and review participants a polished view of "what does this project look like as a system" without spelunking through git.

## Inspiration

Inspired by [Emmz Rendle's "How I Tamed Claude" (NDC London 2026)](https://www.youtube.com/watch?v=pey9u_ANXZM).

## Community

- **Discord:** [Join](https://discord.gg/qnKVnJEuQz)
- **GitLab Issues:** [Report bugs / request features](https://gitlab.com/stefanberreth/agentic-engineering-harness/-/issues)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md) -- prompts preferred over patches

## Supporting AEH

AEH is free, AGPL-3.0, maintained by one person. If it saves you time:

- **[Support on Ko-fi](https://ko-fi.com/stefanberreth)**
- **Star the repo**

For organisations wanting to embed AEH in proprietary tooling or host it as a service without AGPL obligations, a commercial license is available -- contact Stefan Berreth.

## License

AGPL-3.0. See [LICENSE](LICENSE) and [LICENSE-FAQ.md](LICENSE-FAQ.md). Generated outputs (personas, prompts, CLAUDE.md sections) belong to you under any license you choose. AGPL applies only to modifications of AEH itself if you offer them as a public service or distribute them externally.

---

Stefan Berreth -- [gitlab.com/stefanberreth/agentic-engineering-harness](https://gitlab.com/stefanberreth/agentic-engineering-harness)
