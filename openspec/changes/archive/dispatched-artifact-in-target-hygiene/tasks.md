# Tasks: dispatched-artifact-in-target-hygiene

Ordered; each task carries a mechanical completion signal.

1. **Required role-activation announcement.** Add to `CLAUDE.md` "Prompt File Format",
   the dispatched-prompt templates, and the base/role personas' Step 0: emit
   `ACTIVE ROLE: <role> -- loaded from <path>` as the first output line (freestyle:
   `ACTIVE ROLE: none (freestyle)`), before any other work; pair with the existing
   suppress-the-banner rule.
   - Signal: prompt-file format + a dispatched-prompt template + a base persona Step 0
     all carry the required first-line announcement and the explicit freestyle form.

2. **Legacy-target banner-skip in the alignment path.** Ensure the "Dispatch-prompt
   invocation -- skip the banner entirely" rule is part of the legacy-target CLAUDE.md
   alignment retrofit (not only the role-location section); banner role list / "no active
   role" wording acknowledges dispatch-loaded target-applied roles. Scope the retrofit as
   a whole-block diff per the sibling proposal's rule.
   - Signal: the retrofit/refresh path references the banner-skip rule; the target
     CLAUDE.md template banner wording acknowledges target-applied roles.

3. **Sweep target-applied role files for dangling paths.** In
   `templates/personas/target-aeh-reviewer.md` + `target-aeh-engineer.md`, for each
   harness-only path (`templates/...`, `bin/...`): snapshot the artifact target-side or
   annotate "harness-side, not loadable in-target." Decide the health-check-playbook and
   permission-baselines references explicitly.
   - Signal: grep of both files for `templates/` and `bin/` shows every hit either
     rewritten to a target-side path or carrying the explicit caveat.

4. **Extend the path-resolution check to docs/AE/roles/.** Extend the harness-reviewer
   Dimension-4 path check (and/or the deterministic `overlay-header-target-side` check)
   to cover `docs/AE/roles/` files.
   - Signal: the check's scope statement includes `docs/AE/roles/`; a fixture role file
     with a bare harness path FAILs.

5. **CHANGELOG + gate.** [Unreleased] entry; `bin/validate-personas.sh --staged` and
   `--message` pass; harness-reviewer bookend before push.
   - Signal: validator exits 0; reviewer PASS/WARN; single commit; no push.
