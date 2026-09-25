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
