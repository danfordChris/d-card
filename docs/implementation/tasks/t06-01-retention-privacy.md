# T06-01 — Retention job, gallery closing and guest privacy rights

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-06-completion.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/privacy-and-audit/retention-anonymisation.md`, `docs/implementation/feature-inventory/privacy-and-audit/gallery-page-closing.md`, `docs/implementation/feature-inventory/privacy-and-audit/guest-data-export-delete.md`, `docs/implementation/feature-inventory/privacy-and-audit/privacy-notice.md`

## Agent Context

- Owner: Claude Code (lead) — core, schema, worker; web privacy page and account screens by a subagent
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/privacy-and-audit.md` (W13, MVP privacy basics), `docs/design/features/media.md` (gallery page period), `docs/design/features/auth.md`
- Constraints: the audit log stays append-only except a retention-only masking path guarded by a transaction-local setting; card tokens may only be cleared (never changed) by retention; the host's invitation snapshot (name, phone, pledge, payments, entries) is never touched; the job is idempotent and audited (`retention.run`); commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Two weeks after an event ends, guests without an account are anonymised while the host keeps its records; gallery pages close after the plan period; registered guests can download and delete their data; a privacy notice is published.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` (`event.retention_done_at`) + migration (trigger exceptions for retention)
- `packages/core/src/privacy/**`
- `apps/worker/src/**` (daily retention job)
- `apps/web/src/app/api/v1/me/{export,route}`
- `apps/web/src/app/privacy/**`, account screen links

**Out of scope:**
- PDPA legal review (owner, O3)
- Guest sign-in itself (T06-02)

## Acceptance Criteria

- [x] Daily worker job finds events ended ≥ 14 days ago and not yet processed; for each invitation whose Person has no linked account: `person_id` cleared, link and QR tokens cleared (card link returns 404), Person deleted when it has no other invitations, roles or accounts, `message_log.to_phone`/`body` masked, audit `old_value`/`new_value` personal fields (`phone`, `name`, `guestPhone`, `guestName`) masked; `retention_done_at` set; a `retention.run` audit row with counts.
- [x] Registered guests (Person linked to an account) keep their link, tokens and history.
- [x] Gallery: after the plan's page period the card-page gallery and its media return 410 — enforced on every read, so no job is needed (covered by `packages/core/test/media.test.ts`).
- [x] `GET /api/v1/me/export` returns a JSON file of the signed-in user's account, Person, invitations (event title, date, card number, RSVP, confirmation, contributions) and uploaded media metadata; audited `privacy.exported`.
- [x] `DELETE /api/v1/me` deletes the Firebase user and the D-Card account; a guest's Person is unlinked and treated like an unregistered guest (anonymised now for ended events); hosts who still have events are refused with a clear message (delete the events first); audited `account.deleted`.
- [x] `/privacy` page (sw/en) explains what D-Card stores, why, retention, rights and contact; linked from the card page, sign-up and the apps.
- [x] Tests cover anonymisation, idempotency, registered-guest exemption, export contents and delete.

## Dependencies

- None.

## Implementation Checklist

- [x] Schema + migration with guarded trigger exceptions.
- [x] Core retention service + tests.
- [x] Worker daily job.
- [x] Export and delete endpoints + tests.
- [x] Privacy page and links (subagent).
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 (core 192, web 241, worker 30, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
  - Core `retention.test.ts` (5): W13 anonymises unregistered guests 14 days after the event (person unlinked/deleted, link+QR tokens cleared → card link 404, message logs and audit personal fields masked, host snapshot kept, `retention.run` audited), registered guests and recent events untouched, idempotent; audit log append-only and tokens immutable outside retention; export contents; delete tombstones the account and anonymises past cards; hosts with events refused.
  - Migration `0016_retention` (`user_account.deleted_at`; token-clearing exception guarded by transaction-local `dcard.retention`). Worker job `run-retention` daily 03:00 EAT.
  - Web `privacy-api.test.ts`: `GET /api/v1/me/export` JSON attachment, `DELETE /api/v1/me` removes the Firebase user; `privacy-page.test.tsx`: `/privacy` in sw/en; links from sign-in/sign-up, card page and marketing site. Mobile: Download my data / Delete my account (widget tests).
  - Gallery pages close on read after the plan period (410, `media.test.ts`).
  - Legal wording and contact address wait for the owner (O3).
