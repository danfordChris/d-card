# T05-02 — Web checkout, upgrades and receipts

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-05-payments-media.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/plans-and-billing/snippe-checkout.md`, `docs/implementation/feature-inventory/plans-and-billing/pricing-rules.md`, `docs/implementation/feature-inventory/plans-and-billing/launch-offer.md`

## Agent Context

- Owner: Subagent (web)
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/plans-and-billing.md`, `docs/research/ui-reference-projects.md` (Solomon money flow: form with live breakdown → review → confirm → receipt)
- Constraints: quote shown from the server (never computed only on the client); review before paying; the phone number defaults to the host's; waiting state while the USSD push is pending with status polling; receipt with reference; unpaid events show a clear banner and the checkout entry point; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon (`docs/design/ui/design-system.md` principles: no decorative gradients/shadows); money as whole TZS integers; phone numbers `255` + 9 digits
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts buy guest cards, add blocks of 10 or upgrade the plan on the web with a clear breakdown, pay, and get a receipt.

## Scope Boundary

**In scope:**
- `apps/web/src/features/billing/**`
- `apps/web/src/app/(app)/events/[id]/billing/**`
- `apps/web/src/app/(app)/admin/billing/**` (launch offer setting)
- `billing` namespace in `apps/web/messages/{en,sw}.json`
- one banner/link on `apps/web/src/app/(app)/events/[id]/page.tsx`

**Out of scope:**
- Billing API (T05-01)

## Acceptance Criteria

- [x] Checkout shows plan, guest cards (min charge, blocks of 10), launch-offer discount and total from the quote API, then review → pay (mobile money or hosted) → waiting → receipt.
- [x] Upgrade and extra-block flows show the difference only.
- [x] Admin can change or switch off the launch offer.
- [x] Component tests for quote display, waiting/success/failure states and admin setting; sw/en.

## Dependencies

- T05-01 contract.

## Implementation Checklist

- [x] Checkout page.
- [x] Upgrade + blocks.
- [x] Receipt + history.
- [x] Admin setting.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-26 (built by a web subagent, verified by the lead): full pipeline 27/27; `apps/web/test/billing-ui.test.tsx` (8 tests): money format, quote with launch offer and minimum charge, review → pay body with `expectedTotal`, waiting → receipt via polling (EAT date), failure retry, `quote_changed`, hosted session in a new tab, admin setting, sw render.
  - Lead additions: "Plan and payments" link on paid events; admin section tabs (event types, WhatsApp templates, provider rates, billing).
