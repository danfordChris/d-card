# T01-05 — Web: Guest List

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/guests-and-cards/add-guest-form.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/guests-and-cards.md`
- Constraints: Uses T01-04 API; Tailwind; sw/en; phone input accepts local formats; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts and committee manage the guest list on the web: add (with consent tick), edit, remove and search.

## Scope Boundary

**In scope:**
- `apps/web/src/app/(app)/events/[id]/guests/**`
- `apps/web/src/features/guests/**`
- `apps/web/messages/*.json` (guests keys)

**Out of scope:**
- Import UI (T01-06)

## Acceptance Criteria

- [x] The guest list shows name, phone (local format), card type and status with search and pagination.
- [x] The add form requires the consent tick and shows `invalid_phone` errors inline; adding an existing phone opens that guest.
- [x] Edit and remove work for pending guests; treasurer sees the list read-only.
- [x] Component tests cover the form; build passes.

## Dependencies

- T01-03 and T01-04 done.

## Implementation Checklist

- [x] List + search + pagination.
- [x] Add/edit dialog with consent.
- [x] Remove with confirmation.
- [x] Tests + build.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

```
$ pnpm --filter @dcard/web test → 55 passed
  guest-list.test (jsdom): local phone format + card type + partner shown; treasurer read-only (no Add/Edit);
  add form blocks invalid phone and missing consent without calling the API; successful add → POST body {name, cardType,
  partnerName, phone, consent:true} → row prepended + "Zawadi added."; already-invited phone → notice + Edit dialog opens
$ pnpm turbo run typecheck lint test build → 23 successful, 23 total
Browser (next dev): /events/{id}/guests → Add guest (Juma Hamisi, 0713 555 010, Double, consent) → "Juma Hamisi added.",
  row shows 0713 555 010 · Double · Pending · Edit/Remove
```
- Search is debounced (300 ms) against `GET …/guests?q=`; "Load more" uses the keyset cursor.
- Shared accessible `Dialog` component added (labelled, Escape closes, focus in/out).
