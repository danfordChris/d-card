# D-Card (mobile)

Flutter app for hosts, committee and guests. How to run it: [docs/running-locally.md](../../docs/running-locally.md#5-mobile-app-and-door-app). Design: `docs/design/ui/design-system.md` (all UI comes from `dart_packages/dcard_ui`).

## Structure

- `lib/data/services/` — `AuthService` (Firebase, dev fake), API client factory (adds the Firebase ID token to every request).
- `lib/data/repositories/` — `SessionRepository` (sign-in, one-time `POST /api/v1/me`), events, guests, contributions, billing, walk-ins, my cards, account, push registration, `ThemeRepository` (Light / Dark / System, `shared_preferences` key `settings.theme_mode`).
- `lib/domain/models/` — app models (`EventSummary`, `AppFailure`).
- `lib/ui/features/<feature>/{view_models,views}` — MVVM screens. `home/home_shell.dart` holds the five-tab spotlight bar: Home, My cards, New event, Notifications, Account.
- Screens use only `dcard_ui` (`context.dc` colours, `DcType`, `DcTile`, `DcButton`, …). No Material icons (Hugeicons only), no hex colours.
- Local storage: `shared_preferences`. Never Hive.

## Run

Build-time settings use `--dart-define`:

| Key | Default | Purpose |
|---|---|---|
| `API_BASE_URL` | `http://10.0.2.2:3000` | D-Card API. iOS Simulator: `http://localhost:3000`; Android emulator: the default; phone: your computer's LAN IP; production: `https://api.dcard.danfordchris.dev` |
| `API_KEY` | — | **Required.** The `mobile:` key from the server's `API_KEYS`; sent as `X-API-Key` on every request |
| `AUTH_MODE` | `firebase` | `fake` = sign in with any email (debug builds only; the API must run with `AUTH_VERIFIER=dev` or `fake`) |
| `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID` | — | Firebase project (Project settings → Your apps) |
| `SENTRY_DSN` | — | Crash reports (optional) |

Local development against the local API, without Firebase (iOS Simulator):

```bash
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=API_KEY=<mobile key from .env API_KEYS> --dart-define=AUTH_MODE=fake
```

With Firebase:

```bash
flutter run --dart-define=API_KEY=... --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... --dart-define=FIREBASE_MESSAGING_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...
```

## Test

```bash
flutter test
```
