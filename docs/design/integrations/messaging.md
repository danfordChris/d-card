# Messaging Integrations

## Context

- Research: `docs/research/messaging-providers.md`, `docs/research/whatsapp-pricing.md`.
- Behavior: `docs/design/features/notifications.md`.

## Requirements

- **SMS (outbound only): NextSMS.** Internet SMS with a registered sender ID. Base URL `https://messaging-service.co.tz`. API docs: https://documenter.getpostman.com/view/4680389/SW7dX7JL.
  - Auth: `Authorization: Basic <Base64 username:password>`; `Content-Type` and `Accept: application/json`.
  - Send: `POST /api/sms/v1/text/single` with `from`, `to`, `text` and **`reference` = our message_log id**; the response has a status per recipient (`PENDING` or `REJECTED…`) and `smsCount` (segments) but **no message id**. Test endpoint: `POST /api/sms/v1/test/text/single` (validates, no delivery); the worker uses it unless `NEXTSMS_LIVE=true`, which only production sets.
  - Delivery status: **poll** `GET /api/sms/v1/logs?reference=<id>` (returns NextSMS `messageId`, status group `PENDING`/`DELIVERED`/`UNDELIVERABLE`/`EXPIRED`/`REJECTED`…). A delivery callback is not in the public docs; the webhook route stays as an optional fast path.
  - Limits: a number receives at most 20 different / 6 identical messages per hour (anti-flooding).
  - Price: TZS 10.5–16 per 160-character segment by volume.
  - Inbound SMS: not used (automatic replies deferred).
- **WhatsApp: Meta WhatsApp Cloud API (direct), one D-Card number for all events.**
  - Business-initiated messages use approved templates only.
  - Attendance confirmation: template with two quick-reply buttons. Button payload carries an opaque per-invitation token.
  - Webhooks: message status (delivered/read/failed), button replies, template status and category changes.
  - Charged per **delivered** message, by category. Tanzania = "Rest of Africa": marketing US$0.0225, utility US$0.004, service US$0.004 (rate card effective 1 Oct 2026).
  - Utility volume tiers apply per business portfolio (−5% above 100,000/month).

## Decisions

- Every guest message is sent on both channels by default; the host can change the channel per message.
- All guest templates are written as transactional (utility) messages. The post-event thank-you is marketing.
- A template re-categorised to marketing pauses and alerts admins.
- Adapters sit behind `SmsSender` and `WhatsAppSender` interfaces.

## Contracts

- Webhooks: `POST /api/webhooks/nextsms`, `POST /api/webhooks/whatsapp` (signature/token verified, idempotent).
- Every send and receive writes `message_log` with provider ID, status and cost.

## Acceptance Criteria

- A NextSMS delivery callback updates the matching `message_log.status`.
- A WhatsApp button reply updates the confirmation of exactly the invitation in its payload.
