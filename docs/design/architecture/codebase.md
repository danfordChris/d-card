# Codebase and Technology Choices

## Context

- Decisions recorded in `docs/adr/0003-technical-stack.md`.
- Applies to every workstream.

## Monorepo Layout
```
d-card/
├── apps/
│   ├── web/                 # Next.js (App Router): host/committee/admin UI, guest card pages,
│   │                        #   REST API for Flutter (/api/v1), provider webhooks (/api/webhooks/*)
│   ├── worker/              # Node.js long-lived process: BullMQ consumers + schedulers
│   ├── mobile/              # Flutter – "D-Card" app (guests, hosts, committee, approvers)
│   └── door/                # Flutter – "D-Card Door" app (scanner, offline cache, sync)
├── packages/
│   ├── core/                # Domain modules (TypeScript), shared by web + worker
│   │   └── src/modules/
│   │       auth · events · guests · contributions · cards · checkin · notifications
│   │       media · billing · plans · audit · retention · admin
│   ├── db/                  # Drizzle schema, migrations, seed data (event types, plans, templates)
│   ├── integrations/        # Adapters behind interfaces: NextSMS, Meta WhatsApp, Google Drive,
│   │                        #   Snippe, email, FCM/APNs
│   ├── api-contract/        # Zod schemas → OpenAPI spec → generated Dart client
│   └── config/              # Shared TS/ESLint/test config
├── dart_packages/
│   ├── dcard_api/           # Generated Dart API client (from api-contract)
│   ├── dcard_core/          # Shared models, auth/session, phone normalisation, i18n
│   └── dcard_ui/            # Shared widgets and theme
├── infra/                   # docker-compose (Postgres, Redis) for local dev, env templates
└── docs/
```
- **TypeScript:** pnpm workspaces + Turborepo. **Dart:** Melos for the two Flutter apps and shared packages.
- **One API contract** (`api-contract`) is the source of truth for web and Flutter. The Dart client is **generated**, so the backend and Flutter teams work in parallel against the spec.

## Technology Choices
| Concern | Choice | Why |
|---------|--------|-----|
| Web + API | Next.js App Router, TypeScript, Route Handlers | Agreed stack. Runs on Vercel Fluid Compute (Node.js, not Edge). |
| Database | PostgreSQL (Neon) + **Drizzle ORM** + drizzle-kit migrations | Typed SQL, easy conditional `UPDATE … RETURNING` for atomic check-in, and CHECK constraints and triggers |
| Validation / contract | **Zod** → OpenAPI (zod-to-openapi) → Dart client (openapi-generator) | One schema for validation, docs and the mobile client |
| Auth | **Firebase Auth**: email/password (management roles), Google/Apple (guests), `firebase_auth` in Flutter, Firebase JS SDK on web; the API verifies ID tokens with `firebase-admin`. **Admin 2FA** via TOTP (Identity Platform). **Roles, per-event permissions and the Person link stay in Postgres**, keyed by Firebase UID. | **Decided by the user.** Least work for two Flutter apps (native Google/Apple sign-in, token refresh), proven security, free up to 50k MAU, and the same Firebase project as FCM. Postgres + Drizzle stays for all data (Firestore rejected: no atomic conditional updates for check-in, relational reporting, per-read costs). |
| Queues / scheduling | **BullMQ** on Redis | Delayed jobs, retries, rate limits, repeatable jobs (reminders, retention) |
| Redis hosting | Redis next to the worker (e.g. Railway Redis or Redis Cloud) | BullMQ needs a persistent connection. Serverless per-request Redis is a poor fit. |
| Realtime dashboard | Server-Sent Events from Next.js + Redis pub/sub | Works on the Node runtime; no extra service |
| Card image (WhatsApp) | Server-side render (e.g. `@vercel/og`/Satori or `sharp`) with the QR code, generated per send | Meets "no media storage" |
| i18n | `next-intl` (web), Flutter `intl`/ARB | Swahili + English everywhere |
| Flutter | Riverpod, go_router, dio (generated client), `mobile_scanner`, FCM | Standard, testable |
| Flutter local storage | **`sqflite_sqlcipher`** (encrypted SQLite) for the Door check-in cache, local entries, sync queue, lockout counters and offline walk-ins, and for cached cards/events in the D-Card app · **`shared_preferences`** only for small non-sensitive settings (selected event, language, last gate) · **`flutter_secure_storage`** for session tokens and the database encryption key | Indexed lookups by QR hash, card number and name for 1,000+ guests; atomic transactions for check-in; simple "unsynced" queries; encryption at rest. **Decided: only sqflite and shared_preferences are used for local data. Hive is not used** (the original is unmaintained, and it has no query language or real transactions). |
| Payments | **Snippe** (`@snippe/sdk`): USSD push via `POST /v1/payments` (M-Pesa, Airtel Money, Mixx by Yas, Halotel), hosted checkout via `POST /v1/sessions` (incl. cards), webhooks, `Idempotency-Key`; behind a `PaymentGateway` interface | **Decided by the user.** 2.5% per mobile-money payment, no monthly/setup fees; payouts available for Phase 3 contributions. API limit 60 requests/min. |
| Testing | Vitest (core), Playwright (web), Flutter widget + integration tests, Testcontainers (Postgres/Redis) | Covers domain rules, UI flows and the offline sync |
| CI | GitHub Actions: lint, typecheck, tests, migrations check, Flutter build; Vercel preview per PR | |

## Deployment
| Component | Where |
|-----------|-------|
| `apps/web` | Vercel, Cape Town region (preview per PR, production on `main`) |
| `apps/worker` | Railway/Render/Fly container, close to the Postgres and Redis regions |
| Postgres | Neon (branch per preview environment) |
| Redis | Managed Redis next to the worker |
| Mobile | Play Store + App Store (internal testing tracks from sprint 4) |

## Contracts

- `GET /api/v1/health` returns 200 `{"status":"ok"}` when Postgres is reachable, 503 otherwise.
- All `/api/v1/*` responses are JSON; errors use `{"error":{"code","message"}}`.
