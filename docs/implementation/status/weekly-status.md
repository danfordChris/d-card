# Weekly Status

## 2026-09-24

- Requirements approved and migrated into the workflow layers: `docs/design/`, `docs/adr/0001–0003`, `docs/changes/proposed/`.
- MVP plan migrated to `docs/implementation/` (project, phases 00–07, backlog, feature inventory: 11 features, 81 subfeatures).
- Phase 00 started. Tasks T00-01 to T00-06 ready; T00-07 blocked (Flutter SDK missing); T00-08 blocked (provider credentials).
- T00-01…T00-06 done and reviewed (`docs/implementation/reviews/2026-09-24-phase-00-review.md`): monorepo + CI, local Postgres/Redis, schema v1 + seed, core utilities, API health + account provisioning, worker runtime, Dart core package.
- Phase 00 stays `in-progress`: T00-07 blocked (Flutter SDK), T00-08 blocked (provider credentials).
- T00-07 done: Flutter pub workspace + Melos, D-Card and D-Card Door shells (sw/en), shared `dcard_ui`, generated `dcard_api`; both debug APKs build.
- T00-08 done: `packages/env` + documented `.env.example`, local `.env` (dummy provider keys), `pnpm env:check`, four provider spikes + webhook listener, handover README.
- T00-09 done: CI (TypeScript + Flutter) and Deploy workflow (Neon branch per PR + Vercel preview; migrate + Vercel production on `main`); `docs/deployment.md`.
- Remaining in phase 00: T00-10 live spikes (blocked on real keys).
- Phase 01 planned and started: T01-01…T01-10 (events API, web foundation/login, event wizard, guests API/UI, import, team invitations, mobile login/events, contacts import, admin event types). Decisions: invite link + email (Resend), web UI Tailwind only (ADR 0001 O18, ADR 0003).
- Exception: phase 00 stays open only for T00-10 (live spikes, blocked on keys); does not block phase 01.
- Phase 01 done and reviewed (`docs/implementation/reviews/2026-09-24-phase-01-review.md`): events API + web wizard, guests (form, Excel/CSV import, copy from past event, phone contacts in the D-Card app), team invitations (link + email), D-Card app host login and events, admin event types. Live Firebase/Resend checks wait for real keys.

## 2026-09-25

- Phase 02 planned and started: T02-01…T02-07 (card issue core, contributions core, guest card page, card image renderer, web contributions, web card issue, mobile treasurer). Decisions: RSVP Yes/No (O19), built-in card design until templates (O20), card tokens hashed + encrypted copy (ADR 0003). Branch `feat/phase-02-contributions-cards` stacked on PR #2.
- Phase 02 done and reviewed (`docs/implementation/reviews/2026-09-25-phase-02-review.md`): card issue with numbers and tokens, cancel/reinstate, pledges/payments/refunds with auto-upgrade and auto-issue, web contributions dashboard and export, guest card page with RSVP and calendar, card image renderer, D-Card app treasurer screens.
- Web sign-up fix: local `AUTH_VERIFIER=dev` (test + real Firebase tokens) and specific error messages; the owner must enable Firebase Authentication (Email/Password) in the console (`auth/configuration-not-found`).
- API client keys: `X-API-Key` required on every `/api/v1` request (per-client `API_KEYS`), sent by the web app, the D-Card app (`--dart-define=API_KEY`) and every `http/` request; OpenAPI declares the scheme.
- Phase 02 committed; PR #3 (stacked on #2). Owner requests (navigation, card templates, Drive folders, guest event history) recorded in the backlog for design.
- Phase 03 planned and started: T03-01…T03-08 (messaging foundation, transactional messages, webhooks + STOP, scheduling, settings UI, manual send + log, admin templates/rates, push setup). Decisions: webhook exemption from API keys, transactional outbox (ADR 0003).
- T03-01 done and reviewed: messaging schema, templates, GSM/segment validation, transactional outbox, NextSMS/Meta adapters, BullMQ dispatch/retry, message log and internal cost tracking. Full TypeScript pipeline passes.
- Phase 03 tasks T03-02…T03-08 done: transactional and scheduled messages, WhatsApp/NextSMS webhooks and STOP, host message settings (SMS editor, timing, test send), manual send to groups and the message log, admin WhatsApp templates and provider rates, push token registration. Reviewed (`docs/implementation/reviews/2026-09-25-phase-03-review.md`); phase stays `in-progress` until live WhatsApp sends (T00-10).
- Local e2e sent 4 real SMS through the owner's NextSMS account to test numbers; the worker now uses the NextSMS test endpoint unless `NEXTSMS_LIVE=true`.

## 2026-09-26

- Production: web app on Vercel (`api.dcard.danfordchris.dev`, functions fra1) with Neon Postgres and Upstash Redis (Frankfurt, free); marketing site on `dcard.danfordchris.dev`; WhatsApp keys and webhook live (signed POSTs verified). Worker host still to do. `WHATSAPP_LIVE` added: only production sends WhatsApp.
- Phase 04 planned and started: T04-01…T04-07 (check-in core, offline sync API, confirmations + headcount, door app online, door app offline, walk-ins, live dashboard + backup list). Split: lead T04-01/02/06 backend, JetBrains assistant T04-03, subagents for the door app, approver screens and dashboard.
- Phase 04 done and reviewed (`docs/implementation/reviews/2026-09-26-phase-04-review.md`): online and offline door check-in with CRDT sync and over-use alerts, lockout, walk-ins with push approvals, WhatsApp first-answer confirmations with replies, manual confirmations and expected headcount, live dashboard and printable backup list, D-Card Door app (online + encrypted offline cache).
- UI direction recorded: reference projects analysed (`docs/research/ui-reference-projects.md`), design-system proposal (`docs/design/ui/design-system.md`) and backlog items; owner decisions pending (colours, starter pack, dark mode, prototype).

## 2026-09-27

- Phase 05 tasks T05-01…T05-06 done and reviewed (`docs/implementation/reviews/2026-09-27-phase-05-review.md`): Snippe checkout (mobile money + hosted) with exactly-once unlock, pricing rules and launch offer, payment gate on cards and guest messages; Google Drive connect, folders, sharing modes, direct uploads, private streaming, quota and missing files; web checkout, host media and slideshow, guest gallery; mobile checkout. Phase stays `in-progress` until one real Snippe payment and a live Drive check (owner setup).
- Worker and Redis moved to Railway (europe-west4, pinned TLS for Vercel); `WHATSAPP_LIVE` / `SNIPPE_LIVE` switches.
