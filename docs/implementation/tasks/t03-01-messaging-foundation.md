# T03-01 — Messaging foundation: schema, templates, adapters, send queue, message log

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-03-messaging.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/notifications/nextsms-adapter.md`, `docs/implementation/feature-inventory/notifications/whatsapp-adapter.md`, `docs/implementation/feature-inventory/notifications/message-log-and-cost.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/features/notifications.md`, `docs/design/integrations/messaging.md`, `docs/design/data-models/postgres.md` (message_log, event_message_setting, whatsapp_template, provider_rate, whatsapp_optout), `docs/research/whatsapp-pricing.md`
- Constraints: adapters behind `SmsSender` / `WhatsAppSender` with fakes for tests (providers are not live until T00-10); sends run in the worker from a BullMQ queue per channel with retries; every attempt writes `message_log` with provider id, status and estimated cost from `provider_rate`; SMS text GSM-7 only, segment counting 160/153; every SMS carries the event contact; no network in tests; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The worker can send a rendered guest message by SMS and WhatsApp through provider adapters, retrying failures and logging each message with status and cost.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` + migration (message tables, outbox)
- `packages/core/src/messaging/**` (templates, placeholders, GSM/segments, outbox, cost)
- `apps/worker/src/messaging/**` (adapters, processors, queues)
- `packages/env` (NextSMS/Meta keys already declared)

**Out of scope:**
- Deciding when messages are sent (T03-02, T03-04)
- Webhooks (T03-03)
- Host settings UI (T03-05)

## Acceptance Criteria

- [x] Default sw/en SMS texts exist for NTF-1…8; rendering fills placeholders from event/guest/pledge data and always includes `{contact_name}` + `{contact_phone}`; unknown placeholders are rejected.
- [x] `smsSegments()` counts GSM-7 (160/153) and UCS-2 (70/67) correctly and `gsmProblems()` lists offending characters (emoji, curly quotes).
- [x] An `outbox` row written in a business transaction becomes exactly one send job per channel (idempotent job id); a crash between commit and enqueue does not lose it.
- [x] The NextSMS adapter posts to `/api/sms/v2/text/single` with bearer auth and maps the response id; the Meta adapter sends templates (body params, image header, quick-reply payloads); both are tested against a local fake HTTP server.
- [x] Failed sends retry with backoff (5 attempts) and end as `failed`; each attempt updates one `message_log` row (queued → sent/failed) with provider id and estimated cost (TZS) by channel/category/segments.

## Dependencies

- Phase 02 done.

## Implementation Checklist

- [x] Schema + migration + provider_rate seed.
- [x] Template registry, renderer, GSM/segment utilities + tests.
- [x] Outbox + dispatcher.
- [x] Adapters + fakes + tests.
- [x] Worker processors, retries, message_log + cost.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence: 2026-09-25 — 23/23 Turbo tasks passed; core 98 tests, web 110 tests, worker 13 tests, db 6 tests, env 7 tests; standards/spec review: `docs/implementation/reviews/2026-09-25-t03-01-review.md`.
- Correction 2026-09-25 (official NextSMS docs, https://documenter.getpostman.com/view/4680389/SW7dX7JL): endpoints are `/api/sms/v1/...` (not v2); auth is `Basic` Base64 `username:password` (`NEXTSMS_API_TOKEN` holds that value); the send response has no message id, so the message_log id is sent as `reference` and `smsCount` is used for cost; delivery status is polled from `GET /api/sms/v1/logs?reference=` by a worker job every 10 minutes (`smsAwaitingDelivery` / `applySmsDelivery`); REJECTED at submission is permanent. Tests: worker `senders.test.ts` (v1 URL, Basic header, reference body, REJECTED → permanent, lookup by reference), core `sms-delivery.test.ts` (DELIVERED with NextSMS id and EAT time, UNDELIVERABLE → failed, PENDING keeps sent).

