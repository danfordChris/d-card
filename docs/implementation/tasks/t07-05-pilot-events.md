# T07-05 — Pilot events and fix-only period

## Status

- `pending`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-07-hardening-pilot.md`
- Feature-inventory subfeature(s): none (phase scope item)

## Agent Context

- Owner: Owner (hosts, events) + Claude Code (fixes)
- Skills: none
- Design docs: `docs/launch/pilot-runbook.md`
- Constraints: fix-only: no new features; every fix has a test; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

2–3 real events run on production with real providers and their issues are fixed.

## Scope Boundary

**In scope:**
- fixes anywhere; `docs/implementation/reviews/` pilot reports

**Out of scope:**
- New features

## Acceptance Criteria

- [ ] 2–3 pilot events (e.g. a kitchen party and a wedding) completed on production with real SMS, WhatsApp, Snippe and Drive.
- [ ] Each pilot has a short report: numbers (guests, cards, check-ins, messages, cost), issues, fixes.
- [ ] All pilot bugs fixed with tests or recorded in the backlog with a decision.

## Dependencies

- Owner: friendly hosts and dates; all launch-checklist items for production.

## Implementation Checklist

- [ ] Run pilots.
- [ ] Fix.
- [ ] Report.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence: pending
