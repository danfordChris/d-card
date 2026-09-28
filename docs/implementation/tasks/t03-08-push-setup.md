# T03-08 — Push notification setup (device tokens, FCM sender)

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-03-messaging.md`
- Feature-inventory subfeature(s): none (setup for NTF-9/NTF-10 in phase 04)

## Agent Context

- Skills: `flutter-apply-architecture-best-practices`
- Design docs: `docs/design/integrations/firebase.md` (FCM/APNs), `docs/design/features/notifications.md` (NTF-9, NTF-10)
- Constraints: Firebase Cloud Messaging via firebase-admin behind a `PushSender` interface (fake in tests); apps register their device token after sign-in; no push content is sent in this phase except a test; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The apps register device tokens and the server can send a push notification to a user's devices.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` + migration (`device_token`)
- `apps/web/src/app/api/v1/me/devices/**`
- `apps/worker/src/push/**`
- `apps/mobile/lib/**` (token registration)
- `apps/door/lib/**` (token registration)

**Out of scope:**
- Walk-in and lockout alerts (phase 04)

## Acceptance Criteria

- [x] `POST /api/v1/me/devices` stores a token per user/device (upsert); `DELETE` removes it.
- [x] The worker `PushSender` sends to all tokens of a user and removes tokens FCM reports as invalid.
- [x] Both apps register the token after sign-in (behind an interface, fake in widget tests).
- [x] Tests pass; Android builds pass.

## Dependencies

- T03-01 done.

## Implementation Checklist

- [x] Schema + API.
- [x] Push sender + tests.
- [x] App registration.
- [x] Tests + builds.

## Verification

- Command: `pnpm turbo run typecheck lint test build && dart run melos run test`
- Evidence:

- 2026-09-25 (built by a subagent, verified by the lead): `pnpm turbo run typecheck lint test build --force` → 27/27 tasks (web `devices-api.test.ts` 8 tests; worker `push.test.ts` 7 tests); `dart run melos run analyze` no issues; `melos run test` → core 14, ui 1, door 4, mobile 22 passing; `flutter build apk --debug` passed for mobile and door (subagent run).
  - Migration `packages/db/drizzle/0012_push_devices.sql` (`device_token`).
  - Door app: interface, no-op token source and registration service with tests only; real FCM wiring waits for door sign-in (carried to phase 04 task checklist). `sendToUser` has no caller yet (first caller: phase 04 walk-in push).
