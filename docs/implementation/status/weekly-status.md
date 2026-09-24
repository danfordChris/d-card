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
