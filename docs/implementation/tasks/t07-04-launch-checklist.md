# T07-04 — Launch checklist, pilot runbook and store submission guide

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-07-hardening-pilot.md`
- Feature-inventory subfeature(s): none (phase scope item)

## Agent Context

- Owner: Subagent (docs) with lead review
- Skills: none
- Design docs: `docs/deployment.md`, `docs/store-listings.md`, `docs/implementation/reviews/2026-09-27-phase-06-review.md`
- Constraints: docs only; owner actions clearly marked; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/design/ui/design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The owner has one checklist to go live and a runbook to run each pilot event.

## Scope Boundary

**In scope:**
- `docs/launch/launch-checklist.md`
- `docs/launch/pilot-runbook.md`

**Out of scope:**
- Code changes

## Acceptance Criteria

- [x] Launch checklist: provider accounts and live switches (`NEXTSMS_LIVE`, `WHATSAPP_LIVE`, `SNIPPE_LIVE`), Meta business verification and templates, Firebase providers, Sentry/alerts, migrations, backups (Neon PITR), domains/TLS, store submissions, legal (PDPA O3), support contact, rollback steps.
- [x] Pilot runbook: before (host onboarding, plan payment, guest import, test card to host), during (door devices, offline drill, walk-ins, live dashboard), after (retention, feedback form, metrics to collect), and incident steps.
- [x] Each item names who does it (owner/lead) and how to verify.

## Dependencies

- None.

## Implementation Checklist

- [x] Draft.
- [x] Lead review.
- [x] Validate.

## Verification

- Command: `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`
- Evidence:

- 2026-09-27: `docs/launch/launch-checklist.md` (12 sections, each item with owner/lead and a check; sign-off table) and `docs/launch/pilot-runbook.md` (T-14, T-7, event day, after, incidents with where to look). Lead review: the first live payment is the first pilot's plan checkout (no way to price below the Tsh 50,000 minimum), aligned in phase 05 docs. `validate_workflow.py` → `WORKFLOW:ok`.
