# T04-05 — D-Card Door app: offline mode and sync

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-04-confirmation-check-in.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/check-in/door-offline-cache.md`, `docs/implementation/feature-inventory/check-in/offline-sync.md`, `docs/implementation/feature-inventory/check-in/double-card-entry.md`

## Agent Context

- Owner: Subagent (Flutter)
- Skills: `flutter-apply-architecture-best-practices`
- Design docs: `docs/design/architecture/offline-sync.md` (9.1–9.4), `docs/design/features/check-in.md` (CHK-5, CHK-6)
- Constraints: encrypted SQLite (`sqflite_sqlcipher`) with the key in `flutter_secure_storage`; never Hive; QR checked against the token hash; entries immutable with device UUIDs; offline lockout enforced locally and reported on sync; cache wiped 24 h after the event ends or on revoke; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); phone numbers stored as `255` + 9 digits; sw/en for every user-facing string; web UI Tailwind only
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The door app keeps working without network, checks cards against an encrypted local cache, and syncs entries automatically when the network returns.

## Scope Boundary

**In scope:**
- `apps/door/**` (offline data layer, sync service, sync status UI)

**Out of scope:**
- Server sync API (T04-02)

## Acceptance Criteria

- [x] While online the app downloads and delta-updates the event cache; offline, lookups and admits use it.
- [x] Offline entries and attempts upload automatically with retries; the app shows "N entries waiting to sync".
- [x] Two simulated offline devices admitting the same Double card both keep their entries and the card shows over-used after sync.
- [x] The cache is encrypted and is wiped after the event window or on revoke.
- [x] Tests with fakes cover offline admit, retry, wipe; analyze/test pass; debug APK builds.

## Dependencies

- T04-02 done; T04-04 done.

## Implementation Checklist

- [x] Encrypted cache.
- [x] Delta download.
- [x] Offline lookup/admit + lockout.
- [x] Upload queue + status.
- [x] Wipe rules.
- [x] Tests + APK.

## Verification

- Command: `pnpm turbo run typecheck lint test build` and `dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-26 (built by a Flutter subagent, verified by the lead): `dart run melos run analyze` no issues; `dart run melos run test` → door 72 (43 new), mobile 43, core 14, ui 1; `flutter build apk --debug` builds. No Hive.
  - SQLCipher cache with a random key in `flutter_secure_storage`; full download on event open, delta every 30 s and on reconnect; upload first then download, backoff up to 60 s; status bar "N waiting to sync" + last sync; offline decisions by QR SHA-256 digest, card number and name; same entry id as the failed online call (counted once); local lockout uploaded as `locked`; wipe after `wipeAfter`, on revoke, on sign-out (warns when entries are unsynced).
  - Tests include two offline phones admitting one Double → both entries kept and the card over-used after sync, lost-response retry counted once, and all wipe rules (in-memory SQLite via `sqflite_common_ffi`).
  - Owner checks: iOS pod install/build (SQLCipher), real-device offline run. Debug APKs carry an extra `libsqlite3.so` from the test-only package (release APKs verified clean).
