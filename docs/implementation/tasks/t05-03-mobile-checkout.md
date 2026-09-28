# T05-03 — Host checkout in the D-Card app

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-05-payments-media.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/plans-and-billing/snippe-checkout.md`

## Agent Context

- Owner: Subagent (Flutter)
- Skills: `flutter-apply-architecture-best-practices`
- Design docs: `docs/design/features/plans-and-billing.md`, `docs/research/ui-reference-projects.md` (review → confirm → receipt)
- Constraints: MVVM with fakes; Hugeicons only for new icons; quote from the server; mobile-money push with a waiting screen and status polling; receipt; never Hive; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon (`docs/changes/proposed/ui-design-system.md` principles: no decorative gradients/shadows); money as whole TZS integers; phone numbers `255` + 9 digits
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts pay for an event from the D-Card app with the same quote, review, waiting and receipt flow as the web.

## Scope Boundary

**In scope:**
- `apps/mobile/**`

**Out of scope:**
- Billing API (T05-01)

## Acceptance Criteria

- [x] Checkout, upgrade and extra blocks from the event screen; review; USSD push waiting with polling; success receipt; failure retry.
- [x] Tests with fakes; analyze/test pass; APK builds.

## Dependencies

- T05-01 contract in `dcard_api`.

## Implementation Checklist

- [x] Repository + view models.
- [x] Screens.
- [x] Tests + APK.

## Verification

- Command: `pnpm turbo run typecheck lint test build` and `dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-27 (built by a Flutter subagent, verified by the lead): `dart run melos run analyze` no issues; `dart run melos run test` → mobile 50 (7 new in `test/billing_test.dart`), door 72, core 14, ui 1; `flutter build apk --debug` builds. No Hive.
  - Host banner / payment row on the event screen; billing screen (plan, cards paid/issued, receipts, pending payment resume); checkout: upward plans, blocks of 10, debounced server quote with launch offer and minimum charge, review, mobile-money push with polling or hosted page via url_launcher, receipt (EAT), retry, `quote_changed` and `payment_in_progress` handling; Hugeicons for new icons; sw/en.
  - Reads billing JSON directly: the generated `BillingSummary` model fails on a null nested `pendingAttempt` (follow-up: generator handling of nullable object refs).
