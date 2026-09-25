# T02-02 — Pledges, payments, auto-upgrade and auto-issue (core + API)

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-02-contributions-cards.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/contributions/pledges.md`, `docs/implementation/feature-inventory/contributions/payment-recording.md`, `docs/implementation/feature-inventory/contributions/refunds-and-extras.md`, `docs/implementation/feature-inventory/contributions/auto-issue.md`, `docs/implementation/feature-inventory/contributions/auto-upgrade.md`, `docs/implementation/feature-inventory/contributions/manual-pledge-edit.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/features/contributions.md` (workflow, CON-1..12, Pledge States), `docs/design/features/plans-and-billing.md` (auto-upgrade entitlement), `docs/design/data-models/postgres.md`
- Constraints: D-Card never holds money: payments are records only; host and committee add contributors, host and treasurers record payments and edit pledges; auto-upgrade only if plan entitlement AND event setting are on, only before issue; auto-issue when total paid ≥ pledge; extras beyond the pledge never change an issued card; refunds are negative records; every change audited with old and new values; issue uses T02-01's service; messages (thank-you, balance) are phase 03; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Host, committee and treasurers manage pledges and payments through `/api/v1`, and recording the final payment auto-upgrades (when allowed) and issues the card.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` + migration (`pledge`, `payment`, `event.budget_amount`)
- `packages/core/src/events/events.ts`, `packages/api-contract/src/events.ts` (budget amount field)
- `packages/core/src/guests/guests.ts` (export in-transaction add helper)
- `packages/core/src/contributions/**`
- `apps/web/src/app/api/v1/events/[id]/contributions/**`, `.../pledges/**`, `.../payments/**`
- `packages/api-contract/src/**` (contribution schemas)

**Out of scope:**
- Thank-you and balance messages, reminders (phase 03)
- Web and mobile screens (T02-05, T02-07)
- Host plan payments via Snippe (phase 05)

## Acceptance Criteria

- [x] `POST /api/v1/events/{id}/contributions` (host, committee) with name, phone, pledge amount, card type and consent creates or reuses the invitation (GST-2) and one pledge; a second pledge for the same invitation → 409.
- [x] `POST .../pledges/{pledgeId}/payments` (host, treasurer) records amount, method, reference, date; part payments update paid, balance and status (`not_paid`/`part_paid`/`fully_paid`); committee → 403.
- [x] When total paid ≥ pledge amount the invitation is issued in the same transaction (card number assigned).
- [x] Kawaida/Premium event with auto-upgrade on: a Single pledge whose total paid reaches the Double amount before issue becomes Double with amount `max(pledge, double)`; on Msingi or with the setting off it stays Single and the excess is extra.
- [x] Payments beyond the pledge count as extra; a refund (negative record) can move `fully_paid` back to `part_paid` and the card stays issued.
- [x] `PATCH .../pledges/{pledgeId}` (host, treasurer) changes amount/card type before issue only (409 after); if already covered the card is issued; payment edits and pledge edits are audited with old/new values.
- [x] `GET .../contributions` returns totals (pledged, collected, outstanding, extras, refunds) and contributors by status for host, committee and treasurer only.

## Dependencies

- T02-01 done.

## Implementation Checklist

- [x] Schema + migration.
- [x] Contribution service (add, pay, refund, edit) with the upgrade/issue rules + tests covering the design's worked example (50k + 50k on Single).
- [x] API routes + contract.
- [x] Full pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- Migration `0008_contributions` (`pledge`, `payment` with signed amounts + sign/kind check, payment method enum, `event.budget_amount`).
- Core `packages/core/test/contributions.test.ts` (9): consent required; committee adds, treasurer cannot; one pledge per invitation (409); part → final payment issues the card (committee cannot record); design example 50k + 50k on Single → Single issued after the first, second is extra; one Double-amount payment on Kawaida upgrades (audited) and issues Double; no upgrade on Msingi or with the setting off; refund → part_paid, card stays issued, refund > paid rejected; payment edit recomputes, audited with old/new; pledge edit before issue issues when covered, Double → Single not re-upgraded, 409 after issue; dashboard totals (cancelled excluded from pledged/outstanding, payments kept), status filter, payment history.
- Web `test/contributions-api.test.ts` (2): 201 add / 403 treasurer / 422 no consent; payment 403 committee / 422 bad method / 201; payment PATCH issues the card; pledge PATCH after issue 409; detail and filtered totals incl. budget; 403 stranger; upgrade via API.
- `pnpm turbo run typecheck lint test build` → 23/23 (2026-09-25); `dcard_api` regenerated; melos analyze/test green.
- Thank-you/balance messages are phase 03 (out of scope).
