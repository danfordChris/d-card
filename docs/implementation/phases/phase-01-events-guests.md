# Phase 01 — Events, plans, guests (weeks 3–4)

## Status

- `done`
- Last updated: 2026-09-24

## Objective

- a host can create an event and build a guest list in all 4 ways.

## Scope

| A | B | C |
|---|---|---|
| Event CRUD, event contact, settings, statuses; plan entitlements model | **Event wizard** (plan, type, details, contact, options) | D-Card app: host login, event list, event summary |
| Person/Invitation (one per person per event), consent record | Guest list: add, edit, remove, search | Add guests from **phone contacts** (multi-select, consent tick) |
| Excel/CSV import job (validation report), copy from past event | Import UI with validation report | |
| Committee/staff/approver invitations by email | Team management screen | |

## Included Features

- `docs/implementation/feature-inventory/auth/management-login.md`
- `docs/implementation/feature-inventory/auth/team-invitations.md`
- `docs/implementation/feature-inventory/events/event-setup-wizard.md`
- `docs/implementation/feature-inventory/events/event-contact.md`
- `docs/implementation/feature-inventory/events/event-settings.md`
- `docs/implementation/feature-inventory/events/event-types-and-templates.md`
- `docs/implementation/feature-inventory/guests-and-cards/person-and-invitation.md`
- `docs/implementation/feature-inventory/guests-and-cards/add-guest-form.md`
- `docs/implementation/feature-inventory/guests-and-cards/csv-import.md`
- `docs/implementation/feature-inventory/guests-and-cards/phone-contacts-import.md`
- `docs/implementation/feature-inventory/guests-and-cards/copy-from-past-event.md`
- `docs/implementation/feature-inventory/guests-and-cards/guest-consent.md`
- `docs/implementation/feature-inventory/plans-and-billing/plans-and-entitlements.md`

## Task Checklist

- [x] T01-01 — Events API (`docs/implementation/tasks/t01-01-events-api.md`)
- [x] T01-02 — Web foundation and management login (`docs/implementation/tasks/t01-02-web-foundation-login.md`)
- [x] T01-03 — Web event wizard, list, summary (`docs/implementation/tasks/t01-03-web-events.md`)
- [x] T01-04 — Guests API (`docs/implementation/tasks/t01-04-guests-api.md`)
- [x] T01-05 — Web guest list (`docs/implementation/tasks/t01-05-web-guests.md`)
- [x] T01-06 — Guest import and copy from past event (`docs/implementation/tasks/t01-06-guest-import.md`)
- [x] T01-07 — Team invitations and members (`docs/implementation/tasks/t01-07-team-invitations.md`)
- [x] T01-08 — Mobile host login and events (`docs/implementation/tasks/t01-08-mobile-host-events.md`)
- [x] T01-09 — Mobile contacts import (`docs/implementation/tasks/t01-09-mobile-contacts-import.md`)
- [x] T01-10 — Admin event types (`docs/implementation/tasks/t01-10-admin-event-types.md`)

## Acceptance Criteria

- [x] a host can create an event and build a guest list in all 4 ways.
- [x] Every linked task is `done` with verification evidence.
- [x] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Review

- `docs/implementation/reviews/2026-09-24-phase-01-review.md`

## Blockers

- None.
- Exception (recorded 2026-09-24): phase 00 remains open only for T00-10 (live provider spikes, blocked on owner keys). Reason: no phase 01 task depends on live providers. Scope: phase 01 only. Follow-up: run T00-10 when keys arrive; phase 00 closes then.

## Linked Tasks

- docs/implementation/tasks/t01-01-events-api.md
- docs/implementation/tasks/t01-02-web-foundation-login.md
- docs/implementation/tasks/t01-03-web-events.md
- docs/implementation/tasks/t01-04-guests-api.md
- docs/implementation/tasks/t01-05-web-guests.md
- docs/implementation/tasks/t01-06-guest-import.md
- docs/implementation/tasks/t01-07-team-invitations.md
- docs/implementation/tasks/t01-08-mobile-host-events.md
- docs/implementation/tasks/t01-09-mobile-contacts-import.md
- docs/implementation/tasks/t01-10-admin-event-types.md
