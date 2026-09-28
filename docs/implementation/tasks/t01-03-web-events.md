# T01-03 — Web: Event Wizard, Events List and Summary

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/events/event-setup-wizard.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/events.md` (steps 1–4 only), `docs/design/features/plans-and-billing.md`
- Constraints: Uses T01-01 API; Tailwind components from T01-02; sw/en; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

A signed-in host creates an event through a wizard (plan, type, details, contact, options), sees their events list, and opens an event summary.

## Scope Boundary

**In scope:**
- `apps/web/src/app/(app)/dashboard/**`
- `apps/web/src/app/(app)/events/**`
- `apps/web/src/features/events/**`
- `apps/web/messages/*.json` (events keys)

**Out of scope:**
- Media, messages, team, card design, payment steps (later phases / T01-07)

## Acceptance Criteria

- [x] The wizard validates each step client-side (required fields, phone format) and shows server errors inline.
- [x] Submitting the wizard calls `POST /api/v1/events` and lands on `/events/{id}` showing plan, type, date, venue, contact and settings.
- [x] `/dashboard` lists the caller's events with status badges.
- [x] The host can edit event details and cancel the event from the summary page.
- [x] Component tests cover wizard validation; `pnpm --filter @dcard/web build` passes.

## Dependencies

- T01-01 and T01-02 done.

## Implementation Checklist

- [x] Build wizard steps and form state.
- [x] Build events list and summary.
- [x] Edit and cancel actions.
- [x] Tests + build.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

```
$ pnpm --filter @dcard/web test → 42 passed
  event-form.test: step validation (required, end after start, URL, Tanzanian phone, number ranges), payload (+03:00, whole amounts), local↔ISO
  event-wizard.test (jsdom): details step blocks on required fields; Msingi locks auto-upgrade; inline phone error; valid submit → POST /api/v1/events → router.push(/events/{id})
$ pnpm turbo run typecheck lint test build → 23 successful, 23 total
Browser (next dev, fake session):
  /events/new → Plan (Kawaida) → Details (title, 2026-12-12 15:00, Diamond Jubilee Hall) → Contact (Asha, 0754 123 456)
  → Options (50,000 / 100,000) → Create → /events/{id}: "Kawaida · Tsh 1,500 · Not paid yet", "Saturday, 12 December 2026 at 15:00",
    "Asha Mohamed 0754 123 456", settings line correct
  Edit → venue "Mlimani City Hall" → Save → summary updated
  /dashboard (sw): "Matukio", card "Jumamosi, 12 Desemba 2026, 15:00 · Harusi · Kawaida · Mwenyeji"; no console errors
```
- `@dcard/core/phone` subpath export added so client code validates phones with the same rules.
- Cancel is covered by API tests (T01-01) and the `CancelEventButton` component.
