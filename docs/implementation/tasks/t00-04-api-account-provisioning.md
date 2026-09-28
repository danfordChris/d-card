# T00-04 — API Skeleton and Account Provisioning

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/api-contract.md`, `docs/implementation/feature-inventory/auth/account-provisioning.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/integrations/firebase.md`, `docs/design/features/auth.md`, `docs/design/architecture/codebase.md`
- Constraints: Next.js App Router Route Handlers on the Node runtime; Firebase ID tokens verified with `firebase-admin`; a fake verifier is allowed only when `NODE_ENV` is not `production` and `AUTH_VERIFIER=fake`
- Do not touch: `docs/design/`, `.agents/`, other tasks' scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass, or Next.js cannot be installed
- Handoff when: context becomes recap-heavy, or a design decision is missing (record it in `docs/changes/proposed/` instead of deciding).

## Objective

`apps/web` serves `/api/v1/health` and `/api/v1/me` (Firebase-authenticated account provisioning) and `packages/api-contract` emits the OpenAPI spec.

## Scope Boundary

**In scope:**
- `apps/web/**`
- `packages/api-contract/**`

**Out of scope:**
- Web UI screens beyond a placeholder home page (phase 01)
- Real Firebase project setup (external task)

## Acceptance Criteria

- [x] `GET /api/v1/health` returns 200 `{"status":"ok"}` when Postgres is reachable.
- [x] `POST /api/v1/me` without `Authorization` returns 401.
- [x] `POST /api/v1/me` with a valid token for a new UID returns 201 and creates one `user_account`; a second call returns 200 with the same `id`; exactly one `account.created` audit row exists.
- [x] `GET /api/v1/me` returns 200 with the account for a provisioned UID and 404 for an unprovisioned one.
- [x] `pnpm --filter @dcard/api-contract openapi` writes `packages/api-contract/openapi.json` containing `/api/v1/health` and `/api/v1/me`.
- [x] `pnpm --filter @dcard/web build` and `pnpm --filter @dcard/web test` exit 0.

## Dependencies

- T00-03 done.

## Implementation Checklist

- [x] Scaffold `apps/web` (Next.js, TS, App Router).
- [x] Create `packages/api-contract` with zod schemas and OpenAPI generator.
- [x] Implement token verifier (firebase-admin + non-production fake).
- [x] Implement health and me route handlers using `@dcard/core` and `@dcard/db`.
- [x] Write route tests; build.

## Verification

- Command: `pnpm --filter @dcard/api-contract openapi && pnpm --filter @dcard/web test && pnpm --filter @dcard/web build`
- Evidence:

```
$ pnpm --filter @dcard/api-contract openapi → wrote packages/api-contract/openapi.json
  paths: ['/api/v1/health', '/api/v1/me']
$ pnpm --filter @dcard/web test   (isolated DB dcard_test_web, AUTH_VERIFIER=fake)
  ✓ GET /api/v1/health returns 200 {status: ok}
  ✓ POST /api/v1/me without Authorization returns 401
  ✓ POST with an invalid token returns 401
  ✓ GET for an unprovisioned UID returns 404
  ✓ POST creates the account once (201 then 200) with one account.created audit row
  ✓ concurrent POSTs for one UID create exactly one account
  ✓ GET returns the provisioned account
  Tests 7 passed (7)
$ pnpm turbo run typecheck lint test build → 15 successful, 15 total
  Route (app): ○ /, ƒ /api/v1/health, ƒ /api/v1/me
$ next start (NODE_ENV=production, AUTH_VERIFIER=firebase)
  GET  /api/v1/health                          → 200 {"status":"ok"}
  POST /api/v1/me (no auth)                    → 401 unauthorized
  POST /api/v1/me (Bearer fake:uid)            → 401 "Invalid or expired token." (fake tokens rejected in production)
```
