# T02-03 — Guest card page, RSVP, dietary and calendar

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-02-contributions-cards.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/guests-and-cards/guest-card-page.md`, `docs/implementation/feature-inventory/guests-and-cards/rsvp-and-dietary.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/guests-and-cards.md` (Smartphone Guest, GST-12, GST-13, Card Design), `docs/adr/0001-product-decisions.md` (O4, O19, O20)
- Constraints: no login; the link token is the only credential (look up by hash, constant-time); cancelled cards show "Card cancelled"; RSVP is Yes/No and editable until the event starts; no contribution amounts on the page (CON-12); sw/en; mobile-first Tailwind; rate-limit public writes; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

A guest opens `/c/{linkToken}` without logging in, sees their card (QR, card number, date, venue), answers RSVP Yes/No with dietary needs, and adds the event to their calendar.

## Scope Boundary

**In scope:**
- `apps/web/src/app/c/[token]/**` (public page)
- `apps/web/src/app/api/v1/cards/[token]/**` (public GET, RSVP POST, `.ics`)
- `packages/core/src/cards/public.ts`
- `packages/db/src/schema.ts` + migration (RSVP columns)
- `apps/web/messages/*.json` (card page strings)

**Out of scope:**
- Guest sign-in with Google/Apple (later)
- Programme, table and menu content (later phases)
- Card image rendering (T02-04)

## Acceptance Criteria

- [x] `/c/{token}` for an issued card shows guest name(s), event title, date/time (EAT), venue with map link, card number and a QR code encoding the QR token; unknown token → 404 page; cancelled → "Card cancelled" page.
- [x] `POST /api/v1/cards/{token}/rsvp` with `yes`/`no` and optional dietary note (≤ 300 chars) saves `rsvp_status`, `rsvp_at`, `dietary_notes`; after the event starts → 409; the page shows the saved answer.
- [x] `GET /api/v1/cards/{token}/calendar.ics` returns a valid VEVENT; the page also offers a Google Calendar link.
- [x] The page renders in sw (default) and en, works at 360 px width, and never shows pledge or payment amounts.
- [x] Public endpoints reject more than 20 writes per token per hour with 429.

## Dependencies

- T02-01 done.

## Implementation Checklist

- [x] Core public lookup + RSVP service + tests.
- [x] Public API routes (+ .ics).
- [x] Card page UI + messages.
- [x] Component and API tests; pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- Migration `0009_rsvp` (`rsvp_status` none/yes/no, `rsvp_at`, `dietary_notes`).
- Core `packages/core/test/public-card.test.ts` (5): card by link token shows guest/partner, card type and a QR token whose hash matches, with no contribution amounts; unknown/malformed tokens 404; RSVP yes → no change allowed before the event, closed after (409), "maybe" and > 300-char notes rejected, audited with no actor; cancelled card hides the QR and refuses RSVP; ICS escapes `,` and `;` and defaults to a 4 h end.
- Web `test/card-page-api.test.ts` (3): public GET 200 with `no-store`, unknown 404; RSVP 200 / 422; `.ics` served as `text/calendar`; 20 RSVP writes per card per hour → 429. `test/rsvp-form.test.tsx` (3): exactly Yes/No in sw, answer required, sends trimmed note, 429 message, closed state.
- Manual (dev server, 360 px): contributor paid 40k + 60k → card `001-2893` issued; `/c/<token>` shows the built-in wedding design, names "Juma Salum na Neema", "Watu 2", Swahili date/time (EAT), venue + map link, QR and card number; RSVP "Ndiyo" + dietary note saved (200); no horizontal scroll; no server errors.
- `pnpm turbo run typecheck lint test build` → 23/23 (2026-09-25); melos analyze/test green.
