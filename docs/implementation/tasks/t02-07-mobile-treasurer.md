# T02-07 — Mobile treasurer: contributor list and record payment

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-02-contributions-cards.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/contributions/payment-recording.md`

## Agent Context

- Skills: `flutter-apply-architecture-best-practices`, `flutter-add-widget-test`
- Design docs: `docs/design/features/contributions.md` (CON-2, CON-3), `docs/design/domain/overview.md` (treasurer)
- Constraints: MVVM like T01-08; API via regenerated `dcard_api`; local storage shared_preferences/sqflite only; online only in this phase; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Treasurers and the host use the D-Card app to see contributors with balances and record a payment.

## Scope Boundary

**In scope:**
- `apps/mobile/lib/**` (contributions feature)
- `apps/mobile/test/**`
- `dart_packages/dcard_api/**` (regenerated)

**Out of scope:**
- Offline payment recording (later)
- Pledge edits and exports on mobile (web only this phase)

## Acceptance Criteria

- [x] Event summary shows a Contributions entry for host, committee and treasurer.
- [x] Contributor list shows name, pledge, paid, balance and status, with search and status filter.
- [x] Record payment form (amount, method, reference, date) validates input, calls the API and shows the new balance; when fully paid it shows the issued card number.
- [x] Widget tests with a fake API cover the list, validation and the issue-on-final-payment result in sw/en.
- [x] `dart run melos run test` and `flutter build apk --debug` pass.

## Dependencies

- T02-02 done.

## Implementation Checklist

- [x] Regenerate `dcard_api`.
- [x] Repository + view models.
- [x] Screens + l10n.
- [x] Widget tests + build.

## Verification

- Command: `dart run melos run analyze && dart run melos run test && (cd apps/mobile && flutter build apk --debug)`
- Evidence:

- Mobile: `ContributionsRepository` (`getContributions`, `recordPayment`), `Contributor` domain model, `ContributionsViewModel` (search, status filter, refresh after a payment), `RecordPaymentViewModel` (amount parse/validate, method, reference, EAT date), screens `ContributionsScreen` and `RecordPaymentScreen`; entry on the event summary for host/committee/treasurer; recording only for host/treasurer.
- `apps/mobile/test/contributions_test.dart` (5, fake API): sw totals, "Amelipa … kati ya …", filter and phone search; amount required/invalid block the request; final payment (Cash, ref R-9) shows "Card 007-1234 has been issued", balance 0, list shows the card number after returning; part payment shows the new balance; committee cannot record; door staff see no Contributions entry.
- `dart run melos run analyze` → no issues; `dart run melos run test` → mobile 15, door 2, ui 1, core 14; `flutter build apk --debug` → built.
- `pnpm turbo run typecheck lint test build` → 23/23 (2026-09-25).
