# T01-08 — Mobile: Host Login and Events

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/auth/management-login.md`, `docs/implementation/feature-inventory/events/event-setup-wizard.md`

## Agent Context

- Skills: `flutter-apply-architecture-best-practices`, `flutter-use-http-package`, `flutter-add-widget-test`
- Design docs: `docs/design/features/auth.md`, `docs/design/features/events.md`, `docs/design/integrations/firebase.md`
- Constraints: Firebase Auth behind an `AuthService` interface (real config via `--dart-define`/flutterfire later; fake in tests); API via generated `dcard_api`; local data only sqflite + shared_preferences; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The D-Card app lets a host sign in with email/password and see their events list and an event summary from the API.

## Scope Boundary

**In scope:**
- `apps/mobile/lib/**`, `apps/mobile/test/**`, `apps/mobile/pubspec.yaml`
- `dart_packages/dcard_api/**` (regenerated)

**Out of scope:**
- Door app
- Guest-facing screens

## Acceptance Criteria

- [x] Login screen validates input and calls `AuthService.signIn`; errors show localised messages.
- [x] After sign-in the app calls `POST /api/v1/me` once, then shows `GET /api/v1/events` as a list with status.
- [x] Tapping an event shows its summary (type, date, venue, contact).
- [x] Widget tests with fake `AuthService` and fake API cover login success/failure and the events list.
- [x] `dart run melos run test` and `flutter build apk --debug` pass.

## Dependencies

- T01-01 done.

## Implementation Checklist

- [x] Regenerate `dcard_api`.
- [x] AuthService (Firebase + fake) and session repository.
- [x] Events repository and view models.
- [x] Screens + localisation.
- [x] Widget tests + build.

## Verification

- Command: `dart run melos run analyze && dart run melos run test && (cd apps/mobile && flutter build apk --debug)`
- Evidence:

- `pnpm api:dart` regenerated `dcard_api` (events, guests, imports, team endpoints).
- `dart run melos run analyze` → No issues in dcard_core, dcard_ui, dcard_door, dcard_mobile.
- `dart run melos run test` → dcard_core 14, dcard_ui 1, dcard_door 2, dcard_mobile 6 passing (2026-09-24).
- Mobile widget tests (fake `AuthService` + fake API): sw validation without calling auth; localised invalid-credentials error with no provisioning; sign-in → `POST /api/v1/me` once (not repeated for the same UID) → `GET /api/v1/events` list with status → sign out; empty state; network error + retry; event summary in sw (type, 15:00 EAT date, venue, contact phone, status).
- `flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk` built. (Gradle warns that some plugins have not moved to built-in Kotlin yet; the build still passes.)
- Firebase config via `--dart-define` (documented in `apps/mobile/README.md`); dev `AUTH_MODE=fake` only in debug builds.
