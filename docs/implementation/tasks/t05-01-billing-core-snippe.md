# T05-01 — Billing core, Snippe checkout and payment gate

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-05-payments-media.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/plans-and-billing/snippe-checkout.md`, `docs/implementation/feature-inventory/plans-and-billing/pricing-rules.md`, `docs/implementation/feature-inventory/plans-and-billing/launch-offer.md`

## Agent Context

- Owner: Claude Code (lead)
- Skills: `snippe-integration`, `vercel:nextjs`
- Design docs: `docs/design/features/plans-and-billing.md` (pricing rules, launch offer), `docs/design/integrations/snippe.md`, `docs/design/data-models/postgres.md` (`host_payment`)
- Constraints: Snippe has no sandbox: real calls only when `SNIPPE_LIVE=true` (production); tests and local dev use a fake gateway behind the `PaymentGateway` interface; every create call sends an `Idempotency-Key` ≤ 30 chars; webhooks verified with HMAC-SHA256 of `{timestamp}.{raw body}`, timestamps older than 5 min rejected, deduplicated by event id; a confirmed payment unlocks the event exactly once; no cards or guest messages are sent before the event is paid; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon (`docs/changes/proposed/ui-design-system.md` principles: no decorative gradients/shadows); money as whole TZS integers; phone numbers `255` + 9 digits
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

A host pays for an event's guest cards through Snippe (mobile money push or hosted checkout) and the confirmed payment unlocks sending exactly once.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` (`host_payment`, `payment_attempt`, `billing_setting`) + migration
- `packages/core/src/billing/**`
- `packages/api-contract/src/billing.ts`
- `apps/web/src/app/api/v1/events/[id]/checkout/**`, `.../billing/**`, `apps/web/src/app/api/webhooks/snippe/**`, `apps/web/src/app/api/v1/admin/billing/**`
- `apps/worker/src/billing/**` (pending-payment polling)
- `packages/core/src/messaging/dispatch.ts` and `packages/core/src/cards/**` (payment gate only)

**Out of scope:**
- Checkout screens (T05-02, T05-03)
- Contribution money (never collected through D-Card)

## Acceptance Criteria

- [x] Quote: minimum Tsh 50,000 per event, extra guests in blocks of 10 at the plan price, upgrade = per-guest difference for all paid cards, launch offer (default 20 % off the host's first event, admin can change or switch off) — unit-tested.
- [x] `POST /api/v1/events/{id}/checkout` starts a mobile-money push or a hosted session with an idempotency key and records a pending payment; `GET` returns its status.
- [x] `POST /api/webhooks/snippe` verifies the signature and timestamp, records `host_payment`, raises `guest_limit`/`amount_paid` and audits — once, even when delivered twice; a worker job polls pending payments as a fallback.
- [x] Guest messages are held and card issue is refused while the event is unpaid or over its guest limit (clear 409 `payment_required` / `guest_limit`).
- [x] Fake gateway in tests and local dev; `SNIPPE_LIVE=true` required for real calls. (The one real Tsh 500 production payment is tracked in the phase acceptance, owner step.)

## Dependencies

- Phase 04 done.

## Implementation Checklist

- [x] Schema + migration.
- [x] Pricing/quote service.
- [x] Gateway interface, Snippe adapter, fake gateway.
- [x] Checkout + status API.
- [x] Webhook + polling job.
- [x] Payment gate in dispatch and card issue.
- [x] Admin launch-offer setting.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-26: `pnpm turbo run typecheck lint test build --force` → 27/27 tasks (core 154, web 214, worker 28).
  - Core `packages/core/test/billing.test.ts` (7 tests): pricing (minimum Tsh 50,000 first purchase, blocks of 10, upgrade per paid card, no downgrade, nothing to pay), payment gate (card issue refused unpaid → `payment_required`, beyond paid cards → `guest_limit`; guest messages held in the outbox until paid; contributor card waits and is issued on payment), checkout with the fake gateway (idempotency key ≤ 30, metadata `attempt_id`, `quote_changed`, `payment_in_progress`), unlock exactly once with audit, launch offer on the host's first paid event only and admin setting, provider outage → `provider_unavailable`, polling and 4 h expiry, webhook dedupe and failure.
  - Web `apps/web/test/billing-api.test.ts` (4 tests): quote host-only, checkout 409/201, status, local simulate endpoint, signed webhook (wrong secret and >5 min old → 401, duplicate ignored), admin-only settings with validation.
  - Schema `0014_billing` (`payment_attempt`, `host_payment`, `webhook_event`, `billing_setting`); worker `poll-payments` every 2 min; `SNIPPE_LIVE` switch (Snippe has no sandbox; recorded in `docs/design/integrations/snippe.md`).
  - Existing tests now create paid events (`createPaidEvent` / `grantGuestCards`).
