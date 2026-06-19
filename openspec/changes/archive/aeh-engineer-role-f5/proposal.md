---
slug: aeh-engineer-role-f5
status: archived
archived-at: 2026-06-19T18:47:51Z
since: 2026-06-19
parent: aeh-engineer-role
build-step: F5
---

# F5: permission-config compliance reporting + approved-fix + ground-truth validation

> Operator-ratified follow-on (new in the F-series run prompt). B6 deferred the
> permission-compliance report along with the airtight negation-based lockdown.
> F5 splits those: the compliance REPORT is built in now (report -> operator-approve
> -> fix -> revalidate, split by which tree the config lives in); only the airtight
> lockdown EXPRESSION stays deferred.

## What

Two compliance loops, split by which tree the offending config lives in. BOTH are
report-by-default, offer-fix-after-operator-approval, then
validate-against-measured-ground-truth (the check that detected is the check that
confirms).

1. **Target's own config** (`<target>/.claude/settings.json` + `.local`):
   - Add a `permission-scope` check to `bin/aeh-practice-check.sh` (deterministic
     cases: bypass mode, whole-filesystem-escape allow `Read/Edit/Write(/**|/)`,
     secret literal in a rule, missing non-empty deny list for an AEH-managed
     target). Judgment cases (sprawl) stay the reviewer's narrative.
   - `target-aeh-reviewer` REPORTS the finding + the exact rule change needed
     (read-only; cites `permission-baselines.md`). On operator approval,
     `target-aeh-engineer` APPLIES it in the target; then RE-RUN `permission-scope`
     to validate the config now passes.
2. **AEH-side grant** (this harness project's `.claude/settings.json` scoping the
   `target-orchestrator` to `docs/AE/**`):
   - Add an AEH-side-grant-compliance dimension to `harness-reviewer` (Dimension 5,
     Isolation Boundary Integrity): it reads the harness config directly (a harness
     file is its subject) and reports whether the grant is `docs/AE/`-scoped + any
     change needed. `target-aeh-reviewer` contributes only target-side SYMPTOM
     evidence (AEH-side-authored commits/markers outside `docs/AE/`). On approval,
     `aeh-engineer` fixes the harness config; then re-run to validate.
3. Wire the report/approve/fix/validate loop explicitly in the four roles
   (`target-aeh-reviewer`, `target-aeh-engineer`, `harness-reviewer`,
   `aeh-engineer`); detect-then-route-by-file-location already governs WHO fixes
   WHICH tree.
4. Update the B6 design-call note in `permission-baselines.md`: the compliance
   REPORT is built in (not deferred); only the airtight negation-based lockdown
   stays deferred.

## Why

B6 shipped the AEH-side fence allowlist but deferred ALL of the compliance
machinery (report + airtight lockdown) to "the permission-schema / repo-owner
conversation." But the REPORT half needs no schema change -- a deterministic check
plus reviewer reporting plus an approved-fix-then-revalidate loop is buildable now
and gives real enforcement. Only the airtight negation-based EXPRESSION genuinely
needs the deferred conversation. F5 separates the two so adopters get permission
compliance immediately instead of waiting on the lockdown.

## Decisions made (for operator ratification)

1. **`permission-scope` is grep-based, conservative, deterministic-only.** It runs
   in a target in pure bash (the check framework is portable), greps the raw
   settings JSON for the four deterministic violation shapes, and deliberately
   excludes judgment cases (sprawl) -- those stay the reviewer's narrative. Tuned
   for low false-positives (e.g. a `Read(**/secrets/**)` deny does not trip the
   secret-literal pattern, which requires a keyword immediately assigned a value).
2. **The AEH-side grant is read by `harness-reviewer`, not the check script.** The
   harness config is a harness file; reading it is a harness-reviewer subject (its
   Dimension 5), not a target-side deterministic check. `target-aeh-reviewer` only
   contributes target-side symptom evidence and routes the root cause across.
3. **Re-run the SAME check to validate the fix** (detect == confirm) in both loops,
   rather than a separate verification step.

## Scope

In scope: items 1-4. The airtight negation-based lockdown expression stays
deferred (documented in the updated B6 note).

## Acceptance criteria

1. `aeh-practice-check.sh --list` shows `permission-scope`; the check PASSes on a
   clean config, FAILs (with specifics) on bypass / filesystem-escape /
   secret-literal / missing-deny, and SKIPs when no settings file exists.
2. The report -> approve -> fix -> revalidate loop is documented in all four roles,
   routed by file location.
3. The B6 deferral note in `permission-baselines.md` is corrected (report built in;
   only the lockdown deferred).
4. Validator + publication gate pass; F5 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/`.
- The fence + the deferral it corrects: B6
  (`openspec/changes/aeh-engineer-role-b6/`).
- The check framework it extends: B4
  (`openspec/changes/aeh-engineer-role-b4/`).
