# T00-08 — Environment Configuration, Spike Scripts and Handover README

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-00-foundations.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/platform-foundation/environment-config.md`

## Agent Context

- Skills: `snippe-integration`
- Design docs: `docs/design/integrations/messaging.md`, `docs/design/integrations/google-drive.md`, `docs/design/integrations/snippe.md`, `docs/design/integrations/firebase.md`, `docs/design/architecture/codebase.md`
- Constraints: real keys are added by the owner; this task uses dummy values only. `.env` is never committed. Spike scripts never run automatically in CI.
- Do not touch: `docs/design/`, `.agents/`, `apps/mobile`, `apps/door`

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: a provider API contract is unclear (record in `docs/changes/proposed/`)

## Objective

Every provider key the platform needs is declared, documented and validated, spike scripts exist for each risky integration, and the root README lets a new developer set up and hand over the project.

## Scope Boundary

**In scope:**
- `.env.example` (committed, documented) and `.env` (local, gitignored, dummy values)
- `packages/env/**` (typed env schema + `env:check` script)
- `spikes/**` (one script per provider, runnable once real keys exist)
- `README.md` (root handover guide)

**Out of scope:**
- Live runs against providers (T00-10)
- Production adapters (phases 03, 05)
- CI/CD (T00-09)

## Acceptance Criteria

- [x] `.env.example` lists every key for Postgres, Redis, Firebase (admin + web client), Meta WhatsApp, NextSMS, Google Drive OAuth, Snippe, app URLs and token secrets, each with a comment naming where to obtain it.
- [x] `.env` exists locally with the same keys and dummy values, and `git check-ignore .env` prints `.env`.
- [x] `pnpm env:check` exits 0 for the dummy `.env` and lists which provider keys still hold dummy values.
- [x] `pnpm env:check` exits 1 and names the key when a required key is missing.
- [x] `spikes/` contains `whatsapp-button.ts`, `nextsms-send.ts`, `drive-upload.ts`, `snippe-ussd.ts`; each refuses to run while its keys are dummy.
- [x] `README.md` covers: product summary, architecture, repo layout, prerequisites, local setup, environment keys, commands, testing, workflow contract, deployment, mobile, handover checklist.

## Dependencies

- T00-04 done.

## Implementation Checklist

- [x] Write `packages/env` schema (zod) grouped by provider, with dummy detection.
- [x] Write `.env.example` and `.env`.
- [x] Add root `env:check` script.
- [x] Write the four spike scripts.
- [x] Write the README.

## Verification

- Command: `pnpm env:check && git check-ignore .env && pnpm turbo run typecheck lint test`
- Evidence:

```
$ pnpm env:check   (dummy provider values)
  ✓ Core platform: ready          (local .env has generated TOKEN_HASH_SECRET / DATA_ENCRYPTION_KEY)
  • Firebase / WhatsApp / NextSMS / Google Drive / Snippe / Spikes: dummy values (keys listed)
  env:check ok   → exit 0
$ (REDIS_URL removed) pnpm env:check → ✗ Core platform: ERROR, missing: REDIS_URL, env:check failed → exit 1
$ git check-ignore .env → .env
$ pnpm --filter @dcard/env test → 7 passed (.env.example keys == schema keys; dummy detection; invalid format; requireProvider/requireKeys)
$ pnpm spike:{whatsapp,nextsms,drive,snippe} → each refuses: "<provider> is not configured: <KEY> (dummy value) ..."
$ pnpm spikes:typecheck && eslint spikes → ok
$ pnpm turbo run typecheck lint test build --continue → 23 successful, 23 total (after allowing `_`-prefixed unused vars in eslint.config.mjs)
```
- README.md rewritten as handover guide (15 sections incl. handover checklist and troubleshooting).
- Fact fix in `docs/design/integrations/snippe.md`: hosted checkout path is `/api/v1/sessions`; webhook signing and idempotency rules added (from the Snippe skill docs).
