# Phase 08 — Design system rollout

## Status

- `done`
- Last updated: 2026-09-28

## Objective

- Every screen of the mobile, door and web apps uses the approved design system (`docs/design/ui/design-system.md`), in light and dark.

## Scope

- **Foundations:** tokens, fonts, theme (light/dark) and shared components in `dcard_ui` and web `components/ui`.
- **Host and guest app:** the host flow H1–H11 and the guest flow G5–G7, the spotlight navigation, and a theme setting stored with `flutter_pack` preferences.
- **Door app:** the door flow D1–D10.
- **Web app:** side-navigation shell and bento dashboard (H12), the guest card page (G2, G3), and the admin area.

---

## Included Features

- `docs/implementation/feature-inventory/design-system/tokens-components.md`
- `docs/implementation/feature-inventory/design-system/host-guest-app.md`
- `docs/implementation/feature-inventory/design-system/door-app.md`
- `docs/implementation/feature-inventory/design-system/web-app.md`

## Task Checklist

- [x] Break the scope into task files (T08-01…T08-04).
- [x] All linked tasks done with evidence.
- [x] Phase review written (`docs/implementation/reviews/2026-09-28-phase-08-review.md`).

## Acceptance Criteria

- [x] Every existing screen follows the approved design in light and dark (screens not yet in the mobile app are backlog).
- [x] Every linked task is `done` with verification evidence.
- [x] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- None.

## Linked Tasks

- `docs/implementation/tasks/t08-01-design-foundations.md`
- `docs/implementation/tasks/t08-02-host-guest-app-ui.md`
- `docs/implementation/tasks/t08-03-door-app-ui.md`
- `docs/implementation/tasks/t08-04-web-app-ui.md`
