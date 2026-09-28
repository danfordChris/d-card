# Review Report — 2026-09-27 (Phase 07: Hardening and pilot, part 1)

## Summary

- Tasks in this review:
  - T07-02 (load tests), T07-03 (security review) and T07-04 (launch checklist and pilot runbook) meet their acceptance criteria.
  - T07-01 (marketing site) was already done.
  - T07-05 (pilot events and the fix-only period) is still `pending`. It needs friendly hosts, dates, and the launch checklist completed for production.
- Phase status: stays `in-progress` until the pilots run.
- Who did what:
  - Lead: load tests and the fixes they found; security fixes.
  - Subagents: the security review report (read-only) and the launch docs. The lead reviewed both.
- Checks:
  - `pnpm turbo run typecheck lint test build --force`: 27/27 (core 195, web 244, worker 32, db 6, env 7, site 7).
  - Flutter: Flutter analyze clean; tests mobile 67, door 89, core 14, ui 1.
  - `pnpm load:all`: 11/11 checks pass.
  - `pnpm audit --prod`: clean.
  - `validate_workflow.py` → `WORKFLOW:ok`.

## Standards

- **Load test found three real problems, all fixed:**
  - Over-use was missed when two offline gates uploaded the same card at once. Fixed with sorted row locks in `doorSyncUpload`, plus a regression test.
  - Each dispatch run moved only 100 messages, so 1,000 messages took about 2.5 minutes. It now drains up to 2,000 per run.
  - Sends had no rate caps. WhatsApp now defaults to 60/s and SMS to 20/s, shared through Redis; the limiter windows are a quarter-second, so any one second holds at most 1.25× the cap. Meta's throughput errors (HTTP 400, code 130429 and similar) are now retried.
- **Security review:**
  - 0 critical, 0 high.
  - All 6 medium findings fixed with tests: open redirect, disabled-account page access, door revocation bypass, security headers, CSV formulas, and the admin page 2FA check.
  - Lows fixed where cheap: OAuth callback bound to the session, Snippe dedupe made transactional, media content-type allow-list, secret checks, GCM tag length, device takeover, Android backups, atomic rate limit, scrubber, and `uuid` override. The rest are accepted, with a reason for each in the report.
- **Environment note:** after OrbStack hung, its VM clock drifted about 30 minutes behind the Mac and caused false test failures. It resynced on its own later. The door revocation time now uses the database clock, so it is never compared against the app's clock.

## Spec

- **SEC-03 (AUTH-9 made concrete):** after a revocation, that staff member cannot register another device for the event until the host removes and re-adds them. The host is never blocked.
- **First live payment:** the first pilot's plan checkout. There is no Tsh 500 test, because D-Card cannot price an event below the Tsh 50,000 minimum. The phase 05 docs are aligned with this.
- **Send caps** are configurable (`WHATSAPP_MAX_PER_SECOND`, `SMS_MAX_PER_SECOND`). Meta's daily messaging limit tier must be checked before each pilot.

## Verification

- Commands:
  - `pnpm turbo run typecheck lint test build --force`
  - `dart run melos run analyze`
  - `dart run melos run test`
  - `pnpm load:all`
  - `pnpm audit --prod`
  - `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`
- Evidence:
  - `docs/load-tests.md`
  - `docs/security/2026-09-security-review.md`
  - `docs/launch/`
  - The Verification sections of `docs/implementation/tasks/t07-0[2-4]*.md`.

## Follow-ups

- **T07-05:** run 2–3 pilots with the runbook, and fix what they surface.
- **Backlog:** script-src CSP with nonces, per-purpose keys, a guest report limit (SEC-17), storing the rate category on the message log, guest deep links, and trimming the card page's i18n payload.
- **Owner:** the launch checklist items, especially Meta business verification and the messaging tier, Firebase providers, Sentry and `ALERT_EMAIL`, store accounts, and the PDPA review.
