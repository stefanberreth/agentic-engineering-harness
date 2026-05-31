---
slug: harness-update-propagation-signal
---

# Design: Harness Update Propagation Signal

## Mechanism

### Marker

A `harness-sync-sha:` field in each target's `targets/<slug>/profile.md` (single 40-char SHA string). Reasons:

- `profile.md` is read at orchestrator session-init already; co-locating the marker means no new file to fetch.
- Operator already manages `profile.md` content during onboarding; field is documented in the existing schema.
- Easily inspectable, easily edited by hand if needed.

Field is mandatory for any target onboarded after this change. For pre-existing targets, the field starts absent; health-check flags absence; a one-shot retrofit prompt seeds the field with a sensible SHA (typically harness HEAD at the moment of retrofit, declaring "as of now this target is in sync").

### Detection (orchestrator persona session-init step)

Added to "Before You Start" after the existing `_intake/` scan step:

```
- Read targets/<slug>/profile.md for the harness-sync-sha field.
- If present, run:
    HARNESS_HEAD=$(git -C /workspace/aeh rev-parse HEAD)
    if [ "$HARNESS_HEAD" != "$harness_sync_sha" ]; then
        COUNT=$(git -C /workspace/aeh rev-list --count $harness_sync_sha..HEAD)
        CHANGELOG_DIFF=$(git -C /workspace/aeh diff $harness_sync_sha..HEAD -- CHANGELOG.md)
        # Surface in post-banner area:
        # "Harness has advanced N commits since last sync. Say 'review changes'
        #  to run a harness-reviewer pass that scopes local impact."
    fi
- If absent: surface "harness-sync-sha not set in profile.md -- seed via
  retrofit prompt to enable update detection going forward."
```

### Interpretation gate (harness-reviewer pass on `review changes`)

When the operator says `review changes` (or equivalent), the orchestrator:

1. Loads the harness-reviewer persona.
2. Hands it the commit range (`$harness_sync_sha..HEAD`) and the CHANGELOG diff for that range.
3. Harness-reviewer reads the diff (commit titles + CHANGELOG entries + targeted file inspections as needed) and produces a structured retrofit-action list:

```
Harness updates since <SHA-short>:

  Action 1: Refresh docs/AE/personas/_base/orchestrator.md
    Reason: orchestrator template gained "Harness Capture" section + 4-state vocab
    Effort: file copy + session restart to load new behaviour

  Action 2: Apply openspec close-out convention
    Reason: templates/tools/openspec-setup.md was updated to scaffold AGENTS.md + archive/
    Effort: run retrofit prompt at templates/prompts/openspec-close-out-retrofit.md.template
    Side-effect: unblocks any structurally-closed proposals waiting for the mechanical close-out

  Action 3: (no action) -- CLAUDE.md key-rules updates are harness-internal
    Reason: rule updates affect harness-orchestrator behaviour, not target-snapshotted files
    Effort: none; marker can advance past these commits without local work

Recommended order: Action 1 first (so session loads new persona), then Action 2.
```

4. Orchestrator presents the list to the operator. Operator decides per-action: apply / defer / skip.
5. Applied actions: marker bumps to the SHA covering the applied actions (typically harness HEAD if all are applied).
6. Deferred or skipped actions: marker bumps no further than the SHA before those actions; they remain visible on next session-init.

### Marker bump semantics

- Full sync (all retrofits applied or explicitly skipped): marker bumps to harness HEAD.
- Partial sync: marker bumps to the highest SHA where all preceding commits have been either applied or explicitly skipped by the operator.
- Conservative default: if the operator dismisses the prompt without explicit action, marker does not bump. The signal re-surfaces on next session-init.
- Manual override: operator can edit `profile.md` directly to set the marker to any SHA they want. This is a feature -- e.g. "I've reviewed everything, mark me as fully in-sync".

### Cross-container behaviour

- Each container's orchestrator session reads its OWN target's marker (per-target file under the target tree, which is also bind-mounted).
- Harness-session orchestrator can read all target markers (they're all under `targets/<slug>/profile.md`) and can surface a multi-target summary: "3 targets behind harness HEAD". Useful for fleet-level awareness.
- No cross-target coordination required. Each target advances independently.

## Alternatives considered

**A. Standalone marker file (`docs/AE/.harness-sync-sha`).** Rejected. `profile.md` already exists, is already read at session-init, and is a natural home for per-target metadata. A standalone file adds a file with no other content.

**B. Compare snapshot mtimes instead of using a marker.** Rejected. mtime is unreliable across containers, gets touched by unrelated edits, and provides no SHA-level precision for partial-sync semantics.

**C. Orchestrator interprets the CHANGELOG diff itself (no harness-reviewer pass).** Rejected per operator direction. The orchestrator-as-interpreter would bloat the persona with classification logic ("does this commit touch target snapshots?"). Harness-reviewer is the natural home for that judgment; it already operates on harness files and has the right skills.

**D. Auto-apply retrofits.** Rejected. Operator-gated discipline is the same as the capture inbox; consistency matters.

**E. Use a git tag on harness side per "snapshot release".** Rejected as over-ceremony for the current scale. SHAs are sufficient.

## Trade-offs

- **Marker file is per-target, manually seeded for existing targets.** Acceptable; one-shot retrofit prompt handles seeding cleanly. Pre-existing targets will surface "marker missing" until seeded.
- **Harness-reviewer scope expands slightly** to include the propagation-impact assessment mode. Adjacent to existing scope (review harness for quality/leakage/consistency); now also reviews harness *diffs* for downstream target implications. Acceptable extension; documented in the persona update.
- **Session-init does a `git -C /workspace/aeh rev-parse` and `rev-list --count`.** Negligible cost (~10ms). Falls back silently if /workspace/aeh path is not the harness (e.g. in non-standard container setups).
