# Phase 01 — Events, plans, guests (weeks 3–4)

## Status

- `pending`
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

- [ ] Break the scope below into task files before the phase starts (vertical slices, per `task-spec.md`).

## Acceptance Criteria

- [ ] a host can create an event and build a guest list in all 4 ways.
- [ ] Every linked task is `done` with verification evidence.
- [ ] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- Previous phase not done.

## Linked Tasks

- None yet.
