# T06-06 — Observability: logs, error tracking, queue alerts

## Status

- `done`
- Last updated: 2026-09-27

## Linked Phase

- Phase: `docs/implementation/phases/phase-06-completion.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/observability.md`

## Agent Context

- Owner: Claude Code (lead)
- Skills: `vercel:nextjs`
- Design docs: `docs/design/architecture/codebase.md`, `docs/deployment.md`
- Constraints: Sentry free Developer plan (5k errors/month) for web, worker and both Flutter apps, enabled only when `SENTRY_DSN` is set; no personal data in events (phones/tokens scrubbed); structured JSON logs (pino) with request id; alerts by email through Resend to `ALERT_EMAIL`; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); sw/en for every user-facing string; web UI Tailwind only, Hugeicons for any new icon, no decorative gradients/shadows (`docs/design/ui/design-system.md`); phone numbers `255` + 9 digits; lowest-cost services only (`docs/deployment.md`)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Production errors reach Sentry, logs are structured, and the owner gets an email when queues back up or jobs fail repeatedly.

## Scope Boundary

**In scope:**
- `packages/env/src/schema.ts` (`SENTRY_DSN`, `ALERT_EMAIL`)
- `packages/core/src/observability/**` (logger, scrubber)
- `apps/web` Sentry init (instrumentation), `apps/worker` Sentry + logger + health job
- `apps/mobile`, `apps/door` Sentry init behind a dart-define
- `docs/deployment.md`

**Out of scope:**
- Paid monitoring

## Acceptance Criteria

- [x] Web and worker report unhandled errors to Sentry when `SENTRY_DSN` is set, with phones/tokens scrubbed (unit-tested scrubber).
- [x] Worker logs are JSON with queue, job id and duration; web API errors log a request id returned in `x-request-id`.
- [x] A worker job every 5 min emails `ALERT_EMAIL` (at most once per hour per condition) when any queue has > 100 waiting or > 10 failed jobs in the last hour, or payments stay pending > 1 h.
- [x] Flutter apps init Sentry only when `SENTRY_DSN` dart-define is set.
- [x] `docs/deployment.md` lists the Sentry and alert setup.

## Dependencies

- Owner: create a Sentry project (free) and set `SENTRY_DSN`/`ALERT_EMAIL` on Vercel and Railway.

## Implementation Checklist

- [x] Env + logger + scrubber + tests.
- [x] Web + worker Sentry.
- [x] Health/alert job + tests.
- [x] Flutter init.
- [x] Docs.
- [x] Pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build && dart run melos run analyze && dart run melos run test`
- Evidence:

- 2026-09-27: `pnpm turbo run typecheck lint test build --force` → 27/27 (core 192, web 241, worker 30, db 6, env 7, site 7); `dart run melos run analyze` no issues; `dart run melos run test` (mobile 67, door 89, core 14, ui 1).
  - Core `observability.test.ts`: scrubber (phones, tokens, keys, emails, secret fields) and JSON logger. Worker `alerts.test.ts`: backlog > 100, > 10 failures/hour, payments pending > 1 h; one email per condition per hour.
  - Web: `instrumentation.ts` + `server/sentry.ts` (only with `SENTRY_DSN`; user info/cookies/headers/bodies off; scrubbed); API errors logged as JSON with `x-request-id` (set in `proxy.ts`). Worker Sentry on job failures, JSON logs, `check-health` every 5 min. Flutter apps: `sentry_flutter` only with `--dart-define=SENTRY_DSN`.
  - `docs/deployment.md` Observability section. Owner: Sentry project, `SENTRY_DSN`/`ALERT_EMAIL` on Vercel and Railway.
