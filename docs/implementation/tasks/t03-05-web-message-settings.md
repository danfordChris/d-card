# T03-05 — Web message settings, SMS editor and test send

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-03-messaging.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/notifications/message-settings.md`, `docs/implementation/feature-inventory/notifications/sms-editor.md`, `docs/implementation/feature-inventory/notifications/whatsapp-templates.md`, `docs/implementation/feature-inventory/notifications/quiet-hours.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/notifications.md` (MSG-1…MSG-12)
- Constraints: Tailwind only; sw/en; host edits (committee read-only); controls not allowed by the plan are shown locked with an upgrade note; SMS editor enforces GSM checks, segment counter, required `{contact_phone}`, known placeholders; every change audited; changes reschedule unsent messages; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The host configures every guest message for an event (on/off, channels, SMS wording, WhatsApp variant and note, timing, quiet hours) and sends a test to their own phone.

## Scope Boundary

**In scope:**
- `packages/core/src/messaging/settings.ts`
- `apps/web/src/app/api/v1/events/[id]/messages/**`
- `apps/web/src/app/(app)/events/[id]/messages/**`
- `apps/web/src/features/messages/**`
- `packages/api-contract/src/**`

**Out of scope:**
- Adding the step to the create wizard (can follow)
- Manual send (T03-06)

## Acceptance Criteria

- [x] `GET/PUT /api/v1/events/{id}/messages` returns and saves settings for NTF-1…8 with defaults; NTF-4 cannot be disabled; plan-locked controls are rejected with 409 `plan_limit`.
- [x] The SMS editor shows live characters/segments, flags non-GSM characters, blocks unknown placeholders and missing `{contact_phone}`, and previews with a sample guest in sw/en.
- [x] WhatsApp settings choose an approved variant and a personal note (≤ 200 chars).
- [x] `POST /api/v1/events/{id}/messages/{type}/test` sends the message to the host's own phone (rate-limited).
- [x] Component tests cover the editor checks and locked controls in sw/en.

## Dependencies

- T03-01 done.

## Implementation Checklist

- [x] Settings service + API.
- [x] Editor + page.
- [x] Test send.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-25: `pnpm turbo run typecheck lint test build --force` → 27/27 tasks successful.
  - Core: `packages/core/test/message-settings.test.ts` (4 tests): defaults for NTF-1…8, committee read-only, NTF-4 cannot be disabled, SMS wording checks (unknown placeholder, missing contact, non-GSM), plan locks on Msingi, segment limit, test send to host phone.
  - API: `apps/web/test/messages-api.test.ts` (3 tests): committee GET 200 / PUT 403, stranger 403, host save, 422 for bad wording and disabling NTF-4, 409 `plan_limit`, test send 202 queues a `test:` outbox row, unknown type 422.
  - UI: `apps/web/test/message-settings-ui.test.tsx` (4 tests): live counter, GSM warning and sample preview; PUT of all 8 settings; locked channel/SMS controls; read-only viewer has no save; Swahili render with sw/en SMS tabs.
  - Screen: `apps/web/src/app/(app)/events/[id]/messages/page.tsx`, `apps/web/src/features/messages/*`, "Messages" link on the event summary.
