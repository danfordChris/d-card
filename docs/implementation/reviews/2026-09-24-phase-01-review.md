# Review Report — 2026-09-24 (Phase 01: Events, plans, guests)

## Summary

- Reviewed T01-01 to T01-10. All ten meet their acceptance criteria with recorded evidence.
- Phase objective met: a host can create an event (web wizard) and build a guest list in all 4 ways: form (web), Excel/CSV import (web), copy from a past event (web), phone contacts (D-Card app).
- Pipelines: `pnpm turbo run typecheck lint test build` 23/23 (web 79 tests, core and worker suites green); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 10, door 2, ui 1, core 14); `flutter build apk --debug` builds; `validate_workflow.py` → `WORKFLOW:ok`.

## Standards

- Domain logic lives in `packages/core` (events, guests, import, team, admin event types); API routes stay thin (auth → parse with `@dcard/api-contract` → core → `toErrorResponse`).
- Every write that changes event, guest, team or event-type data records an `audit_log` row; the table is append-only.
- Error codes map to stable HTTP statuses (`validation_error`/`consent_required` 422, `conflict`/`plan_limit` 409, `invite_gone` 410, `account_not_provisioned` 403).
- Invite tokens are random, stored as HMAC-SHA256 hashes (`TOKEN_HASH_SECRET`), single use and valid for 7 days. Team-invite email is sent by the worker (BullMQ `email` queue, idempotent job id).
- Web UI uses Tailwind only. Every user-facing string is in `messages/sw.json` and `messages/en.json`, and a test checks the two stay aligned.
- Flutter follows MVVM (`data/services`, `data/repositories`, `domain/models`, `ui/features/*/{view_models,views}`). Firebase and contacts sit behind interfaces with fakes in tests. Local storage is `shared_preferences` only (no Hive).
- `dcard_api` is regenerated from the contract (`pnpm api:dart`); no hand edits.

## Spec

- GST-2 (one invitation per person per event) is enforced by a unique `(event_id, person_id)`. Form, import, copy and contacts all dedupe by normalised phone.
- MSG-14 consent: every add path requires the host's confirmation and writes one `guest_consent` row per batch with its source (`form`, `import`, `copy`, `contacts`).
- AUTH-8: team invites use a shareable link and, optionally, email (Resend). Door staff respect the plan limit (Msingi) with 409 `plan_limit`.
- GST-6: the contacts permission is asked only when the picker opens. Invalid numbers are shown but cannot be selected. Denial explains why and offers a link to settings.
- EVT-5: admins create, rename and activate/deactivate event types. Inactive types are hidden from new events; existing events keep them.
- Event setup wizard and event types remain `In Progress` in the feature inventory: media, messages, payment (wizard) and card templates are later phases.

## Verification

- Command: `pnpm turbo run typecheck lint test build`, `dart run melos run analyze`, `dart run melos run test`, `(cd apps/mobile && flutter build apk --debug)`, `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`
- Evidence: see the Verification section of each `docs/implementation/tasks/t01-*.md`.

## Follow-ups

- Live checks are pending real keys: Firebase sign-in in the web and mobile apps, and Resend email delivery. All are tested with fakes and dummy keys only (same blocker as T00-10).
- Mobile: Firebase config comes from `--dart-define` (`apps/mobile/README.md`); run `flutterfire configure` or supply the four values when the Firebase project exists.
- Android build warns that some plugins have not moved to Flutter's built-in Kotlin yet (non-fatal). Recheck when upgrading `firebase_*` / `flutter_contacts`.
- Admin second factor (TOTP) is phase 06; until then, admin access relies on `user_account.is_admin` only.
- Workflow contract `_SUB_LABEL` bug still forces one in-progress task at a time (see phase 00 review).
