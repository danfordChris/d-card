# T03-04 — Scheduled messages: reminders, confirmation, event reminder, thank-you, quiet hours, plan limits

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-03-messaging.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/notifications/message-scheduling.md`, `docs/implementation/feature-inventory/notifications/quiet-hours.md`, `docs/implementation/feature-inventory/contributions/contribution-reminders.md`, `docs/implementation/feature-inventory/plans-and-billing/plan-limits.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/features/notifications.md` (NTF-3, NTF-6, NTF-7, NTF-8, MSG-6, MSG-7, MSG-8, MSG-11, MSG-12), `docs/design/features/plans-and-billing.md`
- Constraints: a scheduler job in the worker runs every few minutes and computes due messages from settings (idempotent per invitation, type and occurrence); times are in the event time zone; quiet hours 21:00–07:00 by default delay messages; plan entitlements cap reminders per contributor and block marketing messages (NTF-8) where not allowed; changing settings affects only unsent messages; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The worker sends contribution reminders, attendance confirmations, event reminders and post-event thank-yous at the configured times, respecting quiet hours and plan limits.

## Scope Boundary

**In scope:**
- `packages/core/src/messaging/schedule.ts`
- `apps/worker/src/messaging/scheduler.ts`

**Out of scope:**
- Host confirmation recording UI (phase 04)

## Acceptance Criteria

- [x] NTF-3 goes only to contributors with a balance, every N days, stopping at the plan's max per contributor and the optional stop date; Msingi sends none.
- [x] NTF-6 is sent N days before at the configured time only when confirmation is on; WhatsApp carries yes/no buttons with an opaque per-invitation token; SMS asks the guest to call/text the event contact.
- [x] NTF-7 goes 1 day before at 09:00 by default; NTF-8 (off by default) only on plans that allow marketing messages.
- [x] A message due during quiet hours is delayed to the next allowed time; the same occurrence is never sent twice even if the scheduler runs repeatedly.
- [x] Tests use a fixed clock covering each rule.

## Dependencies

- T03-02 done.

## Implementation Checklist

- [x] Due-message calculator + tests (fixed clock).
- [x] Scheduler job + idempotency.
- [x] Plan limits + quiet hours.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- `packages/core/src/messaging/schedule.ts` + `time.ts`; worker job `schedule-messages` every 5 minutes (dispatch every 5 s).
- Rules: NTF-6 N days before at HH:MM (default 2 days, 10:00) only when confirmation is on, only issued cards not yet confirmed, WhatsApp buttons carry the signed per-invitation token (T03-03); NTF-7 1 day before at 09:00; NTF-8 1 day after at 10:00 only when enabled and the plan allows marketing messages; one-off messages are skipped if more than 24 h late; NTF-3 to pledges with a balance (not cancelled), every N days (default 14) at 10:00, up to min(plan max, setting max), until the stop offset; fixed outbox keys make every occurrence idempotent. Quiet hours 21:00–07:00 (event time zone): the scheduler queues nothing and dispatch holds guest messages until the window ends (host test sends are not held). Scheduled messages run for draft and published events (publishing arrives with host payment in phase 05); cancelled/completed events are skipped.
- `packages/core/test/schedule.test.ts` (6, fixed clock): EAT local-time and quiet-hour boundaries; confirmation due at 07:00Z once, pending and late and confirmation-off events skipped; reminder at 09:00 and custom offset/time; post-event thanks on Premium only; reminders 1–3 then stop on Kawaida, none for the fully paid contributor, none on Msingi; quiet hours hold scheduling and dispatch until 07:30, test sends pass.
- Dispatch tests now use a fixed daytime clock (quiet hours would otherwise fail them at night).
- Ownership note: `messaging/settings.ts` and `api-contract/src/messages.ts` were written by another tool for T03-05; fixed (`smsLength` import, quiet hours removed from the per-message schedule — they are per event) and kept.
- `pnpm turbo run typecheck lint test build --force` → 23/23 (2026-09-25).
