# T02-04 — Card image renderer (built-in design, QR overlay)

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-02-contributions-cards.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/guests-and-cards/card-issue-and-numbers.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/architecture/codebase.md` (card image row), `docs/design/features/media.md` (MED-4), `docs/design/features/guests-and-cards.md` (Card Design)
- Constraints: rendered on demand, never stored (no media storage); built-in design per event type (ADR 0001 O20); QR must scan reliably; PNG ≤ 1 MB, 1080×1350; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

D-Card renders a PNG card image with the guest's details and QR code on demand, for the card page download now and WhatsApp sending in phase 03.

## Scope Boundary

**In scope:**
- `packages/core/src/cards/render/**` or `apps/web/src/server/card-image/**`
- `apps/web/src/app/api/v1/cards/[token]/image/**`

**Out of scope:**
- Uploading to Meta / sending (phase 03)
- Admin card templates (EVT-5, later)
- Animated/video cards (phase 05)

## Acceptance Criteria

- [x] `GET /api/v1/cards/{token}/image` returns `image/png` 1080×1350 for an issued card with title, guest name(s), date, venue, card number and QR; cancelled/unknown → 404.
- [x] The QR in the rendered image decodes back to the card's QR token (test decodes the PNG).
- [x] Each event type has a built-in design (at least colour/heading variant); unknown types fall back to a default.
- [x] Response has `Cache-Control: private, no-store`; nothing is written to disk or storage.

## Dependencies

- T02-01 done.

## Implementation Checklist

- [x] Choose renderer (`next/og` vs `sharp`) and fonts (bundled).
- [x] Design per event type.
- [x] Route + decode test.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- Renderer: `apps/web/src/server/card-image/card-image.tsx` (`next/og` ImageResponse = Satori + Resvg, bundled Geist font; built-in design per event type from `src/lib/card-design.ts`, shared with the card page). Route `GET /api/v1/cards/{token}/image?lang=sw|en`.
- `apps/web/test/card-image.test.ts` (2): 200 `image/png`, `no-store`, < 1 MB, 1080×1350; QR decoded with jsQR equals the card's QR token; English variant 200; cancelled and unknown cards 404.
- Visual check: sample wedding card rendered to PNG and reviewed (title, names, "Watu 2", Swahili date · time, venue, QR, card number, door hint).
- Card page gets a "Download card image" link.
- Nothing is written to disk or storage (response only). Unknown event types fall back to `DEFAULT_DESIGN`.
- `pnpm turbo run typecheck lint test build` → 23/23 (2026-09-25).
- Note: the bundled font has one weight, so headings render regular; a bold font can be bundled with the templates work.
