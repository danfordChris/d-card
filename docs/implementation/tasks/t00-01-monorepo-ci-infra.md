# T00-01 — Monorepo, CI and Local Infrastructure

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/monorepo-and-ci.md`, `docs/implementation/feature-inventory/platform-foundation/local-infra.md`

## Agent Context

- Skills: none required
- Design docs: `docs/design/architecture/codebase.md`, `docs/adr/0003-technical-stack.md`
- Constraints: Node 24, pnpm 10, Turborepo; Postgres 17 and Redis 7 images; no application code
- Do not touch: `docs/design/`, `.agents/`, other tasks' scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass, or a required tool (Docker, pnpm) is unavailable
- Handoff when: context becomes recap-heavy, or a design decision is missing (record it in `docs/changes/proposed/` instead of deciding).

## Objective

The repository root builds as a pnpm + Turborepo monorepo with shared TS config, local Postgres/Redis via Docker, and a CI workflow.

## Scope Boundary

**In scope:**
- root: `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `.npmrc`, `.nvmrc`, `.gitignore`, `.editorconfig`, `tsconfig.base.json`, `eslint.config.mjs`, `.env.example`, `README.md`
- `packages/config/`
- `infra/docker-compose.yml`
- `.github/workflows/ci.yml`

**Out of scope:**
- `apps/*`, `packages/db`, `packages/core`, `packages/api-contract`, `dart_packages/*`
- Deployment to Vercel/Railway

## Acceptance Criteria

- [x] `pnpm install` exits 0 and writes `pnpm-lock.yaml`.
- [x] `pnpm turbo run typecheck lint test` exits 0.
- [x] `docker compose -f infra/docker-compose.yml up -d --wait` reports `postgres` and `redis` healthy.
- [x] `.github/workflows/ci.yml` runs install, `turbo run typecheck lint test`, and `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`.
- [x] `.env.example` lists `DATABASE_URL` and `REDIS_URL` pointing at the compose services.

## Dependencies

- None.

## Implementation Checklist

- [x] Create root workspace files and `packages/config` (tsconfig presets).
- [x] Add ESLint flat config with typescript-eslint.
- [x] Add `infra/docker-compose.yml` with healthchecks.
- [x] Add CI workflow.
- [x] Run install, turbo tasks and compose; record evidence.

## Verification

- Command: `pnpm install && pnpm turbo run typecheck lint test && docker compose -f infra/docker-compose.yml up -d --wait`
- Evidence:

```
$ pnpm install            → Done in 33.7s (pnpm-lock.yaml written)
$ pnpm turbo run typecheck lint test
  Tasks: 0 successful, 0 total  (exit 0; no packages yet)
$ docker compose -f infra/docker-compose.yml up -d --wait
  Container dcard-redis-1 Healthy
  Container dcard-postgres-1 Healthy
  postgres healthy 0.0.0.0:55432->5432/tcp
  redis healthy 0.0.0.0:56379->6379/tcp
```
- `.github/workflows/ci.yml`: install → `turbo run typecheck lint test` → workflow validator; Dart job runs `dart test` per package.
- `.env.example`: `DATABASE_URL=postgres://dcard:dcard@localhost:55432/dcard`, `REDIS_URL=redis://localhost:56379`.
- Deviation: host ports 55432/56379 (overridable via `DCARD_PG_PORT`/`DCARD_REDIS_PORT`) because another local project occupies 5432/6379. CI services use 5432/6379.
