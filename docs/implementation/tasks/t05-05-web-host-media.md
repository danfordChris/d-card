# T05-05 — Host media: connect, card media, story, moderation, slideshow

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-05-payments-media.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/media/card-media.md`, `docs/implementation/feature-inventory/media/story-page.md`, `docs/implementation/feature-inventory/media/slideshow.md`, `docs/implementation/feature-inventory/media/sharing-modes.md`, `docs/implementation/feature-inventory/media/drive-connect.md`

## Agent Context

- Owner: Subagent (web)
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/media.md` (MED-1…MED-5, MED-7…MED-11, MED-14), plan limits in `plans-and-billing.md`
- Constraints: uploads go browser → Drive through the session URL (never through D-Card); images resized in the browser before upload; video length checked before upload; slideshow preloads/caches thumbnails and polls for new items; Msingi shows only the Google Photos link option; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon (`docs/changes/proposed/ui-design-system.md` principles: no decorative gradients/shadows); money as whole TZS integers; phone numbers `255` + 9 digits
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts connect Drive, choose the sharing mode, add card media and story items, moderate the gallery and run the live slideshow from the web.

## Scope Boundary

**In scope:**
- `apps/web/src/features/media/**`
- `apps/web/src/app/(app)/events/[id]/media/**`, `.../slideshow/**`
- `media` namespace in `apps/web/messages/{en,sw}.json`
- one link on the event summary page

**Out of scope:**
- Media API (T05-04)
- Guest pages (T05-06)

## Acceptance Criteria

- [x] Connect/disconnect Drive, sharing-mode choice with the explanation, quota display and warning.
- [x] Card media and story editors within plan limits (count, size, video length), resize before upload, progress, retry.
- [x] Gallery moderation: hide/delete/restore, reported items.
- [x] Premium live slideshow page (full screen, new uploads appear).
- [x] Component tests; sw/en.

## Dependencies

- T05-04 contract.

## Implementation Checklist

- [x] Connect + sharing.
- [x] Card media + story.
- [x] Moderation.
- [x] Slideshow.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-27 (built by a web subagent, verified by the lead): full pipeline 27/27; `apps/web/test/media-ui.test.tsx` (18 tests): connect link, sharing mode, reconnect prompt, Msingi Photos-link only, plan-limit disabling, upload session → PUT to Drive → complete with resize and 308 chunk resume, retry, too-long video rejected, delete, gallery moderation, slideshow merge/poll/preload and Premium gate, sw render.
