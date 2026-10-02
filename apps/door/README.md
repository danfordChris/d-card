# D-Card Door

Flutter app for door check-in: online by default, offline from an encrypted event cache (T04-05), and walk-in requests (T04-06). How to run it: [docs/running-locally.md](../../docs/running-locally.md#5-mobile-app-and-door-app). Design: `docs/design/ui/design-system.md` (all UI comes from `dart_packages/dcard_ui`; the app follows the phone's light/dark setting and has no bottom navigation).

## Structure

- `lib/data/services/` — `AuthService` (Firebase, dev fake), API client factory (X-API-Key + Firebase ID token), FCM push token source, `DoorDeviceStore` (device ID per event and gate name in `shared_preferences`), `DoorCache` (SQL for the offline cache), `DoorCacheStore` (SQLCipher database + random key in `flutter_secure_storage`; `wipe()` deletes both), `ConnectivitySource` (`connectivity_plus`).
- `lib/data/repositories/` — `SessionRepository` (sign-in, one-time `POST /api/v1/me`, push registration, `beforeSignOut` hook), `DoorRepository` (`/api/v1/door/*`: events, device registration, lookup, entries, sync, walk-ins; refusals as `DoorRefusedException`), `DoorSyncRepository` (full download on event open, delta every 30 s and when the network returns, upload queue with backoff, over-used flags, wipe rules), `OfflineCheckInRepository` (local decisions: QR by SHA-256 digest, card number, name; pending entries/attempts/walk-ins; CHK-5 lockout).
- `lib/data/models/` — cache and sync payloads (`CachedCard`, `PendingEntry`, `PendingAttempt`, `PendingWalkIn`, `SyncSnapshot`, …).
- `lib/domain/models/` — `DoorEvent`, `DoorSession`, `CheckInCard`, `RefusalReason`, `WalkInRequest`, `AppFailure`.
- `lib/ui/features/<feature>/{view_models,views}` — sign-in, event select (reopen the cached event offline), check-in (header with sync chip and panel, Scan / Number / Name, result, lockout), walk-in (request + wait for the decision, or offline admission with a reason).
- Local storage: `shared_preferences` and SQLCipher (`sqflite_sqlcipher`). Never Hive.

## Offline mode

- Online is the default and the server decides. When a lookup/admit fails with a network error, or the phone is known to be offline, the app decides from the cache and shows **Offline**. Admits become immutable entries (device UUID, time) that upload on the next sync; a retried tap keeps its entry ID so a lost online response is never counted twice.
- The header's sync chip shows how many entries wait to upload; tap it to open the sync panel (online/offline, waiting, last sync, "Try to sync now").
- The cache is deleted 24 h after the event (`wipeAfter`), when the device is revoked (403) and on sign-out (which first tries to upload, and asks before deleting unsynced entries).

## Run

Same `--dart-define` keys as `apps/mobile` (see its README), with the `door:` key from the server's `API_KEYS`:

```bash
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=API_KEY=<door key> --dart-define=AUTH_MODE=fake
flutter run --dart-define=API_KEY=... --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... --dart-define=FIREBASE_MESSAGING_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...
```

`FIREBASE_APP_ID` must be the Firebase app registered for `tz.dcard.dcard_door` (Android) / the door iOS bundle ID. `API_BASE_URL` per device: see the mobile README. Do not add `flutter_pack` here: its plain `sqflite` conflicts with `sqflite_sqlcipher`.

## Test

```bash
flutter test
```

Cache tests run the real SQL on an in-memory SQLite (`sqflite_common_ffi`, dev only); the app itself opens it with SQLCipher.
