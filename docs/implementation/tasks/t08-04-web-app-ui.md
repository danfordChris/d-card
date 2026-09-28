# T08-04 — Web app on the design system

## Status

- `done`
- Last updated: 2026-09-28

## Linked Phase

- Phase: `docs/implementation/phases/phase-08-design-system.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/design-system/web-app.md`

## Agent Context

- Owner: Subagent (web) with lead review
- Skills: `vercel:nextjs`
- Design docs: `docs/design/ui/design-system.md`, prototype https://claude.ai/artifact/VPpuUGour1sRuU2sgD6ZhD
- Constraints: no behaviour or API changes; keep performance of the card page (T06-07 numbers); sw/en strings; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The web app (dashboard, event pages, guest card page, admin) matches the approved design in light and dark.

## Scope Boundary

**In scope:**
- `apps/web/src/app/**` pages and layouts (not `api/`)
- `apps/web/src/features/**`
- `apps/web/messages/*.json`

**Out of scope:**
- API routes
- packages/

## Acceptance Criteria

- [x] App shell with side navigation panel (tile background, active primary pill) and header; theme follows the system with a toggle.
- [x] Event dashboard as a 4-column bento (hero, stats, contributions progress, table, next messages) like prototype H12; other event pages (guests, contributions, messages, door devices, media, billing, audit) restyled with `components/ui`.
- [x] Guest card page `/c/[token]` and gallery follow G2/G3 (bento, Playfair), accessibility and performance kept (card-page tests pass).
- [x] Admin area uses the same shell and components; no outlined cards or decorative shadows remain; UI tests pass.

## Dependencies

- T08-01 done.

## Implementation Checklist

- [x] Shell.
- [x] Dashboard + event pages.
- [x] Card page.
- [x] Admin.
- [x] Tests.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-28: `AppShell` side navigation (tile panel, active primary pill, ThemeToggle, locale, account; mobile top bar + menu with Escape/focus return; skip link), `PageHeader`, `SectionNav`, `EventNav` by role; event overview bento (hero, stats, contributions progress, recent contributions, next messages; sections hidden by role); all event pages, events list, wizard, auth, invite, privacy and admin restyled; guest card page `/c/[token]` as a 2-column bento with the lazy gallery kept; `brand-*` aliases removed; remaining non-token colours only for print, QR contrast and the photo viewer; `test/app-shell.test.tsx`, `test/event-bento.test.tsx` (+9 tests, none changed).
  - `pnpm turbo run typecheck lint test build --force` 27/27 (core 195, web 261, worker 32, db 6, env 7, site 7); `dart run melos run analyze` clean (--fatal-infos); `dart run melos run test` (core 14, ui 23, mobile 72, door 91).
