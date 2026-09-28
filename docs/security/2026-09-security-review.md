# D-Card security review — September 2026 (T07-03)

- Date: 2026-09-27
- Branch reviewed: `feat/phase-07-hardening-pilot` (after `b97f14b`)
- Type: read-only code review (no code changed). Evidence is `path:line` at the reviewed commit.
- Scope: `apps/web` (Next.js 16 web + API, `src/proxy.ts`), `packages/core`, `packages/db`, `packages/api-contract`, `apps/worker`, `apps/door`, `apps/mobile`.
- Out of scope: third-party penetration test, provider consoles (Firebase, Meta, Snippe, Google Cloud, Vercel, Railway) configuration.
- Findings marked **needs confirmation** are plausible from the code but depend on framework or provider behaviour that was not exercised live.

## Summary

| Severity | Count | IDs |
| --- | --- | --- |
| Critical | 0 | — |
| High | 0 | — |
| Medium | 6 | SEC-01, SEC-02, SEC-03, SEC-04, SEC-05, SEC-06 |
| Low | 11 | SEC-07 … SEC-17 |
| Info | 8 | SEC-18 … SEC-25 |

No IDOR was found: every `/api/v1` route authenticates, and every event-scoped core function calls `requireEventRole` (or `requireDoorDevice`, which calls it) and scopes sub-resource ids (guest, pledge, payment, media item, walk-in, invite, import job, checkout attempt, door device) by `event_id`. Webhook signatures, token entropy and hashing, AES-GCM usage, TOTP and CSV escaping in the main export are sound. The medium findings are hardening gaps: missing HTTP security headers, an open redirect on login, disabled accounts keeping server-rendered page access, device revocation that can be bypassed, CSV formula injection in one export, and admin page data rendered under a layout-only 2FA gate.

---

## 1. Authorization (AUTH-6)

### What was checked

- Gatekeeping: `apps/web/src/proxy.ts:12-47`. Every `/api/*` request needs a valid `X-API-Key` (`server/api-key.ts:36-44`, SHA-256 digests compared with `timingSafeEqual`, keys < 32 chars or `dummy_` ignored) except `/api/webhooks/*` and two keyless patterns: `/api/v1/media/google/(connect|callback)` and `/api/v1/cards/<token>/media/<uuid>/content` (`proxy.ts:12`).
- User auth: `server/current-user.ts:20-26` (`requireUser`: Firebase ID token or session cookie via `server/auth/verifier.ts:131-142`; refuses unprovisioned and disabled accounts). Fake verifiers refuse to run with `NODE_ENV=production` (`verifier.ts:54-56`, `80-82`).
- Event roles: `packages/core/src/auth/roles.ts:13-44` (host, or a listed role for that event; 404 if the event does not exist, 403 otherwise).
- Admin: `server/admin-auth.ts:25-36` (`requireAdminAccount` = admin flag; `requireAdminUser` = flag + 12 h signed 2FA proof cookie) plus `requireAdmin` in core (`admin/event-types/event-types.ts:14-17`).
- Every route file under `apps/web/src/app/api/v1` (101 files) was listed with its auth call, and every core function that takes a user id was checked for its role call and for `event_id` scoping of child ids.

### Route matrix

| Route(s) | Auth | Authorization (core) | Child-id scoping |
| --- | --- | --- | --- |
| `events` GET/POST | requireUser | list: own + role events; create: caller becomes host | — |
| `events/[id]` GET/PATCH, `cancel` | requireUser | getEvent ALL_ROLES; update/cancel host (`events.ts:231,286,324`) | — |
| `events/[id]/audit` | requireUser | EVENT_AUDIT_ROLES (`event-audit.ts:43`) | — |
| `events/[id]/billing`, `billing/quote`, `checkout`, `checkout/[attemptId]` | requireUser (+ rate limit on checkout) | host (`billing.ts:145,174,232,299`) | attempt by id **and** event (`billing.ts:300`) |
| `checkout/[attemptId]/simulate` | requireUser | 404 in production or with real gateway (`simulate/route.ts:20`) | via getCheckout |
| `guests`, `guests/bulk`, `guests/[guestId]` | requireUser | MANAGE/READ (`guests.ts:158-301`) | `loadPending` id+event (`guests.ts:252-256`) |
| `guests/[guestId]/issue|cancel|reinstate|card` | requireUser | host; card link: committee (`cards.ts:101-161`) | `lockInvitation` id+event (`cards.ts:40-48`) |
| `imports`, `imports/copy`, `imports/[jobId]/confirm` | requireUser | committee; copy source must be caller's own event (`import.ts:196-200`) | job id+event (`import.ts:226`) |
| `contributions`, `contributions/export`, `pledges/[pledgeId]`, `pledges/[pledgeId]/payments`, `payments/[paymentId]` | requireUser | ADD/PAY/READ (`contributions.ts:198-434`) | pledge/payment id+event (`contributions.ts:107,186,302`) |
| `confirmations`, `confirmations/[guestId]` | requireUser | MANAGE (`confirmations.ts:69,93`) | id+event (`confirmations.ts:97,104`) |
| `dashboard`, `dashboard/stream` | requireUser | committee, checked before the stream starts (`stream/route.ts:29-33`) | — |
| `door-devices`, `door-devices/[deviceId]` | requireUser | list committee, revoke host (`door.ts:132,143`) | device id+event (`door.ts:148`) |
| `exports/[kind]` | requireUser | EXPORT_ROLES per kind (`exports.ts:68`) | — |
| `media`, `media/settings`, `media/upload-sessions`, `media/[itemId]`, `…/complete`, `…/content` | requireUser | host / committee (`media.ts:145-546`) | `hostItem` id+event (`media.ts:363-367`) |
| `messages`, `messages/log`, `messages/send`, `messages/[type]/test` | requireUser (+ rate limit on test) | host / committee (`manual.ts:42,106`, `settings.ts:80,170,207`) | — |
| `team`, `team/invites`, `team/invites/[inviteId]`, `team/members/[userId]` | requireUser | host (`team.ts:72-190`) | invite id+event (`team.ts:182`), role row event+user (`team.ts:194`) |
| `walk-ins`, `walk-ins/[walkInId]/decision` | requireUser | host / committee / walk-in approver (`walk-ins.ts:154-169`) | update by id **and** event (`walk-ins.ts:176`) |
| `door/devices` | requireUser | DOOR_ROLES on the named event (`door.ts:108`) | device belongs to that event (`door.ts:111`) |
| `door/lookup`, `door/entries`, `door/sync`, `door/walk-ins`, `door/walk-ins/[walkInId]` | requireUser | `requireDoorDevice`: device exists, not revoked, caller has DOOR_ROLES on the device's event (`door.ts:155-162`) | invitation id+device event (`door.ts:242,321`; `sync.ts:131`; `walk-ins.ts:125,150`) |
| `door/events` | requireUser | only caller's host/door-role events (`door.ts:70-95`) | — |
| `me` GET/POST/DELETE, `me/export`, `me/devices`, `me/devices/[token]`, `me/cards`, `me/cards/link` | Firebase token / requireUser | own rows only (`devices.ts:60-66`, `account-link.ts:30-57`) | — |
| `invites/[token]` GET, `invites/[token]/accept` | API key / requireUser | 256-bit token, single use (`team.ts:106-153`) | — |
| `cards/[token]/*` (card, rsvp, calendar.ics, image, media, upload-sessions, complete, report, delete, content) | card link token (256-bit), rate limits on rsvp/uploads | `cardContext` issued cards only (`media.ts:419-425`); delete only own uploads (`media.ts:505-507`) | item id+event (`media.ts:493`) |
| `media/google/connect` (keyless) | session cookie | host (`connect/route.ts:13-16`) | — |
| `media/google/callback` (keyless) | signed state | host re-checked for state's user (`media.ts:202`) | — |
| `media/google` DELETE | requireUser | own connections (`media.ts:229-233`) | — |
| `admin/2fa/*` | requireAdminAccount | `requireAdminRow` (`totp.ts:81-84`) | — |
| all other `admin/*` | requireAdminUser (flag + 2FA proof) | `requireAdmin` in core | target user ≠ self (`platform.ts:68-74`) |
| `event-types`, `plans`, `health` | API key only | public catalogue / liveness | — |
| `webhooks/whatsapp`, `webhooks/snippe`, `webhooks/nextsms` | signature / verify token (section 3) | — | — |

Result: no route trusts an id without checking ownership. Related findings: SEC-02 (server-rendered pages skip the disabled check), SEC-03 (device revocation), SEC-06 (admin pages behind a layout-only 2FA gate), SEC-14 (invite email not enforced).

## 2. Tokens and encryption

- Generation: `packages/core/src/tokens.ts:6-8` — `randomBytes(32)` base64url (256 bits) for card QR/link tokens and team invites (`cards.ts:69-70`, `team.ts:85`).
- Hashing: `tokens.ts:10-15` — HMAC-SHA256 with `TOKEN_HASH_SECRET` (throws if < 32 chars). Lookups use the hash (`media.ts:421`, `account-link.ts:41`, `door.ts:245`, `team.ts:109`); equality happens in SQL on the HMAC, so no timing leak on the raw token.
- Card-link format check before any DB call (`media.ts:420`, `account-link.ts:37`, proxy `[A-Za-z0-9_-]{20,100}`).
- AES-256-GCM (`crypto/secrets.ts:12-25`): 96-bit random IV per encryption (no reuse), auth tag stored and set before `final()`, 32-byte key enforced. Tag length is not checked on decrypt (SEC-19).
- Constant-time compares: API keys (`api-key.ts:41`), Meta and NextSMS (`webhook-auth.ts:3-7`), Snippe (`gateway.ts:196-197`), OAuth state (`store.ts:228`), admin proof (`totp.ts:259`), TOTP (`totp.ts:78`), confirmation token (`confirm-token.ts:24`). WhatsApp GET verify token uses `===` (SEC-22).
- Card number: `NNN-PPPP` with a random 4-digit pin (`cards.ts:71`); card-number lookup at the door locks the staff account after 3 misses for 5 minutes (`door.ts:232,253-283`).
- Exposure: plaintext link token is returned only to host/committee (`cards.ts:155-166`) and to the linked guest (`account-link.ts` `listMyCards`); the QR token only on the public card view for the card holder (`public.ts:66`). The door cache receives `sha256(qrToken)` digests, never tokens (`sync.ts:22,89`). Sentry scrubs `/c/`, `/cards/`, `/confirm/` tokens, bearer tokens, phones, emails and Snippe keys (`observability/scrub.ts:4-9`, `server/sentry.ts:15-18`, `sendDefaultPii = false` in both Flutter apps). `/invite/<token>` paths are not in the scrub list (SEC-24). Card pages set `referrer: no-referrer` and the card API sets `referrer-policy: no-referrer` (`c/[token]/page.tsx:15`, `cards/[token]/route.ts:13`).
- Confirmation quick-reply token: invitation id + 64-bit HMAC (`confirm-token.ts:6-25`). It is only accepted inside a signature-verified Meta webhook, so the truncation is acceptable.

## 3. Webhooks

| Provider | Verification | Raw body | Replay | Dedupe | Evidence |
| --- | --- | --- | --- | --- | --- |
| Meta WhatsApp | `X-Hub-Signature-256` HMAC-SHA256(app secret) over the raw text, constant time; `dummy_` secret refused | yes (`request.text()` before `JSON.parse`) | no timestamp from Meta; handlers idempotent | status updates idempotent | `webhooks/whatsapp/route.ts:19-38`, `webhook-auth.ts:10-14` |
| Snippe | HMAC-SHA256 over `{timestamp}.{raw body}`, constant time | yes | ±300 s window | `webhook_event` insert on event id | `webhooks/snippe/route.ts:11-31`, `gateway.ts:185-198`, `billing.ts:383-395` |
| NextSMS | shared verify token (query, header or bearer), constant time | n/a | none | idempotent updates | `webhooks/nextsms/route.ts:8-19`, `webhook-auth.ts:20-26` |

Payment completion is a conditional `pending → completed` update and `host_payment.attempt_id` is unique, so cards unlock once (`billing.ts:311-381`). Findings: SEC-09 (dedupe row written before processing), SEC-12 (Snippe compare throws on non-hex input), SEC-18 (amount/currency not cross-checked), SEC-22 (NextSMS token in query string; WhatsApp verify token `===`).

## 4. Google OAuth and media proxy

- Scope: `drive.file openid email` only (`store.ts:215`); exchange refuses a grant without `drive.file` (`store.ts:268`).
- State: HMAC-SHA256 signed `{userId, eventId, exp (15 min), nonce}`, constant-time verify, expiry checked (`store.ts:218-235`). The callback re-checks the host role for the state's user (`media.ts:202`). The state is not bound to the browser session and the nonce is not stored (SEC-13). The secret falls back to `""` when `TOKEN_HASH_SECRET` is unset (SEC-11).
- Redirect URI from `GOOGLE_OAUTH_REDIRECT_URI` (server env), not from the request (`connect/route.ts:18`, `server/media.ts:17-21`). Post-callback redirects go to `APP_URL` origin plus the state's event id (a validated UUID when signed) (`callback/route.ts:11-21`).
- Refresh token: AES-GCM encrypted at rest (`media.ts:209`), decrypted only for Drive calls (`media.ts:79-83`).
- Upload completion accepts only a Drive file whose parent is this event's folder (`media.ts:353-354`); `drive_file_id` is unique (`packages/db/src/schema.ts:909`).
- Media proxy: host content needs committee (`media.ts:545-550`); guest content needs an issued card link, visible non-card items, gallery page open (`media.ts:552-557`). Headers forwarded from Drive: content-type, length, range (`media.ts:535-541`) — see SEC-10.
- Google Photos album link restricted to `https://photos.app.goo.gl/` or `https://photos.google.com/` and never fetched server-side (`media.ts:246-251`).

## 5. Door app (AUTH-9, offline cache)

- Cache: SQLCipher (`sqflite_sqlcipher`) with a random 256-bit key from `Random.secure()` kept in `flutter_secure_storage` (Keychain/Keystore) (`apps/door/lib/data/services/door_cache_store.dart:20-35,81-96`). A database without its key is deleted and recreated.
- Wipe: deletes the database file and the key (`door_cache_store.dart:99-109`); triggered after `wipeAfter` = event end + 24 h (`sync.ts:100`, `door_sync_repository.dart:96-124`), on 403 revoke after one last upload try (`door_sync_repository.dart:200-225`) and on sign-out (`door_sync_repository.dart:251-260`).
- Cached data: guest names, card numbers, entry counts and QR digests (not tokens) (`sync.ts:81-101`).
- Device binding: device id is client-generated and stored in `shared_preferences` (`door_device_store.dart:24`); each door call re-checks the device is not revoked and that the caller still holds a door role (`door.ts:155-162`). Revocation can be bypassed by registering a new device id (SEC-03). A second staff user of the same event can take over an existing device id (`door.ts:113-117`, SEC-20).
- Android auto-backup is not disabled in either app manifest (SEC-21).

## 6. Admin 2FA, admin routes, accounts, cookies

- TOTP (RFC 6238, SHA-1, 6 digits, 30 s, ±1 step) with replay protection (`step > lastUsedStep`), 5 failures → 15 min lock, 10 one-time recovery codes stored as HMACs, secret AES-GCM encrypted (`admin/totp.ts:12-199`). Enrolment refused while a factor is confirmed (`totp.ts:95`); disable needs a valid code (`totp.ts:182-188`). Failures are committed even though the call throws (`totp.ts:145-162`).
- Proof cookie `dcard_admin_2fa`: HMAC over `admin2fa.<userId>.<exp>`, 12 h, `HttpOnly; SameSite=Strict; Secure` in production (`admin-auth.ts:43-48`, `totp.ts:245-260`); empty secret refused (`totp.ts:253`). Proofs are not revoked when 2FA is disabled (SEC-15).
- Admin API: all non-2FA admin routes use `requireAdminUser`; account actions refuse self-targeting (`platform.ts:68-74`); revoking admin deletes the TOTP row (`platform.ts:81`). Admin pages: see SEC-06.
- Disable: sets `disabled_at` only (`platform.ts:86-91`); the API refuses disabled accounts (`current-user.ts:24`) but server-rendered pages do not (SEC-02).
- Delete my account: tombstones the account then deletes the Firebase user (`me/route.ts:34-47`); Firebase session cookies are verified with `checkRevoked = true` (`verifier.ts:114`), so the web session ends.
- Session cookie `dcard_session`: Firebase session cookie, `HttpOnly; SameSite=Lax; Secure` (production), 5 days (`session/route.ts:10-20`, `verifier.ts:93`). Logout clears the cookie but does not revoke the Firebase session (SEC-16).
- CSRF: every state-changing API call needs the custom `X-API-Key` header and no CORS headers are emitted, so cross-site requests cannot send it (preflight fails). The two keyless routes are GET-only and either redirect to Google (connect) or need a signed state (callback). No server actions exist.

## 7. Rate limiting

`apps/web/src/server/rate-limit.ts:14-26`: Redis fixed window, fails open.

| Surface | Limit | Evidence |
| --- | --- | --- |
| RSVP | 20/h per card token | `cards/[token]/rsvp/route.ts:14` |
| Guest upload sessions | 60/h per card token + per-guest plan cap | `cards/[token]/media/upload-sessions/route.ts:15`, `media.ts:487` |
| Checkout | 10/h per user | `events/[id]/checkout/route.ts:19` |
| Test message | 5/h per user per event | `messages/[type]/test/route.ts:20` |
| Door card-number lookup | 3 misses → 5 min lock per staff user (Redis) | `door.ts:253-283`, `server/door.ts:26-61` |
| Admin 2FA | 5 misses → 15 min lock (DB) | `totp.ts:14-16,137-140` |
| Sign-in / sign-up / password reset | Firebase Auth (client SDK) | provider-side |
| `/api/v1/session`, `/api/v1/me` POST, `me/cards/link`, `invites/[token]`, `cards/[token]` GET, media report, media content | none | tokens are 256-bit, so enumeration is not practical; see SEC-17 (report) and SEC-25 (content bandwidth) |

The `INCR` then `EXPIRE` pair is not atomic (`rate-limit.ts:19-20`): if the process dies between them the key never expires and the limit becomes permanent for that key (SEC-23).

## 8. Input validation, injection, SSRF, XSS, CSV, redirects

- Validation: every JSON body goes through `parseBody` + zod (`server/http.ts:76-91`); path ids are UUID-checked before the DB (`server/ids.ts`, route-level `UUID.test`). Door sync arrays are bounded (`api-contract/src/checkin.ts:239-241`). Import upload is capped at 2 MB (after `formData()` is parsed) (`imports/route.ts:9-22`).
- SQL: all queries use Drizzle builders or `sql` templates with bound parameters. The only `sql.raw` is a constant string in the admin cost report (`admin/cost-report.ts:71,80-84`), with no user input. `LIKE` patterns escape `%`, `_` and `\` (`platform.ts:19`, `door.ts:287`).
- SSRF: server-side fetches go only to fixed hosts (Google OAuth/Drive, Snippe base URL from env, NextSMS, Meta Graph, Resend, and the worker to `APP_URL`) (`store.ts:59-72`, `gateway.ts:62`, `worker/src/messaging/senders.ts`, `card-image.ts:10`). The Drive thumbnail URL comes from Google's API response (`store.ts:147-152`). User-supplied URLs (venue map, Google Photos album) are never fetched.
- XSS: the one `dangerouslySetInnerHTML` renders a QR SVG generated by the `qrcode` package from the server-issued token (`c/[token]/page.tsx:145`). User text renders as React text. `venueMapUrl` is `z.url()`, which accepts `javascript:` and `data:` (checked: zod 4.6.5); React 19.3 replaces `javascript:` hrefs on server and client render, so it is not exploitable on the web page; the mobile app opens any parsed URI (SEC-08).
- CSV injection: `core/exports/csv.ts:7-16` prefixes `= + - @ \t \r` cells; used by event exports and the admin audit export. The contributions CSV uses `Papa.unparse` without `escapeFormulae` (SEC-05).
- Open redirect: `next` on login/sign-up only checks `startsWith("/")` (SEC-01). `proxy.ts:41-43` sets `next` to the request path (safe).
- ICS: text escaped (`\`, `;`, `,`, newlines) (`cards/public.ts:125`).

## 9. HTTP headers, CORS, CSP

- `apps/web/next.config.ts:28-33` defines no `headers()`; `apps/web/vercel.ts` defines none; `proxy.ts` only adds `x-request-id`. No CSP, HSTS, `X-Frame-Options`/`frame-ancestors`, `X-Content-Type-Options`, `Referrer-Policy` (except on card pages), or `Permissions-Policy` (SEC-04). Vercel adds HSTS on `*.vercel.app` but not necessarily on a custom domain (needs confirmation in the Vercel project).
- CORS: no `Access-Control-*` headers anywhere (correct: the API is same-origin for the web app; the Flutter apps are not browsers).
- `x-request-id` from the client is reflected (truncated to 64 chars) (`proxy.ts:16-18`); logs are JSON, so this is not a log-injection risk.
- API keys: the web key is `NEXT_PUBLIC_DCARD_API_KEY` (`lib/api-fetch.ts:4`), and the app keys ship in binaries, so API keys identify clients but are not secrets (by design; see `api-key.ts:3-5`). Nothing relies on them for authorization.

## 10. Secrets

- `.gitignore` excludes `.env` and `.env.*` (keeps `.env.example`) and `http/http-client.private.env.json`. No `.env`, service-account JSON, keystore, `google-services.json` or `GoogleService-Info.plist` is tracked.
- Git history scan (`git log -p --all`, added lines only; values not printed):
  - `snp_…` Snippe keys: none.
  - `re_…` Resend-shaped strings: 3 matches, all false positives (test database names and a Dart lint comment).
  - `AIza…`: 1 match — the Firebase **web** API key in `http/http-client.env.json` (a public identifier by Firebase design; see SEC-24).
  - `BEGIN PRIVATE KEY`: 3 matches, all `dummy_` placeholders (`.env.example`, `apps/worker/test/push.test.ts`) or a validation regex (`packages/env/src/schema.ts`).
  - `API_KEYS`, `TOKEN_HASH_SECRET`, `DATA_ENCRYPTION_KEY`, `SNIPPE_WEBHOOK_SECRET`, `WHATSAPP_APP_SECRET` assignments: only placeholders in `.env.example`.
  - Postgres URLs: only `localhost` development credentials.
- Env schema requires the secrets with format checks (`packages/env/src/schema.ts:51-52,87,122-125`), but the web app does not validate them at boot (SEC-11).
- One secret (`TOKEN_HASH_SECRET`) is reused for token hashing, confirmation tokens, OAuth state and admin proofs (SEC-19).

## 11. Dependencies

- `pnpm audit --prod` (2026-09-27): **1 moderate**, 0 high/critical — `uuid < 11.1.1` (GHSA-w5hq-g745-h8pq, missing buffer bounds check in v3/v5/v6 when `buf` is passed) via `apps/web > firebase-admin > @google-cloud/storage > gaxios > uuid`. D-Card does not call `uuid` with a buffer, and Cloud Storage is unused, so it is not reachable. Fix: pnpm `overrides` to `uuid@^11.1.1` or wait for `firebase-admin`.
- Parsers on untrusted files: `papaparse` and `read-excel-file` for guest imports (`guests/import.ts:3-4`) — no known advisories reported by the audit; SheetJS (`xlsx`) is not used.
- `flutter pub outdated` (door): `sentry_flutter` 8.14.2 vs 9.30.1 (major behind); otherwise minor/transitive lag. No known security advisories for the direct packages (`sqflite_sqlcipher`, `flutter_secure_storage`, `mobile_scanner`, `firebase_*`, `http`). The mobile app was not run through `pub outdated` in this review.

## 12. OWASP ASVS 4.0.3 Level 1 quick checklist

| Area | Status | Notes |
| --- | --- | --- |
| V1 Architecture | Pass | Auth in one place per layer (`requireUser`, `requireEventRole`, `requireAdminUser`) |
| V2 Authentication | Pass (provider) | Firebase Auth handles passwords, reset, lockout; admin 2FA TOTP |
| V3 Session management | Partial | Cookie flags good; logout does not revoke (SEC-16); disabled accounts keep SSR access (SEC-02) |
| V4 Access control | Pass with notes | No IDOR; SEC-03, SEC-06, SEC-14 |
| V5 Validation, sanitisation, encoding | Partial | zod everywhere; SEC-01, SEC-05, SEC-08 |
| V6 Cryptography | Pass | AES-256-GCM random IV, HMAC-SHA256, 256-bit tokens; SEC-19 hardening |
| V7 Errors and logging | Pass | Generic 500s, request ids, scrubbed Sentry; audit log for sensitive actions |
| V8 Data protection | Pass with notes | Tokens hashed, secrets encrypted, door cache encrypted and wiped; SEC-21 |
| V9 Communications | Partial | HTTPS by platform; no HSTS header on custom domain (SEC-04, needs confirmation) |
| V10 Malicious code | Pass | No eval, no dynamic code, no untrusted downloads |
| V11 Business logic | Pass with notes | Payment gate, plan limits, idempotent webhooks; SEC-07, SEC-09, SEC-17 |
| V12 Files and resources | Partial | Type/size allowlists, Drive folder check; SEC-10 |
| V13 API | Pass | API key + user auth, no CORS, JSON only |
| V14 Configuration | Partial | Missing security headers (SEC-04); env not validated at boot (SEC-11); 1 moderate dependency advisory |

---

## Findings

| ID | Severity | Title | Evidence | Impact | Recommended fix | Status |
| --- | --- | --- | --- | --- | --- |
| SEC-01 | Medium | Open redirect after login/sign-up via `next` | `apps/web/src/features/auth/login-form.tsx:15,30`; `features/auth/signup-form.tsx:15,45` | `next.startsWith("/")` accepts `//evil.example` and `/\evil.example`; after a real sign-in the host is sent to an attacker page (credential phishing: "session expired, sign in again"). **Needs confirmation** in a browser that `router.replace("//host")` leaves the origin (Next treats it as external). | Accept only paths matching `^/(?![/\\])`, or resolve with `new URL(next, location.origin)` and require the same origin; share one helper for login and sign-up; add a unit test. | **Fixed**: `features/auth/safe-next.ts` (same-origin check) for login and sign-up; `apps/web/test/security.test.ts`. |
| SEC-02 | Medium | Disabled accounts keep server-rendered page access | `apps/web/src/server/session.ts:8-17`; `server/events-page-data.ts:8-12,32`; `packages/core/src/admin/platform.ts:86-91` | `getSessionAccount`/`requireAccount` do not check `disabled_at`, and disabling does not revoke Firebase sessions. A disabled user keeps reading event pages (guests, contributions) rendered from core for up to the 5-day cookie life. | Return null (or redirect) in `getSessionAccount` when `disabledAt` or `deletedAt` is set; on disable also call Firebase `revokeRefreshTokens(uid)` (and `updateUser({disabled:true})`). Test: disabled account gets redirected from `/events/[id]`. | **Fixed**: `getSessionAccount` returns null for disabled/deleted accounts; disabling revokes Firebase refresh tokens (session cookies are verified with `checkRevoked`); tested in `admin-platform-api.test.ts`. |
| SEC-03 | Medium | Door device revocation can be bypassed by re-registering | `packages/core/src/checkin/door.ts:103-129,155-162`; `apps/door/lib/data/services/door_device_store.dart:24` | Revocation is per client-generated device id. The same user (or a thief holding a lost phone's Firebase session) can clear app data, get a new id and register again; AUTH-9's "host can revoke a device" does not hold unless the host also removes the role. | On revoke, also block (event, staff user) re-registration until the host re-approves, or require host approval for new devices after a revoke; show this in the revoke dialog. Test: revoked user registering a new device id gets 403. | **Fixed**: after a revocation the staff member cannot register a new device for the event until the host re-adds their role (host never blocked); revocation uses the database clock; `packages/core/test/door-security.test.ts`. |
| SEC-04 | Medium | No HTTP security headers (CSP, frame-ancestors, nosniff, HSTS, Referrer-Policy) | `apps/web/next.config.ts:28-33`; `apps/web/vercel.ts:5-12`; `apps/web/src/proxy.ts:14-20` | Admin and host pages can be framed (clickjacking of admin actions, card cancel, payments); no CSP backstop for any future XSS; token-bearing URLs rely on per-page referrer settings. | Add `headers()` in `next.config.ts`: `Content-Security-Policy` (at least `frame-ancestors 'none'; object-src 'none'; base-uri 'self'`, then script/img/connect allowlists for Firebase and Google), `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin` (keep `no-referrer` on `/c/*`), `Strict-Transport-Security: max-age=63072000; includeSubDomains`, `Permissions-Policy: camera=(), microphone=(), geolocation=()`. Test with a header snapshot. | **Fixed (baseline)**: `next.config.ts` sends frame-ancestors/base-uri/object-src/form-action CSP, X-Frame-Options, nosniff, Referrer-Policy, Permissions-Policy, HSTS; tested. **Follow-up:** script-src CSP with nonces (backlog). |
| SEC-05 | Medium | CSV formula injection in the contributions export | `apps/web/src/app/api/v1/events/[id]/contributions/export/route.ts:55`; names only trimmed in `packages/core/src/guests/guests.ts:59-64` | Guest and partner names (entered by committee or imported from a file) starting with `=`, `+`, `-`, `@` become formulas when the host opens the CSV in Excel/Sheets (data exfiltration via `HYPERLINK`/`WEBSERVICE`, DDE prompts). | Build this CSV with `toCsv` from `core/exports/csv.ts` (already guarded) or pass `escapeFormulae: true` to `Papa.unparse`; add a test with `=HYPERLINK(...)`. | **Fixed**: `Papa.unparse(..., { escapeFormulae: true })`; other exports already guarded (`exports/csv.ts`). |
| SEC-06 | Medium | Admin pages rely on a layout-only 2FA gate while pages fetch admin data themselves (**needs confirmation**) | `apps/web/src/app/(app)/admin/layout.tsx:13-16`; `admin/provider-rates/page.tsx:9-11`; `admin/event-types/page.tsx:9-11`; `admin/whatsapp-templates/page.tsx:9-12`; core `requireAdmin` checks only the flag (`admin/event-types/event-types.ts:14-17`) | Next.js renders layouts and pages in parallel; hiding `children` in the layout may not stop the page's server component from running and its data reaching the RSC payload. An admin account without a verified second factor (e.g. a stolen session) could read provider rates, templates and event types. Low data sensitivity, but it defeats AUTH-7 for these pages. | Check the proof in each admin page (or a shared `requireAdminPage()` that reads the cookie and calls `hasAdminProof`) before calling core; test that an admin without the cookie gets no data in the page payload. | **Fixed**: admin pages that load data call `requireVerifiedAdminPage()` (admin, valid 2FA proof, still enrolled). |
| SEC-07 | Low | Test messages bypass the payment gate and can go to any number | `packages/core/src/messaging/settings.ts:200-235` (`toPhone` = person phone ?? event contact phone, line 224); `packages/core/src/messaging/dispatch.ts:17-22`; limit `messages/[type]/test/route.ts:20` | A host without a person phone (Google/Apple sign-up) sends test SMS/WhatsApp to the event contact phone, which they set freely; 5/h per event, and draft events are free to create, so the cap scales with events. SMS cost and nuisance messages to third parties. | Send tests only to a verified host phone, or cap per user per day across events; fail closed if Redis is down for this limiter. | **Accepted**: host-only, to the event's own contact phones; bounded cost, useful before paying. |
| SEC-08 | Low | `venueMapUrl` accepts any scheme | `packages/api-contract/src/events.ts:41`; `apps/web/src/app/c/[token]/page.tsx:134`; `apps/mobile/lib/ui/features/my_cards/views/card_screen.dart:145-146` | `z.url()` accepts `javascript:`/`data:`/`intent:`. React 19.3 neutralises `javascript:` on the web, but the mobile app launches any URI and messages may include the link. | Restrict to `https:` (e.g. `z.url({ protocol: /^https$/ })` or a refine); the mobile app should open only `http(s)` URIs. | **Fixed**: `venueMapUrl` must be http(s) in the contract; the mobile link opener refuses other schemes. |
| SEC-09 | Low | Snippe webhook dedupe row is written before processing | `packages/core/src/billing/billing.ts:386-395` | If `applyPaymentResult` throws, the route answers 500 so Snippe retries, but the retry hits the existing `webhook_event` row and is ignored as a duplicate. The poller (`billing.ts:398-417`) usually recovers, but only for attempts with a provider reference. | Insert the dedupe row inside the same transaction as `applyPaymentResult`, or delete it on failure. Test: first delivery throws, retry completes the payment. | **Fixed**: dedupe row and payment update commit in one transaction. |
| SEC-10 | Low | Media proxy forwards Drive's content type without `nosniff` or a type check | `packages/core/src/media/media.ts:341-361,521-541` | The declared MIME type is allowlisted at session start, but completion does not compare the Drive file's `mimeType`/size with the item, and the proxy serves Drive's `content-type` from the D-Card origin with no `X-Content-Type-Options`. Defence in depth against a crafted upload served as active content. | In `completeItem`, reject files whose `mimeType` differs from the item's; in `streamItem`, set `content-type` from the allowlist, add `X-Content-Type-Options: nosniff`, `Content-Security-Policy: sandbox` and `Content-Disposition: inline`. | **Fixed**: only image/video types served inline, others as `application/octet-stream` attachment, with nosniff. |
| SEC-11 | Low | OAuth state (and admin proof) secret falls back to empty; env not validated at boot | `apps/web/src/server/media.ts:31`; `server/admin-auth.ts:8`; `apps/web/src/instrumentation.ts:4-8` | If `TOKEN_HASH_SECRET` were missing, `verifyOAuthState` would accept states signed with an empty key, letting an attacker connect their own Drive to someone else's event and receive its guest media. Admin proofs already refuse an empty secret (`totp.ts:253`). Misconfiguration only. | Make `oauthStateSecret()` throw unless ≥ 32 chars; validate required env with `@dcard/env` in `instrumentation.ts register()` for production. | **Fixed**: OAuth state and admin proof secrets throw when `TOKEN_HASH_SECRET` is missing or short. |
| SEC-12 | Low | Snippe signature compare throws on non-hex input | `packages/core/src/billing/gateway.ts:195-197` | A signature with the right length but non-hex characters decodes to a shorter buffer and `timingSafeEqual` throws a `RangeError`, turning a rejected webhook into an unhandled 500. No bypass. | Check `/^[0-9a-f]{64}$/` before decoding, or compare the hex strings as UTF-8 buffers. | **Fixed**: non-hex signatures rejected before `timingSafeEqual`; tested in `billing.test.ts`. |
| SEC-13 | Low | OAuth state not bound to the browser session | `packages/core/src/media/store.ts:218-235`; `apps/web/src/app/api/v1/media/google/callback/route.ts:8-21` | A host can send someone their own consent URL; if that person consents, their Google account's Drive is connected to the host's event (D-Card creates folders and stores uploads there; `drive.file` limits access to those files). The state can also be replayed within 15 minutes. | Set a short-lived `HttpOnly` cookie with the state nonce at `/connect` and require it at `/callback`; store used nonces (Redis, 15 min). | **Fixed**: the callback requires the signed-in user (session cookie, SameSite=Lax) to match the state's user; tested in `media-api.test.ts`. |
| SEC-14 | Low | Team invites with an email are not bound to that email | `packages/core/src/team/team.ts:71-104,128-153` | Anyone who gets the link accepts the role, whatever their account email. Acceptable if links are treated as bearer credentials; surprising if the host expects the email to restrict it. | When `invite.email` is set, require the accepting account's verified email to match (or record in design that links are bearer tokens). | **Accepted (design)**: AUTH-8 makes invite links shareable; email is a delivery channel. Hosts see and can remove members. |
| SEC-15 | Low | Admin 2FA proofs survive disabling 2FA | `packages/core/src/admin/totp.ts:182-188,245-260`; `apps/web/src/app/api/v1/admin/2fa/disable/route.ts:14` | Disable clears the cookie only in the current browser; proofs issued to other browsers stay valid up to 12 h. | Include a per-admin 2FA generation (e.g. `confirmedAt` or a counter) in the signed proof and check it; bump it on disable and on admin revoke. | **Fixed**: admin routes and pages also require the second factor to still be enrolled; tested. |
| SEC-16 | Low | Logout does not revoke the Firebase session; no recent-sign-in check when minting session cookies | `apps/web/src/app/api/v1/session/route.ts:22-34`; `server/auth/verifier.ts:102-108` | A copied session cookie stays valid for 5 days after logout. Firebase recommends refusing ID tokens older than ~5 min (`auth_time`) when creating session cookies. | On `DELETE /session`, verify the cookie and call `revokeRefreshTokens(uid)`; in `createSessionCookie`, reject tokens whose `auth_time` is older than 5 minutes. | **Accepted**: logout clears the cookie; revoking refresh tokens would sign out every device. Sessions are revoked on disable/delete. |
| SEC-17 | Low | Any guest can hide all story and gallery items by reporting them | `packages/core/src/media/media.ts:512-517`; `apps/web/src/app/api/v1/cards/[token]/media/[itemId]/report/route.ts:9`; design `docs/design/features/media.md:21` | Reporting sets `status = reported`, which removes the item from every guest's view; no rate limit and no threshold, so one card holder can empty the host's story and gallery until the host reviews. Design says guests can "report", not that a report hides. | Decide in design (docs/changes/proposed) whether a report hides immediately; if so, rate-limit per card and require N reports, or keep items visible until the host acts. | **Accepted for pilot**: needs a design decision on a per-guest report limit (backlog). |
| SEC-18 | Info | Snippe completion does not cross-check amount/currency | `packages/core/src/billing/billing.ts:383-395` | The amount is set server-side when the payment is created, so payers cannot change it; a check guards against provider-side mix-ups. | Compare `data.amount`/currency and reference with the attempt before completing. | **Accepted**: amounts are set by D-Card at creation; webhooks are HMAC-verified; polling uses Snippe's status API. |
| SEC-19 | Info | Crypto hardening: one secret for four purposes; GCM tag length not enforced | `tokens.ts:10`, `confirm-token.ts:6`, `store.ts:220`, `admin-auth.ts:8`; `crypto/secrets.ts:22-23` | Messages are domain-separated, so no practical attack; short tags would only matter if an attacker could write ciphertexts. | Derive per-purpose keys with HKDF from one master secret; pass `{ authTagLength: 16 }` to `createDecipheriv` and reject tags ≠ 16 bytes. Consider AAD (row id) for encrypted columns. | **Fixed (tag length)**: decrypt requires a 16-byte GCM tag. Per-purpose keys: backlog. |
| SEC-20 | Info | Door device id can be taken over by another door user of the same event | `packages/core/src/checkin/door.ts:109-118` | Re-registering an existing id rewrites `staff_user_id`; audit attribution of later entries changes. Same event only. | Refuse re-registration of a device owned by another active user, or require the host to reassign it. | **Fixed**: another staff member cannot take over a device id (409); tested. |
| SEC-21 | Info | Android auto-backup left on in both apps | `apps/door/android/app/src/main/AndroidManifest.xml`, `apps/mobile/android/app/src/main/AndroidManifest.xml` (no `android:allowBackup`) | The encrypted door database and prefs are backed up without the Keystore key (unreadable, but restores fail oddly); `flutter_secure_storage` recommends disabling backup. | Set `android:allowBackup="false"` (or exclude the database and secure-storage prefs with backup rules). | **Fixed**: `allowBackup=false`, `fullBackupContent=false` in both apps. |
| SEC-22 | Info | NextSMS verify token accepted in the query string; WhatsApp verify token compared with `===` | `apps/web/src/server/webhook-auth.ts:20-25`; `app/api/webhooks/whatsapp/route.ts:12` | Query strings land in platform logs; the GET verify-token compare is not constant time (subscription setup only). | Prefer the header form once NextSMS's carrier is confirmed (T00-10); use `safeEqual` for the Meta verify token. | **Accepted**: NextSMS supports only a query-string token; compared with `safeEqual`. |
| SEC-23 | Info | Rate-limit `INCR`/`EXPIRE` not atomic | `apps/web/src/server/rate-limit.ts:19-20` | A crash between the calls leaves a key without TTL (permanent limit for that key). | Use `SET key 0 EX window NX` then `INCR`, or a `MULTI`, or a small Lua script. | **Fixed**: one `MULTI` with `EXPIRE ... NX`. |
| SEC-24 | Info | Scrubber misses invite tokens; Firebase web API key committed | `packages/core/src/observability/scrub.ts:6`; `http/http-client.env.json` | `/invite/<token>` and `/api/v1/invites/<token>` paths reach Sentry unscrubbed. The Firebase web key is public by design but should be restricted. | Add `invite|invites` to the path rule; confirm HTTP-referrer/API restrictions on the Firebase web key in Google Cloud. | **Fixed (scrubber)**: invite tokens scrubbed. The Firebase web API key is public by design. |
| SEC-25 | Info | Guest media content streams through Vercel without a limit | `apps/web/src/app/api/v1/cards/[token]/media/[itemId]/content/route.ts:14-20`; `media.ts:521-557` | Any card holder can pull videos repeatedly through D-Card functions (bandwidth and Drive quota cost). `cache-control: private, max-age=3600` helps only per browser. | Rate-limit per card token and item, or prefer link mode (Drive-direct) for video. | **Accepted**: needs a valid card token; responses cached for an hour. Revisit after the pilot. |

## Triage (2026-09-27, lead)

- 0 critical, 0 high. All 6 medium fixed with tests. Lows and infos fixed where cheap, otherwise accepted with a reason (Status column).
- `pnpm audit --prod`: clean after overriding `uuid` to ^11.1.1.
- Backlog: script-src CSP with nonces, per-purpose keys, guest report limit (SEC-17).

## Items checked with no finding

- IDOR on every event child id (section 1).
- Copy-from-event import requires the caller to host the source event (`import.ts:196-200`).
- Guests can only complete and delete their own uploads (`media.ts:498-507`).
- Walk-in decision is conditional on status and event (first answer wins) (`walk-ins.ts:168-198`).
- Door admit is serialised with a row lock and rejects cross-event entry ids (`door.ts:309-322`); offline sync locks cards in sorted order (`sync.ts:141-145`).
- Checkout simulate is unreachable in production (`simulate/route.ts:20`); the fake gateway never completes a payment by itself.
- `sql.raw` usage has no user input (`cost-report.ts:71`).
- Error responses never include stack traces (`server/http.ts:47-57`).
- Account deletion revokes Firebase access (`me/route.ts:34-47`, `verifier.ts:114`).

## Next steps (for the lead)

1. Triage: fix SEC-01, SEC-02, SEC-04, SEC-05 (small, testable); decide SEC-03 and SEC-17 in `docs/changes/proposed/` if behaviour changes; confirm SEC-06 with a request that omits the 2FA cookie and inspect the RSC payload.
2. Record a status (fixed with test / accepted with reason) per finding in this file, as the T07-03 acceptance criteria require.
3. Run `flutter pub outdated` for `apps/mobile` and add the `uuid` override.
