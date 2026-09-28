# Review Report — 2026-09-27 (Phase 05: Payments and media)

## Summary

- Reviewed T05-01 to T05-06. All six meet their acceptance criteria with recorded evidence in tests.
- Phase stays `in-progress`: its acceptance needs one real Tsh 500 Snippe payment in production and a live Google Drive connect with uploads in both sharing modes. Both wait for owner setup (Snippe webhook URL, Google OAuth consent screen and redirect URIs).
- Work split: lead T05-01 (billing core, Snippe, payment gate) and T05-04 (Drive backend); subagents T05-02 (web checkout), T05-03 (mobile checkout), T05-05 (host media screens), T05-06 (guest gallery). All verified by the lead.
- Pipelines: `pnpm turbo run typecheck lint test build --force` 27/27 (core 161, web 217, worker 28, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 50, door 72, core 14, ui 1); debug APKs build; `validate_workflow.py` → `WORKFLOW:ok`.

## Standards

- Money as whole TZS; pricing rules in one pure function (`priceQuote`), unit-tested; the client always shows the server quote and sends `expectedTotal` (409 `quote_changed` if the price moved).
- Payments are applied exactly once (conditional `pending → completed` update, unique `host_payment.attempt_id`, webhook events deduplicated by id); webhook HMAC over `{timestamp}.{raw body}` with a 5-minute replay window; idempotency keys ≤ 30 characters; worker polling as a fallback.
- Snippe has no sandbox: fake gateway everywhere except `SNIPPE_LIVE=true` (production), like `NEXTSMS_LIVE` / `WHATSAPP_LIVE`.
- Payment gate under the event row lock: no card beyond the paid cards; guest messages stay in the outbox until the event is paid (filtered in the query so unpaid events cannot starve dispatch).
- Media bytes never stored by D-Card: resumable Drive sessions created with the app origin; only files in the event's own folder can be registered; refresh tokens encrypted; `MediaStore` interface with a fake for tests.
- Keyless API routes are limited to Drive connect/callback (signed, expiring state) and card-link media content (card token as credential), enforced in `proxy.ts` and tested.

## Spec

- Plans and pricing as in `docs/design/features/plans-and-billing.md`: minimum Tsh 50,000, blocks of 10, upgrades per paid card, launch offer on the host's first paid event (admin can change or switch off).
- MED-1…MED-16 as in `docs/design/features/media.md`; MED-6 upload window set to 12 h before the event until the plan's days after it (owner to confirm).
- Contributors who pay in full before the host pays keep a pending card that is issued automatically when the host pays.
- Guest upload from the D-Card app (scope C, optional) moved to the backlog.

## Verification

- Commands: `pnpm turbo run typecheck lint test build --force`, `dart run melos run analyze`, `dart run melos run test`, `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`
- Evidence: Verification sections of `docs/implementation/tasks/t05-*.md`.

## Follow-ups

- Owner: Snippe webhook URL in the dashboard; `SNIPPE_LIVE=true` on Vercel production and the Railway worker; one real Tsh 500 payment. Google Cloud OAuth consent screen (test users) and redirect URIs for localhost and `api.dcard.danfordchris.dev`; then a live Drive connect and uploads in both sharing modes. Confirm the MED-6 upload window.
- Deploy migrations `0014_billing` and `0015_media` with the next production deploy.
- Dart client: nullable nested object refs (e.g. `BillingSummary.pendingAttempt`) generate non-nullable models; the apps read raw JSON meanwhile.
- UI refinement per `docs/changes/proposed/ui-design-system.md` (backlog).
