# T06-05 — Rate table and internal cost/margin report

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-06-completion.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/plans-and-billing/cost-margin-report.md`

## Agent Context

- Owner: Claude Code (lead)
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/plans-and-billing.md` (Cost check), `docs/research/whatsapp-pricing.md`
- Constraints: admin only; message cost from `message_log.cost_tzs` (estimated at send from `provider_rate`); revenue from completed `host_payment`; Snippe fee from settings as a percentage; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/design/ui/design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Admins see revenue, message cost, payment fees and margin per event, per plan and per month.

## Scope Boundary

**In scope:**
- `packages/core/src/admin/cost-report.ts`
- `apps/web/src/app/api/v1/admin/cost-report`
- `apps/web/src/app/(app)/admin/cost-report/**`

**Out of scope:**
- Changing prices

## Acceptance Criteria

- [x] Report per event (plan, cards paid, revenue, WhatsApp/SMS counts and cost, payment fee, margin TZS and %) and totals per plan and per month, date-range filter.
- [x] Messages missing a cost estimate are counted and shown ("uncosted"); re-costing needs the rate category stored on `message_log` (backlog).
- [x] Tests with seeded rates, messages and payments check the numbers.

## Dependencies

- None.

## Implementation Checklist

- [x] Core report + tests.
- [x] Route + admin screen.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 (core 192, web 241, worker 30, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
  - Core `admin-platform.test.ts`: revenue from host payments, WhatsApp/SMS cost from `message_log.cost_tzs`, payment fee %, margin per event/plan/month; uncosted messages counted (not re-costed: `message_log` does not keep the rate category). Admin Cost report page (UI tests).
