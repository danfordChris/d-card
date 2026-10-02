# D-Card

**Kadi za mwaliko za kidigitali** · Self-service digital invitation cards for events in Tanzania.

A host (and their committee) runs an event end to end: collect contributions (**michango**), send cards automatically on **WhatsApp and SMS**, get attendance confirmations, and check guests in at the door **online or offline**. Guests with basic phones are fully supported (SMS card numbers).

> **New here?** Read this file top to bottom, then [`AGENTS.md`](AGENTS.md) and [`docs/README.md`](docs/README.md). Everything decided about the product is in `docs/design/`; everything planned or in progress is in `docs/implementation/`.

---

## Contents

1. [Product in one minute](#1-product-in-one-minute)
2. [Architecture](#2-architecture)
3. [Repository layout](#3-repository-layout)
4. [Prerequisites](#4-prerequisites)
5. [Local setup](#5-local-setup)
6. [Environment keys](#6-environment-keys)
7. [Everyday commands](#7-everyday-commands)
8. [Testing](#8-testing)
9. [Mobile apps](#9-mobile-apps)
10. [Integration spikes](#10-integration-spikes)
11. [How we work (workflow contract)](#11-how-we-work-workflow-contract)
12. [Deployment](#12-deployment)
13. [Current status](#13-current-status)
14. [Handover checklist](#14-handover-checklist)
15. [Troubleshooting](#15-troubleshooting)

---

## 1. Product in one minute

| Who | What they do |
|-----|-------------|
| **Host** | Creates an event (any type), picks a plan (Msingi / Kawaida / Premium, Tsh 1,000–2,000 per guest card), pays via Snippe, invites the committee, adds guests, customises messages. |
| **Treasurer / committee** | Records pledges and payments. When a pledge is fully paid, the card is **issued and sent automatically**. |
| **Guest (smartphone)** | Opens the card link (no login), RSVPs, confirms attendance with WhatsApp buttons, shows the QR code at the door. |
| **Guest (basic phone)** | Receives SMS with a card number (e.g. `005-4827`) and the event contact's phone. |
| **Door staff** | Scan QR / enter card number in **D-Card Door**, admit 1 or 2 (double cards), handle walk-ins — works offline and syncs later. |

Details: [`docs/design/domain/overview.md`](docs/design/domain/overview.md) and [`docs/design/features/`](docs/design/features/).

## 2. Architecture

```
            ┌──────────────── Flutter ────────────────┐
            │  apps/mobile (D-Card)   apps/door (Door) │──┐
            └──────────────────────────────────────────┘  │ REST /api/v1 (Firebase ID token)
 Browser ──► apps/web (Next.js: dashboard + API + webhooks) ◄┘
                 │              │                 ▲ webhooks
                 ▼              ▼                 │
           PostgreSQL        Redis ──► apps/worker (BullMQ: messages, schedules)
           (Neon)                           │
                                            ▼
             Meta WhatsApp · NextSMS · Snippe · Google Drive (host's) · Firebase
```

| Concern | Choice | Decision record |
|---------|--------|-----------------|
| Web + API | Next.js 16 (App Router, Route Handlers), Vercel (Cape Town) | [ADR 0003](docs/adr/0003-technical-stack.md) |
| Mobile | Flutter 3.44 — two apps; local data **sqflite + shared_preferences only (no Hive)** | ADR 0003 |
| Database | PostgreSQL + Drizzle ORM (Neon in production) | ADR 0003 |
| Jobs | Redis + BullMQ, long-lived worker | ADR 0003 |
| Auth | Firebase Auth (email/password; Google/Apple for guests); roles in Postgres | ADR 0003 |
| Payments | Snippe (host plan payments) | ADR 0003 |
| Messaging | NextSMS (SMS) + Meta WhatsApp Cloud API | [messaging.md](docs/design/integrations/messaging.md) |
| Media | Host's Google Drive — **no media stored on D-Card servers** | [ADR 0002](docs/adr/0002-media-storage.md) |

## 3. Repository layout

| Path | What it is |
|------|-----------|
| `apps/web` | Next.js web dashboard, REST API (`/api/v1/*`), provider webhooks |
| `apps/worker` | BullMQ worker process (message sending, schedules, retention jobs) |
| `apps/mobile` | Flutter app **D-Card** (guests, hosts, committee) |
| `apps/door` | Flutter app **D-Card Door** (door check-in, offline) |
| `packages/db` | Drizzle schema, migrations (`drizzle/`), seed data, test DB helper |
| `packages/core` | Domain rules shared by web + worker: phone format, audit log, roles, queue names |
| `packages/api-contract` | Zod schemas → `openapi.json` (source for the Dart client) |
| `apps/site` | Public marketing site (Astro, static, Swahili + English, zero JavaScript); deployed separately (`docs/deployment.md`) |
| `http/` | Runnable API docs: one `.http` file per area for the JetBrains HTTP Client / httpYac, environments in `http/http-client.env.json` (see `http/README.md`) |
| `packages/env` | Typed list of every environment key + `env:check` |
| `packages/config` | Shared TypeScript config |
| `dart_packages/dcard_core` | Dart domain rules (mirrors `packages/core`) |
| `dart_packages/dcard_ui` | Shared Flutter theme and widgets |
| `dart_packages/dcard_api` | **Generated** Dart API client (do not edit; run `pnpm api:dart`) |
| `spikes/` | Manual provider checks (never run in CI) |
| `infra/` | Local Docker services (Postgres, Redis) |
| `scripts/` | Repo scripts (Dart client generation) |
| `docs/` | Design truth, ADRs, plans, research — see [`docs/README.md`](docs/README.md) |
| `.agents/workflows/workflow-contract` | Workflow contract (git submodule) |

## 4. Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Node.js | 24 (see `.nvmrc`) | `nvm use` |
| pnpm | 10 | `corepack enable` |
| Docker | any recent (OrbStack works) | Local Postgres + Redis |
| Flutter | 3.44+ (Dart 3.12) | FVM users: `~/fvm/default/bin` on `PATH` |
| Python | 3.10+ | Workflow validator |
| Android SDK / Xcode | — | Only for building the mobile apps |

## 5. Local setup

Full guide, with the apps on a simulator or phone, fake sign-in, and a local end-to-end run: **[docs/running-locally.md](docs/running-locally.md)**. Short version:

```bash
git clone --recurse-submodules <repo-url> d-card && cd d-card
cp .env.example .env            # then see section 6
pnpm install
pnpm infra:up                   # Postgres :55432, Redis :56379
pnpm env:check                  # core must be "ready"
pnpm --filter @dcard/db build
pnpm --filter @dcard/db db:migrate
pnpm --filter @dcard/db db:seed # event types + plans
pnpm --filter @dcard/web dev    # http://localhost:3000 (API health: /api/v1/health with X-API-Key)
pnpm --filter @dcard/worker start
pnpm --filter @dcard/site dev   # marketing site, http://localhost:4321
```

Generate local secrets for `.env`:

```bash
openssl rand -hex 32       # TOKEN_HASH_SECRET
openssl rand -base64 32    # DATA_ENCRYPTION_KEY
```

## 6. Environment keys

- **`.env.example`** is the documented template (committed). **`.env`** holds your values (gitignored).
- The web app loads the root `.env` itself (`apps/web/next.config.ts`), so `npm run dev` inside `apps/web` works. Restart the dev server after editing `.env`.
- Every key is declared in [`packages/env/src/schema.ts`](packages/env/src/schema.ts); a test fails if `.env.example` and the schema drift.
- Values starting with **`dummy_`** are placeholders. `pnpm env:check` lists them per provider; spikes and (later) adapters refuse to run with dummy values.

| Group | Keys | Where to get them |
|-------|------|-------------------|
| Core | `APP_URL`, `DATABASE_URL`, `DATABASE_URL_UNPOOLED`, `REDIS_URL`, `AUTH_VERIFIER`, `TOKEN_HASH_SECRET`, `DATA_ENCRYPTION_KEY`, `API_KEYS`, `NEXT_PUBLIC_DCARD_API_KEY` | Local Docker / Neon / Vercel; secrets via `openssl` |
| Firebase | `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`, `NEXT_PUBLIC_FIREBASE_*` | Firebase console → Project settings |
| WhatsApp | `WHATSAPP_ACCESS_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`, `WHATSAPP_BUSINESS_ACCOUNT_ID`, `WHATSAPP_APP_SECRET`, `WHATSAPP_WEBHOOK_VERIFY_TOKEN`, `WHATSAPP_API_VERSION` | Meta for Developers → WhatsApp → API Setup |
| NextSMS | `NEXTSMS_BASE_URL`, `NEXTSMS_API_TOKEN` (Base64 `username:password`), `NEXTSMS_SENDER_ID`, `NEXTSMS_WEBHOOK_VERIFY_TOKEN` | NextSMS dashboard; [API docs](https://documenter.getpostman.com/view/4680389/SW7dX7JL) |
| Google Drive | `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_REDIRECT_URI` | Google Cloud console → Credentials (enable Drive API) |
| Snippe | `SNIPPE_BASE_URL`, `SNIPPE_API_KEY`, `SNIPPE_WEBHOOK_SECRET` | Snippe Dashboard → Settings |
| Spikes (local) | `SPIKE_TEST_PHONE`, `SPIKE_PUBLIC_WEBHOOK_BASE_URL`, `WHATSAPP_TEST_TEMPLATE(_LANGUAGE)`, `GOOGLE_TEST_REFRESH_TOKEN` | Your own test resources |

Every `/api/v1` request must send `X-API-Key` with a key from `API_KEYS` (per client: web, mobile, door, tools); otherwise `401 invalid_api_key`.

`AUTH_VERIFIER=dev` (local default) accepts both real Firebase sign-in and test tokens `Authorization: Bearer fake:<uid>:<email>`; `fake` accepts only test tokens (automated tests). The server **refuses** both when `NODE_ENV=production`; Vercel uses `firebase`.

## 7. Everyday commands

| Command | Does |
|---------|------|
| `pnpm turbo run typecheck lint test build` | Full TypeScript pipeline (what CI runs) |
| `pnpm infra:up` / `pnpm infra:down` | Start / stop local Postgres + Redis |
| `pnpm env:check` | Validate `.env`; list dummy keys |
| `pnpm --filter @dcard/db db:generate` | Create a migration after editing `packages/db/src/schema.ts` |
| `pnpm --filter @dcard/db db:migrate` / `db:seed` | Apply migrations / seed data |
| `pnpm --filter @dcard/api-contract openapi` | Regenerate `openapi.json` |
| `pnpm api:dart` | Regenerate the Dart API client (Docker) |
| `pnpm mobile:analyze` / `pnpm mobile:test` | Analyze / test all Dart packages and apps (Melos) |
| `pnpm workflow:validate` | Validate docs against the workflow contract |

## 8. Testing

- **TypeScript:** Vitest. Database tests create an isolated database per package (`dcard_test_db`, `dcard_test_core`, `dcard_test_web`) on the local server — your dev data is never touched. Infra must be up.
- **API:** route handlers are tested directly (`apps/web/test`), including race-safety of account provisioning.
- **Dart/Flutter:** `pnpm mobile:test` (widget tests in both locales, `dcard_core` unit tests).
- **Phone format** rules have identical test cases in `packages/core` and `dart_packages/dcard_core` — change both together.

## 9. Mobile apps

Both Flutter apps share one Dart workspace and the `dcard_ui` design system (`docs/design/ui/design-system.md`). How to run them on the iOS Simulator, Android emulator or a phone, and the `--dart-define` settings: [docs/running-locally.md](docs/running-locally.md#5-mobile-app-and-door-app).

```bash
export PATH="$HOME/fvm/default/bin:$PATH"   # if using FVM
flutter pub get                              # from the repo root (pub workspace)
cd apps/mobile && flutter run -d ios --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=API_KEY=<mobile key> --dart-define=AUTH_MODE=fake
```

- `apps/mobile`: hosts and guests ([README](apps/mobile/README.md)). `apps/door`: check-in staff ([README](apps/door/README.md)).
- Localisation: `lib/l10n/app_en.arb` and `app_sw.arb` (Swahili + English), generated on `flutter pub get`.
- Structure per app: `lib/data` (services, repositories), `lib/domain`, `lib/ui/core`, `lib/ui/features/<feature>`.
- Store builds and releases are manual (Play Console / App Store Connect); see `docs/store-listings.md`.

## 10. Integration spikes

Manual scripts that prove each provider works with real keys (task [T00-10](docs/implementation/tasks/t00-10-live-integration-spikes.md)). They refuse to run while keys are dummy.

```bash
pnpm spike:webhooks     # local listener on :4040 (expose via an HTTPS tunnel)
pnpm spike:whatsapp     # template with Approve/Decline quick-reply payloads
pnpm spike:nextsms      # send SMS + poll delivery report
pnpm spike:drive        # folder + resumable upload into a test Drive
pnpm spike:snippe       # 500 TZS USSD push + poll status
```

Record results in `docs/research/spike-results.md`.

## 11. How we work (workflow contract)

This repo follows a planning-first contract ([`.agents/workflows/workflow-contract`](.agents/workflows/workflow-contract/README.md)):

1. Unresolved ideas → `docs/changes/proposed/` (or `wayfinding/` if foggy).
2. Approved behavior → `docs/design/`; hard decisions → `docs/adr/`.
3. Plans → `docs/implementation/` (project, phases, **tasks**, feature inventory, status).
4. Code is written **only against a task** that passes the readiness gate (objective, scope, acceptance criteria, session budget, verification).
5. Tasks close with verification evidence and a review in `docs/implementation/reviews/`.

Run `pnpm workflow:validate` before merging doc changes. Research notes (market, providers) are in `docs/research/` — reference only.

## 12. Deployment

| Component | Target | How |
|-----------|--------|-----|
| `apps/web` (dashboard + API) | **Vercel** (region `cpt1`) | GitHub Actions on push/PR — see [`docs/deployment.md`](docs/deployment.md) |
| Database | **Neon** (branch per pull request) | Migrations run in CI before deploy |
| `apps/worker` | Railway (planned) | Not in the pipeline yet |
| Mobile apps | Play Store / App Store | Manual by the owner |

## 13. Current status

- Phases 00–08 are merged or in review; phase 07 (pilots) waits for the owner. Phase files: [`docs/implementation/phases/`](docs/implementation/phases/).
- Feature-by-feature status: [`docs/implementation/feature-inventory/README.md`](docs/implementation/feature-inventory/README.md).
- Reviews per phase: [`docs/implementation/reviews/`](docs/implementation/reviews/). Launch: [`docs/launch/`](docs/launch/).
- Open questions: [`docs/changes/proposed/`](docs/changes/proposed/).

## 14. Handover checklist

- [ ] Access: GitHub repo (with the `workflow-doc` submodule), Vercel team, Neon project, Firebase project, Meta Business/WhatsApp, NextSMS, Snippe, Google Cloud.
- [ ] `.env` filled from `.env.example`; `pnpm env:check` shows every provider **ready**.
- [ ] GitHub Actions secrets set (list in `docs/deployment.md`).
- [ ] `pnpm turbo run typecheck lint test build` and `pnpm mobile:test` green locally.
- [ ] Read `docs/design/domain/overview.md`, `docs/adr/`, and the current phase file.
- [ ] External approvals tracked: Meta business verification, WhatsApp templates, NextSMS sender ID `DCARD`, Snippe KYC, Google OAuth verification, legal review (PDPA 2022).

## 15. Troubleshooting

| Symptom | Fix |
|---------|-----|
| `port is already allocated` on `infra:up` | Another project uses the port; set `DCARD_PG_PORT` / `DCARD_REDIS_PORT` in `.env` and update URLs |
| `Cannot connect to the Docker daemon` | Start Docker/OrbStack (`orb start`) |
| DB tests fail with connection errors | `pnpm infra:up`, check `DATABASE_URL` |
| `flutter: command not found` | Add Flutter (or `~/fvm/default/bin`) to `PATH` |
| `401` from `/api/v1/me` locally | Use `AUTH_VERIFIER=dev` and `Bearer fake:<uid>:<email>`, or a real Firebase ID token |
| Sign-up says it cannot start a session | `AUTH_VERIFIER` is `fake` (test tokens only) or the Firebase admin keys are wrong; use `dev` locally with real `FIREBASE_*` values |
| Next.js build tries to bundle `drizzle/` | Import migrations only from `@dcard/db/migrate`, never from the web app |
