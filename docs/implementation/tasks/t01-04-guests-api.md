# T01-04 — Guests API (people, invitations, consent)

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/guests-and-cards/person-and-invitation.md`, `docs/implementation/feature-inventory/guests-and-cards/add-guest-form.md`, `docs/implementation/feature-inventory/guests-and-cards/guest-consent.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/features/guests-and-cards.md`, `docs/design/data-models/postgres.md`, `docs/design/features/notifications.md` (MSG-14 consent)
- Constraints: One Person per phone; at most one Invitation per Person per event; host-owned name/phone snapshot on the invitation; host and committee manage guests, treasurer reads; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts and committee can add, edit, remove, search and list an event's guests through `/api/v1`, with consent recorded.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` + migration (`invitation`, `guest_consent`)
- `packages/core/src/guests/**`
- `apps/web/src/app/api/v1/events/[id]/guests/**`
- `packages/api-contract/src/**` (guest schemas)

**Out of scope:**
- Card numbers, tokens and issuing (phase 02)
- Pledges (phase 02)
- Import (T01-06)

## Acceptance Criteria

- [x] `POST /api/v1/events/{id}/guests` with name, phone, card type (single/double), optional partner name and `consent: true` returns 201 with an invitation in status `pending`; without `consent: true` returns 422 `consent_required`.
- [x] Adding a phone that already has an invitation in the same event returns 200 with the existing invitation and `existing: true`; no duplicate is created.
- [x] The same phone added to two different events creates one `person` and two invitations.
- [x] `GET /api/v1/events/{id}/guests?q=` searches by name or phone, paginates (`limit`, `cursor`) and is visible to host, committee and treasurer; other users get 403.
- [x] `PATCH` updates name, partner name and card type while status is `pending`; `DELETE` removes a pending invitation; both audited.
- [x] A `guest_consent` row records who confirmed consent, when and the source (`form`).

## Dependencies

- T01-01 done.

## Implementation Checklist

- [x] Add schema + migration.
- [x] Write core guests module with tests (dedupe, roles).
- [x] Add API schemas and routes.
- [x] Route tests.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

```
$ pnpm --filter @dcard/core test → 46 passed (guests: consent required; pending invitation + person + consent row;
   existing phone → existing:true, no duplicate; same phone in two events → 1 person, 2 invitations; single drops partner;
   invalid phone; treasurer/stranger forbidden to add; bulk: added/existing/invalid + one consent (count 2);
   list: host/committee/treasurer only, search by name and local-format phone, keyset pagination; update card type → entries 2/1 + audits;
   remove pending; cancelled event → 409)
$ pnpm --filter @dcard/web test → 49 passed (guests-api: 422 consent_required, 201 create + consent source form,
   200 existing:true, 422 invalid_phone, 403 treasurer/stranger on POST, list for treasurer, search q=zaw, 403 stranger,
   422 limit=0, PATCH 200 / treasurer 403, DELETE 204 then 404, malformed id 404)
$ pnpm turbo run typecheck lint test build → 23 successful, 23 total
```
- Migration `0003_invitations.sql` (`invitation`, `guest_consent`; unique (event_id, person_id); phone format and entries/card-type checks).
- Guest numbers (for card numbers) are assigned at card issue in phase 02.
- Design addition: `docs/design/features/guests-and-cards.md` › Access (host + committee manage, treasurer read-only).
