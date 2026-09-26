# T04-01 — Check-in core and door API (online)

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-04-confirmation-check-in.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/check-in/online-check-in.md`, `docs/implementation/feature-inventory/check-in/double-card-entry.md`, `docs/implementation/feature-inventory/check-in/card-number-lockout.md`

## Agent Context

- Owner: Claude Code (lead)
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/check-in.md` (CHK-1…CHK-5), `docs/design/architecture/offline-sync.md` (9.2), `docs/design/features/auth.md` (AUTH-9)
- Constraints: the server is the authority online; entries are immutable with device-generated UUIDs (same row shape as offline entries); `entries_used` is derived from entries, never written by a client; every attempt (admitted or refused) is audited; lockout: 3 wrong card numbers in a row → 5 minutes for that staff account (Redis TTL) + host alert; door staff limited by plan; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); phone numbers stored as `255` + 9 digits; sw/en for every user-facing string; web UI Tailwind only
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Door staff find a card by QR, card number or name and admit 1 or 2 people online, atomically, with refusals, lockout and audit.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` (new tables `door_device`, `entry`, `check_in_attempt`) + migration
- `packages/core/src/checkin/**`
- `packages/api-contract/src/checkin.ts`
- `apps/web/src/app/api/v1/door/**`

**Out of scope:**
- Offline sync and cache download (T04-02)
- Walk-ins (T04-06)
- Door app UI (T04-04)

## Acceptance Criteria

- [x] `POST /api/v1/door/devices` registers a device for one event (door staff, host or committee); `DELETE …/devices/{id}` by the host revokes it; revoked devices get 403 on every door call.
- [x] `POST /api/v1/door/lookup` finds a card by QR token, card number or name (name returns a short list) and returns name(s), type, entries left, table and status.
- [x] `POST /api/v1/door/entries` with a device-generated UUID admits 1 or 2; two concurrent requests can never admit more than the card allows (test with parallel requests); repeating the same UUID is idempotent.
- [x] Refusals `fully_used` (with entry times), `cancelled`, `not_found` are returned and recorded as attempts.
- [x] Three wrong card numbers in a row lock card-number entry for that staff account for 5 minutes (423) and alert the host (audit + push when available).
- [x] Every attempt is audited; tests cover double cards (together and separately) and the lockout.

## Dependencies

- Phase 03 done (push sender available).

## Implementation Checklist

- [x] Schema + migration.
- [x] Lookup service.
- [x] Atomic admit + attempts.
- [x] Lockout.
- [x] Device register/revoke.
- [x] API routes + contract + OpenAPI.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-26: `pnpm turbo run typecheck lint test build --force` → 27/27 tasks (core 126, web 155, worker 25).
  - Schema: migration `packages/db/drizzle/0013_check_in.sql` (`door_device`, `entry` with device-generated ids and nullable invitation for walk-ins, `check_in_attempt`); `docs/design/data-models/postgres.md` updated.
  - Core `packages/core/test/checkin.test.ts` (6 tests): door events by role; idempotent device registration; revoke → 403; QR / card number (any spacing) / name lookup; lockout after 3 wrong numbers in a row, reset by a correct number, 5-minute expiry, audited; Double together and separately, then `fully_used` with entry times; `too_many`; same entry id admits once; 6 parallel admits on a Double → exactly 2 succeed; cancelled / not issued / not found refusals; every outcome recorded as an attempt.
  - Web `apps/web/test/door-api.test.ts` (4 tests): events, device 201/200/403, lookup + 422 for two identifiers, admit 201 / repeat 200 / 409 `fully_used` with card, 423 lockout with `lockedUntil`, host revoke 204 (staff 403), revoked device 403.
  - Contract `packages/api-contract/src/checkin.ts` in OpenAPI; `dcard_api` regenerated (melos analyze clean).
  - Host lockout alert is recorded in the audit log for the dashboard; the push alert is wired with T04-06 (first push caller).
