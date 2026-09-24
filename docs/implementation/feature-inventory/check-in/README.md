# Door Check-in

## Feature

- Door Check-in (`docs/design/features/check-in.md`)

## Description

- D-Card Door app: online and offline check-in, double cards, lockout and walk-ins.

## Capability Leverage

- Controls entry reliably even without network.

## Status

- Pending

## Subfeature Index

| Subfeature | Description | Status | Evidence |
|---|---|---|---|
| [`online-check-in`](./online-check-in.md) | Atomic server check-in by QR, card number or name. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
| [`door-offline-cache`](./door-offline-cache.md) | Encrypted sqflite cache of the event's cards, kept up to date while online. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
| [`offline-sync`](./offline-sync.md) | Entries as a G-Set with device UUIDs; idempotent sync; over-use detection. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
| [`double-card-entry`](./double-card-entry.md) | Admit 1 / Admit 2 with entries left. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
| [`card-number-lockout`](./card-number-lockout.md) | Lock card-number entry after 3 wrong attempts for 5 minutes. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
| [`walk-in-requests`](./walk-in-requests.md) | Staff request, host/approvers decide; first answer wins. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
| [`offline-walk-ins`](./offline-walk-ins.md) | Offline walk-ins with mandatory reason, reviewed after sync. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
| [`printable-backup-list`](./printable-backup-list.md) | Printable guest list with card numbers. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
