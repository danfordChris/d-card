# Phase 05 — Payments and media (weeks 11–12)

## Status

- `in-progress`
- Last updated: 2026-09-27

## Objective

- a host pays via Snippe (fake gateway in tests; one real Tsh 500 payment in production — Snippe has no sandbox), cards unlock, and guests upload to the host's Drive (both sharing modes).

## Scope

| A | B | C |
|---|---|---|
| **Snippe:** checkout (USSD push + hosted session), webhook with idempotency, host_payment, min charge, guest blocks of 10, upgrades, launch offer; "no sending before payment" gate | Checkout and plan-upgrade screens, receipts | Checkout in D-Card app (host) |
| **Google Drive:** connect (drive.file), folder creation, sharing mode (private/link), resumable upload sessions, quota check, missing-file handling, `MediaStore` interface; private-mode media proxy | Media step (connect, sharing mode), card media and story editor, gallery moderation, **slideshow** | Guest upload from the D-Card app (optional; the web card link is primary) |

## Included Features

- `docs/implementation/feature-inventory/media/drive-connect.md`
- `docs/implementation/feature-inventory/media/sharing-modes.md`
- `docs/implementation/feature-inventory/media/direct-uploads.md`
- `docs/implementation/feature-inventory/media/card-media.md`
- `docs/implementation/feature-inventory/media/story-page.md`
- `docs/implementation/feature-inventory/media/guest-gallery.md`
- `docs/implementation/feature-inventory/media/slideshow.md`
- `docs/implementation/feature-inventory/media/drive-quota.md`
- `docs/implementation/feature-inventory/plans-and-billing/snippe-checkout.md`
- `docs/implementation/feature-inventory/plans-and-billing/pricing-rules.md`
- `docs/implementation/feature-inventory/plans-and-billing/launch-offer.md`

## Task Checklist

- [x] Break the scope below into task files before the phase starts (vertical slices, per `task-spec.md`).

## Acceptance Criteria

- [ ] a host pays via Snippe (test mode), cards unlock, and guests upload to the host's Drive (both sharing modes).
- [x] Every linked task is `done` with verification evidence.
- [x] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- Google OAuth consent screen (test users) and the production redirect URI `https://api.dcard.danfordchris.dev/api/v1/media/google/callback` (owner).
- Snippe webhook URL `https://api.dcard.danfordchris.dev/api/webhooks/snippe` registered in the Snippe dashboard (owner).
- Guest upload from the D-Card app (scope C, optional) moved to backlog; the card link is the primary upload path.

## Linked Tasks

- docs/implementation/tasks/t05-01-billing-core-snippe.md
- docs/implementation/tasks/t05-02-web-checkout.md
- docs/implementation/tasks/t05-03-mobile-checkout.md
- docs/implementation/tasks/t05-04-drive-core.md
- docs/implementation/tasks/t05-05-web-host-media.md
- docs/implementation/tasks/t05-06-guest-gallery.md
