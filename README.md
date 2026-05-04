<p align="center">
  <img src="docs/Images/AEH-Round.png" alt="AEH" width="120">
</p>

# AEH -- Agentic Engineering Governance Harness

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2)](https://discord.gg/qnKVnJEuQz)
[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B)](https://ko-fi.com/stefanberreth)

## What is this?

AEH is a governance harness for software work driven by AI coding agents. It puts the work inside an engineering shape -- separated roles, spec-first changes, closed-loop quality gates, explicit handoffs -- so the work stays auditable, restartable, and amendable across sessions, days, and teammates.

It is for operators and teams whose work has to meet **mature, enterprise-grade SDLC needs, principles, and requirements**: review gates that are not bypassable, change records you can audit a year later, regression safety on a long-lived codebase, division of concerns across roles that actually do different things, the ability to pause and resume cleanly, and a pipeline that holds up to compliance scrutiny. None of this is unique to enterprise -- a serious open-source project, a pre-IPO platform, or a regulated startup all carry the same realities.

This is a different problem than what fast-prototype tooling solves. Lovable and similar single-shot or low-stakes builders give you a fast path from idea to a running thing -- valuable in their own right and optimised for speed of first artefact. "Prompt, magic, code, product, done" is the right shape for those situations; it is not the right shape when you are building software that has to be reviewed, regression-tested, audited, handed off, and operated under real-world stress for months or years. AEH targets the latter. Different problems, different categories; not in competition.

Currently developed with Claude Code; the persona templates work with any LLM-based coding agent.

## Why this exists

AI coding agents produce code at a rate human review does not naturally keep up with. Without structure, that work is hard to audit, hard to course-correct, and hard to hand off across people or sessions. AEH addresses that by giving the work an engineering shape -- the same separation of concerns that makes human teams effective. An analyst clarifies requirements, an architect chooses a design, a developer implements, a reviewer gates the result. Each role has its own focus and its own constraints, and the work moves through them in a way that leaves a clean trail behind it.

The outcome is that AI work becomes governable. You can stop it, resume it, audit it, hand it off, and trust that the parts you have not personally watched were nonetheless reviewed.

## Inner mechanics

The discipline AEH installs is an engineering pattern mature teams will recognise:

- **Spec-first.** Every change starts with a written proposal: requirements, scope, acceptance criteria. The proposal is the single instruction set for everything downstream -- it briefs the architect, anchors the developer, and is the reviewer's checklist. **The rigour of the proposal is the quality of every downstream handoff.** A vague proposal produces a sloppy review; a precise one produces decisive gating.
- **Specifications managed as artefacts.** AEH uses [OpenSpec](https://openspec.dev/) as the substrate -- specifications live as markdown files alongside code, change proposals are directories under version control, completed proposals archive into a dated history. No service to run; CLI agents read and write the files directly.
- **Closed-loop quality gating.** Each role's output is checked against the proposal before the next role takes it forward. The reviewer's spec-traceability check is structural, not advisory: code without a governing change proposal does not pass.
- **Test-driven implementation.** Developers write the test before the change, watch it fail, write the change, watch it pass. Standard TDD; AEH's contribution is enforcing that the test references the spec it validates.
- **Current library documentation, not training-data recall.** AEH bakes [context7](https://context7.com/) into the persona templates so agents check current API shape on fast-moving libraries instead of recalling stale training data.
- **Restartable persistent state.** Every persistent fact lives in committed files. Kill any session at any time; the next picks up cleanly. Switch machines, change models, take a break, come back.
- **Evolve-the-system.** When a review finds something critical, the correction adds a guardrail (a test surface, a reviewer check, a convention) so the same class of issue does not recur. Each fix tightens the system rather than just patching a symptom.

The shapes are not novel. What AEH brings is a known-good default arrangement of them, ready to drive a real change end-to-end on day one, that you mold to your team's specifics through project overlays.

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

Two sessions, two scopes. The harness session manages the pipeline (state, prompts, cadence, chain composition). Your project's own session executes the prompts and modifies the code. Most teams keep them separate because the separation gives a clean audit trail and predictable permission boundaries; some collapse them and that works too if the audit trail is not a priority. The default keeps them separate; the choice is yours.

## Operation modes

A spectrum, not a binary. Three named points along it:

- **Conversational.** You dialogue with any role mid-session for investigations, decisions, and document edits before anything commits. Useful for exploring a domain, debating a design choice, or refining a proposal interactively before dispatch.
- **Operator-paced.** You read each generated prompt, paste it into the role's session, watch the result, then decide the next move. The orchestrator drives the pipeline but the operator approves each step. Default for sensitive or first-of-its-kind work.
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

Onboarding is also where you mold the harness to your project. The persona overlays carry your team's conventions, your hard boundaries (security, regulatory, performance), and your domain knowledge. The base templates ship as a known-good default; the overlays are where the harness adapts to how you actually work.

## Required infrastructure

AEH governs the work; it does not isolate it. An agent running with permission to edit your code, run tests, push commits, and call external APIs is operationally serious. Run agents in dedicated, isolated, ephemeral development sandboxes (dev-containers, throwaway VMs, scoped Docker contexts) where the blast radius of an unexpected agent action is bounded.

This is not part of AEH. It is one of several control-in-depth layers AEH assumes you have independently. AEH provides governance, traceability, and review discipline; sandboxing provides the safety boundary; your CI/CD provides the deploy gate; your secrets management provides credential isolation. You want all of them.

## Quick start

```bash
git clone https://gitlab.com/stefanberreth/agentic-engineering-harness.git
cd agentic-engineering-harness
claude
```

Then say `onboard /path/to/your/project`. The harness reads your project, runs the assessment, produces the ranked report, generates a transformation plan, and scaffolds the agentic structure. The assessment is read-only; nothing in your project changes without your explicit consent.

## What AEH is not

- Not a framework or library -- no install, no dependencies, no build step
- Not language- or stack-specific -- base templates are project-agnostic; overlays carry the specifics
- Not an implementation tool -- it produces the configuration, documentation, and prompts that drive implementation
- Not Claude-exclusive -- currently developed with Claude Code; the persona templates work with any LLM-based coding agent
- Not a SaaS product -- open source, AGPL-3.0, side project

## Pointers to deeper docs

- `CLAUDE.md` -- harness session instructions
- `templates/personas/` -- base role templates
- `templates/governance/` -- assessment checklist + reviewer quality rubric
- `templates/playbooks/` -- onboarding, health, tool configuration
- `targets/index.md` -- registry of projects under AEH governance
- `docs/` -- reference material, talk transcript, deeper specs

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
