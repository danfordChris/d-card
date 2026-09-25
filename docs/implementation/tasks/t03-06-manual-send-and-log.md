# T03-06 — Manual send to groups and host message log

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-03-messaging.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/notifications/manual-send.md`, `docs/implementation/feature-inventory/notifications/message-log-and-cost.md`, `docs/implementation/feature-inventory/notifications/stop-optout.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/notifications.md` (MSG-13, MSG-14, MSG-9)
- Constraints: host only; plan limit on manual sends per event; groups: all, unpaid (balance > 0), not confirmed, issued cards; quiet hours respected; the host sees delivery status per guest and who opted out, but not internal costs; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The host sends a chosen message to a filtered group now and sees the delivery log and opt-outs for the event.

## Scope Boundary

**In scope:**
- `packages/core/src/messaging/manual.ts`
- `apps/web/src/app/api/v1/events/[id]/messages/send/**`, `.../messages/log/**`
- `apps/web/src/features/messages/**` (log and send views)

**Out of scope:**
- Admin cost reports (later)

## Acceptance Criteria

- [x] `POST /api/v1/events/{id}/messages/send` with a message type and group queues one message per matching guest; the plan's manual-send limit returns 409 `plan_limit` when exceeded.
- [x] `GET /api/v1/events/{id}/messages/log` lists messages with guest, type, channel, status and time, filterable; costs are not included.
- [x] The web log shows statuses and an opt-out list; the send dialog shows the recipient count before confirming.
- [x] Tests cover groups, limits and the log in sw/en.

## Dependencies

- T03-02 done.

## Implementation Checklist

- [x] Manual send service + API.
- [x] Log API.
- [x] Web views.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-25: `pnpm turbo run typecheck lint test build --force` → 27/27 tasks (core 120, web 151, worker 23 tests); `dart run melos run analyze` clean and `melos run test` green after regenerating `dcard_api`.
  - Core: `packages/core/test/manual-send.test.ts` (3 tests): recipient counts for all/confirmed/not_confirmed/unpaid, reminders reach unpaid contributors without a card, committee forbidden, marketing and manual-send limits → `PlanLimitError`, empty group → `ConflictError`, one outbox row per guest (`manual:<batch>:<invitation>`) and an audit row per send; log newest first without costs, status/channel/search filters, counts, cursor paging across rows sharing `created_at`, opt-outs.
  - API: `apps/web/test/manual-send-api.test.ts` (2 tests): preview 200 with counts, send 202, committee 403, bad group 422, third send 409 `plan_limit`; log 200 for committee, bad status 422.
  - UI: `apps/web/test/message-log-ui.test.tsx` (10 tests, built by a subagent against the contract): preview then confirm, plan_limit, locked at 0 sends, zero recipients, log items and opt-outs, filters in the URL, load more, sw renders.
  - OpenAPI: `registerMessagePaths` documents settings, test, send and log; Dart client regenerated.
