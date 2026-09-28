# Review Report — 2026-09-25 (Phase 03: Messaging)

## Summary

- Reviewed T03-01 to T03-08. All eight meet their acceptance criteria with recorded evidence.
- Work was split: messaging core, worker, db, settings screen and manual-send backend by the lead; admin templates and rates (T03-07) by the JetBrains assistant; push setup (T03-08) and the log/send screens (part of T03-06) by subagents. Each was verified by the lead with the full pipeline.
- End to end on the dev server: event → 2 guests issued → settings saved (event reminder SMS only) → preview (2 recipients, 0 of 2 manual sends used) → manual send → worker dispatch → log shows the cards and reminders sent by SMS and the WhatsApp cards `held` (no approved template yet).
- Pipelines: `pnpm turbo run typecheck lint test build --force` 27/27 (core 120, web 151, worker 24, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (core 14, ui 1, door 4, mobile 22); `validate_workflow.py` → `WORKFLOW:ok`.
- Phase stays `in-progress`: its first criterion needs real sends on **both** channels. SMS delivery was proven live (see Follow-ups); WhatsApp needs a Meta number, keys and approved templates (T00-10).

## Standards

- Transactional outbox: triggers enqueue inside the business transaction; dispatch creates one `message_log` row per channel; the BullMQ job id is the log id; retries with backoff; quiet hours 21:00–07:00 in the event time zone hold guest messages.
- Providers sit behind `SmsSender` / `WhatsAppSender`; webhooks are exempt from `X-API-Key` and verified by signature (Meta HMAC) or token (NextSMS); SMS status is polled from NextSMS logs by `reference`.
- Hosts never see costs; admins manage WhatsApp variants and effective-dated provider rates, audited.
- Manual sends are counted per audited batch against the plan limit; the log cursor carries `created_at` + id so rows written in one transaction are not skipped.
- Web: Tailwind only, sw/en for every string; OpenAPI documents the message endpoints and `dcard_api` is regenerated.

## Spec

- MSG-1…MSG-13 and NTF-1…NTF-8 as in `docs/design/features/notifications.md`; manual-send groups are all / unpaid / not confirmed / confirmed (MSG-13 lists unpaid and not confirmed as examples).
- Contribution reminders sent manually reach contributors with a balance even before their card is issued; every other manual message needs an issued card.
- Door push registration and the first `sendToUser` caller are carried to phase 04 (door sign-in, walk-in push).

## Verification

- Commands: `pnpm turbo run typecheck lint test build --force`, `dart run melos run analyze`, `dart run melos run test`, `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`
- Evidence: Verification sections of `docs/implementation/tasks/t03-*.md`.

## Follow-ups

- Incident during the e2e check: the local `.env` held the real NextSMS credential and the worker used the live endpoint, so 4 real SMS (card + reminder) went to two made-up numbers (0713600101, 0713600102). No jobs remain queued. Fix: the worker now uses the NextSMS test endpoint unless `NEXTSMS_LIVE=true` (production only); test added, `.env.example`, `docs/deployment.md` and the messaging integration doc updated.
- NextSMS returned HTTP 429 on back-to-back sends; retries recovered. Consider throttling the SMS queue (BullMQ limiter) before pilot volume.
- Stale `email/team-invite` jobs from earlier local runs were rejected by Resend (`example.com` recipients, unverified `dcard.example` domain); nothing was delivered.
- The log page does not refresh itself after a manual send (Refresh button).
- Live WhatsApp sends, template approval and push delivery wait for T00-10 keys and Firebase/APNs setup.
