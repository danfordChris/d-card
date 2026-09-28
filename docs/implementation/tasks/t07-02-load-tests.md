# T07-02 — Load tests and provider throughput limits

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-07-hardening-pilot.md`
- Feature-inventory subfeature(s): none (phase scope item)

## Agent Context

- Owner: Claude Code (lead)
- Skills: none
- Design docs: `docs/design/features/check-in.md`, `docs/design/architecture/offline-sync.md`, `docs/design/integrations/messaging.md`, `docs/design/features/media.md` (MED-8)
- Constraints: load scripts run against the local stack (Postgres, Redis, web on localhost) with fake providers — never real SMS/WhatsApp/Drive; WhatsApp sends stay under Meta's default 80 messages/second per number (throughput counts inbound too), error 130429 backs off; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/changes/proposed/ui-design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Measured evidence that check-in, offline sync, message fan-out and the gallery/slideshow hold at pilot scale, with send rates capped below provider limits.

## Scope Boundary

**In scope:**
- `apps/worker/load/**` (run with `pnpm load:all`)
- `apps/worker/src/**` (queue rate limiters, 130429 handling)
- `packages/env/src/schema.ts` (rate settings)
- `docs/load-tests.md`

**Out of scope:**
- Real providers (pilot, T07-05)
- Paid load-testing services

## Acceptance Criteria

- [x] Seed script creates a paid event with 1,000 issued cards (single and double) and 4 door devices.
- [x] 4 gates admit concurrently online (every card once, doubles twice, plus duplicate scans): zero over-admits, every refusal correct, p95 latency recorded.
- [x] 4 offline gates upload overlapping batches concurrently: merge is exactly-once, over-used cards flagged once, timings recorded.
- [x] Fan-out of 1,000 guest messages through outbox → dispatch → send queues with fake senders completes, respecting the WhatsApp limiter (default 60/s, `WHATSAPP_MAX_PER_SECOND`) and SMS limiter (`SMS_MAX_PER_SECOND`, default 20/s); fixed quarter-second windows allow at most 1.25× the cap in any one second; Meta 130429 → retry with backoff (unit test).
- [x] Gallery listing and slideshow feed with 500 items in private and link modes (fake store) respond within recorded times.
- [x] `docs/load-tests.md` records machine, commands, numbers and limits (including Meta's messaging-limit tiers for unverified businesses).

## Dependencies

- Docker (Postgres, Redis) running locally.

## Implementation Checklist

- [x] Limiters + 130429 handling + tests.
- [x] Seed script.
- [x] Check-in and sync load scripts.
- [x] Fan-out script.
- [x] Gallery script.
- [x] Run, record, fix bottlenecks.
- [x] Pipeline.

## Verification

- Command: `pnpm load:all`
- Evidence:

- 2026-09-27: `pnpm load:all` 11/11 checks pass (`docs/load-tests.md`): 1,000 guests, 4 gates online 260 admits/s p95 24 ms with 0 over-admits; offline merge exactly-once with over-use flagged exactly; 1,000-message fan-out in one dispatch tick at 101/s (cap 100, busiest second 115 ≤ 1.25×); gallery/slideshow p95 ≤ 120 ms with 500 photos in both modes.
  - Fixed: concurrent offline over-use (row locks + regression test in `checkin-sync.test.ts`), dispatch 100-per-tick bottleneck, send limiters (`WHATSAPP_MAX_PER_SECOND` 60, `SMS_MAX_PER_SECOND` 20) and Meta 130429-family retries (`senders.test.ts`).
  - `pnpm turbo run typecheck lint test build --force` 27/27 (core 195, web 244, worker 32, db 6, env 7, site 7); `dart run melos run analyze` clean; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
