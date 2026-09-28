# T03-07 — Admin WhatsApp template registry and provider rates

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-03-messaging.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/notifications/whatsapp-templates.md`, `docs/implementation/feature-inventory/notifications/template-category-guard.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/notifications.md` (MSG-5, MSG-15), `docs/design/integrations/messaging.md`, `docs/design/data-models/postgres.md` (whatsapp_template, provider_rate)
- Constraints: admins only; templates are registered with their Meta name, language, category, editable parameters and status; submitting to Meta can be manual in the MVP (record the Meta name after approval); rates drive internal cost only; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths

## Assignment and Coordination (2026-09-25)

- Assigned to the second assistant (JetBrains IDE). Claude Code owns the rest of phase 03 (T03-05, T03-06, T03-08) and everything under `packages/core/src/messaging/**`, `apps/worker/**`, `packages/db/**` (schema and migrations).
- Work only in this task's in-scope paths. No schema or migration changes: `whatsapp_template` and `provider_rate` already exist (`packages/db/src/schema.ts`, migration `0010_messaging`). Read them through `@dcard/db`.
- Shared files: `apps/web/messages/en.json` / `sw.json` (add keys only under a new `adminMessaging` namespace), `packages/api-contract/src/index.ts` and `openapi.ts` (append only). Re-read a shared file immediately before writing it; never rewrite other sections.
- Do not change task statuses, the phase doc, the backlog or the feature inventory; report back instead. Claude Code records the evidence.
- Done means: the acceptance criteria below pass, with tests in `packages/core/test/admin-messaging.test.ts`, `apps/web/test/admin-messaging-api.test.ts` and a component test, and `pnpm turbo run typecheck lint test build` is green.

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Admins manage the WhatsApp template variants hosts can choose and the provider rates used for cost tracking.

## Scope Boundary

**In scope:**
- `packages/core/src/admin/messaging/**`
- `apps/web/src/app/api/v1/admin/whatsapp-templates/**`, `.../admin/provider-rates/**`
- `apps/web/src/app/(app)/admin/**` (templates, rates)

**Out of scope:**
- Automatic submission to Meta (later)

## Acceptance Criteria

- [x] Admins list/create/update template variants per message type and language with category and status; only approved, active, non-paused variants are offered to hosts.
- [x] Admins list/add provider rates with an effective date; cost estimates use the rate in force at send time.
- [x] Non-admins get 403; changes are audited; sw/en pages.

## Dependencies

- T03-01 done.

## Implementation Checklist

- [x] Core + API.
- [x] Admin pages.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-25 (built by the JetBrains assistant, verified by the lead): `pnpm turbo run typecheck lint test build --force` → 27/27 tasks.
  - Core `packages/core/test/admin-messaging.test.ts` (3 tests): non-admins forbidden; audited template create/update, hosts offered only approved + active variants (paused is a status, so excluded); audited effective-dated rates, cost uses the rate in force at send time (`messaging/cost.ts` `effectiveFrom <= at`).
  - Web `apps/web/test/admin-messaging-api.test.ts` (3 tests: 403, templates CRUD, rates with audit) and `admin-messaging-ui.test.tsx` (3 tests: sw render, status update with API key, add rate).
