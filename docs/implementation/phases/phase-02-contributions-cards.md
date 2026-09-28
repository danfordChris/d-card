# Phase 02 — Contributions and cards (weeks 5–6)

## Status

- `done`
- Last updated: 2026-09-25

## Objective

- recording the final payment issues a card, and the card page opens from its link. (Sending comes in sprint 3.)

## Scope

| A | B | C |
|---|---|---|
| Pledges, payments, refunds, extras; **auto-issue** and **auto-upgrade** (plan-gated); manual pledge edits before issue | Contributions dashboard (pledged/paid/balance, status lists), record payment, export | Treasurer screens in D-Card app: record payment, contributor list |
| Card numbers `NNN-PPPP`, QR and link tokens (hashed), cancel/reinstate; card type immutable (DB trigger) | **Guest card page** (no login): card, QR, date/venue, RSVP, dietary, add to calendar | |
| Card image renderer (QR overlay) | Direct card issue UI | |

## Included Features

- `docs/implementation/feature-inventory/guests-and-cards/card-issue-and-numbers.md`
- `docs/implementation/feature-inventory/guests-and-cards/card-cancel-reinstate.md`
- `docs/implementation/feature-inventory/guests-and-cards/guest-card-page.md`
- `docs/implementation/feature-inventory/guests-and-cards/rsvp-and-dietary.md`
- `docs/implementation/feature-inventory/contributions/pledges.md`
- `docs/implementation/feature-inventory/contributions/payment-recording.md`
- `docs/implementation/feature-inventory/contributions/refunds-and-extras.md`
- `docs/implementation/feature-inventory/contributions/auto-issue.md`
- `docs/implementation/feature-inventory/contributions/auto-upgrade.md`
- `docs/implementation/feature-inventory/contributions/manual-pledge-edit.md`
- `docs/implementation/feature-inventory/contributions/contributions-dashboard.md`

## Task Checklist

- [x] T02-01 — Card issue, numbers, tokens, cancel/reinstate (core + API) (`docs/implementation/tasks/t02-01-card-issue-core.md`)
- [x] T02-02 — Pledges, payments, auto-upgrade and auto-issue (core + API) (`docs/implementation/tasks/t02-02-contributions-core.md`)
- [x] T02-03 — Guest card page, RSVP, dietary and calendar (`docs/implementation/tasks/t02-03-guest-card-page.md`)
- [x] T02-04 — Card image renderer (built-in design, QR overlay) (`docs/implementation/tasks/t02-04-card-image-renderer.md`)
- [x] T02-05 — Web contributions dashboard, record payment, pledge edit, export (`docs/implementation/tasks/t02-05-web-contributions.md`)
- [x] T02-06 — Web direct card issue, cancel/reinstate and card link (`docs/implementation/tasks/t02-06-web-card-issue.md`)
- [x] T02-07 — Mobile treasurer: contributor list and record payment (`docs/implementation/tasks/t02-07-mobile-treasurer.md`)

## Acceptance Criteria

- [x] recording the final payment issues a card, and the card page opens from its link. (Sending comes in sprint 3.)
- [x] Every linked task is `done` with verification evidence.
- [x] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Review

- `docs/implementation/reviews/2026-09-25-phase-02-review.md`

## Blockers

- None. Decisions for this phase: RSVP Yes/No (ADR 0001 O19), built-in card design until templates (O20), card token storage (ADR 0003).

## Linked Tasks

- docs/implementation/tasks/t02-01-card-issue-core.md
- docs/implementation/tasks/t02-02-contributions-core.md
- docs/implementation/tasks/t02-03-guest-card-page.md
- docs/implementation/tasks/t02-04-card-image-renderer.md
- docs/implementation/tasks/t02-05-web-contributions.md
- docs/implementation/tasks/t02-06-web-card-issue.md
- docs/implementation/tasks/t02-07-mobile-treasurer.md
