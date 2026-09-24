# System Architecture

## Context

- Modular monolith. Stack: Next.js (web + API), Flutter (2 apps), PostgreSQL, Redis.

## Technology Stack and Hosting
| Layer | Technology | Notes |
|-------|-----------|-------|
| Web app | **Next.js** (App Router, TypeScript) | Host, committee, admin and guest web views. |
| Backend API | **Next.js** (Route Handlers / Server Actions) | One codebase with the web app. REST/JSON API for the Flutter apps, plus provider webhooks. |
| Mobile | **Flutter**, **two apps** | **D-Card**: guests, hosts, committee, walk-in approvers. **D-Card Door**: door staff scanner with offline cache and sync. Shared Dart packages (API client, models, auth) in one repository. |
| Database | **PostgreSQL** | Source of truth for all business data and the audit log. |
| Messaging / jobs | **Redis** | Queues, scheduled jobs, retries, rate limits, lockouts, live updates (`docs/design/architecture/system.md`). |
| Background worker | Node.js worker (same repo, shared modules) | Long-lived process that consumes the Redis queues. |
| Integrations | **Firebase Auth** (email/password, Google & Apple sign-in; same Firebase project as FCM), **Google Drive API** (host media, `drive.file` scope), **Snippe** (host plan payments: mobile-money USSD push and hosted checkout, 2.5% per payment), **NextSMS** (outbound SMS, sender ID, delivery webhooks), **Meta WhatsApp Cloud API** (templates, quick-reply buttons, webhooks), email provider, push notifications (FCM/APNs). *(Inbound SMS reply number: backlog.)* | See [research/messaging-providers.md](../../research/messaging-providers.md). |

### 3.1 Hosting (managed cloud)
| Component | Host |
|-----------|------|
| Next.js web + API | **Vercel**, Cape Town region (closest to Tanzania) |
| Worker | Managed container host (Railway, Render or Fly.io), in or near an African region |
| PostgreSQL | Managed Postgres (e.g. Neon), in the region closest to the API |
| Redis | Managed Redis, in the same region as the worker |
| Media storage | **Host's Google Drive** via the Drive API (no D-Card media storage) |

**Architecture style:** a **modular monolith** with the modules
`Auth` · `Events` · `Guests & Invitations` · `Contributions` · `Check-in & Sync` · `Notifications` · `Media` · `Audit` · `Retention`.

## Messaging and Background Processing (Redis)
PostgreSQL is the **source of truth**. Redis handles:

| Use | Mechanism |
|-----|-----------|
| Outbound queues | One queue per channel (WhatsApp, SMS, email, push), e.g. BullMQ, with retries and exponential backoff. |
| Scheduled jobs | Confirmations, event reminders, contribution reminders, post-event thank-you (all at the times set by the host, respecting quiet hours), **retention job (event end + 14 days)**, offline-cache wipe. |
| SMS reply-window queue *(backlog)* | Per-phone queue of pending confirmations. The next one is released when the current window closes or expires. |
| Rate limiting | Per-provider send throttling. |
| Card-number lockout | Per-staff failure counter with a 5-minute TTL. |
| Live updates | Pub/Sub for check-ins, syncs, payments, walk-ins, pushed to web (SSE/WebSocket) and the apps. |
| Idempotency | Short-lived keys to deduplicate provider webhooks. |

Inbound flow: **provider webhook → Next.js route → verify signature → idempotency check → enqueue → worker updates Postgres → audit + pub/sub.**

## Non-Functional Requirements
| ID | Requirement |
|----|-------------|
| NFR-1 | Online check-in in under 2 s at p95 on a mobile connection. Offline check-in feels instant (< 300 ms). |
| NFR-2 | Guest card pages load quickly on slow 3G. |
| NFR-3 | Swahili and English across web, apps and messages. |
| NFR-4 | Automatic message retries. Permanent failures are visible to the host. |
| NFR-5 | Real-time dashboard updates within a few seconds. |
| NFR-6 | Supports 1,000+ guests and several gates. No over-admission while online. |
| NFR-7 | Times stored in UTC, shown in the event time zone. |
| NFR-8 | Offline entries sync within 1 minute of the network returning. |

## Security
- Authentication by **Firebase Auth** (password storage and hashing, email verification, password reset, brute-force protection). The API verifies Firebase ID tokens on every request, then applies roles from Postgres. TOTP 2FA for admins (Identity Platform). Login data held by Google must be covered in the data-protection review (O3).
- Per-event role checks. Door devices registered and revocable.
- Long random link and QR tokens, stored hashed.
- Offline cache encrypted and auto-wiped.
- Card-number brute-force lockout.
- Webhook signature verification.
- Google refresh tokens encrypted at rest. Only the `drive.file` scope is requested. Drive upload links are single-use and short-lived.
