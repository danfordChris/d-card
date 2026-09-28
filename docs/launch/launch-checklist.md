# Launch checklist

> Task: `docs/implementation/tasks/t07-04-launch-checklist.md`. Sources: `docs/deployment.md`, `docs/store-listings.md`, `docs/design/integrations/*.md`, phase 05 and 06 reviews (`docs/implementation/reviews/2026-09-27-phase-0{5,6}-review.md`). Last checked: 2026-09-27.

One list to take D-Card live. Work top to bottom. Tick an item only after its check passes.

- **Owner** = the business owner (accounts, money, legal, stores, anything behind a login only they hold).
- **Lead** = the lead developer (code, deploys, checks).
- Never write secret values in this file, in chat or in commits. Names only.

Production at a glance:

| Part | Where |
|---|---|
| Web dashboard, REST API, webhooks | Vercel project `dcard-web` → https://api.dcard.danfordchris.dev |
| Marketing site | Vercel project `dcard-site` → https://dcard.danfordchris.dev |
| Database | Neon Postgres `dcard` (`aws-eu-central-1`) |
| Worker + Redis | Railway project `dcard` (Hobby), services `worker` and `redis` (`europe-west4`) |
| Auth + push | Firebase |
| Messages | Meta WhatsApp Cloud API, NextSMS |
| Payments | Snippe (no sandbox) |
| Media | Host's own Google Drive |
| Email | Resend |
| Errors | Sentry (free plan) |

---

## 1. Accounts and verification

| # | Item | Who | How to verify |
|---|---|---|---|
| 1.1 | Vercel, Neon, Railway (Hobby) and GitHub accounts owned by the business, with 2FA on. | Owner | Log in to each; 2FA prompt appears. |
| 1.2 | Meta Business portfolio **verified** (Business Settings → Security Centre). | Owner | Status shows "Verified". |
| 1.3 | WhatsApp Business number registered, display name approved. | Owner | WhatsApp Manager → Phone numbers: status "Connected", name "Approved". |
| 1.4 | WhatsApp **messaging limit** checked. New or unverified businesses get a low daily cap (unique recipients per 24 h) until verification. Throughput defaults to 80 messages/s per number. | Owner | WhatsApp Manager → Phone numbers → Messaging limit. Write the current tier here: `<OWNER: tier, date>`. It must be above the largest pilot's guest count. |
| 1.5 | NextSMS account funded; sender ID registered and approved. | Owner | NextSMS dashboard shows balance and sender ID "Active". |
| 1.6 | Snippe merchant account approved (KYC done), payouts set to the business account. | Owner | Snippe dashboard shows the account as live. |
| 1.7 | Resend account; sending domain verified (SPF/DKIM). | Owner | Resend → Domains shows "Verified". |
| 1.8 | Google Cloud project with the Drive API enabled. | Owner | Cloud console → APIs & Services → Enabled APIs lists "Google Drive API". |
| 1.9 | Sentry account (free Developer plan), one Node project. | Owner | Project exists; DSN visible in Project settings → Client keys. |
| 1.10 | Firebase project on the Spark/Blaze plan chosen by the owner. | Owner | Firebase console opens the project. |
| 1.11 | Google Play Developer and Apple Developer accounts (see section 11). | Owner | Consoles open; identity verification complete. |

## 2. Environment variables

Names only. Use `.env.example` for the meaning of each. Production values on Vercel are **sensitive** (write-only). Keep your own copy in a password manager.

### 2.1 Vercel `dcard-web` → Settings → Environment Variables → Production

| Group | Names |
|---|---|
| Core | `APP_URL`, `AUTH_VERIFIER` (must be `firebase`), `API_KEYS`, `NEXT_PUBLIC_DCARD_API_KEY`, `TOKEN_HASH_SECRET`, `DATA_ENCRYPTION_KEY`, `QUEUE_PREFIX` |
| Database (set by the Neon integration) | `DATABASE_URL` (pooled), `DATABASE_URL_UNPOOLED` |
| Redis | `REDIS_URL` (Railway TCP proxy), `REDIS_TLS_CA_B64` |
| Firebase | `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`, `NEXT_PUBLIC_FIREBASE_API_KEY`, `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`, `NEXT_PUBLIC_FIREBASE_PROJECT_ID`, `NEXT_PUBLIC_FIREBASE_APP_ID` |
| WhatsApp | `WHATSAPP_ACCESS_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`, `WHATSAPP_BUSINESS_ACCOUNT_ID`, `WHATSAPP_APP_SECRET`, `WHATSAPP_WEBHOOK_VERIFY_TOKEN`, `WHATSAPP_API_VERSION` |
| NextSMS | `NEXTSMS_BASE_URL`, `NEXTSMS_API_TOKEN`, `NEXTSMS_SENDER_ID`, `NEXTSMS_WEBHOOK_VERIFY_TOKEN` |
| Google Drive | `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_REDIRECT_URI` |
| Snippe | `SNIPPE_BASE_URL`, `SNIPPE_API_KEY`, `SNIPPE_WEBHOOK_SECRET`, `SNIPPE_LIVE` |
| Email | `RESEND_API_KEY`, `EMAIL_FROM` |
| Observability | `SENTRY_DSN` |

Never set `AUTH_VERIFIER=fake` or `dev` on Vercel. Never set `NEXTSMS_LIVE` or `WHATSAPP_LIVE` on Vercel (the worker sends messages, not the web app).

### 2.2 Railway `worker` → Variables

| Group | Names |
|---|---|
| Core (same values as Vercel) | `APP_URL`, `TOKEN_HASH_SECRET`, `DATA_ENCRYPTION_KEY`, `WORKER_API_KEY` (= the `worker:` entry of `API_KEYS`), `QUEUE_PREFIX` |
| Database | `DATABASE_URL` (Neon direct URL) |
| Redis | `REDIS_URL` (private network, references `${{redis.REDIS_PASSWORD}}`) |
| Firebase (push) | `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` |
| Providers | `WHATSAPP_ACCESS_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`, `WHATSAPP_API_VERSION`, `NEXTSMS_BASE_URL`, `NEXTSMS_API_TOKEN`, `NEXTSMS_SENDER_ID`, `SNIPPE_BASE_URL`, `SNIPPE_API_KEY` |
| Email + alerts | `RESEND_API_KEY`, `EMAIL_FROM`, `ALERT_EMAIL`, `SENTRY_DSN` |
| Live switches | `WHATSAPP_LIVE`, `NEXTSMS_LIVE`, `SNIPPE_LIVE` (section 3) |
| Optional | `WHATSAPP_MAX_PER_SECOND`, `SMS_MAX_PER_SECOND` (leave unset for the defaults) |

### 2.3 Other places

| Where | Names |
|---|---|
| Railway `redis` | `REDIS_PASSWORD`, `REDIS_TLS_CERT_B64`, `REDIS_TLS_KEY_B64` |
| Vercel `dcard-site` | `SITE_URL`, `SITE_APP_URL`, `SITE_WHATSAPP`, `SITE_PHONE`, `SITE_EMAIL` |
| GitHub → Settings → Secrets and variables → Actions | Secrets `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`, `NEON_API_KEY`, `DATABASE_URL_PRODUCTION` (environment `production`); variable `NEON_PROJECT_ID` |
| Flutter release builds (local, gitignored defines file) | `API_BASE_URL`, `API_KEY` (`mobile:` or `door:` entry), `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `SENTRY_DSN` (optional) |

| # | Item | Who | How to verify |
|---|---|---|---|
| 2.4 | All names above set in the right place. | Lead sets generated secrets; Owner pastes provider keys only they can see | `vercel env ls production` lists every Vercel name. Railway → worker → Variables lists every worker name. `pnpm env:check` locally shows the list in `.env.example` is complete. |
| 2.5 | Same `TOKEN_HASH_SECRET`, `DATA_ENCRYPTION_KEY`, `APP_URL` on Vercel and the worker. | Lead | A card link sent by the worker opens on the web (same token hash). |
| 2.6 | Web → Redis over pinned TLS. | Lead | 21st quick request to a rate-limited route returns 429. A `system/ping` job is processed by the worker (Railway logs). |

## 3. Live switches

Production only. Anywhere else no message reaches a phone and no money moves.

| Switch | Set on | Off means | Who | How to verify |
|---|---|---|---|---|
| `WHATSAPP_LIVE=true` | Railway `worker` only | WhatsApp messages are held (Meta has no test endpoint) | Lead, after owner OK | Test send to the owner's own phone arrives on WhatsApp; `message_log` gets a Meta message id. |
| `NEXTSMS_LIVE=true` | Railway `worker` only | SMS go to the NextSMS test endpoint (no delivery, no charge) | Lead, after owner OK | Test SMS arrives on the owner's phone; NextSMS balance drops. |
| `SNIPPE_LIVE=true` | Vercel `dcard-web` production **and** Railway `worker` | Fake gateway, no money moves | Lead, after owner OK | Section 7: first real payment. |

Turn switches on only after sections 1, 2, 6 and 7 are done. To stop all real sends quickly: remove `WHATSAPP_LIVE` and `NEXTSMS_LIVE` on the worker and redeploy it. Messages stay queued.

## 4. Database: migrations and backups

| # | Item | Who | How to verify |
|---|---|---|---|
| 4.1 | Migrations `0013_check_in`, `0014_billing`, `0015_media`, `0016_retention`, `0017_admin` applied to production. They run in `deploy.yml › production` (`pnpm --filter @dcard/db db:migrate && db:seed` with `DATABASE_URL_PRODUCTION`, the direct URL) on every push to `main`, before the Vercel deploy. A failed migration stops the deploy; the site keeps the previous version. | Lead | GitHub Actions → Deploy → "Migrate production database" step is green. Neon SQL editor: `select count(*) from drizzle.__drizzle_migrations;` returns 18 (0000–0017). |
| 4.2 | Worker redeployed after the migrations (it reads the new tables). | Lead | Railway → worker → Deployments shows a deploy newer than the migration run; no errors in logs. |
| 4.3 | Neon restore window checked. Neon keeps history for point-in-time restore; the window depends on the plan (short on Free). | Owner (plan), Lead (check) | Neon console → project → Settings → history retention / instant restore. Write it here: `<OWNER: window, plan>`. Choose a plan that covers at least 24 h for pilot weeks. |
| 4.4 | Manual backup before each production migration and before each pilot event: `pg_dump` with the direct URL to an encrypted file outside the repo, or a Neon branch named `backup/<date>`. | Lead | File or branch exists with today's date. |
| 4.5 | Restore drill once: restore a Neon branch to a past time and query it. | Lead | Query on the restored branch returns the older rows. Delete the branch after. |

## 5. Domains and TLS

| # | Item | Who | How to verify |
|---|---|---|---|
| 5.1 | `dcard.danfordchris.dev` → Vercel `dcard-site` (Cloudflare DNS). | Owner (DNS), Lead | Page loads over HTTPS; `dcard-site.vercel.app` redirects to it. |
| 5.2 | `api.dcard.danfordchris.dev` → `CNAME cname.vercel-dns.com`, **DNS-only** (grey cloud). Vercel issues the certificate. | Owner (DNS), Lead | `curl -I https://api.dcard.danfordchris.dev` returns a Vercel response with a valid certificate. Vercel → Domains shows "Valid Configuration". |
| 5.3 | Resend sending domain (SPF/DKIM records in Cloudflare). | Owner | Resend → Domains "Verified"; a team invite email reaches an inbox, not spam. |
| 5.4 | Redis TLS certificate valid (private CA). | Lead | Section 2.6 check passes. Note its expiry date: `<LEAD: date>`. |

## 6. Provider setup

### 6.1 Firebase

| # | Item | Who | How to verify |
|---|---|---|---|
| 6.1.1 | Email/password provider on (hosts, staff, admins). | Owner | Sign up and sign in on https://api.dcard.danfordchris.dev. |
| 6.1.2 | Google and Apple providers on (guests). Android SHA-1/SHA-256 (upload key and Play App Signing) added. iOS URL scheme and Sign in with Apple capability set. | Owner, Lead (Xcode) | Guest signs in with Google on Android and with Apple on iPhone. |
| 6.1.3 | Authorised domains include `api.dcard.danfordchris.dev`. | Owner | Web sign-in works on the production domain. |
| 6.1.4 | Android and iOS apps registered for both apps; APNs key uploaded to Cloud Messaging. | Owner | Walk-in request push arrives on a host's phone (Android and iPhone). |

### 6.2 Meta WhatsApp

| # | Item | Who | How to verify |
|---|---|---|---|
| 6.2.1 | App set to **Live** (published), not Development. | Owner | Meta for Developers → app → top bar shows "Live". |
| 6.2.2 | Webhook callback `https://api.dcard.danfordchris.dev/api/webhooks/whatsapp`, verify token = production `WHATSAPP_WEBHOOK_VERIFY_TOKEN`. Subscribed to `messages` and template status fields. | Owner | Meta shows the webhook verified. A status update from a test send appears in `message_log`. |
| 6.2.3 | Every guest template **approved**, category **Utility** (thank-you is Marketing), Swahili and English. | Owner submits, Lead checks names | Admin → WhatsApp templates shows each as approved. WhatsApp Manager → Message templates shows "Active". |
| 6.2.4 | Permanent system-user access token (not the 24 h test token). | Owner | Token still works the next day (test send succeeds). |

### 6.3 NextSMS

| # | Item | Who | How to verify |
|---|---|---|---|
| 6.3.1 | Delivery callback URL `https://api.dcard.danfordchris.dev/api/webhooks/nextsms` with the verify token (optional fast path; polling works without it). | Owner | A test SMS reaches `DELIVERED` in `message_log`. |

## 7. Snippe payments

| # | Item | Who | How to verify |
|---|---|---|---|
| 7.1 | Webhook URL `https://api.dcard.danfordchris.dev/api/webhooks/snippe` in the Snippe dashboard; webhook secret copied to `SNIPPE_WEBHOOK_SECRET`. | Owner | Snippe dashboard shows the URL; a delivery shows HTTP 200. |
| 7.2 | API key with scopes `collection:read`, `collection:create`. | Owner | Checkout starts a USSD push. |
| 7.3 | **First real payment** with `SNIPPE_LIVE=true`: the plan checkout for the first pilot event, paid from the host's or the owner's phone. D-Card has no way to price an event below the Tsh 50,000 minimum (less the launch offer), so there is no separate Tsh 500 test. Do it at T-14 days so a problem does not block the event. | Owner/host pays, Lead watches | The phone gets the USSD prompt; Admin → Billing shows the payment `completed` once; the event shows as paid; the payment appears in the Snippe dashboard. |

## 8. Google Drive (OAuth)

| # | Item | Who | How to verify |
|---|---|---|---|
| 8.1 | OAuth consent screen: app name D-Card, support email, privacy URL `https://dcard.danfordchris.dev/privacy`, scope `drive.file` only. Test users added while in "Testing"; publish when ready. | Owner | Consent screen shows D-Card and only the Drive file scope. |
| 8.2 | OAuth client (Web) redirect URIs: `https://api.dcard.danfordchris.dev/api/v1/media/google/callback` and the localhost one used in development. Same production value in `GOOGLE_OAUTH_REDIRECT_URI`. | Owner | A host connects Drive on production without `redirect_uri_mismatch`. |
| 8.3 | Live Drive connect and one upload in each sharing mode (`private` and `link`). | Owner, Lead | Files appear in the host's Drive folder `D-Card – {event}/`; the guest card page shows them. |

## 9. Monitoring and alerts

| # | Item | Who | How to verify |
|---|---|---|---|
| 9.1 | `SENTRY_DSN` on Vercel production and Railway worker. | Owner creates project, Lead sets | Trigger a test error; it appears in Sentry with no phone numbers or tokens in it. |
| 9.2 | Sentry alert rule "a new issue is created" → email. | Owner | Rule listed in Sentry → Alerts. |
| 9.3 | `ALERT_EMAIL` on the worker (needs `RESEND_API_KEY` and verified `EMAIL_FROM`). Alerts: >100 waiting jobs in a queue, >10 failed jobs in an hour, host payment pending >1 h. | Owner picks the inbox, Lead sets | Worker logs show the alert check every 5 minutes. Optional: pause the worker briefly on a quiet day and confirm the email arrives. |
| 9.4 | Admin account with 2FA (TOTP) and recovery codes stored safely. | Owner | Admin → Queues opens after the TOTP code. |

## 10. Legal and support

| # | Item | Who | How to verify |
|---|---|---|---|
| 10.1 | **PDPA O3:** legal adviser confirms duties under Tanzania's Personal Data Protection Act 2022 (PDPC registration, consent wording, who is controller) and the Firebase/Google data point. | Owner | Written advice filed. O3 closed in `docs/design/features/privacy-and-audit.md` by the lead. |
| 10.2 | Privacy notice final wording (sw + en) and a real **privacy contact** (email + `255` phone). | Owner gives text, Lead publishes | https://dcard.danfordchris.dev/privacy shows the contact; no placeholders left. |
| 10.3 | Support channel: one WhatsApp number (`255` + 9 digits) and one email, with hours. Set `SITE_WHATSAPP`, `SITE_PHONE`, `SITE_EMAIL`; fill the `<OWNER: …>` support fields in `docs/store-listings.md`. | Owner | Contact buttons show on the marketing site; a test message gets an answer. |
| 10.4 | Consent checkbox on guest import/add is on (it is built in). | Lead | Import without ticking consent is refused. |

## 11. Store submissions

Full steps: `docs/store-listings.md` sections 9 and 10.

| # | Item | Who | How to verify |
|---|---|---|---|
| 11.1 | Upload keystore created outside the repo; `key.properties` in both apps, not tracked. | Owner | `git status` does not list `key.properties` or `*.jks`. |
| 11.2 | Real launcher icons and Swahili `InfoPlist.strings`. | Lead | `flutter build ipa` shows no placeholder-icon warning. |
| 11.3 | Google Play **internal testing**: both apps (`tz.dcard.dcard_mobile`, `tz.dcard.dcard_door`) uploaded with production defines; Data safety filled. | Owner | Testers install from the opt-in link; sign-in and a door scan work. |
| 11.4 | **TestFlight**: both apps (`tz.dcard.dcardMobile`, `tz.dcard.dcardDoor`) with Push, Sign in with Apple (D-Card), export compliance answered. | Owner | Internal testers install; Apple sign-in and push work. |
| 11.5 | App Review risks decided: iOS in-app mobile-money checkout (fallback: pay on web) and account deletion for door staff. | Owner decides, Lead builds fallback if needed | Decision written in `docs/store-listings.md`. |

## 12. Rollback

| What broke | Do this | Who | How to verify |
|---|---|---|---|
| Web/API deploy | Vercel instant rollback: Vercel → `dcard-web` → Deployments → previous good one → "Instant Rollback", or `vercel rollback` from the linked repo. Takes seconds. | Lead | `curl -I https://api.dcard.danfordchris.dev` serves the old deployment id; errors stop in Sentry. |
| Worker deploy | Railway → `worker` → Deployments → previous good one → "Redeploy". | Lead | Worker logs show the old commit (`RAILWAY_GIT_COMMIT_SHA`); Admin → Queues drains again. |
| Migration | **Forward-fix only.** Do not run down-migrations or edit an applied migration. Write a new migration that fixes the problem and deploy it. The old code must still work with the new schema (additive changes first). If data was damaged, restore a Neon branch to a time before the migration (section 4.3), compare, and copy back only what is needed. | Lead | New migration green in Actions; affected screens work. |
| Provider trouble | Turn off the live switch on the worker (section 3) and redeploy it. Messages wait in the outbox. | Lead | Queue counts stop rising in sent; nothing new in provider dashboards. |

## Sign-off

| | Name | Date |
|---|---|---|
| Owner | | |
| Lead | | |
