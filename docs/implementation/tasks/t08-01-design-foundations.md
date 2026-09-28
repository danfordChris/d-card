# T08-01 — Design tokens, fonts, theme and shared components

## Status

- `done`
- Last updated: 2026-09-28

## Linked Phase

- Phase: `docs/implementation/phases/phase-08-design-system.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/design-system/tokens-components.md`

## Agent Context

- Owner: Claude Code (lead)
- Skills: `flutter-apply-architecture-best-practices`, `vercel:nextjs`
- Design docs: `docs/design/ui/design-system.md`, prototype https://claude.ai/artifact/VPpuUGour1sRuU2sgD6ZhD
- Constraints: token roles and values exactly as in the design doc; fonts bundled (Flutter assets) / `next/font` (web), no runtime font fetching; Hugeicons only; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Both platforms have the design tokens, light and dark themes, fonts and the shared component set, ready for the screen rollouts.

## Scope Boundary

**In scope:**
- `dart_packages/dcard_ui/**` (tokens, `DcTheme`, components, bundled Playfair Display and Plus Jakarta Sans)
- `apps/web/src/app/globals.css`, `apps/web/src/app/layout.tsx` (fonts, theme attribute)
- `apps/web/src/components/ui/**`

**Out of scope:**
- Screen changes (T08-02…T08-04)

## Acceptance Criteria

- [x] `dcard_ui` exports `DcTheme.light()/dark()`, `DcColors` (ThemeExtension with every role), `DcSpace`, `DcRadius`, `DcType`, and `DcTile`, `DcStatTile`, `DcButton`, `DcField`, `DcBadge`, `DcProgress`, `DcTopBar`, `DcSpotlightNavBar`, `DcStateView`, `DcSegmented`, with widget tests (light and dark).
- [x] Web `@theme` defines every role as `--dc-*` variables switched by `prefers-color-scheme` and `data-theme`; Tailwind colours and `font-display`/`font-sans` work; `components/ui` has `Tile`, `StatTile`, `Button`, `Field`, `Badge`, `Progress`, `EmptyState`, `Tabs` with UI tests.
- [x] Fonts: Playfair Display and Plus Jakarta Sans (OFL) bundled in `dcard_ui`; self-hosted on web via `next/font`.

## Dependencies

- None.

## Implementation Checklist

- [x] Flutter tokens + theme + fonts.
- [x] Flutter components + tests.
- [x] Web tokens + fonts.
- [x] Web components + tests.
- [x] Pipelines.

## Verification

- Command: `pnpm turbo run typecheck lint test build && dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-28: `dcard_ui` tokens (`DcColors` ThemeExtension light/dark, `DcSpace`, `DcRadius`, `DcTone`), `DcType` (bundled OFL variable fonts Playfair Display + Plus Jakarta Sans with explicit `FontVariation.weight`), `DcTheme.light()/dark()`, components `DcTile`, `DcStatTile`, `DcProgress`, `DcBento`, `DcButton`, `DcField`, `DcBadge`, `DcSegmented`, `DcTopBar`, `DcCircleButton`, `DcSpotlightNavBar`, `DcStateView`; `dcard_ui` tests 15/15 (light and dark, nav labels and glow, loading button, segmented, state view); both apps now use `DcTheme` (old alias removed).
  - Web: `globals.css` `--dc-*` roles switched by `prefers-color-scheme` and `data-theme`, `dark:` variant, Tailwind colours/radii, `brand-*` aliased to the purple roles; fonts self-hosted via `next/font` (`--font-playfair`, `--font-jakarta`); theme cookie read in the root layout (no flash) and `ThemeToggle`; `components/ui` restyled (Button, Card, Input, Field, Alert, Dialog) and new `Tile`, `StatTile`, `Progress`, `Badge`, `EmptyState`, `Tabs`; `test/ui-components.test.tsx` 8/8.
  - Checks: web `tsc` clean, vitest 252/252, `next build` ok; `dart run melos run analyze` clean; `dart run melos run test` (core 14, ui 15, mobile 67, door 89).
