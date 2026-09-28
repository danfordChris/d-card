# Review Report — 2026-09-27 (Phase 06: Completion)

## Summary

- Reviewed T06-01 to T06-09. All nine meet their acceptance criteria, with recorded evidence.
- Two criteria were narrowed to what was built. The follow-ups are in the backlog:
  - T06-02: cards are linked by pasting; opening a card link in the app is not set up yet.
  - T06-05: uncosted messages are counted, not re-costed.
- Phase stays `in-progress`. Its acceptance ("feature-complete MVP on staging") needs a deploy with migrations 0013–0017, plus owner setup:
  - Firebase Google/Apple providers;
  - Sentry DSN and `ALERT_EMAIL`;
  - store accounts and signing keys;
  - the privacy notice's legal wording and contact (O3).
- Work split:
  - Lead: retention/privacy core, guest linking API, admin 2FA and admin APIs, cost report, observability.
  - Subagents: privacy pages, mobile guest mode, admin screens (T06-03/05 UI), host audit and exports (T06-04), card page performance and accessibility (T06-07), door app states (T06-08), store listings and release builds (T06-09).
  - The lead reviewed each agent's output and fixed three things: a duplicate CSV helper was merged into `exports/csv.ts`, an order-dependent audit test was fixed, and unused imports were removed.
- Checks:
  - `pnpm turbo run typecheck lint test build --force`: 27/27 tasks (core 192, web 241, worker 30, db 6, env 7, site 7).
  - `dart run melos run analyze`: no issues.
  - `dart run melos run test`: mobile 67, door 89, core 14, ui 1.
  - `validate_workflow.py` → `WORKFLOW:ok`.

## Standards

- **Retention and audit rules:**
  - The audit log stays append-only. The only exceptions are retention masking and clearing card tokens, and both need a transaction-local flag (`dcard.audit_mask`, `dcard.retention`) that the database triggers check.
  - Deleted accounts remain as tombstones, because the audit trail points at them.
- **Admin 2FA:**
  - App-level TOTP (RFC 6238, tested against the RFC vectors), with no code reuse and single-use hashed recovery codes.
  - Lockout after 5 wrong codes.
  - Proof is an HMAC cookie bound to the user (HttpOnly, SameSite=Strict, 12 h), and every admin API route checks it.
- **No personal data in error tracking or logs:**
  - Sentry's user info, cookie, header and body collection is off.
  - Events and log lines pass through one scrubber (phones, tokens, keys, emails).
- **CSV exports:** UTF-8 with BOM, formula injection guarded, every download audited.
- **Cost:** the Sentry free plan, alerts through the existing Resend setup, no new paid services.

## Spec

- **AUTH-7 recorded in `docs/design/features/auth.md`:** app-level TOTP instead of Firebase TOTP MFA, which needs the paid Identity Platform upgrade.
- **W13 retention** runs daily at 03:00 EAT. For events that ended ≥ 14 days ago (or started ≥ 14 days + 12 h ago when there is no end time):
  - guests without an account are anonymised;
  - the host's snapshot is kept;
  - registered guests keep their link.
- **Delete my account** is refused while the user still hosts events.
- **Door check-in:**
  - The server refuses revoked devices with 403 (not 423). The app treats any 403 from a door call as revoked.
  - "Not started / ended" are warnings, not blocks.

## Verification

- Commands:
  - `pnpm turbo run typecheck lint test build --force`
  - `dart run melos run analyze`
  - `dart run melos run test`
  - `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`
- Evidence: the Verification sections of `docs/implementation/tasks/t06-*.md`.

## Follow-ups

- Owner:
  - Enable the Google and Apple providers in Firebase, add the Android SHA fingerprints, and set up the iOS URL scheme and the Sign in with Apple capability.
  - Create a Sentry project and set `SENTRY_DSN` and `ALERT_EMAIL` on Vercel and Railway.
  - Legal review of the privacy notice, and confirm the contact address (O3).
  - Store accounts, upload keystore, app icons and APNs key (`docs/store-listings.md`).
- Deploy migrations 0013–0017 to production (they run on deploy when the PRs are merged).
- Backlog:
  - Store the rate category on `message_log`, so the cost report can re-cost older messages.
  - Guest deep links, so a card link opens in the app.
  - Load only the needed message namespaces on the card page.
- App Review risks from `docs/store-listings.md`:
  - Apple may require In-App Purchase for in-app mobile-money checkout; the fallback is paying on the web.
  - The door app needs a way for staff to delete their account.
