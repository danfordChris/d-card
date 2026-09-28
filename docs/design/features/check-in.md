# Door Check-in

## Context

- D-Card Door app; online-first with offline fallback. Sync design: `docs/design/architecture/offline-sync.md`.

## Workflow: Door Check-in
1. Door staff log in and select the event. The app **downloads the event's check-in data** (`docs/design/architecture/offline-sync.md`) and keeps it updated while online.
2. They find the card by **QR scan**, **card number** or **name search**.
3. **Online:** the server checks the card and applies the entry atomically. The server is the authority.
4. **Offline:** the app checks the card against its local copy, records the entry locally with a device-generated ID, and syncs later.
5. The app shows the name(s), Single/Double, entries left, table and status. Staff tap **Admit 1** or **Admit 2**.
6. Refusals: *Card fully used* (with entry times), *Card cancelled*, *Card not found*.
7. **Card-number lockout:** after 3 wrong card numbers in a row, card-number entry is locked for that staff account for 5 minutes and the host is notified. Online, the server enforces it. Offline, the app enforces it and reports it on sync.
8. Every attempt, successful or refused, is audited (offline attempts at sync time, with their original timestamps).
9. **Backup:** the host can still print the guest list with card numbers as a last resort.

## Workflow: Double Card Entry
- Together: **Admit 2** → 0 left. Separately: **Admit 1**, then **Admit 1** → 0 left. After that: **Card fully used**.
- **Online**, two gates can never admit more than the card allows (atomic database update).
- **Offline**, two gates without network may both admit on the same card. After sync the card is flagged **over-used** and the host is alerted (`docs/design/architecture/offline-sync.md`).

## Workflow: Walk-in
1. Staff send a walk-in request (description, optionally linked to an invitation).
2. **The host and all named walk-in approvers** get a push notification.
3. **The first approver to answer decides.** Everyone sees who decided.
4. Approved walk-ins are recorded as extra entries (attendance counts and audit log).
5. **Offline walk-ins:** if the door device is offline, staff can admit the walk-in on the device and must enter a reason (e.g. "host approved by phone call"). It syncs later as **admitted offline – needs review**, and the host or an approver then marks it **accepted** or **flagged**. Both outcomes are audited.

## Requirements
| ID | Requirement | Pri |
|----|-------------|-----|
| CHK-1 | QR, card number or name search. Online checks are done by the server. | M |
| CHK-2 | Result shows name(s), type, entries left, table and status. | M |
| CHK-3 | Admit 1 / Admit 2. Online entries are applied atomically. | M |
| CHK-4 | Refusal reasons: fully used (with times), cancelled, not found. | M |
| CHK-5 | 3 wrong card numbers → 5-minute lock for that staff account + host alert (online and offline). | M |
| CHK-6 | **Offline check-in** from the local cache, with automatic sync (`docs/design/architecture/offline-sync.md`). | M |
| CHK-7 | Over-used card detection and host alert after sync. | M |
| CHK-8 | Walk-in requests to the host and named approvers. First answer decides. | M |
| CHK-8a | **Offline walk-ins** admitted by staff with a mandatory reason, synced as "needs review", then accepted or flagged by the host/approver. | M |
| CHK-9 | Printable guest list as a last-resort backup. | M |
| CHK-10 | Live attendance vs. expected headcount, device sync status. | M |

## Walk-in Request States
Online: `pending → approved | refused` (first approver to answer).
Offline: `admitted_offline → accepted | flagged` (reviewed after sync).
