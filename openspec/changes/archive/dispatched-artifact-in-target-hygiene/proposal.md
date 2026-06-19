---
slug: dispatched-artifact-in-target-hygiene
status: archived
archived-at: 2026-06-19T18:48:01Z
since: 2026-06-19
sibling: claude-md-size-discipline
---

# Dispatched-artifact in-target hygiene: crisp role activation + resolvable target-facing paths

## What

Two fixes to the class "a harness artifact delivered/dispatched into a target session
must land cleanly." Both were observed watching real dispatched role-bound prompts
execute in a target; both are instances of the broader resolvable-pointer invariant
(every reference resolves from where it is read; the consumer that needs it loads it).
The CLAUDE.md-slimming side of that invariant lives in the sibling
`claude-md-size-discipline`; this proposal owns the dispatched-prompt and
target-facing-role-file sides.

1. **Crisp role-activation announcement (prompt-format).** A dispatched prompt's Step 0
   tells the agent to adopt a role and suppress the orientation banner, but nothing
   requires it to EMIT a single unambiguous activation line first. The operator,
   reading the target window, cannot tell what is running ("Role loaded" is not
   "ACTIVE ROLE: <role> -- loaded from <path>"). Make a first-line role-activation
   announcement REQUIRED: `ACTIVE ROLE: <role> -- loaded from <path>` (and on freestyle,
   `ACTIVE ROLE: none (freestyle)` -- explicitly, so "no role" is never ambiguous). One
   line, terminal-native, before any other work. Pair this POSITIVE confirmation with the
   existing "suppress the banner" rule.

2. **No dangling harness-only paths in target-facing role files.** The two single-file
   target-applied role files (`target-aeh-reviewer`, `target-aeh-engineer`) -- delivered
   into a target and loaded from `docs/AE/roles/` -- cite harness-only paths
   (`templates/...`, `bin/...`) that do not resolve in a target tree, without a
   target-side caveat. This is the same class the harness-reviewer Dimension-4
   "no harness-only path or script references in target-facing templates" check exists to
   catch, but the check did not cover `docs/AE/roles/` files. Sweep both role files and,
   for each harness-only path: snapshot the referenced artifact target-side, or annotate
   it "harness-side, not loadable from a target session." Extend the Dimension-4 check
   (and/or the deterministic overlay-header check) to cover `docs/AE/roles/` files so the
   class is caught mechanically.

## Why

During a dispatch, the FIRST thing the operator sees should be the active role, not a
contradictory interactive banner and waffle that omits the single load-bearing fact.
And a target-session reviewer driving a real flow (not a fully self-contained dispatched
prompt) hits dangling paths when its own role file points at harness-only locations --
the exact dead-reference failure the Dimension-4 check was created to prevent, slipping
through because the check's coverage did not include the role files delivered by the
target-applied-role delivery wiring. Both defects degrade the in-target experience of
the harness and both are mechanically preventable.

## Scope

In scope:
- **Role activation:** make the first-line `ACTIVE ROLE: ...` announcement required in the
  prompt-file format (`CLAUDE.md` "Prompt File Format"), the prompt templates, and the
  base/role personas' Step 0; include the explicit freestyle form.
- **Banner alignment for legacy targets:** ensure the "Dispatch-prompt invocation -- skip
  the banner entirely" rule (already in `templates/project/CLAUDE.md.template`) is part of
  what a legacy-target CLAUDE.md alignment retrofit applies, not just the role-location
  section; the banner's role list / "no active role" wording should acknowledge
  dispatch-loaded target-applied roles. (Coordinate the retrofit-scoping with the sibling
  proposal's whole-block-diff rule.)
- **Dangling paths:** sweep `templates/personas/target-aeh-reviewer.md` +
  `target-aeh-engineer.md` for harness-only path refs; snapshot-or-annotate each;
  specifically decide the health-check playbook reference (deliver target-side vs make the
  role self-contained) and the permission-baselines reference (snapshot the cited baseline
  target-side or inline the cited rules).
- **Check extension:** extend the harness-reviewer Dimension-4 path check (and/or the
  deterministic overlay-header check) to cover `docs/AE/roles/` files.
- CHANGELOG entry.

Out of scope:
- The CLAUDE.md router/size discipline and the whole-block-diff retrofit-scoping rule
  (sibling `claude-md-size-discipline`); this proposal only consumes the whole-block-diff
  rule when scoping the banner retrofit.
- Reworking the layered-persona delivery wiring itself (F1); this fixes the content the
  wiring delivers, not the wiring.

## Acceptance criteria

1. The prompt-file format + templates + base/role Step 0 require the first-line
   `ACTIVE ROLE: <role> -- loaded from <path>` announcement, with `ACTIVE ROLE: none
   (freestyle)` as the explicit freestyle form.
2. The legacy-target CLAUDE.md alignment path includes the banner-skip rule (not only the
   role-location section).
3. `target-aeh-reviewer.md` and `target-aeh-engineer.md` carry no harness-only path
   reference without a target-side snapshot or an explicit "harness-side, not loadable
   in-target" caveat.
4. The Dimension-4 / overlay-header check covers `docs/AE/roles/` files.
5. CHANGELOG entry; validator + publication gate pass; harness-reviewer bookend.

## References

- Sibling (same resolvable-pointer invariant, CLAUDE.md side): `claude-md-size-discipline`.
- The check this extends: `openspec/changes/base-template-layer-hygiene/` (Dimension-4
  layered-persona consistency) and the deterministic `overlay-header-target-side` check
  (B4 framework).
- The delivery wiring whose delivered content this fixes: F1.
- Provenance: two private intake captures (2026-06-19), surfaced watching dispatched
  role-bound prompts execute in a target and during target-aeh-reviewer post-uplift
  verification; sanitized at promotion.
