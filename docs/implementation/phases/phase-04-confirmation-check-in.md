# Phase 04 — Confirmations and check-in (weeks 9–10)

## Status

- `done`
- Last updated: 2026-09-26

## Objective

- a simulated event with 2 offline gates and double cards syncs correctly. Over-use is flagged and audited.

## Scope

| A | B | C |
|---|---|---|
| WhatsApp confirmation buttons → webhook → first answer counts, acknowledgement; manual confirmation recording; expected headcount | Confirmation and headcount views; manual status override | **D-Card Door:** event select, download cache, QR / card-number / name lookup, Admit 1/2, refusal reasons |
| **Atomic online check-in** endpoint; lockout (Redis TTL); entries as a G-Set with device UUIDs; **sync endpoint** (idempotent, over-used detection) | Live dashboard (SSE): check-ins vs expected, device sync status, alerts | **Offline mode:** local entries, encrypted cache, auto-sync, sync status UI, cache wipe |
| Walk-in requests (online) + push to host/approvers; offline walk-in review | Walk-in approval (web) | Walk-in request (online + offline with reason); approver screen in D-Card app |

## Included Features

- `docs/implementation/feature-inventory/events/event-dashboard.md`
- `docs/implementation/feature-inventory/guests-and-cards/expected-headcount.md`
- `docs/implementation/feature-inventory/attendance-confirmation/whatsapp-buttons.md`
- `docs/implementation/feature-inventory/attendance-confirmation/sms-contact-confirmation.md`
- `docs/implementation/feature-inventory/attendance-confirmation/manual-confirmation.md`
- `docs/implementation/feature-inventory/check-in/online-check-in.md`
- `docs/implementation/feature-inventory/check-in/door-offline-cache.md`
- `docs/implementation/feature-inventory/check-in/offline-sync.md`
- `docs/implementation/feature-inventory/check-in/double-card-entry.md`
- `docs/implementation/feature-inventory/check-in/card-number-lockout.md`
- `docs/implementation/feature-inventory/check-in/walk-in-requests.md`
- `docs/implementation/feature-inventory/check-in/offline-walk-ins.md`
- `docs/implementation/feature-inventory/check-in/printable-backup-list.md`

## Task Checklist

- [x] Break the scope below into task files before the phase starts (vertical slices, per `task-spec.md`).
- [ ] Carried from T03-08: wire the door app's real FCM token source and `PushRegistrationRepository` into door sign-in, and add the first `sendToUser` caller (walk-in push to host/approvers).

## Acceptance Criteria

- [x] a simulated event with 2 offline gates and double cards syncs correctly. Over-use is flagged and audited.
- [x] Every linked task is `done` with verification evidence.
- [x] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- Phase 03 stays open only for live WhatsApp sends (T00-10); it does not block phase 04.
- Door app sign-in needs Firebase Email/Password enabled and `api.dcard.danfordchris.dev` in Firebase authorized domains.

## Linked Tasks

- docs/implementation/tasks/t04-01-check-in-core.md
- docs/implementation/tasks/t04-02-offline-sync-api.md
- docs/implementation/tasks/t04-03-confirmations-headcount.md
- docs/implementation/tasks/t04-04-door-app-online.md
- docs/implementation/tasks/t04-05-door-app-offline.md
- docs/implementation/tasks/t04-06-walk-ins.md
- docs/implementation/tasks/t04-07-live-dashboard-backup.md
