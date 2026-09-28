# Guests, Invitations and Cards

## Feature

- Guests, Invitations and Cards (`docs/design/features/guests-and-cards.md`)

## Description

- People, per-event invitations, the four ways of adding guests, cards and the guest card page.

## Capability Leverage

- Turns a guest list into deliverable, verifiable cards.

## Status

- Pending

## Subfeature Index

| Subfeature | Description | Status | Evidence |
|---|---|---|---|
| [`person-and-invitation`](./person-and-invitation.md) | One Person per phone, at most one Invitation per Person per event. | In Review | `P01` (`docs/implementation/phases/phase-01-events-guests.md`) |
| [`add-guest-form`](./add-guest-form.md) | Add, edit and remove guests one by one. | In Review | `P01` (`docs/implementation/phases/phase-01-events-guests.md`) |
| [`csv-import`](./csv-import.md) | Excel/CSV import with template and validation report. | In Review | `P01` (`docs/implementation/phases/phase-01-events-guests.md`) |
| [`phone-contacts-import`](./phone-contacts-import.md) | Multi-select from phone contacts in the D-Card app. | In Review | `P01` (`docs/implementation/phases/phase-01-events-guests.md`) |
| [`copy-from-past-event`](./copy-from-past-event.md) | Copy people from the host's earlier event. | In Review | `P01` (`docs/implementation/phases/phase-01-events-guests.md`) |
| [`guest-consent`](./guest-consent.md) | Host confirms guests agreed to receive messages; stored per event. | In Review | `P01` (`docs/implementation/phases/phase-01-events-guests.md`) |
| [`card-issue-and-numbers`](./card-issue-and-numbers.md) | Card issue with NNN-PPPP number, QR and link tokens; immutable card type. | In Review | `P02` (`docs/implementation/phases/phase-02-contributions-cards.md`) |
| [`card-cancel-reinstate`](./card-cancel-reinstate.md) | Host cancels and reinstates cards. | In Review | `P02` (`docs/implementation/phases/phase-02-contributions-cards.md`) |
| [`guest-card-page`](./guest-card-page.md) | Card link page without login: card, QR, venue, programme basics. | In Review | `P02` (`docs/implementation/phases/phase-02-contributions-cards.md`) |
| [`rsvp-and-dietary`](./rsvp-and-dietary.md) | RSVP, dietary needs and add-to-calendar from the card link. | In Review | `P02` (`docs/implementation/phases/phase-02-contributions-cards.md`) |
| [`expected-headcount`](./expected-headcount.md) | Expected headcount from confirmation states and host percentage. | Done | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
