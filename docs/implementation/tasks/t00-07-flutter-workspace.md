# T00-07 — Flutter Workspace and App Shells

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/flutter-workspace.md`

## Agent Context

- Skills: `flutter-apply-architecture-best-practices`, `flutter-setup-localization`
- Design docs: `docs/design/architecture/codebase.md`, `docs/adr/0003-technical-stack.md`, `docs/design/architecture/offline-sync.md`
- Constraints: Local storage: sqflite (`sqflite_sqlcipher`) and `shared_preferences` only — no Hive; tokens in `flutter_secure_storage`
- Do not touch: `docs/design/`, `.agents/`, other tasks' scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a design decision is missing (record it in `docs/changes/proposed/` instead of deciding).

## Objective

A Melos (pub workspace) setup builds the `apps/mobile` and `apps/door` Flutter shells with sw/en localisation and a generated Dart API client.

## Scope Boundary

**In scope:**
- `melos.yaml` / root `pubspec.yaml` workspace
- `apps/mobile/**`
- `apps/door/**`
- `dart_packages/dcard_api/**`
- `dart_packages/dcard_ui/**`

**Out of scope:**
- `dart_packages/dcard_core` (T00-06)
- Door offline cache logic (phase 04)

## Acceptance Criteria

- [x] `flutter build apk --debug` succeeds for `apps/mobile` and `apps/door` (requires Android SDK licenses accepted by the owner; otherwise `flutter build ios --debug --no-codesign` is accepted as build evidence).
- [x] Both apps show a localised (sw/en) placeholder screen.
- [x] `dart_packages/dcard_api` is generated from `packages/api-contract/openapi.json`.
- [x] `melos run test` exits 0.

## Dependencies

- Flutter 3.44.6 / Dart 3.12.2 available via FVM at `~/fvm/default/bin` (not on the non-interactive PATH).
- T00-04 done (OpenAPI spec).

## Implementation Checklist

- [x] Create Melos (pub workspace) setup and both app shells.
- [x] Add localisation and theme package.
- [x] Generate Dart API client.
- [x] Add widget smoke tests.

## Verification

- Command: `melos run test && (cd apps/mobile && flutter build apk --debug) && (cd apps/door && flutter build apk --debug)`
- Evidence:

```
Flutter 3.44.6 / Dart 3.12.2 (FVM). Dart pub workspace (root pubspec.yaml) + Melos 8 as dev dependency.
$ ./scripts/generate-dart-client.sh   → dart_packages/dcard_api generated from packages/api-contract/openapi.json
  (api/default_api.dart; models account, auth_provider, error_response, health_response)
$ dart run melos run analyze   → dcard_core, dcard_ui, dcard_door, dcard_mobile: No issues found! (SUCCESS)
$ dart run melos run test
  [dcard_core]   +14 All tests passed!
  [dcard_ui]     +1  All tests passed!
  [dcard_door]   +2  All tests passed!  (English + Swahili home screen)
  [dcard_mobile] +2  All tests passed!  (English + Swahili home screen)
$ (cd apps/mobile && flutter build apk --debug) → ✓ Built build/app/outputs/flutter-apk/app-debug.apk
$ (cd apps/door && flutter build apk --debug)   → ✓ Built build/app/outputs/flutter-apk/app-debug.apk
```
- Deviation: `melos run test` instead of a globally installed `melos` (run via `dart run melos`).
