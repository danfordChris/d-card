# Platform Foundation

## Feature

- Platform Foundation (`docs/design/architecture/codebase.md`)

## Description

- Monorepo, local infrastructure, database, API contract, worker and Flutter workspace every feature builds on.

## Capability Leverage

- Lets three workstreams build in parallel against one contract.

## Status

- In Progress

## Subfeature Index

| Subfeature | Description | Status | Evidence |
|---|---|---|---|
| [`monorepo-and-ci`](./monorepo-and-ci.md) | pnpm + Turborepo workspace, shared config, CI running lint/typecheck/test. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-01` |
| [`local-infra`](./local-infra.md) | docker-compose Postgres and Redis for local development. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-01` |
| [`database-foundation`](./database-foundation.md) | Drizzle schema v1, migrations and seed data. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-02` |
| [`core-utilities`](./core-utilities.md) | Phone normalisation, audit helper and per-event role check in packages/core. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-03` |
| [`api-contract`](./api-contract.md) | Zod schemas emitted as OpenAPI, source for the Dart client. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-04` |
| [`worker-runtime`](./worker-runtime.md) | Long-lived Node worker consuming BullMQ queues on Redis. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-05` |
| [`dart-core-package`](./dart-core-package.md) | Pure Dart package with shared models and phone normalisation. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-06` |
| [`flutter-workspace`](./flutter-workspace.md) | Melos workspace with the D-Card and D-Card Door app shells. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-07` |
| [`observability`](./observability.md) | Logs, error tracking, queue dashboards and alerts. | Done | `P06` (`docs/implementation/phases/phase-06-completion.md`) |
| [`environment-config`](./environment-config.md) | Typed, documented environment keys for every provider, with dummy detection and a handover README. | In Progress | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-08`, `T00-10` |
| [`deployment-pipeline`](./deployment-pipeline.md) | GitHub Actions deploying the web app and API to Vercel with Neon branches per pull request. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-09` |
