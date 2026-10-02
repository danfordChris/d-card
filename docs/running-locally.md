# Running the apps

How to run every part of D-Card on your machine, and how to point the apps at production. Tool versions are in the root `README.md` (section 4).

| Part | Where | Default address |
|---|---|---|
| Web app and API (Next.js) | `apps/web` | http://localhost:3000 |
| Background worker (BullMQ) | `apps/worker` | — (logs only) |
| Marketing site (Astro) | `apps/site` | http://localhost:4321 |
| D-Card mobile app (host and guest) | `apps/mobile` | simulator or phone |
| D-Card Door (check-in) | `apps/door` | simulator or phone |
| Postgres and Redis | `infra/docker-compose.yml` | Postgres `:55432`, Redis `:56379` |

## 1. One-time setup

```bash
git clone --recurse-submodules <repo-url> d-card && cd d-card
cp .env.example .env
pnpm install
```

Fill in `.env`. For local work you need only the **Core** group; every other provider can stay `dummy_…`, and those features then use fakes (see section 7).

- **`TOKEN_HASH_SECRET`:** `openssl rand -hex 32`.
- **`DATA_ENCRYPTION_KEY`:** `openssl rand -base64 32`.
- **`API_KEYS`:** one random key per client, `web:<key>,mobile:<key>,door:<key>,tools:<key>,worker:<key>`. Make each key with `openssl rand -hex 24`. Set `NEXT_PUBLIC_DCARD_API_KEY` to the `web` key and `WORKER_API_KEY` to the `worker` key.
- **`AUTH_VERIFIER=dev`:** accepts real Firebase sign-in and the test tokens `fake:<uid>:<email>`, so the apps can sign in without Firebase.

Then start the database and cache, migrate and seed:

```bash
pnpm infra:up
```

```bash
pnpm env:check
```

```bash
pnpm --filter @dcard/db build && pnpm --filter @dcard/db db:migrate && pnpm --filter @dcard/db db:seed
```

`pnpm env:check` should report **core: ready**. The seed adds event types, plans and message templates. Docker must be running (OrbStack works). If Docker hangs, restart it (`open -a OrbStack`) and run `pnpm infra:up` again.

## 2. Web app and API

```bash
pnpm --filter @dcard/web dev
```

- Open http://localhost:3000. Check the API with `curl -H "x-api-key: <web key>" http://localhost:3000/api/v1/health`. The answer is `{"status":"ok"}`.
- Sign up at `/signup` (this needs real `FIREBASE_*` keys), or use the mobile app with fake sign-in (section 5).
- **Theme:** the web app follows the system light/dark setting. The Light/Dark/System switch in the side navigation saves the choice in a cookie.
- **To reach the API from a physical phone**, start it on all interfaces and use your computer's LAN address in the app (section 5):

```bash
pnpm --filter @dcard/web exec next dev -H 0.0.0.0 -p 3000
```

The web app loads the root `.env` itself. Restart the dev server after changing `.env`.

## 3. Background worker

The worker sends SMS, WhatsApp, push and email, dispatches the outbox, polls payments, runs the daily retention job and sends health alerts.

```bash
pnpm --filter @dcard/worker start
```

Leave it running next to the web app; without it, messages stay in the outbox. Locally, messages are never delivered for real:
- **SMS:** without `NEXTSMS_LIVE=true`, SMS go to the NextSMS test endpoint.
- **WhatsApp:** without `WHATSAPP_LIVE=true`, WhatsApp messages are held.
- **Payments:** without `SNIPPE_LIVE=true`, payments use a fake gateway.

## 4. Marketing site

```bash
pnpm --filter @dcard/site dev
```

Open http://localhost:4321. Contact buttons stay hidden until `SITE_WHATSAPP`, `SITE_PHONE` or `SITE_EMAIL` is set, and "Sign up" appears once `SITE_APP_URL` is set.

## 5. Mobile app and Door app

Both apps are Flutter apps in one Dart workspace. Put Flutter on `PATH` (FVM users: `~/fvm/default/bin`) and fetch packages once from the repository root:

```bash
export PATH="$HOME/fvm/default/bin:$HOME/fvm/default/bin/cache/dart-sdk/bin:$PATH"
```

```bash
flutter pub get
```

### Settings (`--dart-define`)

| Key | Needed | What to put |
|---|---|---|
| `API_BASE_URL` | yes, except on the Android emulator | Where the API runs (table below) |
| `API_KEY` | yes | The `mobile` key (mobile app) or `door` key (Door app) from `API_KEYS` |
| `AUTH_MODE` | for local work | `fake`: sign in with any email, no Firebase (debug builds only; the API must run with `AUTH_VERIFIER=dev` or `fake`) |
| `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID` | for real sign-in | Firebase console → Project settings → Your apps. The Door app uses the app registered for `tz.dcard.dcard_door` |
| `SENTRY_DSN` | optional | Crash reports; leave out locally |

| Where the app runs | `API_BASE_URL` |
|---|---|
| iOS Simulator | `http://localhost:3000` |
| Android emulator | `http://10.0.2.2:3000` (the default) |
| Physical phone on the same Wi-Fi | `http://<your computer's LAN IP>:3000`, with the API started on `0.0.0.0` (section 2). Find the IP with `ipconfig getifaddr en0` on macOS |
| Production API | `https://api.dcard.danfordchris.dev` |

### Run the mobile app (host and guest)

List the simulators and devices Flutter can see:

```bash
flutter devices
```

iOS Simulator with fake sign-in against your local API:

```bash
cd apps/mobile && flutter run -d ios --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=API_KEY=<mobile key> --dart-define=AUTH_MODE=fake
```

Android emulator:

```bash
cd apps/mobile && flutter run -d android --dart-define=API_KEY=<mobile key> --dart-define=AUTH_MODE=fake
```

- **Signing in:**
  - With `AUTH_MODE=fake`, enter any email.
  - "Continue with Google" or "Continue with Apple" in fake mode signs in a test guest.
  - With the Firebase keys set, real Google, Apple and email sign-in work, once the providers are enabled in the Firebase console.
- **Theme:** Account → Theme switches Light, Dark or System. The choice is kept on the phone.
- **Tabs:** Home, My cards, New event (points hosts to the web for now), Notifications, Account.

### Run the Door app

Same settings, with the `door` key:

```bash
cd apps/door && flutter run -d ios --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=API_KEY=<door key> --dart-define=AUTH_MODE=fake
```

- Sign in as a person the host added as **door staff** (or the host). Only the events that person works appear.
- Open the event once while online; the guest list is then kept on the phone, encrypted, for offline check-in.
- The Door app follows the phone's light/dark setting.

### A quick end-to-end run on one machine

1. Start `pnpm infra:up`, the web app (section 2) and the worker (section 3).
2. Create an event and add guests on the web, or sign in on the mobile app as a host.
3. Pay for the event (event → Plan and payment). Locally the fake gateway leaves the payment **pending**. To complete it, open the browser console on that page and run the snippet below (development only). Use the `web` key; `<event id>` is the id in the page address.

```js
const key = "<web key>", id = "<event id>";
const b = await (await fetch(`/api/v1/events/${id}/billing`, { headers: { "x-api-key": key } })).json();
await fetch(`/api/v1/events/${id}/checkout/${b.pendingAttempt.id}/simulate`, {
  method: "POST",
  headers: { "x-api-key": key, "content-type": "application/json" },
  body: JSON.stringify({ status: "completed" }), // or "failed"
});
```

4. Issue cards. On the guests page, **Open link** on a guest row shows the guest's card page (`/c/<token>`).
5. On the web, Team → invite a person as door staff. Sign in as that person in the Door app, open the event, and scan the guest's QR code from the card page, or type its card number.

## 6. Admin area

Admin pages live under `/admin` on the web app. To make an account an admin locally:

```bash
docker exec -it dcard-postgres-1 psql -U $(docker exec dcard-postgres-1 printenv POSTGRES_USER) -d dcard -c "update user_account set is_admin = true where email = 'you@example.com';"
```

On the first visit, set up two-step sign-in with an authenticator app (scan the QR code, confirm a code, keep the recovery codes). The database name is in `DATABASE_URL`, if yours differs.

## 7. What works without provider keys

| Feature | Without keys | With keys |
|---|---|---|
| Sign-in | `AUTH_VERIFIER=dev` + `AUTH_MODE=fake` in the apps; web sign-up needs Firebase | Real Firebase sign-in |
| SMS / WhatsApp | Held or sent to the test endpoint; message log shows them | Real delivery only with `NEXTSMS_LIVE` / `WHATSAPP_LIVE` (production) |
| Payments | Fake gateway; complete or fail a payment with the development-only simulate call (section 5, end-to-end run) | Real Snippe only with `SNIPPE_LIVE=true` (production) |
| Google Drive media | Fake store (uploads succeed, files are not kept) | Real Drive with `GOOGLE_OAUTH_*` |
| Push notifications | Skipped | FCM with the Firebase keys |
| Email (team invites) | Skipped | Resend with `RESEND_API_KEY` and a verified `EMAIL_FROM` |

## 8. Pointing the apps at production

For testing a release build against the live API, use `API_BASE_URL=https://api.dcard.danfordchris.dev`, the production `mobile` or `door` key, and the real Firebase settings. There is no fake sign-in in release builds. The owner keeps the production keys outside the repository. Never commit them or put them in `.env.example`.

```bash
cd apps/mobile && flutter run --release --dart-define=API_BASE_URL=https://api.dcard.danfordchris.dev --dart-define=API_KEY=<production mobile key> --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... --dart-define=FIREBASE_MESSAGING_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...
```

Store builds: `docs/store-listings.md`. Deployment of the web app and worker: `docs/deployment.md`.

## 9. Tests and checks

| What | Command |
|---|---|
| Everything TypeScript (what CI runs) | `pnpm turbo run typecheck lint test build` |
| Flutter analyze / tests (all apps and packages) | `pnpm mobile:analyze` / `pnpm mobile:test` |
| One Flutter app | `cd apps/mobile && flutter test` (or `apps/door`) |
| Load tests (local, fake providers) | `pnpm load:all` (`docs/load-tests.md`) |
| Docs against the workflow contract | `pnpm workflow:validate` |

Database tests create their own `dcard_test_*` databases, so your local data is never touched. Docker must be running.

## 10. Troubleshooting

| Problem | Fix |
|---|---|
| App says it cannot reach the server | Check `API_BASE_URL` for where the app runs (section 5); on a phone, start the API with `-H 0.0.0.0` and use the LAN IP |
| `401 invalid_api_key` | `API_KEY` must be the `mobile` or `door` entry of the server's `API_KEYS` |
| Fake sign-in rejected | The API needs `AUTH_VERIFIER=dev` (or `fake`); fake sign-in works only in debug builds |
| Messages never leave the outbox | Start the worker (section 3); the web app only queues |
| `Cannot connect to the Docker daemon` or tests hang | Restart Docker (`open -a OrbStack`), then `pnpm infra:up` |
| Tests fail on dates or payment windows after Docker was stuck | The Docker VM clock may have drifted; quit and reopen OrbStack |
| iOS build fails on pods | `cd apps/mobile/ios && pod install` (or `apps/door/ios`), then build again |
| `flutter: command not found` | Add Flutter (or `~/fvm/default/bin`) to `PATH` |
