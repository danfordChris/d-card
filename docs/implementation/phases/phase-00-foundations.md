# Phase 00 — Foundations (weeks 1–2)

## Status

- `in-progress`
- Last updated: 2026-09-24

## Objective

- deployable skeleton; login works on web and Door; all 4 integration spikes proven (or risks logged).

## Scope

| A. Platform | B. Web | C. Mobile |
|-------------|--------|-----------|
| Monorepo, CI, envs; Neon + Redis; worker skeleton with BullMQ | Next.js app shell, design system, i18n (sw/en), auth screens | Melos workspace, both app shells, theme, i18n, generated API client pipeline |
| Drizzle schema v1: person, user_account, event, event_role, invitation, pledge, payment, audit_log, plan, event_type | Admin: event types and plans (seeded) | Login (email/password) for Door; secure session storage |
| Firebase project (Auth + FCM); `firebase-admin` token verification middleware → `user_account` lookup by UID; per-event role middleware; `normalisePhone()` (255…) with tests | | Spike: **sqflite_sqlcipher offline cache + QR scan** prototype |
| **Spikes:** Meta template with quick-reply payload + webhook · NextSMS send + delivery webhook · Drive resumable upload from a browser · Snippe test USSD push | | |

## Included Features

- `docs/implementation/feature-inventory/platform-foundation/environment-config.md`
- `docs/implementation/feature-inventory/platform-foundation/deployment-pipeline.md`
- `docs/implementation/feature-inventory/platform-foundation/monorepo-and-ci.md`
- `docs/implementation/feature-inventory/platform-foundation/local-infra.md`
- `docs/implementation/feature-inventory/platform-foundation/database-foundation.md`
- `docs/implementation/feature-inventory/platform-foundation/core-utilities.md`
- `docs/implementation/feature-inventory/platform-foundation/api-contract.md`
- `docs/implementation/feature-inventory/platform-foundation/worker-runtime.md`
- `docs/implementation/feature-inventory/platform-foundation/dart-core-package.md`
- `docs/implementation/feature-inventory/platform-foundation/flutter-workspace.md`
- `docs/implementation/feature-inventory/auth/account-provisioning.md`
- `docs/implementation/feature-inventory/auth/per-event-roles.md`
- `docs/implementation/feature-inventory/privacy-and-audit/audit-log.md`

## Task Checklist

- [x] T00-01 — Monorepo, CI and local infrastructure (`docs/implementation/tasks/t00-01-monorepo-ci-infra.md`)
- [x] T00-02 — Database foundation (`docs/implementation/tasks/t00-02-database-foundation.md`)
- [x] T00-03 — Core utilities: phone, audit, roles (`docs/implementation/tasks/t00-03-core-utilities.md`)
- [x] T00-04 — API skeleton and account provisioning (`docs/implementation/tasks/t00-04-api-account-provisioning.md`)
- [x] T00-05 — Worker runtime (`docs/implementation/tasks/t00-05-worker-runtime.md`)
- [x] T00-06 — Dart core package (`docs/implementation/tasks/t00-06-dart-core-package.md`)
- [x] T00-07 — Flutter workspace and app shells (`docs/implementation/tasks/t00-07-flutter-workspace.md`)
- [x] T00-08 — Environment config, spike scripts, README (`docs/implementation/tasks/t00-08-integration-spikes.md`)
- [x] T00-09 — CI/CD: web + API to Vercel with Neon (`docs/implementation/tasks/t00-09-ci-cd-vercel-neon.md`)
- [ ] T00-10 — Live integration spikes (`docs/implementation/tasks/t00-10-live-integration-spikes.md`)

## Acceptance Criteria

- [ ] deployable skeleton; login works on web and Door; all 4 integration spikes proven (or risks logged).
- [ ] Every linked task is `done` with verification evidence.
- [ ] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- T00-10 blocked: real provider test keys (Meta, NextSMS, Google Cloud, Snippe) not yet in `.env`.

## Review

- `docs/implementation/reviews/2026-09-24-phase-00-review.md`
- `docs/implementation/reviews/2026-09-24-phase-00-review-2.md`

## Linked Tasks

- docs/implementation/tasks/t00-01-monorepo-ci-infra.md
- docs/implementation/tasks/t00-02-database-foundation.md
- docs/implementation/tasks/t00-03-core-utilities.md
- docs/implementation/tasks/t00-04-api-account-provisioning.md
- docs/implementation/tasks/t00-05-worker-runtime.md
- docs/implementation/tasks/t00-06-dart-core-package.md
- docs/implementation/tasks/t00-07-flutter-workspace.md
- docs/implementation/tasks/t00-08-integration-spikes.md
- docs/implementation/tasks/t00-09-ci-cd-vercel-neon.md
- docs/implementation/tasks/t00-10-live-integration-spikes.md
