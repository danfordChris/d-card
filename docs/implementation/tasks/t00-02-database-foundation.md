# T00-02 — Database Foundation

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/database-foundation.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/data-models/postgres.md`, `docs/design/domain/overview.md`, `docs/design/features/plans-and-billing.md`
- Constraints: Drizzle ORM + drizzle-kit; schema v1 limited to foundation tables; money as integer TZS; timestamps in UTC
- Do not touch: `docs/design/`, `.agents/`, other tasks' scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass, or the local database is unreachable
- Handoff when: context becomes recap-heavy, or a design decision is missing (record it in `docs/changes/proposed/` instead of deciding).

## Objective

`packages/db` defines schema v1 (person, user_account, event_type, plan, event, event_role, audit_log) with migrations and idempotent seed data.

## Scope Boundary

**In scope:**
- `packages/db/**`

**Out of scope:**
- Invitation, pledge, payment and later-phase tables (phases 01–05)
- Business logic (packages/core)

## Acceptance Criteria

- [x] `pnpm --filter @dcard/db db:migrate` exits 0 against the compose Postgres.
- [x] `pnpm --filter @dcard/db db:seed` run twice leaves exactly 6 event types and 3 plans (msingi 1000, kawaida 1500, premium 2000 TZS per guest).
- [x] `person.phone` has a unique constraint; `user_account.firebase_uid` has a unique constraint.
- [x] An `UPDATE` or `DELETE` on `audit_log` raises a database error (append-only trigger).
- [x] `pnpm --filter @dcard/db test` exits 0.

## Dependencies

- T00-01 done.

## Implementation Checklist

- [x] Create `packages/db` with Drizzle config and client.
- [x] Define schema v1 tables and enums.
- [x] Generate the migration and add the append-only trigger migration.
- [x] Write seed for event types and plans (entitlements JSON per `plans-and-billing.md`).
- [x] Write tests against the compose Postgres.

## Verification

- Command: `pnpm --filter @dcard/db db:migrate && pnpm --filter @dcard/db db:seed && pnpm --filter @dcard/db db:seed && pnpm --filter @dcard/db test`
- Evidence:

```
$ pnpm --filter @dcard/db db:migrate   → db:migrate ok (0000_foundation, 0001_audit_log_append_only)
$ pnpm --filter @dcard/db db:seed (×2)  → db:seed ok, db:seed ok
$ psql: event_types|6, plans|3 → msingi|1000, kawaida|1500, premium|2000
$ pnpm --filter @dcard/db test
  ✓ seed is idempotent: 6 event types and 3 plans after two runs
  ✓ rejects duplicate person phones (person_phone_unique)
  ✓ rejects phones not in 255 + 9 digits format (person_phone_format)
  ✓ rejects duplicate firebase_uid (user_account_firebase_uid_unique)
  ✓ blocks UPDATE and DELETE (append-only trigger)
  ✓ allows UPDATE only inside a masking transaction (dcard.audit_mask)
  Tests 6 passed (6)
$ pnpm turbo run typecheck lint test → 3 successful, 3 total
```
- Tests run in an isolated `dcard_test_db` database (`@dcard/db/testing`).
