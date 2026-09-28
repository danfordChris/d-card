# T08-03 — Door app screens on the design system

## Status

- `done`
- Last updated: 2026-09-28

## Linked Phase

- Phase: `docs/implementation/phases/phase-08-design-system.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/design-system/door-app.md`

## Agent Context

- Owner: Subagent (Flutter) with lead review
- Skills: `flutter-apply-architecture-best-practices`, `flutter-setup-localization`
- Design docs: `docs/design/ui/design-system.md`, prototype https://claude.ai/artifact/VPpuUGour1sRuU2sgD6ZhD
- Constraints: no `flutter_pack` in the door app (SQLCipher conflict); behaviour from P04/P06 unchanged; large high-contrast result states; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

D-Card Door matches the approved door flow in light and dark.

## Scope Boundary

**In scope:**
- `apps/door/lib/**`, `apps/door/test/**`

**Out of scope:**
- Server APIs
- Mobile app

## Acceptance Criteria

- [x] Sign in, Choose event, check-in with `DcSegmented` Scan / Number / Name, card-number keypad with lockout banner, name search rows, result states (admit / used / cancelled / over-used / locked), walk-in request, sync/offline, revoked screens follow the prototype using `dcard_ui` components.
- [x] Header shows event, gate and a sync chip; follows system light/dark.
- [x] Existing 89 tests pass; widget tests updated for the new layouts.

## Dependencies

- T08-01 done.

## Implementation Checklist

- [x] Screens.
- [x] Tests.

## Verification

- Command: `dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-28: sign in, choose event, check-in header + `DcSegmented` Scan/Number/Name, viewfinder, keypad with lockout tile, name results, result status tile + 2×2 details, walk-in form and states, new sync panel, revoked/not-started/ended/cache-expired/no-network status tiles, clock-skew notice — all on `dcard_ui`; new `DcStatusTile`, `DcNoticeTile` (+4 tests); `door_tones.dart` replaces hex verdict colours; no Material icons, raw colours or hex in `lib/ui`; no `flutter_pack` (SQLCipher); `test/dark_mode_test.dart` plus 89 existing tests (phone-sized test screen).
  - `pnpm turbo run typecheck lint test build --force` 27/27 (core 195, web 261, worker 32, db 6, env 7, site 7); `dart run melos run analyze` clean (--fatal-infos); `dart run melos run test` (core 14, ui 23, mobile 72, door 91).
