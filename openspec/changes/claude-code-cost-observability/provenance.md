---
captured-at: 2026-06-15T16:51:08Z
captured-from: e7660dfe2ec1
captured-during: target orchestrator session, user-feedback relay
area: other
status: untriaged
---

# Cost / token observability for AEH workflows (claude-code agent-knowledge + attribution convention)

**Trigger:** A user running AEH (cloned from the public repo) asked how to monitor work efficiency -- tokens/cost per task type, "where does the money go" (e.g. a long-growing orchestrator context vs. a clean post-`/clear` in-target session that nonetheless ingests ~30 troubleshooting screenshots). Their own honest objection: cost telemetry is Claude-Code-specific, whereas AEH's core stays CLI-agent-agnostic.

**Insight:** AEH's existing layered architecture already resolves the agnosticism tension. Runtime-specific knowledge lives in `templates/agents/claude-code/` (e.g. `permissions.md`), walled off from the agnostic personas/playbooks. So cost observability is admissible as a `claude-code` agent-knowledge module -- only the MECHANISM is Claude-specific; the CONVENTION can stay agnostic. The deeper point: raw token counting is already solved (Claude Code's built-in `/cost`; the community tool `ccusage`), so AEH should NOT reinvent it. AEH's unique value is ATTRIBUTION: because work runs as discrete, numbered, role-tagged prompts in `/clear`-bounded sessions, one prompt approximates one session approximates one cost figure. AEH's own discipline is the instrumentation boundary; a freeform chat workflow has no such unit.

**Suggested change:**
- Add `templates/agents/claude-code/cost-observability.md`: where the JSONL transcripts live + the usage fields (`input`/`output`/`cache-read`/`cache-write`), the built-in `/cost`, `ccusage` as the recommended external roll-up (reference only -- `npx`, MIT), the model price model, and the Docker `~/.claude`-invisible caveat (Artifact Output Rule).
- Add an OPTIONAL per-prompt cost field to the orchestrator "Outcome Scorecard" in `orchestrator-state.md` (agnostic convention: capture whatever cost readout the agent provides; the "how to read it" is the claude-code doc). Attribution over measurement.
- Fold an agnostic EFFICIENCY-PRACTICE note into the relevant playbooks/personas: screenshot-heavy troubleshooting re-tokenises every image each turn until `/clear` (ingest-then-`/clear`, prefer text dumps, batch screenshots); long orchestrator contexts accumulate cache-read cost (reinforces the existing lean-session/handoff discipline -- the reason `orchestrator-state.md` exists is so a session can reset cheaply).

**Tooling decision (ccusage: REFERENCE + optionally compose, do NOT reimplement):** Reference `ccusage`; do not reimplement its parser/pricing. Reimplementation signs AEH up to chase Claude Code's internal JSONL schema + Anthropic's changing price tables forever -- the exact over-engineering the reviewer ethos rejects (it would rot within a model cycle). Two sanctioned paths: (a) zero-dependency = built-in `/cost` per session -> the scorecard convention (no external tool at all); (b) richer = `ccusage`, optionally consuming its `--json` output IF a thin `bin/` attribution wrapper is ever built (tag sessions to AEH prompt/role). Never vendor `ccusage` into the harness -- reference + optional compose only.

**Memory updates:** none superseded. Tensions to honour at triage: keep it OPT-IN and OUT of the agnostic core (no required step -- respects the AEH tool-agnostic principle); attribution cleanliness depends on the one-prompt-one-session discipline actually holding (sprawling sessions blur it); and the Docker `~/.claude` invisibility means any helper must run inside the volume-owning container.
