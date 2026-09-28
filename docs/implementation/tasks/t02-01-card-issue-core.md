# T02-01 — Card issue, numbers, tokens, cancel/reinstate (core + API)

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-02-contributions-cards.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/guests-and-cards/card-issue-and-numbers.md`, `docs/implementation/feature-inventory/guests-and-cards/card-cancel-reinstate.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/features/guests-and-cards.md` (GST-8..11, Invitation States), `docs/design/domain/overview.md` (card number), `docs/design/data-models/postgres.md`, `docs/adr/0003-technical-stack.md` (card tokens)
- Constraints: card number `NNN-PPPP` (per-event guest sequence assigned at issue + random 4-digit PIN), unique per event; link and QR tokens 32 random bytes, stored as HMAC hash + AES-256-GCM encrypted copy; card type immutable once issued (service rule + DB trigger); host only issues/cancels/reinstates; every change audited; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The host can issue a card directly, cancel it and reinstate it through `/api/v1`, and each issued card has a unique card number, QR token and link token.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` + migration (invitation card columns, `event.next_guest_seq`, card-type trigger)
- `packages/core/src/cards/**`, `packages/core/src/crypto/**`, `packages/core/src/guests/guests.ts` (card fields in the guest view)
- `apps/web/src/app/api/v1/events/[id]/guests/[guestId]/{issue,cancel,reinstate,card}/**`
- `packages/api-contract/src/**` (card schemas)
- `packages/env` (use existing `DATA_ENCRYPTION_KEY`)

**Out of scope:**
- Pledges and auto-issue (T02-02)
- Sending the card (phase 03)
- Card page and image (T02-03, T02-04)

## Acceptance Criteria

- [x] `POST .../guests/{guestId}/issue` (host) moves a `pending` invitation to `issued`, sets `issued_at`, a card number matching `^\d{3,}-\d{4}$` unique within the event, and QR/link token hashes; non-host → 403; already issued → 409.
- [x] Concurrent issues in one event never produce duplicate guest sequences (test with parallel calls).
- [x] `GET .../guests/{guestId}/card` (host, committee) returns the card number and the card link `APP_URL/c/{linkToken}` decrypted from storage; the database holds no plain token.
- [x] `POST .../cancel` sets `cancelled`; `POST .../reinstate` returns to `issued` (was issued) or `pending` (never issued) with the same card number and tokens; both audited.
- [x] Updating `card_type` or `total_entries` of an issued invitation fails in the database (trigger) and `PATCH` of an issued guest returns 409.

## Dependencies

- T01-04 done.

## Implementation Checklist

- [x] Schema, migration and trigger.
- [x] Token crypto helpers (random, hash, encrypt/decrypt) + tests.
- [x] Issue/cancel/reinstate service with row locking + tests.
- [x] API routes + contract + OpenAPI.
- [x] Full pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- Migrations `0006_card_issue` (card columns, `event.next_guest_seq`, unique card number / guest sequence / token hashes, card-number format check) and `0007_card_type_immutable` (trigger).
- Core `packages/core/test/cards.test.ts` (8): AES-GCM round trip + tamper detection; card number format; host-only issue with number `001-NNNN`, token hashes match decrypted tokens; 12 parallel issues → 12 distinct sequences; card type change blocked by service (409) and by the DB trigger; cancel → reinstate keeps number and link token, audited; never-issued reinstates to pending; issue refused on a cancelled event.
- Web `test/guests-api.test.ts` (11): issue 200 / treasurer 403 / repeat 409; `GET .../card` 409 before issue, then `https://dcard.test/c/<43-char token>`; PATCH after issue 409; cancel + reinstate keep the card number; guest list shows status and card number.
- `pnpm turbo run typecheck lint test build` → 23/23 (2026-09-25); `dcard_api` regenerated; melos analyze/test green.
