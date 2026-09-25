# T01-10 — Admin: Event Types

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/events/event-types-and-templates.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/events.md` (EVT-5), `docs/design/domain/overview.md`
- Constraints: Admin-only (`user_account.is_admin`); deactivating a type hides it from new events but keeps existing events; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Admins list, create, rename and activate/deactivate event types via API and a web admin page.

## Scope Boundary

**In scope:**
- `packages/core/src/admin/event-types/**`
- `apps/web/src/app/api/v1/admin/event-types/**`
- `apps/web/src/app/(app)/admin/event-types/**`

**Out of scope:**
- Card templates (phase 02)
- Admin 2FA (phase 06)

## Acceptance Criteria

- [x] `GET/POST/PATCH /api/v1/admin/event-types` return 403 for non-admins.
- [x] Creating a type with a duplicate key returns 409; created types appear in `GET /api/v1/event-types` when active.
- [x] Deactivating a type removes it from `GET /api/v1/event-types` but existing events keep it; all changes audited.
- [x] Web admin page lists types and supports create/rename/toggle in sw/en.

## Dependencies

- T01-02 done.

## Implementation Checklist

- [x] Core admin module + tests.
- [x] API routes.
- [x] Web admin page.
- [x] Tests + build.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- Core `packages/core/src/admin/event-types/event-types.ts` + `test/admin-event-types.test.ts` (4): non-admin Forbidden; create (key normalised) appears in public list; duplicate → Conflict; bad key/name → Validation; rename + deactivate; existing event keeps its type, new events cannot use it; 3 audit rows by the admin.
- API `test/admin-event-types-api.test.ts` (3): GET/POST/PATCH → 403 for non-admin; POST 201, duplicate 409, empty key 422; PATCH deactivates (hidden from `GET /api/v1/event-types`, listed for admin), renames; unknown key 404; audited.
- Web `/admin/event-types` (admins only, `notFound()` otherwise; header "Admin" link for admins). `test/admin-event-types-ui.test.tsx` (3): sw labels, validation + create + duplicate message, rename + deactivate/activate.
- `pnpm turbo run typecheck lint test build` → 23/23 (web 79 tests) on 2026-09-24; `dcard_api` regenerated; melos analyze/test green.
