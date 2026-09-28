# Review Report — 2026-09-25 (Phase 02: Contributions and cards)

## Summary

- Reviewed T02-01 to T02-07. All seven meet their acceptance criteria with recorded evidence.
- Phase objective met: recording the final payment issues the card (card number, QR and link tokens), and the card page opens from its link without login. Checked end to end on the dev server (40k + 60k → card `001-2893` → `/c/<token>` → RSVP saved).
- Pipelines: `pnpm turbo run typecheck lint test build` 23/23; `dart run melos run analyze` no issues; `dart run melos run test` (mobile 15, door 2, ui 1, core 14); `flutter build apk --debug` builds; `validate_workflow.py` → `WORKFLOW:ok`.

## Standards

- Money is whole TZS integers; payments are signed records (refunds negative) with a DB check tying sign to kind; pledge totals are recomputed from the records inside the same transaction that locks the pledge and invitation.
- Card numbers use an atomic per-event counter (`event.next_guest_seq`); 12 parallel issues produce 12 distinct sequences. Card type, number and tokens are immutable after issue (service rule + trigger).
- Link and QR tokens: 32 random bytes, HMAC hash for lookup, AES-256-GCM copy for re-sending (ADR 0003). No plain token in the database.
- Public card endpoints: no login, `no-store`, `noindex`, `no-referrer`; RSVP writes rate-limited in Redis (fails open).
- Every issue/cancel/reinstate, pledge/payment change, auto-upgrade and RSVP is audited.
- Web: Tailwind only, sw/en for every string; mobile: MVVM with fakes in tests; `dcard_api` regenerated from the contract.

## Spec

- CON-5/CON-6 order matches the design: auto-upgrade (plan entitlement AND event setting, before issue only) then auto-issue. The design's 50k + 50k example issues Single after the first payment; the second is extra.
- CON-5a: manual pledge edits skip auto-upgrade so a host's Double → Single change is not undone; if payments already cover the new amount the card is issued.
- CON-9 totals: cancelled cards leave pledged/outstanding but their payments stay in collected (design: "payment records are kept and still count in totals").
- GST-12/O19: RSVP is Yes/No, editable until the event starts; O20 built-in design per event type on the page and the image.
- CON-12: amounts visible only to host, committee and treasurers (web page, export, mobile); the public card never returns amounts.
- Added to design during the phase: `event.budget_amount` (CON-9 budget progress), `invitation.qr_token_enc/link_token_enc`, RSVP columns, payment method list.

## Verification

- Commands: `pnpm turbo run typecheck lint test build`, `dart run melos run analyze`, `dart run melos run test`, `(cd apps/mobile && flutter build apk --debug)`, `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`
- Evidence: Verification sections of `docs/implementation/tasks/t02-*.md`.

## Follow-ups

- Sending (card by WhatsApp/SMS, thank-you and balance messages) is phase 03; the renderer (`GET /api/v1/cards/{token}/image`) is ready for it.
- Card image font has one weight; bundle a bold face with the card templates work (EVT-5).
- Web card actions use native `confirm()`; consider the shared `Dialog` for a consistent look.
- Bug caught in review: ICS text did not escape `;` (fixed, test added).
