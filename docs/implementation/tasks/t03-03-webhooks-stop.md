# T03-03 — Provider webhooks: delivery status, button replies, STOP, template category guard

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-03-messaging.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/notifications/stop-optout.md`, `docs/implementation/feature-inventory/notifications/template-category-guard.md`, `docs/implementation/feature-inventory/notifications/message-log-and-cost.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/integrations/messaging.md` (Contracts, Acceptance Criteria), `docs/design/features/notifications.md` (MSG-14, MSG-15), `docs/design/integrations/snippe.md` (webhook pattern)
- Constraints: `/api/webhooks/*` are exempt from the `X-API-Key` check and verified instead (Meta `X-Hub-Signature-256` over the raw body with the app secret, constant-time; NextSMS verify token); handlers are idempotent and answer 200 fast; unknown payloads are logged and ignored; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Provider webhooks update message status and cost, record WhatsApp button replies and STOP opt-outs, and pause templates Meta re-categorises.

## Scope Boundary

**In scope:**
- `apps/web/src/app/api/webhooks/**`
- `apps/web/src/proxy.ts` (webhook exemption)
- `packages/core/src/messaging/webhooks.ts`
- `packages/db/src/schema.ts` (confirmation status if missing)

**Out of scope:**
- Host confirmation screens and headcount (phase 04)

## Acceptance Criteria

- [x] `GET /api/webhooks/whatsapp` answers Meta's verify challenge with the verify token; wrong token → 403.
- [x] `POST /api/webhooks/whatsapp` with a bad or missing signature → 401; a valid delivered/read/failed status updates the matching `message_log` (idempotent on repeats).
- [x] A quick-reply button payload `cnf:<token>:yes|no` updates the confirmation of exactly that invitation; a STOP reply (button or text) creates one `whatsapp_optout` for that person and event.
- [x] A template-status/category webhook that moves a utility template to marketing marks it paused and later sends using it are held (not sent) with an admin alert logged.
- [x] `POST /api/webhooks/nextsms` with the verify token updates the matching SMS `message_log` status; wrong token → 401.
- [x] Webhook routes do not require `X-API-Key`; every other `/api/*` route still does.

## Dependencies

- T03-01 done.

## Implementation Checklist

- [x] Proxy exemption + tests.
- [x] Signature/token verification.
- [x] Status, button, STOP, template handlers + tests.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- Routes `GET/POST /api/webhooks/whatsapp` (Meta verify challenge; `X-Hub-Signature-256` HMAC over the raw body with `WHATSAPP_APP_SECRET`, constant-time) and `POST /api/webhooks/nextsms` (verify token as `?token=`, `X-Verify-Token` or bearer — carrier to confirm with live keys, T00-10). Proxy exempts `/api/webhooks/*` from `X-API-Key`; every other `/api/*` still needs it.
- Core `messaging/webhooks.ts`: status advance (sent → delivered → read; failed terminal; repeats no-op); inbound messages logged once; quick-reply `cnf:<token>:yes|no` with a signed per-invitation token (`confirmationToken`, HMAC, no storage) records `invitation.confirmation_status` + audit; STOP / SITISHA / ACHA (or a `stop` payload) opts the person out for the event they were messaged about (reply context, else latest message); template status updates tracked; a utility template re-categorised as marketing is paused + audited (sends then hold, T03-01). NextSMS Infobip-style `results[]` DELIVERED / UNDELIVERABLE / EXPIRED / REJECTED update SMS logs. Migration `0011_confirmation`.
- Worker passes `confirmationToken` into NTF-6 WhatsApp buttons.
- `apps/web/test/webhooks.test.ts` (8): verify challenge 200/403; bad/missing signature 401; delivered twice counts once, read not downgraded; button yes recorded for that invitation, forged token ignored, both inbound messages logged; STOP twice → one opt-out + one audit; APPROVED then category → MARKETING pauses + audit; NextSMS wrong token 401, DELIVERED updates status; proxy lets webhooks through and still 401s `/api/v1/health` without a key.
- `pnpm turbo run typecheck lint test build --force` → 23/23 (2026-09-25).
