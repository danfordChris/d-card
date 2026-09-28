# T02-06 — Web direct card issue, cancel/reinstate and card link

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-02-contributions-cards.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/guests-and-cards/card-issue-and-numbers.md`, `docs/implementation/feature-inventory/guests-and-cards/card-cancel-reinstate.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/guests-and-cards.md` (Direct Card Issue, Card Cancellation and Reinstatement, Access)
- Constraints: Tailwind only; sw/en; host-only actions with confirmation dialogs; committee sees card number and link read-only; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

From the guest list the host issues cards directly, cancels and reinstates them, and copies or opens each card's link.

## Scope Boundary

**In scope:**
- `apps/web/src/features/guests/**` (card actions)
- `apps/web/src/app/(app)/events/[id]/guests/**`
- `apps/web/messages/*.json`

**Out of scope:**
- Sending the card (phase 03)

## Acceptance Criteria

- [x] Guest list shows status (pending/issued/cancelled) and card number; host sees Issue, Cancel and Reinstate with confirmation; each updates the row without reload.
- [x] Host and committee can copy the card link and open the card page.
- [x] Treasurer and committee do not see issue/cancel/reinstate controls.
- [x] Component tests cover the actions and role visibility in sw/en.

## Dependencies

- T02-01 and T02-03 done.

## Implementation Checklist

- [x] Row actions + dialogs.
- [x] Card link copy/open.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- Guest list (`apps/web/src/features/guests/guest-list.tsx`): card number column; status badges for pending/issued/cancelled; host-only Issue / Cancel / Reinstate with confirmation (`window.confirm`, same pattern as Remove); host and committee Copy link / Open card (link fetched on demand from `GET .../card`, new tab opened without `opener`). Page passes `canManageCards` (host, open event) and `canViewCards` (host, committee).
- `test/guest-card-actions.test.tsx` (5): sw labels for host actions; issue after confirm updates the row (card number, Edit hidden, Copy link shown) without reload; declined confirm makes no request; cancel → "Cancelled", reinstate → "Issued"; committee copies and opens links but has no issue/cancel/reinstate; treasurer sees card numbers only. Existing `test/guest-list.test.tsx` still passes.
- API behaviour behind the buttons is covered by T02-01 (`test/guests-api.test.ts`).
- `pnpm turbo run typecheck lint test build` → 23/23 (2026-09-25).
- Not checked in a live browser (native confirm dialogs); component tests cover the flows.
