# T00-05 — Worker Runtime

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/worker-runtime.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/architecture/system.md` (Messaging and Background Processing)
- Constraints: BullMQ on Redis; long-lived Node process; graceful shutdown on SIGTERM
- Do not touch: `docs/design/`, `.agents/`, other tasks' scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass, or Redis is unreachable
- Handoff when: context becomes recap-heavy, or a design decision is missing (record it in `docs/changes/proposed/` instead of deciding).

## Objective

`apps/worker` runs a BullMQ worker that processes a `system:ping` job, with queue names defined in `packages/core/src/queues`.

## Scope Boundary

**In scope:**
- `apps/worker/**`
- `packages/core/src/queues/**`

**Out of scope:**
- Messaging adapters and scheduled jobs (phase 03)

## Acceptance Criteria

- [x] `pnpm --filter @dcard/worker start` logs `worker:ready` once connected to Redis.
- [x] A `ping` job added to the `system` queue completes within 5 seconds (`pnpm --filter @dcard/worker test`).
- [x] SIGTERM closes the worker and Redis connections and the process exits 0.

## Dependencies

- T00-01 done.

## Implementation Checklist

- [x] Define queue names in `packages/core/src/queues`.
- [x] Create `apps/worker` with BullMQ worker and ping processor.
- [x] Add graceful shutdown.
- [x] Write integration test against compose Redis.

## Verification

- Command: `pnpm --filter @dcard/worker test`
- Evidence:

```
$ pnpm --filter @dcard/worker test
  ✓ logs worker:ready once connected
  ✓ completes a system ping job within 5 seconds
  Tests 2 passed (2)
$ node dist/main.js  →  worker:ready ; kill -TERM → worker:stopping (SIGTERM), worker:stopped ; exit=0
```
- Queue names in `packages/core/src/queues/index.ts`; one export line added to `packages/core/src/index.ts` (touches T00-03's file after it was done — noted for review).
