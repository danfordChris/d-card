# T02-05 — Web contributions dashboard, record payment, pledge edit, export

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-02-contributions-cards.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/contributions/contributions-dashboard.md`, `docs/implementation/feature-inventory/contributions/payment-recording.md`, `docs/implementation/feature-inventory/contributions/manual-pledge-edit.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/contributions.md` (CON-2, CON-3, CON-5a, CON-9, CON-10, CON-12)
- Constraints: Tailwind only; sw/en; host, committee and treasurer see amounts, door staff never; amounts in TZS integers formatted `Tsh 100,000`; export is xlsx + csv; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Host, committee and treasurers use a web contributions screen to see totals and contributors by status, add contributors, record payments/refunds, edit pledges and export.

## Scope Boundary

**In scope:**
- `apps/web/src/app/(app)/events/[id]/contributions/**`
- `apps/web/src/features/contributions/**`
- `apps/web/src/features/events/**` (budget amount field in the wizard/edit form)
- `apps/web/src/app/api/v1/events/[id]/contributions/export/**`
- `apps/web/messages/*.json`

**Out of scope:**
- Core rules (T02-02)
- Mobile treasurer screens (T02-07)

## Acceptance Criteria

- [x] Dashboard shows pledged, collected, outstanding, extras, refunds and budget progress, and lists contributors filterable by status with search.
- [x] Contributor detail shows pledge, paid, balance, extra and payment history; record payment/refund form validates amount, method, reference and date.
- [x] Recording the final payment shows the card as issued with its card number without a page reload.
- [x] Pledge edit (before issue) works for host and treasurer; controls are hidden after issue and for committee.
- [x] Export downloads xlsx and csv with one row per contributor (name, phone, pledge, card type, paid, balance, extra, status, card number).
- [x] Component tests cover the forms and totals in sw/en.

## Dependencies

- T02-02 done.

## Implementation Checklist

- [x] Dashboard + list.
- [x] Contributor detail + payment form + pledge edit.
- [x] Export endpoint.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- Web `/events/{id}/contributions` (host, committee, treasurer; `notFound()` otherwise) linked from the event summary; budget field added to the event wizard/edit form.
- `test/contributions-ui.test.tsx` (5): amount parsing and form validation (incl. refund > paid, EAT date); totals, budget progress 10 %, sw filters and phone search; final payment shows "Card 001-2893 has been issued" in the dialog and updates totals without reload, pledge edit hidden after issue; pledge edit (Single → Double 100k) before issue; committee sees no record/edit controls; add contributor with event default amount, consent required, `canAdd=false` hides the button.
- `test/contributions-api.test.ts` export: CSV (BOM, 1 header + 2 rows, local phone format) for treasurer; xlsx readable by read-excel-file (3 rows); stranger 403.
- Manual (dev server, sw): demo event with 4 contributors → totals Tsh 350,000 / 220,000 / 130,000, budget 22 %; Kawaida auto-upgrade visible (Bw. Kassim Single 50k paid 100k → Double); recording Tsh 30,000 for Bi Zuhura in the dialog issued card 003-2143 without reload, budget 25 %; CSV (Swahili headers) and xlsx downloads 200.
- `pnpm turbo run typecheck lint test build` → 23/23 (2026-09-25); melos analyze/test green.
