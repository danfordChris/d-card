# T06-03 — Admin panel: users, events, audit search, queues and admin 2FA

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-06-completion.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/auth/admin-2fa.md`

## Agent Context

- Owner: Claude Code (lead) — core, API, 2FA; admin screens by a subagent
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/auth.md` (AUTH-7), `docs/design/features/admin.md` if present, `docs/design/features/privacy-and-audit.md`
- Constraints: admin 2FA is app-level TOTP (RFC 6238, authenticator apps) — Firebase TOTP MFA needs the paid Identity Platform upgrade; TOTP secret AES-GCM encrypted; 10 one-time recovery codes stored hashed; every admin API route requires a verified second factor (signed httpOnly cookie, 12 h); commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Admins manage users and events, search the audit log and see queue health, and admin access needs a second factor.

## Scope Boundary

**In scope:**
- `packages/core/src/admin/{users,events,audit,totp}.ts`
- `packages/db/src/schema.ts` (`admin_totp`) + migration
- `apps/web/src/app/api/v1/admin/{users,events,audit,queues,2fa}/**`
- `apps/web/src/app/(app)/admin/{users,events,audit,queues,security}/**`

**Out of scope:**
- Template/plan/rates/launch-offer screens (already shipped in P03/P05)
- Cost report (T06-05)

## Acceptance Criteria

- [x] Admin 2FA: enrol (QR `otpauth://` URI + confirm code), verify, recovery codes, disable (needs a code); admin routes return 403 `second_factor_required` until verified; failures rate-limited and audited.
- [x] Users: search by email/phone, view roles and events, grant/revoke admin (not self), disable/enable account (audited).
- [x] Events: search by title/host/date, view plan, payments, card counts and message totals; read-only.
- [x] Audit search: filter by event, actor, action prefix, date range; paginated; CSV export.
- [x] Queues: counts (waiting, active, failed, delayed) per queue from Redis; retry failed jobs.
- [x] Tests cover TOTP verification (window ±1 step), recovery codes single-use, route guard and searches.

## Dependencies

- None.

## Implementation Checklist

- [x] TOTP core + schema + tests.
- [x] Admin guard in web layer.
- [x] Users/events/audit/queues APIs + tests.
- [x] Admin screens (subagent).
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 (core 192, web 241, worker 30, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
  - Core `totp.test.ts` (4): RFC 6238 vectors, ±1 step, no code reuse, single-use recovery codes, lockout after 5 failures (15 min), signed 12 h proof bound to the user. `admin-platform.test.ts`: user/event/audit search, grant/revoke admin and disable (never self, audited), audit CSV.
  - Migration `0017_admin` (`admin_totp`, `user_account.disabled_at`); disabled accounts refused (`account_disabled`).
  - Web `admin-platform-api.test.ts`: every admin route needs the second factor (`second_factor_required`), enrol → confirm → cookie, users/events/audit/CSV/cost; existing admin tests send the proof cookie. `admin-platform-ui.test.tsx` (9): 2FA gate, users actions, cost report. Pages: Users, Events, Audit, Queues, Cost report, Security.
