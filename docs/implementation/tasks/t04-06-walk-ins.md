# T04-06 — Walk-in requests and approvals (online and offline)

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-04-confirmation-check-in.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/check-in/walk-in-requests.md`, `docs/implementation/feature-inventory/check-in/offline-walk-ins.md`

## Agent Context

- Owner: Claude Code (lead): backend; subagents: approver screens
- Skills: `vercel:nextjs`, `flutter-apply-architecture-best-practices`
- Design docs: `docs/design/features/check-in.md` (CHK-8, CHK-8a, walk-in states)
- Constraints: online: `pending → approved | refused`, the first approver to answer decides and everyone sees who decided; push to the host and all walk-in approvers (first `sendToUser` caller); offline: `admitted_offline → accepted | flagged` with a mandatory reason; approved/accepted walk-ins count as entries; all audited; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); phone numbers stored as `255` + 9 digits; sw/en for every user-facing string; web UI Tailwind only
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Door staff request walk-ins, the host and approvers get a push and the first answer decides, and offline walk-ins sync for review.

## Scope Boundary

**In scope:**
- `packages/core/src/checkin/walk-ins.ts`
- `apps/web/src/app/api/v1/door/walk-ins/**`, `apps/web/src/app/api/v1/events/[id]/walk-ins/**`
- `apps/worker/src/push/**` wiring (job)
- `apps/web/src/features/walk-ins/**`
- `apps/mobile/lib/**` (approver screen)
- `apps/door/lib/**` (request + offline walk-in screens)

**Out of scope:**
- Dashboard (T04-07)

## Acceptance Criteria

- [x] `POST /api/v1/door/walk-ins` creates a pending request and pushes to host + approvers.
- [x] The first `approve`/`refuse` wins; a later answer gets 409 with who decided; approved walk-ins count as entries.
- [x] Offline walk-ins upload through sync as `admitted_offline` with their reason; host/approver marks `accepted` or `flagged`.
- [x] Web and D-Card app approver screens; door request and offline walk-in screens.
- [x] Tests cover the race (two approvers), offline review and audit.

## Dependencies

- T04-01 and T04-02 done.

## Implementation Checklist

- [x] Model + services.
- [x] APIs + push job.
- [x] Web approval.
- [x] Mobile approver screen.
- [x] Door screens.
- [x] Tests + pipelines.

## Verification

- Command: `pnpm turbo run typecheck lint test build` and `dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-26: `pnpm turbo run typecheck lint test build` green for the walk-in code (core 140, web 166, worker 28); Flutter analyze clean, door 72 / mobile 43 tests; APKs build.
  - Core `packages/core/test/walk-ins.test.ts` (7 tests): pending request once with push to host + every approver; two approvers racing → one wins, the other gets 409 with who decided; approved walk-in is an extra entry, never charged to the linked card; host/committee/approvers list, only host and approvers decide; offline walk-ins sync as `admitted_offline` with reason and entry, reviewed once (accept/flag); users holding several roles (committee + approver) can decide (`roles` on events); lockout refusal carries the host push.
  - Worker `apps/worker/test/push.test.ts`: `notify` job pushes to every device of each user, deduplicated; skips quietly without FCM keys. Host alerts for lockout and over-use now go through the same `push` queue.
  - Screens: web approval page (`apps/web/test/walk-ins-ui.test.tsx`, 5 tests), D-Card app approver screen with push routing (20 tests), door request + online wait for decision + offline walk-in with mandatory reason (door walk-in view-model tests) — built by subagents, verified by the lead.
