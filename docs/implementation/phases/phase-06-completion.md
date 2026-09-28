# Phase 06 — Completion (weeks 13–14)

## Status

- `in-progress`
- Last updated: 2026-09-27

## Objective

- feature-complete MVP on staging.

## Scope

| A | B | C |
|---|---|---|
| Retention job (W13 anonymisation, gallery page closing), privacy (export/delete for registered guests) | Admin panel: users, events, templates (submit/track Meta status), plans, provider rates, launch offer, audit search | D-Card app for guests: Google/Apple sign-in, my cards, card view, RSVP; polish |
| Rate table + internal cost/margin report | Host audit log view, exports | Door app: host device revocation, lockout UX, edge cases |
| Observability: logs, error tracking, queue dashboards, alerts | Accessibility and performance pass on the guest card page (slow 3G) | Store listings, internal testing tracks |

## Included Features

- `docs/implementation/feature-inventory/platform-foundation/observability.md`
- `docs/implementation/feature-inventory/auth/guest-social-login.md`
- `docs/implementation/feature-inventory/auth/admin-2fa.md`
- `docs/implementation/feature-inventory/auth/door-device-sessions.md`
- `docs/implementation/feature-inventory/plans-and-billing/cost-margin-report.md`
- `docs/implementation/feature-inventory/privacy-and-audit/retention-anonymisation.md`
- `docs/implementation/feature-inventory/privacy-and-audit/gallery-page-closing.md`
- `docs/implementation/feature-inventory/privacy-and-audit/guest-data-export-delete.md`
- `docs/implementation/feature-inventory/privacy-and-audit/privacy-notice.md`

## Task Checklist

- [x] Break the scope into task files (vertical slices, per `task-spec.md`).
- [x] All linked tasks done with evidence.
- [x] Phase review written (`docs/implementation/reviews/2026-09-27-phase-06-review.md`).
- [ ] Deploy to staging with migrations 0013–0017 and owner setup (Firebase Google/Apple, Sentry, `ALERT_EMAIL`).

## Acceptance Criteria

- [ ] feature-complete MVP on staging.
- [x] Every linked task is `done` with verification evidence.
- [ ] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- Phase 05 waits only on the owner's live Snippe payment and Google Drive check; phase 06 work does not depend on them.

## Linked Tasks

- `docs/implementation/tasks/t06-01-retention-privacy.md`
- `docs/implementation/tasks/t06-02-guest-sign-in.md`
- `docs/implementation/tasks/t06-03-admin-panel.md`
- `docs/implementation/tasks/t06-04-host-audit-exports.md`
- `docs/implementation/tasks/t06-05-cost-margin-report.md`
- `docs/implementation/tasks/t06-06-observability.md`
- `docs/implementation/tasks/t06-07-card-page-a11y-perf.md`
- `docs/implementation/tasks/t06-08-door-app-polish.md`
- `docs/implementation/tasks/t06-09-store-listings.md`
