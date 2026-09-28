# T04-04 — D-Card Door app: sign-in and online check-in

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-04-confirmation-check-in.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/check-in/online-check-in.md`, `docs/implementation/feature-inventory/check-in/card-number-lockout.md`

## Agent Context

- Owner: Subagent (Flutter)
- Skills: `flutter-apply-architecture-best-practices`, `flutter-setup-localization`
- Design docs: `docs/design/features/check-in.md` (CHK-1…CHK-5), `docs/design/features/auth.md` (AUTH-9)
- Constraints: MVVM with repositories and fakes in tests; local storage sqflite / shared_preferences only (never Hive); API via generated `dcard_api` with the door API key (`--dart-define=API_KEY`); results and refusals readable at a glance at a noisy door (large text, colour + icon); commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); phone numbers stored as `255` + 9 digits; sw/en for every user-facing string; web UI Tailwind only
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Door staff sign in, pick their event, register the device, and check guests in online by QR, card number or name with Admit 1 / Admit 2.

## Scope Boundary

**In scope:**
- `apps/door/**`
- `dart_packages/dcard_ui/**` (shared widgets only if needed)

**Out of scope:**
- Offline cache and sync (T04-05)
- Walk-in UI (T04-06)

## Acceptance Criteria

- [x] Email/password sign-in (Firebase) and event selection; the device registers once per event; a revoked device returns to sign-in.
- [x] QR scan, card-number entry and name search each reach the result screen with name(s), type, entries left, table and status.
- [x] Admit 1 / Admit 2 call the entries API with a device UUID; refusals and the 5-minute lockout are shown clearly.
- [x] Push token registration (from T03-08) runs after sign-in.
- [x] Widget and repository tests with fakes; `dart run melos run analyze` and `test` pass; debug APK builds.

## Dependencies

- T04-01 API contract merged into `dcard_api`.

## Implementation Checklist

- [x] Auth + event select.
- [x] Device registration.
- [x] Scan / number / name lookup.
- [x] Result + admit + refusals + lockout.
- [x] Push wiring.
- [x] Tests + analyze + APK.

## Verification

- Command: `pnpm turbo run typecheck lint test build` and `dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-26 (built by a Flutter subagent, verified by the lead): `dart run melos run analyze` no issues; `dart run melos run test` → door 29, mobile 22, core 14, ui 1 passing; `flutter build apk --debug --dart-define=API_KEY=…` builds (subagent run).
  - Sign-in (Firebase email/password + dev fake mode), event list with role, device registration (UUID per install + event), QR / card-number keypad / name search, full-screen result with Admit 1 / Admit 2, refusals (fully used with entry times, cancelled, not issued, not found, too many), lockout banner with countdown, revoked device → sign-out with message, push registration after sign-in; sw default, en.
  - Lead fixes from its report: door inputs accept null for omitted optionals; `scripts/generate-dart-client.sh` drops the generator's debug-only null assertion on nullable fields (affected mobile too).
  - Not yet exercised: real camera scanning and a run against the live API (owner: register the door app in Firebase).
