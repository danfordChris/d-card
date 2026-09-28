# T04-03 — Confirmations, manual recording and expected headcount

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-04-confirmation-check-in.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/attendance-confirmation/whatsapp-buttons.md`, `docs/implementation/feature-inventory/attendance-confirmation/manual-confirmation.md`, `docs/implementation/feature-inventory/attendance-confirmation/sms-contact-confirmation.md`, `docs/implementation/feature-inventory/guests-and-cards/expected-headcount.md`

## Agent Context

- Owner: JetBrains assistant
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/attendance-confirmation.md` (CNF-1…CNF-3, CNF-5), `docs/design/features/guests-and-cards.md` (GST-14)
- Constraints: the first WhatsApp answer counts; later taps get a short "answer already recorded" reply and change nothing; acknowledgement is sent inside the 24 h window; host or committee can record or override any status (audited); non-responders are never blocked; headcount: approved 100 %, no response = event `headcount_pct`, declined 0 %, Double counts 2; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); phone numbers stored as `255` + 9 digits; sw/en for every user-facing string; web UI Tailwind only
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Assignment and Coordination (2026-09-26)

- Assigned to the second assistant (JetBrains IDE). Claude Code owns check-in and walk-ins (`packages/core/src/checkin/**`, `apps/web/src/app/api/v1/door/**`), `packages/db/**` (schema and migrations), `apps/worker/**`; subagents own `apps/door/**`, `apps/mobile/**` and `apps/web/src/features/walk-ins/**` for now.
- Work only in this task's in-scope paths. No schema change is needed: `invitation.confirmation_status/_at/_source` and `event.headcount_pct` already exist. If you need one, stop and report it.
- The WhatsApp side is done by the lead (2026-09-26): the first answer counts (conditional update on `confirmation_status = 'none'`), and the acknowledgement / "answer already recorded" replies go out as free-form text in the 24 h window (queue `whatsapp`, job `reply`). Do not change `packages/core/src/messaging/**`; manual records and overrides write `confirmation_source = 'host'`.
- Shared files: `apps/web/messages/en.json` / `sw.json` (new `confirmations` namespace only), `packages/api-contract/src/index.ts` and `openapi.ts` (append only), `apps/web/src/app/(app)/events/[id]/page.tsx` (one link next to Messages). Re-read a shared file immediately before writing it.
- Do not change task statuses, the phase doc or the feature inventory; report back instead. Claude Code records the evidence.
- Done means: the acceptance criteria below pass with tests (`packages/core/test/confirmations.test.ts`, `apps/web/test/confirmations-api.test.ts`, a component test) and `pnpm turbo run typecheck lint test build` is green.

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Confirmations follow the first-answer rule with acknowledgements, the host and committee can record and override answers, and the event shows its expected headcount.

## Scope Boundary

**In scope:**
- `packages/core/src/confirmations/**`
- `apps/web/src/app/api/v1/events/[id]/confirmations/**`
- `apps/web/src/features/confirmations/**`
- `apps/web/src/app/(app)/events/[id]/confirmations/**`
- `confirmations` namespace in `apps/web/messages/{en,sw}.json`

**Out of scope:**
- SMS reply routing (CNF-4, backlog)
- Check-in code (T04-01/02)

## Acceptance Criteria

- [x] A second WhatsApp tap does not change the first answer and queues a short "answer already recorded" reply; the first answer queues the acknowledgement. (Lead, 2026-09-26: `apps/web/test/webhooks.test.ts`, `apps/worker/test/messaging.test.ts` "confirmation replies".)
- [x] `PUT /api/v1/events/{id}/confirmations/{guestId}` lets host or committee set yes / no / none with an audit entry; treasurers and strangers get 403.
- [x] `GET /api/v1/events/{id}/confirmations` returns counts by state and the expected headcount per GST-14.
- [x] The web page lists guests by confirmation state with filters and a record/override action, in sw/en.
- [x] Tests cover first answer, override, headcount maths (single/double, percentage).

## Dependencies

- Phase 03 done.

## Implementation Checklist

- [x] First-answer + replies (lead).
- [x] Record/override service + API.
- [x] Headcount service + API.
- [x] Web page.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-26 (built by the JetBrains assistant, verified and adjusted by the lead): `pnpm turbo run typecheck lint test build --force` → 27/27 tasks (core 147, web 174).
  - Core `packages/core/test/confirmations.test.ts` (3 tests): host and committee record/override with source `host` and an audit entry per change; expected headcount GST-14 (yes 100 %, none = event %, no 0 %, Double = 2); treasurers and strangers forbidden. Web `apps/web/test/confirmations-api.test.ts` (3) and `confirmations-ui.test.tsx` (2, sw render, override updates the headcount).
  - WhatsApp first answer + acknowledgement / "already recorded" replies: lead (webhooks and worker tests).
  - Lead fixes: routes and admin pages imported core through `../packages/core/dist/...` paths → `@dcard/core` exports (also T03-07 admin pages); contract moved to `packages/api-contract/src/confirmations.ts`; expected headcount counts issued cards only (same basis as the dashboard).
