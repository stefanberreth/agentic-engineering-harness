---
slug: claude-code-cost-observability
status: proposed
since: 2026-06-16
---

# Cost / token observability as opt-in claude-code agent-knowledge

## What

Add cost/token observability to AEH as runtime-specific knowledge walled inside `templates/agents/claude-code/`, plus an optional convention -- never a required step, never in the agnostic core:

- **`templates/agents/claude-code/cost-observability.md`** (new): where the JSONL transcripts live + the usage fields (`input` / `output` / `cache-read` / `cache-write`), the built-in `/cost`, `ccusage` as the recommended external roll-up (REFERENCE only -- `npx`, MIT; do not vendor, do not reimplement), the model price model, and the Docker `~/.claude`-invisible caveat (Artifact Output Rule: any cost helper must run inside the volume-owning container).
- **Optional per-prompt cost field** in the orchestrator "Outcome Scorecard" (`orchestrator-state.md`): an agnostic convention -- capture whatever cost readout the agent provides; the "how to read it" lives in the claude-code doc. Attribution over measurement.
- **Agnostic efficiency-practice note** folded into the relevant playbooks/personas: screenshot-heavy troubleshooting re-tokenises every image each turn until `/clear` (ingest-then-`/clear`, prefer text dumps, batch screenshots); long orchestrator contexts accumulate cache-read cost (reinforces the existing lean-session/handoff discipline -- the reason `orchestrator-state.md` exists is so a session can reset cheaply).

## Why

AEH users (cloning the public repo) ask how to monitor work efficiency -- tokens/cost per task type, "where does the money go." The honest tension: cost telemetry is Claude-Code-specific, whereas AEH's core stays CLI-agent-agnostic. AEH's existing layered architecture already resolves this: runtime-specific knowledge lives in `templates/agents/claude-code/` (e.g. `permissions.md`), walled off from the agnostic personas/playbooks. So cost observability is admissible -- only the MECHANISM is Claude-specific; the CONVENTION stays agnostic.

The deeper point: raw token counting is already solved (built-in `/cost`; the community `ccusage`), so AEH must NOT reinvent it -- that would sign AEH up to chase Claude Code's internal JSONL schema and Anthropic's price tables forever, the exact over-engineering the reviewer ethos rejects. AEH's unique value is ATTRIBUTION: because work runs as discrete, numbered, role-tagged prompts in `/clear`-bounded sessions, one prompt approximates one session approximates one cost figure. AEH's own discipline is the instrumentation boundary; a freeform chat workflow has none.

## Scope

In scope:

- `templates/agents/claude-code/cost-observability.md` (new doc, reference-not-reimplement).
- Optional cost field in the orchestrator Outcome Scorecard convention (clearly marked optional; agnostic capture).
- Agnostic efficiency-practice note in the relevant playbook(s)/persona(s).
- Wire the new doc into `templates/agents/README.md` and `templates/agents/claude-code/` index per the document-placement ground-truth discipline.
- CHANGELOG [Unreleased] entry.

Out of scope:

- Any required cost-tracking step (respects the tool-agnostic principle -- opt-in only).
- Vendoring or reimplementing `ccusage` (reference + optional compose only; never a parser/pricing copy).
- A `bin/` attribution wrapper around `ccusage --json`. Named as a future possibility in the doc, not built here.
- Any cost mechanism in the agnostic core personas/playbooks beyond the agnostic efficiency-practice note + the optional scorecard field.

## Acceptance criteria

1. `templates/agents/claude-code/cost-observability.md` exists, covers transcript location + usage fields + `/cost` + `ccusage` (reference, MIT, npx) + price model + Docker `~/.claude` caveat, and explicitly says do-not-reimplement / do-not-vendor.
2. The orchestrator Outcome Scorecard carries an OPTIONAL, clearly-marked cost field (agnostic capture; reading guidance points to the claude-code doc).
3. An agnostic efficiency-practice note (screenshot re-tokenisation; long-context cache-read; ingest-then-`/clear`) lands in the relevant playbook(s)/persona(s).
4. The new doc is wired into `templates/agents/README.md` (discoverable, not orphaned).
5. The agnostic core carries no REQUIRED cost step; opt-in throughout.
6. CHANGELOG [Unreleased] entry present.

## References

- Provenance: `provenance.md` (intake 2026-06-15-1651).
- Layering precedent: `templates/agents/claude-code/permissions.md` (runtime-specific knowledge walled off from agnostic core).
- Reinforces: lean-session/handoff discipline (`orchestrator-state.md` exists so sessions reset cheaply).
- Tooling stance: reference `ccusage` (MIT, npx), never vendor/reimplement.
