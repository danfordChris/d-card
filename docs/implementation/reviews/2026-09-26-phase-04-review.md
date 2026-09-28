# Review Report — 2026-09-26 (Phase 04: Confirmations and check-in)

## Summary

- Reviewed T04-01 to T04-07. All seven meet their acceptance criteria with recorded evidence.
- Phase objective met: two offline gates admitting Single and Double cards sync to the same totals in any order; over-use is kept (both entries), flagged once, alerted to the host and audited (`packages/core/test/checkin-sync.test.ts`, door app tests with two offline phones, and a local end-to-end run: 6 cards, 2 gates, offline upload over-using one card, walk-ins, lockout → dashboard showed the alert and live counts).
- Work split: lead T04-01, T04-02, T04-06 backend and push, WhatsApp confirmation replies; JetBrains assistant T04-03; subagents the door app (T04-04, T04-05), walk-in screens (web, mobile, door) and the dashboard (T04-07). All verified by the lead.
- Pipelines: `pnpm turbo run typecheck lint test build --force` 27/27 (core 147, web 174, worker 28, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (door 72, mobile 43, core 14, ui 1); debug APKs build; `validate_workflow.py` → `WORKFLOW:ok`.

## Standards

- Server is the authority online: admits run under a row lock on the invitation; 6 parallel admits on a Double admit exactly 2.
- Entries are immutable with device-generated ids (G-Set); uploads are idempotent and order-free; over-use is detected after merge, never rejected.
- Door devices are registered per event and revocable; revoked devices get 403 and wipe their cache. The offline cache is SQLCipher with the key in secure storage; QR codes are checked offline by a plain SHA-256 digest (the server lookup stays HMAC-keyed).
- Every door attempt (admitted or refused) is recorded; lockouts, over-use, walk-in decisions, device changes and confirmation overrides are audited.
- Push goes through one `push` queue (walk-ins, lockout, over-use); WhatsApp window replies through the `whatsapp` queue (`reply` job, id = inbound message id).
- Web builds type-check without `.next/dev/types` (`tsconfig.build.json`); the generated Dart client no longer asserts non-null on nullable fields.

## Spec

- CHK-1…CHK-10, CNF-1…CNF-3, CNF-5, GST-14 as in `docs/design/features/check-in.md`, `attendance-confirmation.md`, `guests-and-cards.md`.
- First WhatsApp answer counts (conditional update); later taps and Meta re-deliveries never change it or reply twice.
- Walk-ins count as extra entries, never against a card; users with several roles (committee + walk-in approver) can decide (`roles` on events).
- Expected headcount counts issued cards only on both the confirmations page and the dashboard.
- Added to design during the phase: `door_device`, `entry` (nullable invitation for walk-ins), `check_in_attempt`, `walkin_request`, `invitation.over_used_at`, `door_device.pending_count` (`docs/design/data-models/postgres.md`); device QR digest (`docs/design/architecture/offline-sync.md`).

## Verification

- Commands: `pnpm turbo run typecheck lint test build --force`, `dart run melos run analyze`, `dart run melos run test`, `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`
- Evidence: Verification sections of `docs/implementation/tasks/t04-*.md`.

## Follow-ups

- Live checks wait for owner setup: Firebase (Email/Password, authorized domain `api.dcard.danfordchris.dev`, door app registration, FCM/APNs), WhatsApp templates approved, worker host.
- Door app: real-device camera and offline run; iOS pod install (SQLCipher). Sign-out currently wipes unsynced entries after a warning — consider blocking sign-out until they upload.
- Seating table on cards and the backup list waits for GST-15 (P2).
- UI refinement per `docs/changes/proposed/ui-design-system.md` (backlog, 2026-09-26).
- Local `node_modules` had been removed outside the session and was reinstalled from the lockfile; Docker/Postgres had hung and recovered.
