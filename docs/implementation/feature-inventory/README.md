# Feature Inventory

> Rollup lens only. Behavior lives in `docs/design/`; dated progress in `docs/implementation/status/`.

## Purpose

- Register of every D-Card MVP capability, its leverage and delivery status.
- Read before planning a phase or scoping a task.

## Legend

| Status | Meaning |
|---|---|
| `Done` | Shipped and verified. |
| `In Progress` | Some tasks active or shipped. |
| `In Review` | Implemented; awaiting verification. |
| `Pending` | Planned; not started. |
| `Blocked` | Named blocker prevents progress. |

## Feature Index

| # | Feature | Description | Capability leverage | Status | Link |
|---|---|---|---|---|---|
| 1 | Platform Foundation | Monorepo, local infrastructure, database, API contract, worker and Flutter workspace every feature builds on. | Lets three workstreams build in parallel against one contract. | In Progress | [`./platform-foundation/README.md`](./platform-foundation/README.md) |
| 2 | Authentication and Accounts | Firebase-based login for management roles and guests, with per-event roles in Postgres. | Every other feature relies on knowing who acts and in which event role. | In Progress | [`./auth/README.md`](./auth/README.md) |
| 3 | Events | Event creation, settings, contact, types/templates and the event-day dashboard. | The container for every guest, message, payment and check-in. | Pending | [`./events/README.md`](./events/README.md) |
| 4 | Guests, Invitations and Cards | People, per-event invitations, the four ways of adding guests, cards and the guest card page. | Turns a guest list into deliverable, verifiable cards. | Pending | [`./guests-and-cards/README.md`](./guests-and-cards/README.md) |
| 5 | Contributions (Michango) | Pledges, recorded payments, receipts, balances and automatic card issue. | Links michango directly to card delivery — D-Card's key differentiator. | Pending | [`./contributions/README.md`](./contributions/README.md) |
| 6 | Attendance Confirmation | WhatsApp Approve/Decline buttons, SMS contact-based confirmation and manual recording. | Gives hosts a realistic expected headcount. | Pending | [`./attendance-confirmation/README.md`](./attendance-confirmation/README.md) |
| 7 | Door Check-in | D-Card Door app: online and offline check-in, double cards, lockout and walk-ins. | Controls entry reliably even without network. | Pending | [`./check-in/README.md`](./check-in/README.md) |
| 8 | Notifications and Message Customisation | Guest messages on WhatsApp and SMS with host-controlled content, channel and timing. | Keeps guests informed at low, bounded cost. | Pending | [`./notifications/README.md`](./notifications/README.md) |
| 9 | Photos and Videos | Card media, story page, guest gallery and slideshow stored in the host's Google Drive. | Richer events at zero storage cost to D-Card. | Pending | [`./media/README.md`](./media/README.md) |
| 10 | Plans and Billing | Msingi/Kawaida/Premium per-guest plans, Snippe payment and plan limits. | Revenue and bounded cost per event. | Pending | [`./plans-and-billing/README.md`](./plans-and-billing/README.md) |
| 11 | Audit, Privacy and Data Retention | Append-only audit log, post-event anonymisation and guest privacy rights. | Trust and legal compliance across all features. | In Progress | [`./privacy-and-audit/README.md`](./privacy-and-audit/README.md) |
| 12 | UI Design System | Purple and white, bento grid, Playfair Display, Hugeicons, light and dark themes across the mobile, door and web apps. | A consistent, human-made interface is the product's main marketing. | Done | [`./design-system/README.md`](./design-system/README.md) |

## Capability Outlook

- Foundation → events/guests → contributions/cards → messaging → check-in → payments/media compounds into a full self-service event run.
- Gap: no feature is shipped yet; the MVP needs all features through phase 05 before a pilot.
- Gap: live provider tests wait for real keys (T00-10).

## Maintenance

- Split mirrors `docs/design/features/*` and `docs/design/architecture/*`.
- Update a subfeature `Status` when a linked phase or task changes state; re-roll the feature status.
- Add subfeatures only for behavior present in `docs/design/`. Keep feature numbers stable.
