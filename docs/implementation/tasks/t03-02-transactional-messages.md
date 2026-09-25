# T03-02 — Transactional messages: contribution request, thank-you, card, upgrade

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-03-messaging.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/notifications/message-settings.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/features/notifications.md` (NTF-1, NTF-2, NTF-4, NTF-5, MSG-1, MSG-2, MSG-14), `docs/design/features/contributions.md`, `docs/design/features/guests-and-cards.md`
- Constraints: messages are queued through the outbox inside the same transaction as the business change; respect per-event settings (on/off, channels) with defaults when no setting exists; the card (NTF-4) is always sent on at least one channel; opted-out guests get SMS only; language per Person (default sw); WhatsApp card uses the rendered card image as the template header; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Adding a contributor, recording a payment, issuing a card and auto-upgrading a pledge each queue the right guest message on the right channels.

## Scope Boundary

**In scope:**
- `packages/core/src/messaging/triggers.ts`
- `packages/core/src/contributions/**`, `packages/core/src/cards/**` (outbox calls)
- `apps/worker/src/messaging/**` (card image for WhatsApp)

**Out of scope:**
- Scheduled messages (T03-04)
- Settings UI (T03-05)

## Acceptance Criteria

- [x] Adding a contributor queues NTF-1 on both channels by default; recording a payment queues NTF-2 with the new balance; issuing a card (direct or auto) queues NTF-4 with card number and link; auto-upgrade queues NTF-5.
- [x] A message turned off in `event_message_setting` is not queued, except NTF-4 which cannot be turned off; channel settings are honoured.
- [x] A guest who replied STOP for the event gets SMS only (NTF-4 still arrives by SMS).
- [x] Rolling back the business transaction queues nothing; retrying the same business action does not send twice.
- [x] The WhatsApp card message carries the card image (renderer from T02-04) as the header; SMS carries the card number and link.

## Dependencies

- T03-01 done.

## Implementation Checklist

- [x] Trigger service + tests per NTF.
- [x] Wire into contributions and cards.
- [x] Worker: card image upload/header.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- Triggers (queued through the outbox in the same transaction as the business change): NTF-1 on add contributor (`contribution_request:<pledgeId>`, payload pledge amount); NTF-2 on each payment (`thank_you:<paymentId>`, totals after the payment); NTF-4 on every issue, direct or auto (`invitation_card:<invitationId>`); NTF-5 on auto-upgrade (`card_upgraded:<pledgeId>`); updated balance on pledge edit (rule 9, `pledge_updated:<auditId>`). Refunds and payment corrections send nothing.
- `event.payment_details` exposed in core, API contract, wizard and edit form (sw/en), used by NTF-1/NTF-3.
- Worker: WhatsApp card header = card image fetched from the web renderer with the worker's own API key (`WORKER_API_KEY`, `worker:` entry of `API_KEYS`), uploaded to Meta, sent as the template header.
- Tests: `packages/core/test/message-triggers.test.ts` (4): request → thank-you (20k/30k) → card → thank-you (50k/0) in order; auto-upgrade queues upgrade then card, refund queues nothing; pledge edit queues balance 70,000; direct issue queues the card once and failed actions queue nothing. `apps/worker/test/messaging.test.ts` WhatsApp header test: card image rendered (sw, 43-char token), uploaded, sent as `headerImageId`, body params include name and card link. `apps/worker/test/senders.test.ts` card-image fetch uses the worker key and rejects non-PNG. Settings (on/off, channels) and STOP are applied at dispatch (T03-01 tests).
- Test hygiene: web `verifier-modes` test mocks firebase-admin (no network when real keys are in `.env`).
- `pnpm turbo run typecheck lint test build --force` → 23/23 twice (2026-09-25); melos analyze/test green; `dcard_api` regenerated.
