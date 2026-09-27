# T06-04 — Host audit log view and exports

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-06-completion.md`
- Feature-inventory subfeature(s): none (phase scope item)

## Agent Context

- Owner: Subagent (web) with lead review
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/privacy-and-audit.md` (Audited Actions), `docs/design/features/contributions.md`, `docs/design/features/check-in.md`
- Constraints: host and treasurer see only their event's entries; personal data already masked by retention stays masked; CSV is UTF-8 with BOM for Excel; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts browse their event's audit trail and export guests, contributions and attendance as CSV.

## Scope Boundary

**In scope:**
- `packages/core/src/audit/event-audit.ts`, `packages/core/src/exports/**`
- `apps/web/src/app/api/v1/events/[id]/{audit,exports/[kind]}`
- `apps/web/src/features/audit/**`, event page link

**Out of scope:**
- Admin audit search (T06-03)

## Acceptance Criteria

- [x] `GET /api/v1/events/{id}/audit` paginated with action filter, host/treasurer only, readable sw/en labels per action.
- [x] `GET /api/v1/events/{id}/exports/{guests|contributions|attendance}` returns CSV (host, treasurer for contributions); audited `export.downloaded`.
- [x] Web page lists entries with actor, time, action and change summary; export buttons.
- [x] Tests cover role access, filters and CSV content.

## Dependencies

- None.

## Implementation Checklist

- [x] Core queries + tests.
- [x] Routes.
- [x] Web page.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 (core 192, web 241, worker 30, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
  - Core `event-audit.test.ts` (14): host/treasurer access, action-prefix filter, cursor pagination, change summaries, CSV (BOM, quoting, formula guard), guests/contributions/attendance exports audited `export.downloaded`. Web `audit-exports-api.test.ts` (7). Audit page with sw/en action labels and export buttons.
