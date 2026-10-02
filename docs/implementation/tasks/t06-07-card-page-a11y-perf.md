# T06-07 — Guest card page accessibility and slow-3G performance

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-06-completion.md`
- Feature-inventory subfeature(s): none (phase scope item)

## Agent Context

- Owner: Subagent (web) with lead review
- Skills: `vercel:nextjs`, `vercel:performance-optimizer`
- Design docs: `docs/design/features/guests-and-cards.md`, `docs/design/ux/` if present
- Constraints: no new features; the page must work without JavaScript for viewing the card; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/design/ui/design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The guest card page loads fast on slow 3G and passes an accessibility check.

## Scope Boundary

**In scope:**
- `apps/web/src/app/c/**`, `apps/web/src/features/card-page/**`

**Out of scope:**
- Other pages

## Acceptance Criteria

- [x] First-load JS for `/c/[token]` reduced (measured before/after in the evidence); card image and details render server-side; images sized and lazy below the fold.
- [x] Lighthouse (mobile, slow 4G/3G throttling) performance ≥ 90 and accessibility ≥ 95 on a seeded card, or the gaps are documented.
- [x] Labels, contrast, focus order, `lang` per language, alt text; RSVP and gallery usable by keyboard and screen reader.
- [x] Existing card-page tests still pass.

## Dependencies

- None.

## Implementation Checklist

- [x] Measure.
- [x] Fix.
- [x] Re-measure.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 (core 192, web 241, worker 30, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
  - `/c/[token]` page chunk 32.3 → 12.9 kB raw (10.9 → 4.8 kB gz); gallery code loads after idle / near viewport. Lighthouse mobile (local production build, seeded card): slow 4G performance 98, accessibility 100; regular 3G (devtools) performance 90, accessibility 100 (CLS 0). Remaining gap: the root layout inlines all messages (~12.7 kB gz). RSVP radio group keyboard, live status regions, viewer focus trap, contrast fixes; card-page tests 15/15.
