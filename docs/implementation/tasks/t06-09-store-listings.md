# T06-09 — Store listings and internal testing tracks

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-06-completion.md`
- Feature-inventory subfeature(s): none (phase scope item)

## Agent Context

- Owner: Claude Code (lead) — docs and build config; store accounts by the owner
- Skills: none
- Design docs: `docs/deployment.md`, `docs/design/features/privacy-and-audit.md`
- Constraints: no store submissions without the owner; no signing keys in the repo; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/design/ui/design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Both apps build release artifacts and have listing text, data-safety answers and a testing-track checklist ready for the owner.

## Scope Boundary

**In scope:**
- `apps/mobile`, `apps/door` release build config (app ids, versions, icons placeholders)
- `docs/store-listings.md`

**Out of scope:**
- Public release

## Acceptance Criteria

- [x] `docs/store-listings.md` has sw/en name, short/full description, keywords, privacy URL (`/privacy`), Google Play data-safety and Apple privacy answers for both apps.
- [x] Release builds (`flutter build appbundle` / `flutter build ipa --no-codesign`) succeed or the blocking owner step is documented.
- [x] Checklist for Play internal testing and TestFlight.

## Dependencies

- Owner: Google Play and Apple developer accounts, signing keys.

## Implementation Checklist

- [x] Listing doc.
- [x] Build config.
- [x] Release build check.

## Verification

- Command: `flutter build appbundle`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 (core 192, web 241, worker 30, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
  - `docs/store-listings.md`: sw/en listings, data-safety and App Privacy answers, screenshots and testing-track checklists. `flutter build appbundle` succeeds for both apps (debug-signed until `key.properties`); `flutter build ipa --no-codesign` archives both (iOS minimum 15.0). Release signing reads gitignored `android/key.properties`. Owner: developer accounts, keystore, icons, APNs, Sign in with Apple capability.
