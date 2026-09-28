# T00-09 — CI/CD: Web + API to Vercel with Neon

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/deployment-pipeline.md`

## Agent Context

- Skills: `vercel:deployments-cicd`, `vercel:vercel-cli`
- Design docs: `docs/design/architecture/codebase.md` (Deployment), `docs/adr/0003-technical-stack.md`
- Constraints: `apps/web` (Next.js web dashboard + API) deploys to Vercel, region Cape Town (`cpt1`); database is Neon; migrations run before each deploy; secrets only in GitHub/Vercel settings; mobile apps are deployed manually by the owner; the worker is not deployed by this pipeline.
- Do not touch: `docs/design/`, `.agents/`, application source code

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: a Vercel or Neon account setting is required that only the owner can create

## Objective

GitHub Actions checks every change, deploys pull requests to Vercel previews on their own Neon branch, and deploys `main` to Vercel production after migrating the Neon production database.

## Scope Boundary

**In scope:**
- `.github/workflows/ci.yml`, `.github/workflows/deploy.yml`
- `apps/web/vercel.ts` (or `vercel.json`)
- `docs/deployment.md` (secrets and one-time setup)

**Out of scope:**
- Creating Vercel/Neon/GitHub accounts or secrets (owner)
- Worker deployment (Railway, later task)
- Mobile store releases (owner, manual)

## Acceptance Criteria

- [x] `ci.yml` runs on every pull request and push: install, `turbo run typecheck lint test build`, Dart tests, workflow validator.
- [x] `deploy.yml` on pull request: creates Neon branch `preview/pr-<number>`, runs `db:migrate` on it, deploys a Vercel preview with that branch's `DATABASE_URL`, and comments the preview URL on the PR.
- [x] `deploy.yml` on pull request close: deletes the Neon branch `preview/pr-<number>`.
- [x] `deploy.yml` on push to `main`: runs checks, runs `db:migrate` against Neon production, then `vercel deploy --prebuilt --prod`.
- [x] Vercel config sets region `cpt1` for functions.
- [x] `docs/deployment.md` lists every GitHub secret/variable (`VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`, `NEON_API_KEY`, `NEON_PROJECT_ID`, `DATABASE_URL_PRODUCTION`) and the one-time Vercel/Neon setup steps.
- [x] Both workflow files pass `actionlint` (or YAML parse) locally.

## Dependencies

- T00-04 done; T00-08 done (env keys documented).

## Implementation Checklist

- [x] Load the deployment skills.
- [x] Update `ci.yml`; write `deploy.yml`.
- [x] Add Vercel config for `apps/web`.
- [x] Write `docs/deployment.md`.
- [x] Validate workflow syntax.

## Verification

- Command: `actionlint .github/workflows/*.yml` (or `python3 -c "import yaml,sys;[yaml.safe_load(open(f)) for f in sys.argv[1:]]" .github/workflows/*.yml`)
- Evidence:

```
$ docker run --rm -v "$PWD:/repo" -w /repo rhysd/actionlint:latest -no-color   → no findings, exit=0
$ cd apps/web && sh -c "cd ../.. && pnpm turbo run build --filter=@dcard/web..."   → 4 successful, 4 total (Vercel buildCommand)
$ pnpm turbo run typecheck lint test build → 23 successful, 23 total; melos test → SUCCESS
```
- `ci.yml`: TypeScript job (Postgres/Redis services, turbo typecheck/lint/test/build, spikes typecheck, workflow validator) + Flutter job (flutter-action 3.44.6, melos analyze/test); reusable via `workflow_call`.
- `deploy.yml`: `preview` (Neon branch `preview/pr-<n>` via create-branch-action@v6 → migrate + seed with `db_url` → vercel build/deploy --prebuilt with `--env DATABASE_URL=<db_url_pooled>` → PR comment), `cleanup` (delete-branch-action@v3 on close), `checks` (reuses ci.yml) → `production` (migrate `DATABASE_URL_PRODUCTION` → vercel build --prod → deploy --prebuilt --prod), Vercel CLI pinned to 60.0.0.
- `apps/web/vercel.ts`: framework nextjs, monorepo build command, regions `cpt1`.
- `docs/deployment.md`: every secret/variable + one-time Vercel/Neon/GitHub setup.
- Not verifiable here: live runs need the owner's Vercel/Neon/GitHub secrets.
