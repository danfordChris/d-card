# T08-02 — Host and guest app screens on the design system

## Status

- `done`
- Last updated: 2026-09-28

## Linked Phase

- Phase: `docs/implementation/phases/phase-08-design-system.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/design-system/host-guest-app.md`

## Agent Context

- Owner: Subagent (Flutter) with lead review
- Skills: `flutter-apply-architecture-best-practices`, `flutter-setup-localization`
- Design docs: `docs/design/ui/design-system.md`, prototype https://claude.ai/artifact/VPpuUGour1sRuU2sgD6ZhD
- Constraints: keep MVVM, repositories and the generated `dcard_api` client; add `flutter_pack` only for preferences (theme mode) and helpers; sw/en strings; no behaviour changes; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The D-Card mobile app matches the approved host and guest flows in light and dark.

## Scope Boundary

**In scope:**
- `apps/mobile/lib/**`, `apps/mobile/test/**`, `apps/mobile/pubspec.yaml`

**Out of scope:**
- Server APIs
- Door app
- Web

## Acceptance Criteria

- [x] Shell uses `DcSpotlightNavBar` with Home, My cards, New event, Notifications, Account (labels for screen readers).
- [x] Every screen the mobile app has (sign in, dashboard, event, plan & payment/checkout, add from contacts, contributions and record payment, walk-in approver, my cards, card, account) follows the prototype layouts using `dcard_ui` components only. Host screens the app does not have yet (create event, guests list, messages, team — web only today) are backlog, not restyles.
- [x] Account has a Light / Dark / System theme setting, persisted with `shared_preferences` because `flutter_pack` does not resolve with the workspace (win32 ^5 vs ^6; recorded in the design doc).
- [x] No Material icons remain; no hex colours in screens; existing tests pass and new widget tests cover the nav and the theme switch.

## Dependencies

- T08-01 done.

## Implementation Checklist

- [x] Shell + nav.
- [x] Screens in flow order.
- [x] Theme setting.
- [x] Tests.

## Verification

- Command: `dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-28: shell with `DcSpotlightNavBar` (Home, My cards, New event, Notifications, Account; sw/en labels); sign in, dashboard bento, event, plan & payment/checkout, add from contacts, contributions and record payment, walk-in approver, my cards, card and account restyled on `dcard_ui`; Light/Dark/System setting (`shared_preferences`; `flutter_pack` unresolvable: win32 ^5 vs ^6); dcard_ui additions `extra_rows.dart` (`DcIconDisc`, `DcSectionHeader`, `DcListRow`, `DcDateBlock`, `DcActionTile`, `DcChoice`, `DcPageHeader`) with tests; one-off `FlatCard`/`IconDisc`/`Notice`/`Pill` removed; no Material icons, raw colours or hex in screens; `test/shell_test.dart` (tabs, labels en/sw, theme saved/restored, dark dashboard) plus 67 existing tests.
  - `pnpm turbo run typecheck lint test build --force` 27/27 (core 195, web 261, worker 32, db 6, env 7, site 7); `dart run melos run analyze` clean (--fatal-infos); `dart run melos run test` (core 14, ui 23, mobile 72, door 91).
