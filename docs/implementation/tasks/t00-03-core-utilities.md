# T00-03 — Core Utilities: Phone, Audit, Roles

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/core-utilities.md`, `docs/implementation/feature-inventory/privacy-and-audit/audit-log.md`, `docs/implementation/feature-inventory/auth/per-event-roles.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/features/guests-and-cards.md`, `docs/design/features/privacy-and-audit.md`, `docs/design/domain/overview.md#users-and-roles`
- Constraints: Pure functions and DB helpers only; no HTTP; follow design phone format exactly
- Do not touch: `docs/design/`, `.agents/`, other tasks' scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a design decision is missing (record it in `docs/changes/proposed/` instead of deciding).

## Objective

`packages/core` provides tested phone normalisation, an audit writer and a per-event role check.

## Scope Boundary

**In scope:**
- `packages/core/src/phone/**`
- `packages/core/src/audit/**`
- `packages/core/src/auth/roles*`
- `packages/core/src/errors*`
- `packages/core/package.json`, `tsconfig.json`, `vitest.config.ts`, `src/index.ts`

**Out of scope:**
- `packages/core/src/queues/**` (T00-05)
- HTTP routes (T00-04)

## Acceptance Criteria

- [x] `normalisePhone` returns `255754123456` for `0754123456`, `+255754123456`, `754123456`, `255754123456` and `0754 123 456`.
- [x] `normalisePhone` throws `InvalidPhoneError` for inputs that do not reduce to `255` + 9 digits (e.g. `12345`, `2557541234567`).
- [x] `formatLocalPhone("255754123456")` returns `0754 123 456`.
- [x] `recordAudit` inserts one `audit_log` row with actor, event, action, target, old and new values.
- [x] `requireEventRole` allows the event host and users holding a listed role, and throws `ForbiddenError` otherwise.
- [x] `pnpm --filter @dcard/core test` exits 0.

## Dependencies

- T00-02 done.

## Implementation Checklist

- [x] Implement phone module with tests.
- [x] Implement errors module.
- [x] Implement audit writer with DB test.
- [x] Implement role check with DB test.
- [x] Export from `src/index.ts`.

## Verification

- Command: `pnpm --filter @dcard/core test`
- Evidence:

```
$ pnpm --filter @dcard/core test
  phone.test.ts: normalises 0754123456, +255754123456, 754123456, 255754123456,
                 "0754 123 456", "+255 754-123-456" → 255754123456
                 rejects "12345", "2557541234567", "", "07541234ab", "+0754123456",
                 "+754123456", "07541234567" with InvalidPhoneError
                 formatLocalPhone("255754123456") → "0754 123 456"
  db.test.ts:    recordAudit inserts one row (actor, event, action, target, old/new);
                 system actor when none; requireEventRole allows host and listed role,
                 throws ForbiddenError for unlisted role / no role, NotFoundError for unknown event
  Test Files 2 passed (2) · Tests 21 passed (21)
$ pnpm turbo run typecheck lint test build --filter=@dcard/core... → 8 successful, 8 total
```
