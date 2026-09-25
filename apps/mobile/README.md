# D-Card (mobile)

Flutter app for guests, hosts and committee. See the root `README.md` for workspace setup.

## Structure

- `lib/data/services/` — `AuthService` (Firebase, dev fake), API client factory (adds the Firebase ID token to every request).
- `lib/data/repositories/` — `SessionRepository` (sign-in, one-time `POST /api/v1/me`), `EventsRepository`.
- `lib/domain/models/` — app models (`EventSummary`, `AppFailure`).
- `lib/ui/features/<feature>/{view_models,views}` — MVVM screens.
- Local storage: `shared_preferences` (and `sqflite` later). Never Hive.

## Run

Build-time settings use `--dart-define`:

| Key | Default | Purpose |
|---|---|---|
| `API_BASE_URL` | `http://10.0.2.2:3000` | D-Card API (10.0.2.2 = your machine from the Android emulator) |
| `AUTH_MODE` | `firebase` | `fake` = dev sign-in (debug builds only; API must run with `AUTH_VERIFIER=fake`) |
| `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID` | — | Firebase project (Project settings → Your apps) |

Local development against `pnpm dev` without Firebase:

```bash
flutter run --dart-define=AUTH_MODE=fake
```

With Firebase:

```bash
flutter run --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... --dart-define=FIREBASE_MESSAGING_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...
```

## Test

```bash
flutter test
```
