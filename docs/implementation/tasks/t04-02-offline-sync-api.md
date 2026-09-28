# T04-02 — Offline cache and sync API

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-04-confirmation-check-in.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/check-in/offline-sync.md`, `docs/implementation/feature-inventory/check-in/door-offline-cache.md`

## Agent Context

- Owner: Claude Code (lead)
- Skills: `vercel:nextjs`
- Design docs: `docs/design/architecture/offline-sync.md` (9.1–9.4), `docs/design/features/check-in.md` (CHK-6, CHK-7)
- Constraints: entries are a G-Set keyed by device UUID (merge is idempotent, any order); the cache carries only the QR token **hash**, never the token; over-use is detected after merge, flagged, alerted and audited — never rejected; offline attempts keep their original timestamps; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); phone numbers stored as `255` + 9 digits; sw/en for every user-facing string; web UI Tailwind only
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

A door device downloads its event's check-in data, keeps it current with a delta cursor, and uploads offline entries and attempts that merge safely.

## Scope Boundary

**In scope:**
- `packages/core/src/checkin/sync.ts`
- `apps/web/src/app/api/v1/door/sync/**`
- `packages/api-contract/src/checkin.ts` (sync schemas)

**Out of scope:**
- Door app storage and UI (T04-05)

## Acceptance Criteria

- [x] `GET /api/v1/door/sync?since=` returns invitations (names, card number, QR token hash, type, total/used entries, status, table), walk-in approvers and a new cursor; `since` returns only changes.
- [x] `POST /api/v1/door/sync` uploads entries and attempts; re-uploading the same batch changes nothing; batches from two devices merge in any order to the same totals.
- [x] A card admitted beyond its entries by two offline devices is flagged over-used; the host gets an alert with both entries (gate, staff, time); the event is audited.
- [x] Each device's last sync time and unsynced count are stored for the dashboard.

## Dependencies

- T04-01 done.

## Implementation Checklist

- [x] Snapshot + delta query.
- [x] Upload merge.
- [x] Over-use detection + alert.
- [x] Device sync status.
- [x] Tests (idempotency, ordering, two devices) + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-26: `pnpm turbo run typecheck lint test build --force` → 27/27 tasks (core 130, web 156).
  - Core `packages/core/test/checkin-sync.test.ts` (4 tests): full snapshot with QR digests (SHA-256 the device can compute; the token itself never sent), host + walk-in approvers, `wipeAfter` = event end + 24 h, device `pending_count`/`last_sync_at` stored; delta after a cursor returns only changed cards, including entries from another gate; uploads from two devices merge idempotently and in any order; two offline gates on a Single keep both entries, card flagged over-used once with both entries (gate, staff, time) audited; entries for other events rejected; offline lockout reported to the host (audit).
  - Web `apps/web/test/door-api.test.ts` sync case: snapshot 200 without the raw QR token, upload accepted then duplicate, invalid device id 422.
  - Schema: `invitation.over_used_at`, `door_device.pending_count` (in `0013_check_in.sql`); `docs/design/architecture/offline-sync.md` records the device QR digest.
  - Push alert for over-use waits for T04-06 (first push caller); the dashboard reads `door.over_used` and `door.card_number_lockout` audits.
