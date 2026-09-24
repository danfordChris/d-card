# Phase 02 — Contributions and cards (weeks 5–6)

## Status

- `pending`
- Last updated: 2026-09-24

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

- [ ] Break the scope below into task files before the phase starts (vertical slices, per `task-spec.md`).

## Acceptance Criteria

- [ ] recording the final payment issues a card, and the card page opens from its link. (Sending comes in sprint 3.)
- [ ] Every linked task is `done` with verification evidence.
- [ ] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- Previous phase not done.

## Linked Tasks

- None yet.
