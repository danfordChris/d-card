# T06-08 — Door app: revocation, lockout UX and edge cases

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-06-completion.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/auth/door-device-sessions.md`

## Agent Context

- Owner: Subagent (Flutter) with lead review
- Skills: `flutter-apply-architecture-best-practices`, `flutter-setup-localization`
- Design docs: `docs/design/features/check-in.md`, `docs/design/architecture/offline-sync.md`, `docs/design/features/auth.md` (AUTH-9)
- Constraints: server behaviour from P04 is fixed; the app only reacts; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The door app handles revocation, lockouts and edge cases clearly.

## Scope Boundary

**In scope:**
- `apps/door/lib/**`, `apps/door/test/**`

**Out of scope:**
- Server APIs (P04)

## Acceptance Criteria

- [x] A revoked device (423/`device_revoked`) stops scanning, uploads pending entries if allowed, wipes the offline cache and shows a clear screen.
- [x] Card-number lockout shows the remaining wait time and blocks input until it ends.
- [x] Edge cases have clear screens: event not started/ended, cancelled card, over-used card, no network with empty cache, clock skew warning.
- [x] Widget tests for each state.

## Dependencies

- None.

## Implementation Checklist

- [x] States + screens.
- [x] Tests.
- [x] Analyze + test.

## Verification

- Command: `pnpm turbo run typecheck lint test build && dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 (core 192, web 241, worker 30, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
  - Revoked device (server sends 403): stops, uploads pending once, wipes the SQLCipher cache, clear screen; lockout countdown kept in the cache; event not started/ended warnings, cancelled and over-used detail, offline with no cache, clock-skew banner (HTTP `Date`). 17 new widget tests; door 89 tests pass.
