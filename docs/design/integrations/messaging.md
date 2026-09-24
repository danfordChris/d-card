# Messaging Integrations

## Context

- Research: `docs/research/messaging-providers.md`, `docs/research/whatsapp-pricing.md`.
- Behavior: `docs/design/features/notifications.md`.

## Requirements

- **SMS (outbound only): NextSMS.** Internet SMS with registered sender ID `DCARD`. Base URL `https://messaging-service.co.tz`.
  - Send: `POST /api/sms/v2/text/single`, `POST /api/sms/v2/text/multi`.
  - Delivery reports: webhook (Delivery Callback URL + verify token) with polling fallback `GET /api/v2/reports`.
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
