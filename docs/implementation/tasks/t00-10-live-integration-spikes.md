# T00-10 — Live Integration Spikes

## Status

- `blocked`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/environment-config.md`

## Agent Context

- Skills: `snippe-integration`
- Design docs: `docs/design/integrations/*`
- Constraints: run only with owner-provided test credentials; record results, never commit keys.
- Do not touch: `docs/design/`, application source code

## Session Budget

- Mode: `interactive`
- Stop when: each of the four spikes has a recorded pass/fail
- Handoff when: a provider rejects the approach (record in `docs/changes/proposed/`)

## Objective

Each risky integration is proven live with the `spikes/` scripts and the results are recorded.

## Scope Boundary

**In scope:**
- Running `spikes/*.ts`
- `docs/research/spike-results.md`

**Out of scope:**
- Production adapters (phases 03, 05)

## Acceptance Criteria

- [ ] `docs/research/spike-results.md` records, per provider, the request, the webhook/response and pass/fail.
- [ ] A Meta test template with a quick-reply button returns the per-invitation payload in the webhook.
- [ ] A NextSMS test send produces a delivery callback.
- [ ] A browser upload through a Drive resumable session creates a file in a test Drive folder.
- [ ] A Snippe test-mode USSD push returns a payment webhook.

## Dependencies

- Blocked: owner adds real test keys to `.env` (Meta, NextSMS, Google Cloud, Snippe).
- T00-08 done.

## Implementation Checklist

- [ ] Owner fills keys; `pnpm env:check` shows no dummy values for the tested providers.
- [ ] Run each spike and record results.

## Verification

- Command: `pnpm env:check && pnpm tsx spikes/<script>.ts`
- Evidence: pending
