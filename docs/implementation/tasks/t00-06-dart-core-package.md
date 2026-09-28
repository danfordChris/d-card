# T00-06 — Dart Core Package

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/dart-core-package.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/features/guests-and-cards.md`, `docs/design/architecture/codebase.md`
- Constraints: Pure Dart (no Flutter dependency); behavior identical to `packages/core` phone module
- Do not touch: `docs/design/`, `.agents/`, other tasks' scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a design decision is missing (record it in `docs/changes/proposed/` instead of deciding).

## Objective

`dart_packages/dcard_core` provides `normalisePhone` and `formatLocalPhone` with tests matching the TypeScript behavior.

## Scope Boundary

**In scope:**
- `dart_packages/dcard_core/**`

**Out of scope:**
- Flutter apps and Melos config (T00-07)
- Generated API client (T00-07)

## Acceptance Criteria

- [x] `normalisePhone` returns `255754123456` for `0754123456`, `+255754123456`, `754123456`, `255754123456` and `0754 123 456`.
- [x] `normalisePhone` throws `InvalidPhoneException` for `12345` and `2557541234567`.
- [x] `formatLocalPhone("255754123456")` returns `0754 123 456`.
- [x] `dart test` in `dart_packages/dcard_core` exits 0.

## Dependencies

- None.

## Implementation Checklist

- [x] Create package with pubspec and analysis options.
- [x] Implement phone functions.
- [x] Write tests.

## Verification

- Command: `cd dart_packages/dcard_core && dart pub get && dart test`
- Evidence:

```
$ cd dart_packages/dcard_core && dart pub get && dart analyze && dart test
  No issues found!
  normalises 6 accepted formats → 255754123456; rejects 7 invalid inputs with InvalidPhoneException;
  formatLocalPhone('255754123456') → '0754 123 456'
  00:00 +14: All tests passed!
```
- Same accepted/rejected cases as `packages/core/test/phone.test.ts`.
