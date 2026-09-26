# Deployment

> Pipeline: `.github/workflows/ci.yml` (checks) and `.github/workflows/deploy.yml` (Vercel + Neon).
> Task: `docs/implementation/tasks/t00-09-ci-cd-vercel-neon.md`. Stack decision: `docs/adr/0003-technical-stack.md`.

## What deploys where

| Component | Target | Trigger |
|-----------|--------|---------|
| `apps/web` — web dashboard + REST API + webhooks | Vercel project `dcard-web` (https://api.dcard.danfordchris.dev; also dcard-web.vercel.app), functions in `fra1` (Frankfurt, next to the database) | `deploy.yml`, or `vercel deploy --prod` from the repo root |
| Database | Neon Postgres `dcard` (Vercel Marketplace, `aws-eu-central-1`), connected to `dcard-web` (sets `DATABASE_URL`, `DATABASE_URL_UNPOOLED`) | Migrated by `deploy.yml` before each deploy |
| Redis | Upstash Redis `dcard-redis` (Vercel Marketplace, `fra1`, free, auto-upgrade off) | — |
| `apps/worker` | Railway (planned, not automated yet) | — |
| `apps/mobile`, `apps/door` | Play Store / App Store | Manual by the owner |

## Pipeline

| Event | Jobs |
|-------|------|
| Pull request opened/updated | `ci.yml` (TypeScript + Flutter + workflow validator) · `deploy.yml › preview`: create Neon branch `preview/pr-<n>` → migrate + seed → `vercel build` → `vercel deploy --prebuilt` with the branch's pooled `DATABASE_URL` → comment URL on the PR |
| Pull request closed | `deploy.yml › cleanup`: delete Neon branch `preview/pr-<n>` |
| Push to `main` | `deploy.yml › checks` (reuses `ci.yml`) → `production`: migrate + seed Neon production → `vercel build --prod` → `vercel deploy --prebuilt --prod` |

- Preview jobs skip pull requests from forks (no secrets there).
- Until the secrets and `NEON_PROJECT_ID` variable below are set, the `config` job reports "Deployment skipped" and all deploy jobs are skipped (checks stay green).
- Seed is idempotent (upserts event types and plans).
- The `production` job uses the GitHub environment `production` — add required reviewers there to gate releases.

## One-time setup

### 1. Neon

1. Create a Neon project (region closest to Cape Town/Africa available).
2. Note the **project ID** (Settings → General).
3. Create an **API key** (Account → API keys).
4. Copy the production branch **direct** connection string (not pooled) for migrations, and the **pooled** string for the app.

### 2. Vercel

1. Create a project from this repo with **Root Directory = `apps/web`** (framework Next.js). Turn off automatic Git deployments (Settings → Git → Ignored Build Step: `exit 0`) so only GitHub Actions deploys.
2. Locally: `npx vercel@60.0.0 link` inside `apps/web`, then read `org_id` and `project_id` from `apps/web/.vercel/project.json` (do not commit `.vercel/`).
3. Create a token (Account Settings → Tokens).
4. Add environment variables in Vercel (Settings → Environment Variables) for **Production** and **Preview**, using `.env.example` as the list:
   - `DATABASE_URL` (Production: Neon **pooled** URL; Preview is overridden per PR by the pipeline)
   - `APP_URL`, `AUTH_VERIFIER=firebase`, `TOKEN_HASH_SECRET`, `DATA_ENCRYPTION_KEY`, `REDIS_URL`
   - `API_KEYS` (one `client:key` pair per client: `web`, `mobile`, `door`, `tools`) and `NEXT_PUBLIC_DCARD_API_KEY` (the `web` key). Use different keys per environment; build the mobile and door apps with their key (`--dart-define=API_KEY=…`).
   - Firebase, WhatsApp, NextSMS, Google Drive and Snippe keys
   - `NEXTSMS_LIVE=true` and `WHATSAPP_LIVE=true` on the production worker only (anywhere else SMS go to the NextSMS test endpoint and WhatsApp messages are held; nothing reaches a phone)
   - Never set `AUTH_VERIFIER=fake` or `dev` on Vercel (the server refuses both in production).

### 3. GitHub (Settings → Secrets and variables → Actions)

| Name | Type | Value |
|------|------|-------|
| `VERCEL_TOKEN` | Secret | Vercel token |
| `VERCEL_ORG_ID` | Secret | `org_id` from `.vercel/project.json` |
| `VERCEL_PROJECT_ID` | Secret | `project_id` from `.vercel/project.json` |
| `NEON_API_KEY` | Secret | Neon API key |
| `DATABASE_URL_PRODUCTION` | Secret (environment `production`) | Neon production **direct** connection string |
| `SUBMODULE_TOKEN` | Secret (optional) | Fine-grained PAT with read access to `danfordChris/workflow-doc`, only if that repo is private |
| `NEON_PROJECT_ID` | Variable | Neon project ID |
| `NEON_DATABASE` | Variable (optional) | Database name, default `neondb` |
| `NEON_ROLE` | Variable (optional) | Role, default `neondb_owner` |

Also create the GitHub environment **`production`** (Settings → Environments).

## Current production (2026-09-25)

- Created from the CLI: `vercel project add dcard-web`, `vercel link` at the repo root (Root Directory `apps/web`, build `cd ../.. && pnpm turbo run build --filter=@dcard/web...`, Node 24, Vercel Authentication on previews only so Meta can reach the webhooks).
- `.vercelignore` at the repo root keeps `.env*`, build output and the Flutter apps out of CLI uploads (`next.config.ts` would otherwise load a root `.env` on the build machine).
- Production variables on this account are **sensitive** (write-only). The generated values (API keys per client, token/encryption secrets, webhook verify tokens) are kept by the owner outside the repo; rotate by writing new values with `vercel env add <NAME> production --force` and redeploying.
- Redis connected (`REDIS_URL` from Upstash; rate limit verified live: 21st request → 429).
- WhatsApp keys set (access token, phone number ID, business account ID, App Secret); signed webhook POSTs verified live (valid signature → 200, tampered → 401).
- Still to add: Resend/NextSMS/Snippe/Google keys; the worker host (Railway) is not set up yet, so queued messages and emails are not sent from production.
- Domains (DNS at Cloudflare): `dcard.danfordchris.dev` → `dcard-site` (marketing site; `dcard-site.vercel.app` redirects to it); `api.dcard.danfordchris.dev` → `dcard-web` (API, webhooks and dashboard). The API host is two levels deep, which Cloudflare's free Universal SSL does not cover, so its record is a **DNS-only** (grey cloud) `CNAME api.dcard → cname.vercel-dns.com` and Vercel issues the certificate.
- Meta webhook: callback `https://api.dcard.danfordchris.dev/api/webhooks/whatsapp`, verify token = production `WHATSAPP_WEBHOOK_VERIFY_TOKEN`.

## Operations

| Need | Command |
|------|---------|
| Roll back production | `vercel rollback --token=$VERCEL_TOKEN` (from `apps/web`, linked) |
| Inspect a deployment | `vercel inspect <url>` / `vercel logs <url>` |
| Re-run a deploy | GitHub → Actions → Deploy → Re-run jobs |
| Migration failed | Deploy stops before Vercel; fix the migration, push again (Neon keeps the previous schema) |

## Verification

- Workflows lint clean: `docker run --rm -v "$PWD:/repo" -w /repo rhysd/actionlint:latest -no-color`
- Vercel build command works locally: `cd apps/web && sh -c "cd ../.. && pnpm turbo run build --filter=@dcard/web..."`

## Marketing site (`apps/site`)

A separate Vercel project (static, no functions):

- Root directory `apps/site`; framework preset Astro; build command `pnpm --filter @dcard/site build`; output `dist`.
- Environment variables: `SITE_URL` (the site's own domain, used for canonical/hreflang/sitemap), `SITE_APP_URL` (the web app, for the sign-up button), and optionally `SITE_WHATSAPP`, `SITE_PHONE` (any Tanzanian format), `SITE_EMAIL` — contact buttons stay hidden until set.
- Check locally: `pnpm --filter @dcard/site build && pnpm --filter @dcard/site preview`.

