# Review Report — 2026-09-28 (Phase 08: Design system rollout)

## Summary

- Reviewed T08-01 to T08-04. All four meet their acceptance criteria, with recorded evidence.
- One criterion was narrowed to what exists: T08-02 restyles every screen the mobile app has. Host screens that exist only on web (create event, guests list, messages, team) and notification history are in the backlog.
- Who did what:
  - Lead: design doc, T08-01 foundations (Flutter and web tokens, fonts, themes, components).
  - Subagents: T08-02 mobile, T08-03 door, T08-04 web.
  - The lead ran the full checks and reconciled the docs.
- Checks:
  - `pnpm turbo run typecheck lint test build --force`: 27/27 (core 195, web 261, worker 32, db 6, env 7, site 7).
  - `dart run melos run analyze`: clean (`--fatal-infos`).
  - `dart run melos run test`: core 14, ui 23, mobile 72, door 91.
  - `validate_workflow.py` → `WORKFLOW:ok`.

## Standards

- Screens read colours only through token roles (`context.dc` in Flutter, `--dc-*` and Tailwind roles on web). No hex values in screens.
- Remaining non-token colours on web, each for a stated reason: print output, a white background behind the QR code so door scanners can read it in dark mode, and the black photo viewer.
- Fonts are bundled (Flutter) or self-hosted (web), so nothing loads at runtime and the door app keeps working offline.
- Hugeicons only. No outlined cards and no decorative shadows. The floating nav's shadow and spotlight are the approved exception.
- Every async surface has loading, empty, no-results and error states (`DcStateView`, `DcStatusTile`, `EmptyState`).
- Accessibility:
  - screen-reader labels on icon-only tabs and buttons;
  - selected and current states marked;
  - the web mobile menu handles Escape and returns focus;
  - skip link;
  - touch targets of at least 44 px (56–64 px for door primary actions).

## Spec

- The design doc (`docs/design/ui/design-system.md`) is the adopted truth. The proposal is removed.
- `flutter_pack` could not be resolved: its `package_info_plus ^9` needs `win32 ^5`, while `flutter_secure_storage ^11` needs `win32 ^6`. The theme setting uses `shared_preferences`, as recorded in the design doc.
- Door behaviour changes, all in the layout only:
  - the sync chip opens the sync panel;
  - walk-in moved into a tile;
  - the keypad has a Clear key.

## Verification

- Commands:
  - `pnpm turbo run typecheck lint test build --force`
  - `dart run melos run analyze`
  - `dart run melos run test`
  - `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`
- Evidence: the Verification sections of `docs/implementation/tasks/t08-*.md`.

## Follow-ups

- Backlog:
  - mobile create event, guests list, messages and team;
  - notification history;
  - money and confirmation figures in the mobile events list;
  - door walk-in fields (name, phone, people) and a checked-in counter;
  - `flutter_pack` once it supports win32 ^6.
- Visual check on real devices and in the browser in light and dark before the pilot. The rollout was verified by tests and builds, not by eye.
