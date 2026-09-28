# T05-06 — Guest gallery and uploads on the card link

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-05-payments-media.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/media/guest-gallery.md`, `docs/implementation/feature-inventory/media/direct-uploads.md`, `docs/implementation/feature-inventory/media/story-page.md`

## Agent Context

- Owner: Subagent (web)
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/media.md` (MED-5, MED-6, MED-7, MED-11, MED-12)
- Constraints: no login: uploads tied to the invitation behind the card token; upload window and per-guest limits from the plan; images resized in the browser; gallery page closes after the plan period; guests can delete their own uploads and report an item; works well on low-end phones and slow networks; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon (`docs/changes/proposed/ui-design-system.md` principles: no decorative gradients/shadows); money as whole TZS integers; phone numbers `255` + 9 digits
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Guests see the story and the event gallery from their card link and upload photos and videos directly to the host's Drive.

## Scope Boundary

**In scope:**
- `apps/web/src/app/c/[token]/**` (story + gallery sections)
- `apps/web/src/features/card-page/**`
- `cardPage` namespace additions in `apps/web/messages/{en,sw}.json`

**Out of scope:**
- Media API (T05-04)

## Acceptance Criteria

- [x] Story and gallery on the card page (private: proxied URLs; link: Drive URLs).
- [x] Guest upload with resize, progress and retry within window and limits; clear messages when closed, over the limit or the Drive is full.
- [x] Delete own upload, report an item.
- [x] Component tests; sw/en.

## Dependencies

- T05-04 contract.

## Implementation Checklist

- [x] Story + gallery view.
- [x] Upload flow.
- [x] Delete/report.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-27 (built by a web subagent, verified by the lead): full pipeline 27/27; `apps/web/test/guest-gallery.test.tsx` (9 tests): story + gallery render, closed reasons and 410, upload flow with resize and 8 MB chunking, limits, delete own, report other, sw render.
  - Lead change: private card-link media load directly (card token credential, no API key), so videos stream instead of downloading as a blob.
