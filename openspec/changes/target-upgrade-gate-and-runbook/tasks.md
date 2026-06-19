# Tasks -- target-upgrade-gate-and-runbook

Ordered. Each task names a mechanical completion signal.

1. **Author the upgrade playbook.** Create
   `templates/playbooks/upgrade.md` -- 5 ordered steps, each with a hard
   verification gate, terminal UPGRADE COMPLETE state, marker bump. Target-detail-free
   and name-free.
   - Signal: file exists; `grep -c "Gate (hard)" templates/playbooks/upgrade.md`
     >= 5; contains the explicit `UPGRADE COMPLETE` terminal string.

2. **Rewrite the orchestrator gate.** In
   `templates/personas/target-orchestrator.md`, rename the section to "Harness
   Update Propagation Gate"; rewrite the intro + detection block + session-init
   step 5 -> vocal UPGRADE REQUIRED gate; point the gate at the `upgrade`
   playbook; fold the `review changes` Propagation-Impact pass in as runbook
   Step 3. The only surviving "signal only" mention is the explicit retirement
   sentence; every operative occurrence is gone.
   - Signal: the section is titled "Harness Update Propagation Gate", contains
     `UPGRADE REQUIRED` and a pointer to `templates/playbooks/upgrade.md`; the
     sole "signal only" occurrence is the retirement reference.

3. **Update CLAUDE.md.** Rewrite the propagation bullet to the gate-plus-runbook
   doctrine; add `upgrade` to the Playbooks table and the natural-language
   Commands table.
   - Signal: `grep -c "upgrade" CLAUDE.md` increases; Playbooks table has an
     `upgrade` row pointing at `templates/playbooks/upgrade.md`.

4. **Align the health-check mirror.** In
   `templates/playbooks/health-check.md`, align the `harness-sync-sha` wording so
   a missing/stale marker reads as an upgrade trigger, not merely a LOW finding.
   - Signal: the health-check `harness-sync-sha` text references the upgrade gate
     / runbook.

5. **Align the target-aeh-reviewer mirror.** In
   `templates/personas/target-aeh-reviewer.md`, reframe Propagation-Impact
   Assessment Mode as one folded-in step of the upgrade runbook.
   - Signal: the mode intro references the `upgrade` runbook step rather than
     presenting itself as the whole response.

6. **Align the prompt-template mirrors.** In
   `templates/prompts/refresh-base-personas.md.template`, align the
   "propagation-signal philosophy" line to gate-plus-runbook (Step 1); in
   `templates/prompts/seed-harness-sync-marker.md.template`, align the
   "surface the signal" / "say 'review changes'" expected-outcome wording to the
   UPGRADE REQUIRED gate + `upgrade` runbook.
   - Signal: no "signal only" / "say 'review changes'" framing remains in either
     template.

6b. **Repoint the onboarding section refs (rename subtraction-completeness).**
   In `templates/playbooks/onboarding.md`, change both
   `§ "Harness Update Propagation Signal"` references to
   `§ "Harness Update Propagation Gate"`.
   - Signal: `grep -c 'Harness Update Propagation Signal' templates/playbooks/onboarding.md`
     == 0; both now read "Gate".

7. **CHANGELOG.** Add an [Unreleased] entry (generic terms).
   - Signal: entry present under [Unreleased].

8. **Gates.** Publication gate (`--staged` + `--message`) passes; harness-reviewer
   bookend APPROVE / APPROVE-WITH-MINOR.
   - Signal: both green; ready for close-out.
