# Phase 06 — Completion (weeks 13–14)

## Status

- `pending`
- Last updated: 2026-09-24

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

- [ ] Break the scope below into task files before the phase starts (vertical slices, per `task-spec.md`).

## Acceptance Criteria

- [ ] feature-complete MVP on staging.
- [ ] Every linked task is `done` with verification evidence.
- [ ] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- Previous phase not done.

## Linked Tasks

- None yet.
