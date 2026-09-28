# Snippe Payment Integration

## Context

- Use: hosts pay for plans (guest cards). Contributions are not collected through Snippe in the MVP.
- Decision: `docs/adr/0003-technical-stack.md`. Docs: https://docs.snippe.sh (API version 2026-01-25).

## Requirements

- Base URL `https://api.snippe.sh`; `Authorization: Bearer <api key>`.
- Mobile money USSD push: `POST /v1/payments` (type `mobile`) — M-Pesa, Airtel Money, Mixx by Yas, Halotel.
- Hosted checkout (incl. cards): `POST /api/v1/sessions`.
- Webhooks: signed with a separate webhook secret; `X-Webhook-Signature` = hex HMAC-SHA256 of `{timestamp}.{raw body}`; reject timestamps older than 5 minutes; deduplicate by event `id`.
- Minimum payment 500 TZS; `Idempotency-Key` ≤ 30 characters.
- Every create call sends an `Idempotency-Key`.
- Payment result via webhook; status polling as fallback.
- Rate limit: 60 requests/minute.
- Fees: ~2.5% mobile money, ~3% cards, no monthly fee.

## Decisions

- Snippe has **no sandbox or test keys** (checked 2026-09-26, docs.snippe.sh): every call with the API key is real. Tests and local development use a fake gateway; real calls only when `SNIPPE_LIVE=true` (production), same pattern as `NEXTSMS_LIVE` / `WHATSAPP_LIVE`.

- Adapter behind a `PaymentGateway` interface.
- No cards or messages are sent for an event until its host payment is confirmed.

## Contracts

- `POST /api/v1/events/{id}/checkout` → starts payment for plan + guest cards.
- `POST /api/webhooks/snippe` → verifies signature, records `host_payment`, unlocks sending.

## Acceptance Criteria

- A confirmed Snippe webhook marks the event as paid exactly once, even if delivered twice.
