# T06-02 — Guest Google/Apple sign-in, card linking and My cards

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-06-completion.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/auth/guest-social-login.md`

## Agent Context

- Owner: Claude Code (lead) — core and API; Flutter guest screens by a subagent
- Skills: `flutter-apply-architecture-best-practices`, `flutter-setup-localization`
- Design docs: `docs/design/features/auth.md` (AUTH-3, AUTH-4, AUTH-5), `docs/design/features/guests-and-cards.md`, `docs/design/integrations/firebase.md`
- Constraints: guests sign in with Google or Apple only (no OTP, P4); an account links to one Person; linking needs a valid card link token; a Person already linked to another account is refused; the card stays viewable without login; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

A guest signs in with Google or Apple in the D-Card app, links a card with its link, and sees all their cards with card view and RSVP.

## Scope Boundary

**In scope:**
- `packages/core/src/guests/account-link.ts`
- `packages/api-contract/src/me.ts`
- `apps/web/src/app/api/v1/me/{cards,cards/link}`
- `apps/mobile/lib/**` guest mode (sign-in buttons, My cards, card view, RSVP)
- regenerated Dart client

**Out of scope:**
- Door app
- Event history for past events (GST-16, P2)

## Acceptance Criteria

- [x] `POST /api/v1/me/cards/link {token}` links the signed-in account to the card's Person (first link wins; a Person linked to another account → 409 `person_linked`; account already linked to a different Person → 409 `account_linked`); audited `guest.linked`.
- [x] `GET /api/v1/me/cards` lists the linked Person's issued invitations (event, date, venue, card number, status, RSVP, link URL) newest first.
- [x] Mobile: "Continue with Google" / "Continue with Apple" (Apple on iOS) create a `google`/`apple` account; a guest sees My cards, opens a card (QR + details) and answers RSVP through the existing card-link RSVP endpoint; pasting a card link (or token) links it; opening links in the app (deep links) is in the backlog.
- [x] Tests cover link rules and listing; Flutter widget tests for My cards.

## Dependencies

- Owner: enable Google and Apple providers in Firebase; Apple Sign In capability on the iOS app id.

## Implementation Checklist

- [x] Core + contract + routes + tests.
- [x] Dart client.
- [x] Mobile guest mode (subagent).
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build && dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 (core 192, web 241, worker 30, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
  - Core `account-link.test.ts`: link by card token, first account wins (`person_linked`, `account_linked`), My cards newest first incl. cancelled, audited `guest.linked`. Web `privacy-api.test.ts`: `/api/v1/me/cards` and `/me/cards/link` validation. Dart client regenerated.
  - Mobile: Continue with Google / Apple (iOS), bottom navigation (Events, My cards, Account), link sheet, card view with QR and RSVP; 17 new tests.
  - Owner: enable Google/Apple providers in Firebase, Android SHA fingerprints, iOS URL scheme and Sign in with Apple capability. Deep links not set up (paste only).
