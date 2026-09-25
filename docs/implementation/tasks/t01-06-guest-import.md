# T01-06 — Guest Import (Excel/CSV) and Copy from Past Event

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/guests-and-cards/csv-import.md`, `docs/implementation/feature-inventory/guests-and-cards/copy-from-past-event.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/guests-and-cards.md` (GST-5, GST-7), `docs/design/data-models/postgres.md` (`import_job`)
- Constraints: Validation report before import; nothing is written until the host confirms; consent confirmed once per import; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts import guests from Excel/CSV (with a template and validation report) or copy people from a past event, via API and web UI.

## Scope Boundary

**In scope:**
- `packages/db` migration (`import_job`)
- `packages/core/src/guests/import/**`
- `apps/web/src/app/api/v1/events/[id]/imports/**`
- `apps/web/src/app/(app)/events/[id]/guests/import/**`
- `apps/web/public/templates/**`

**Out of scope:**
- Phone contacts import (T01-09)

## Acceptance Criteria

- [x] `GET /templates/guests-template.xlsx` (and `.csv`) downloads a template with columns name, phone, card_type, partner_name.
- [x] `POST /api/v1/events/{id}/imports` (multipart, `.xlsx` or `.csv`, ≤ 5,000 rows) returns a report: valid rows, invalid phones (row + reason), duplicates within the file, rows matching existing guests; nothing is written.
- [x] `POST /api/v1/events/{id}/imports/{jobId}/confirm` with `consent: true` creates invitations for valid, non-duplicate rows and records `import_job` totals and one `guest_consent` (source `import`).
- [x] `POST /api/v1/events/{id}/imports/copy` with a past event id of the same host previews then copies people only (no pledges/answers); another host's event returns 403.
- [x] Web: upload → report table → confirm flow works in sw/en.

## Dependencies

- T01-04 and T01-05 done.

## Implementation Checklist

- [x] Parser for xlsx/csv + validation.
- [x] Import job schema and endpoints.
- [x] Copy-from-event endpoint.
- [x] Web upload/report/confirm UI.
- [x] Tests + build.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

```
$ pnpm --filter @dcard/core test → 52 passed (import: CSV + XLSX with sw/en headers; unsupported type / missing columns /
   corrupt xlsx rejected; preview report exact (invalid phone, name missing, bad card type, duplicate in file, existing);
   nothing written on preview; confirm needs consent, imports 2 once, second confirm 409, consent source import;
   copy from own past event skips already-invited, consent source copy; other host's event 403; same event 422)
$ pnpm --filter @dcard/web test → 60 passed (imports-api: xlsx upload 201 preview, list still empty, confirm without
   consent 422, with consent 200 {imported:2}, repeat 409; missing file 422, .pdf 422, other user 403; copy 201 / other host 403;
   import-report UI in en + sw)
$ pnpm turbo run typecheck lint test build → 23 successful, 23 total
Templates: apps/web/public/templates/guests-template.xlsx and .csv (header row only: name, phone, card_type, partner_name)
```
- Migration `0004_import_job.sql`. Limits: 2 MB file, 5,000 rows.
- Libraries: read-excel-file 9 (xlsx), papaparse 5 (csv), write-excel-file 4 (template + test fixtures).
- Fixed during verification: a literal BOM character in `import.ts` failed lint; replaced with the `\uFEFF` escape, then the pipeline passed.
