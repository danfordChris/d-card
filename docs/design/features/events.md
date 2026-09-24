# Events

## Context

- Covers event setup, settings and the event-day dashboard.

## Workflow: Host Onboarding and Event Setup
1. Host signs up with email + password and verifies the email.
2. Host creates an event: **plan** (Msingi / Kawaida / Premium, can be upgraded later), **event type** (from the admin list), title, date/time (default time zone `Africa/Dar_es_Salaam`), venue, and the **event contact**: a contact name and phone number (**required**), plus an optional second contact. The phone is stored in `255` format and shown in SMS in local format (e.g. `0754 123 456`) so guests can dial it directly.
3. Host sets contribution amounts per card type (e.g. Single Tsh 50,000, Double Tsh 100,000).
4. Host configures options: attendance confirmation on/off, headcount percentage (default 70%), photo album link.
5. **Media step (Kawaida/Premium):** connect Google Drive and choose how the event folder is shared: **private** (default) or **anyone with the link** (MED-1a).
6. **Messages step:** the host reviews each guest message (pre-filled defaults) and can turn it on or off, choose channels, edit the wording, and set the timing and frequency, within their plan (`docs/design/features/notifications.md`). The screen shows what the plan allows and how close the event is to its limits.
7. Host invites treasurer(s), committee members, door staff and walk-in approvers by email.
8. Host designs the card from a template for that event type.
9. Host confirms the plan and the number of guest cards, and **pays by mobile money** (minimum Tsh 50,000, 20% off the first event). No cards or messages go out until payment is confirmed (`docs/design/features/plans-and-billing.md`).
10. Host publishes the event (`draft → published`).

## Workflow: Event Day Dashboard
The host sees live check-ins against the expected headcount, contribution totals, pending walk-ins, confirmation breakdowns, **offline devices that have not synced**, and **over-used card alerts**.

## Requirements
| ID | Requirement | Pri |
|----|-------------|-----|
| EVT-1 | Create and edit an event of **any admin-defined type**: title, date/time, time zone, venue. | M |
| EVT-1a | **Event contact** (name + phone, required; optional second contact) captured when creating the event and editable later. | M |
| EVT-2 | Status: `draft → published → completed`, or `cancelled`. | M |
| EVT-3 | Settings: confirmation on/off and timing, headcount percentage, single/double amounts (TZS), reminder frequency, **auto-upgrade on/off (default on)**. | M |
| EVT-4 | Card design from templates per event type. Photos, video and animation on the card depend on the plan (`docs/design/features/media.md`). | M |
| EVT-5 | Admin manages event types and their templates and wording. | M |
| EVT-6 | Programme with countdown, menu (incl. drinks), venue/transport/accommodation, polls. | P2 |
