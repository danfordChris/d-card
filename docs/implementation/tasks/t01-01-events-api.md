# T01-01 — Events API (create, list, edit, cancel)

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/events/event-contact.md`, `docs/implementation/feature-inventory/events/event-settings.md`, `docs/implementation/feature-inventory/plans-and-billing/plans-and-entitlements.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/events.md`, `docs/design/features/plans-and-billing.md`, `docs/design/data-models/postgres.md`, `docs/design/integrations/firebase.md`
- Constraints: Business rules in `packages/core`; route handlers stay thin; every change audited; phones stored as 255XXXXXXXXX; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts can create, list, view, edit and cancel events (with plan choice, type, details, contact and settings) through `/api/v1`.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` + new migration (`event_plan`)
- `packages/core/src/events/**`
- `apps/web/src/app/api/v1/events/**`, `apps/web/src/app/api/v1/event-types/**`, `apps/web/src/app/api/v1/plans/**`
- `packages/api-contract/src/**` (event schemas)

**Out of scope:**
- Publishing (needs payment, phase 05)
- Web UI (T01-03)

## Acceptance Criteria

- [x] `GET /api/v1/plans` returns the 3 active plans with price and entitlements; `GET /api/v1/event-types` returns active event types.
- [x] `POST /api/v1/events` with valid data returns 201 with status `draft`, the chosen plan stored in `event_plan`, `contact_phone` normalised to 255XXXXXXXXX, and one `event.created` audit row.
- [x] `POST /api/v1/events` returns 422 with code `invalid_phone` for an invalid contact phone, and 422 `validation_error` for a missing title, unknown plan or inactive event type.
- [x] `GET /api/v1/events` returns only events where the caller is host or holds an event role.
- [x] `PATCH /api/v1/events/{id}` by the host updates details/contact/settings and audits old and new values; by any other user returns 403.
- [x] `POST /api/v1/events/{id}/cancel` by the host sets status `cancelled` (audited); editing a cancelled event returns 409.
- [x] `packages/api-contract/openapi.json` includes the new paths.

## Dependencies

- T00-04 done.

## Implementation Checklist

- [x] Add `event_plan` table + migration.
- [x] Write `packages/core/src/events` (create, list, get, update, cancel) with tests.
- [x] Add zod schemas and OpenAPI paths.
- [x] Add route handlers.
- [x] Route tests with the fake verifier.

## Verification

- Command: `pnpm turbo run typecheck lint test build` && pnpm --filter @dcard/api-contract openapi
- Evidence:

```
$ pnpm --filter @dcard/core test   → 34 passed (events: create/draft + plan snapshot + audit; Msingi auto-upgrade refused;
                                      invalid phone/title/plan/type/headcount/endsAt rejected; list = host or member;
                                      host-only edit with old/new audit; cancel + 409 afterwards)
$ pnpm --filter @dcard/web test    → 21 passed (events-api: plans 3, event types 6, 401 unauthenticated,
                                      403 account_not_provisioned, 201 draft + event_plan + audit, 422 invalid_phone,
                                      422 validation_error with issue paths, 409 plan_limit, list scoped to caller,
                                      host PATCH 200 / others 403 / 404 malformed+unknown id, cancel 200 then PATCH 409)
$ pnpm --filter @dcard/api-contract openapi → paths: /api/v1/event-types, /api/v1/events, /api/v1/events/{id},
                                      /api/v1/events/{id}/cancel, /api/v1/health, /api/v1/me, /api/v1/plans
$ pnpm turbo run typecheck lint test build → 23 successful, 23 total
```
- Migration `0002_event_plan.sql`; shared error types added to `packages/core/src/errors.ts` (ValidationError, ConflictError, PlanLimitError).
- Fix found on the way: `NODE_ENV` removed from `.env`/`.env.example` (sourcing it broke `next build`).
