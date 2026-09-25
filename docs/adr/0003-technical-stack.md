# ADR 0003 — Technical Stack

## Date

2026-09-24

## Decision

| Area | Decision |
|------|----------|
| Web + backend | Next.js (App Router, Route Handlers), TypeScript, on Vercel (Cape Town) |
| Mobile | Flutter: two apps, **D-Card** and **D-Card Door** |
| Database | PostgreSQL (Neon) with **Drizzle ORM** |
| Queues / messaging jobs | Redis + BullMQ, consumed by a long-lived Node.js worker |
| Authentication | **Firebase Auth** (email/password; Google/Apple for guests). Roles and permissions in Postgres, keyed by Firebase UID |
| Push notifications | Firebase Cloud Messaging / APNs |
| Payments (host plans) | **Snippe** (snippe.sh), behind `PaymentGateway` |
| SMS | NextSMS |
| WhatsApp | Meta WhatsApp Cloud API, one D-Card number |
| Media | Host's Google Drive (ADR 0002) |
| Flutter local storage | **sqflite (`sqflite_sqlcipher`) and `shared_preferences` only — no Hive.** `flutter_secure_storage` holds tokens and the DB key only |
| Repo tooling | One monorepo: pnpm + Turborepo (TypeScript), Melos (Dart) |
| Worker + Redis hosting | Railway, near the Neon/Vercel region |
| API contract | Zod → OpenAPI → generated Dart client |
| Web UI | **Tailwind CSS only** (own components, no component library); `next-intl` for Swahili/English |
| Email | **Resend** (team invitation emails), behind `EmailSender` |

## Reason

- Stack agreed by the product owner. Firestore rejected: check-in needs atomic conditional SQL updates and contributions need relational reporting.
- Firebase Auth minimises auth work for two Flutter apps and shares the FCM project.
- Snippe chosen by the product owner: 2.5% mobile money, no monthly fee, USSD push on all major networks, Node SDK.
- Web UI: product owner chose Tailwind only (2026-09-24).
- Email: product owner chose invite link + email; Resend picked for its free tier and Next.js fit (research: `docs/research/`).
- Hive rejected: original package unmaintained; no query language or transactions.

## Impacted Docs

- `docs/design/architecture/system.md`
- `docs/design/architecture/codebase.md`
- `docs/design/integrations/*`
