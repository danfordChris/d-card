# Deployment

> Pipeline: `.github/workflows/ci.yml` (checks) and `.github/workflows/deploy.yml` (Vercel + Neon).
> Task: `docs/implementation/tasks/t00-09-ci-cd-vercel-neon.md`. Stack decision: `docs/adr/0003-technical-stack.md`.

## What deploys where

| Component | Target | Trigger |
|-----------|--------|---------|
| `apps/web` — web dashboard + REST API + webhooks | Vercel, region `cpt1` (Cape Town) | `deploy.yml` |
| Database | Neon Postgres | Migrated by `deploy.yml` before each deploy |
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
