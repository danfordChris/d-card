# Review Report — 2026-09-24 (Phase 00: T00-01 to T00-06)

## Summary

- Reviewed tasks T00-01…T00-06 against `docs/design/` and task acceptance criteria.
- Result: all six tasks pass. T00-07 (Flutter SDK) and T00-08 (provider credentials) remain blocked.
- Full pipeline: `pnpm turbo run typecheck lint test build` → 19/19 tasks successful; Dart: 14/14 tests.

## Standards

- Domain rules live in `packages/core` (phone, audit, roles, queues); route handlers are thin and delegate to `apps/web/src/server/*`.
- Every state change in scope writes an audit row (`account.created` in the same transaction as the insert).
- Strict TypeScript (TS 6.0, `noUncheckedIndexedAccess`), ESLint flat config, no `any` in production code.
- Tests use isolated databases (`dcard_test_*`) created per package; dev data is never touched.
- Deviation: local ports 55432/56379 (another project uses 5432/6379); overridable via env; CI uses defaults.
- Deviation: T00-05 added one export line to `packages/core/src/index.ts` after T00-03 closed (no behavior change).

## Spec

- Phone format matches `docs/design/features/guests-and-cards.md` (GST-3): 255 + 9 digits; TS and Dart implementations share identical test cases.
- `audit_log` is append-only per `docs/design/data-models/postgres.md`; UPDATE allowed only via the `dcard.audit_mask` transaction flag reserved for retention masking; DELETE/TRUNCATE blocked.
- Plans seeded exactly as `docs/design/features/plans-and-billing.md` (1,000 / 1,500 / 2,000 TZS per guest; entitlements per table).
- Auth follows `docs/design/integrations/firebase.md`: Firebase ID token → `user_account` by UID; `POST /api/v1/me` idempotent (201 then 200, race-safe); `GET /api/v1/me` 404 until provisioned.
- Fake verifier refused in production (verified: production server returns 401 for `fake:` tokens).
- Health contract per `docs/design/architecture/codebase.md` (`GET /api/v1/health` → 200 `{"status":"ok"}`).

## Verification

- Command: `pnpm turbo run typecheck lint test build` and `cd dart_packages/dcard_core && dart test`
- Evidence: 19 successful turbo tasks (db 6 tests, core 21, web 7, worker 2); Dart 14 tests passed; evidence per task in `docs/implementation/tasks/t00-0[1-6]-*.md`.

## Follow-ups

- CI checks out the workflow-contract submodule over SSH (`git@github.com:danfordChris/workflow-doc.git`); GitHub Actions needs a deploy key or HTTPS URL, or the validator step fails.
- `firebaseVerifier` calls `verifyIdToken(token, true)` (revocation check = one Firebase call per request); revisit caching when load-testing in phase 07.
- Unblock T00-07: install the Flutter SDK on build machines.
- Unblock T00-08: create Meta test number, NextSMS account, Google Cloud project, Snippe test key.
