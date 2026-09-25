# T01-09 — Mobile: Add Guests from Phone Contacts

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/guests-and-cards/phone-contacts-import.md`

## Agent Context

- Skills: `flutter-apply-architecture-best-practices`, `flutter-add-widget-test`
- Design docs: `docs/design/features/guests-and-cards.md` (GST-6), `docs/design/features/notifications.md` (MSG-14)
- Constraints: Contacts permission requested only when the host opens the picker; phones normalised with `dcard_core`; consent tick required; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts pick several phone contacts in the D-Card app, confirm consent and add them as guests.

## Scope Boundary

**In scope:**
- `apps/mobile/lib/**` (contacts feature)
- `apps/mobile/pubspec.yaml`, Android/iOS contacts permission config
- `apps/web/src/app/api/v1/events/[id]/guests/bulk/**`
- `packages/core/src/guests/**` (bulk create)

**Out of scope:**
- Web import (T01-06)

## Acceptance Criteria

- [x] Opening the picker requests contacts permission; denial shows an explanation and a settings link.
- [x] Multi-select shows each contact's numbers; invalid numbers are marked and cannot be selected.
- [x] `POST /api/v1/events/{id}/guests/bulk` creates invitations (dedupe as T01-04) and one `guest_consent` with source `contacts`.
- [x] Widget tests with a fake contacts source cover selection, invalid numbers and consent.
- [x] Tests and Android build pass.

## Dependencies

- T01-04 and T01-08 done.

## Implementation Checklist

- [x] Bulk endpoint + core function.
- [x] Contacts source (flutter_contacts) behind an interface.
- [x] Picker screen + consent.
- [x] Tests + build.

## Verification

- Command: `pnpm turbo run test && dart run melos run test && (cd apps/mobile && flutter build apk --debug)`
- Evidence:

- API: `POST /api/v1/events/{id}/guests/bulk` (`GuestBulkInput` ≤ 500, OpenAPI `addGuestsBulk`) uses core `addGuestsBulk` with source `contacts`. `test/guests-api.test.ts`: 422 `consent_required`; 201 with added / existing (dedupe by phone) / invalid (`invalid_phone`), exactly one `guest_consent` with source `contacts` and `guestCount` 2; 200 when nothing new; 403 for treasurer.
- `pnpm turbo run typecheck lint test build` → 23/23 (2026-09-24).
- Mobile `ContactsSource` interface (`DeviceContactsSource` = flutter_contacts 2.5.0); `READ_CONTACTS` + `NSContactsUsageDescription` added.
- `test/contacts_picker_test.dart` (fake contacts source + fake API): permission requested only when the picker opens; permanent denial shows the explanation and "Open settings"; button hidden on cancelled events; invalid (+254) number marked and not selectable; one number per contact; consent required before any API call; bulk request has normalised phones; result shows added/existing; sw search filter.
- `dart run melos run analyze` → no issues; `dart run melos run test` → mobile 10, door 2, ui 1, core 14 passing.
- `flutter build apk --debug` → built.
