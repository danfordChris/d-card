# T05-04 — Google Drive connection, folders, uploads and media store

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-05-payments-media.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/media/drive-connect.md`, `docs/implementation/feature-inventory/media/sharing-modes.md`, `docs/implementation/feature-inventory/media/direct-uploads.md`, `docs/implementation/feature-inventory/media/drive-quota.md`

## Agent Context

- Owner: Claude Code (lead)
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/media.md` (MED-1, MED-1a, MED-2, MED-10, MED-12, MED-13, MED-16), `docs/design/integrations/google-drive.md`, `docs/adr/0002-media-storage.md`
- Constraints: scope `drive.file` only; refresh tokens AES-GCM encrypted; folder `D-Card – {event title}` with `card/`, `story/`, `gallery/`; private mode streams through D-Card with a valid card link, link mode shares the folder; resumable upload sessions — bytes never touch D-Card servers; plan limits (counts, sizes, video length) enforced when issuing an upload session; everything behind a `MediaStore` interface with a fake for tests; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon (`docs/changes/proposed/ui-design-system.md` principles: no decorative gradients/shadows); money as whole TZS integers; phone numbers `255` + 9 digits
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

A host connects Google Drive, D-Card creates the event folders with the chosen sharing mode, and clients upload directly to Drive through server-issued resumable sessions.

## Scope Boundary

**In scope:**
- `packages/db/src/schema.ts` (`google_connection`, `media_item`, event sharing mode) + migration
- `packages/core/src/media/**`
- `packages/api-contract/src/media.ts`
- `apps/web/src/app/api/v1/media/google/**`, `apps/web/src/app/api/v1/events/[id]/media/**`, `apps/web/src/app/api/v1/cards/[token]/media/**`

**Out of scope:**
- Media screens (T05-05, T05-06)

## Acceptance Criteria

- [x] OAuth connect/disconnect (`drive.file`), encrypted refresh token, folder + subfolders created once per event, sharing mode private/link (changeable, audited).
- [x] `POST /api/v1/events/{id}/media/upload-sessions` (host) and `/api/v1/cards/{token}/media/upload-sessions` (guest) return a Drive resumable URL within plan and per-guest limits and the upload window; completion registers a `media_item` with `drive_file_id`.
- [x] Private mode: thumbnails/files streamed through D-Card for valid card links only; link mode: direct Drive URLs.
- [x] Quota read and warning; uploads paused with a clear message when Drive is full; missing files hidden and reconnect prompt flagged.
- [x] Tests with a fake `MediaStore`; no media bytes written to D-Card storage.

## Dependencies

- Owner: Google OAuth consent screen (test users) with the production redirect URI.

## Implementation Checklist

- [x] Schema + migration.
- [x] MediaStore interface, Drive adapter, fake.
- [x] OAuth connect/disconnect.
- [x] Folders + sharing modes.
- [x] Upload sessions + completion.
- [x] Private proxy + link mode.
- [x] Quota + missing files.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 tasks (core 161, web 217, worker 28).
  - Core `packages/core/test/media.test.ts` (7 tests, fake `MediaStore`): signed OAuth state (tamper/expiry rejected); connect creates `D-Card – {title}` with card/story/gallery once, refresh token encrypted, reconnect keeps folders; sharing mode host-only and applied to the folder; Google Photos link validated; Msingi media disabled; upload sessions within plan counts, types, sizes and video length, created with the app origin; only files in the event folder can be registered; Drive full → uploads paused; revoked access → reconnect flag; guest window (opens 12 h before, closes N days after), per-guest limit, delete own / report others, gallery page closes after the plan period (410); files deleted in Drive become `missing`; link mode serves Drive URLs.
  - Web `apps/web/test/media-api.test.ts` (3 tests): proxy lets only Drive connect/callback and card-link content skip the API key; connect → Google consent (drive.file) → signed callback → connected; host upload + complete; guest upload, view and private streaming by card token.
  - Schema `0015_media` (`google_connection`, `event_media`, `media_item`); decisions recorded in `docs/design/integrations/google-drive.md` and `features/media.md` (MED-6 window, owner to confirm).
  - Live Google check waits for the owner: OAuth consent screen (test users) and redirect URIs `http://localhost:3000/api/v1/media/google/callback` and `https://api.dcard.danfordchris.dev/api/v1/media/google/callback`.
