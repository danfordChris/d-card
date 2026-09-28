# T07-03 — Security review and fixes

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-07-hardening-pilot.md`
- Feature-inventory subfeature(s): none (phase scope item)

## Agent Context

- Owner: Subagent (review report) + Claude Code (lead, fixes)
- Skills: none
- Design docs: `docs/adr/0003-technical-stack.md`, `docs/design/features/auth.md`, `docs/design/features/privacy-and-audit.md`, `docs/design/integrations/*.md`
- Constraints: review is evidence-based (file:line); fixes keep behaviour in design; no secrets printed; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/design/ui/design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Every MVP security control is checked against the code, findings are fixed or recorded with a decision.

## Scope Boundary

**In scope:**
- `docs/security/2026-09-security-review.md`
- fixes anywhere in `apps/**`, `packages/**` for confirmed findings

**Out of scope:**
- Penetration test by a third party (after pilot)

## Acceptance Criteria

- [x] Report covers: per-event role checks on every route (AUTH-6), token generation/hashing/encryption, webhook signatures (Meta, Snippe) and replay windows, Drive `drive.file` scope and state signing, encrypted door cache and wipe, admin 2FA, rate limits, API keys, CORS/headers, input validation, SQL injection, SSRF, XSS on card/story pages, secrets handling, dependency audit (`pnpm audit`, `flutter pub outdated`), OWASP ASVS L1 items.
- [x] Each finding has severity, evidence and a status (fixed with test, or accepted with reason).
- [x] All high/critical findings fixed with regression tests.

## Dependencies

- None.

## Implementation Checklist

- [x] Review (subagent).
- [x] Triage.
- [x] Fix + tests.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-27: `docs/security/2026-09-security-review.md`: 0 critical, 0 high, 6 medium (all fixed with tests), 11 low, 8 info — each with a Fixed/Accepted status and reason. Tests: `apps/web/test/security.test.ts` (SEC-01, SEC-04), `admin-platform-api.test.ts` (SEC-02, SEC-15), `packages/core/test/door-security.test.ts` (SEC-03, SEC-20), `media-api.test.ts` (SEC-13), `billing.test.ts` (SEC-12). `pnpm audit --prod` clean (uuid override).
  - `pnpm turbo run typecheck lint test build --force` 27/27 (core 195, web 244, worker 32, db 6, env 7, site 7); `dart run melos run analyze` clean; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
