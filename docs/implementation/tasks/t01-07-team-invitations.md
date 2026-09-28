# T01-07 — Team Invitations (link + email) and Members

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/auth/team-invitations.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/auth.md` (Team Invitation workflow, AUTH-8), `docs/design/integrations/email.md`, `docs/design/features/plans-and-billing.md` (door staff limits)
- Constraints: Invite token stored hashed, 7-day expiry, single use; door staff limited by plan; emails via worker queue; dummy Resend key skips sending; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

Hosts invite team members by shareable link and optional email, invitees accept after signing in, and hosts manage members.

## Scope Boundary

**In scope:**
- `packages/db` migration (`team_invite`)
- `packages/core/src/team/**`
- `packages/core/src/queues/**` (email queue)
- `packages/integrations/email/**` or `apps/worker/src/processors/email.ts`
- `apps/web/src/app/api/v1/events/[id]/team/**`, `apps/web/src/app/api/v1/invites/**`
- `apps/web/src/app/(app)/events/[id]/team/**`, `apps/web/src/app/invite/**`
- `packages/env/src/schema.ts`, `.env.example` (`RESEND_API_KEY`, `EMAIL_FROM`)

**Out of scope:**
- WhatsApp/SMS invite sending

## Acceptance Criteria

- [x] `POST /api/v1/events/{id}/team/invites` (host only) returns 201 with a one-time link; the stored token is hashed; with an email, one `team-invite` job is enqueued.
- [x] Door staff invites beyond the plan limit (Msingi 2, Kawaida 5) return 409 `plan_limit`.
- [x] `POST /api/v1/invites/{token}/accept` by a signed-in user grants the role for that event only; a reused, revoked or expired token returns 410.
- [x] `GET /api/v1/events/{id}/team` lists members and pending invites; `DELETE` removes a member or revokes an invite; all actions audited.
- [x] The worker email processor skips with a logged reason when `RESEND_API_KEY` is dummy, and calls Resend otherwise (tested with a mocked fetch).
- [x] Web: team screen (invite, copy link, revoke, remove) and `/invite/{token}` accept page work in sw/en.

## Dependencies

- T01-02 and T01-03 done.

## Implementation Checklist

- [x] Schema + core team module with tests.
- [x] Email queue + Resend adapter + worker processor.
- [x] API routes.
- [x] Web team screen and accept page.
- [x] Env keys + docs.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- `pnpm turbo run typecheck lint test build` → 23/23 tasks successful (2026-09-24).
- Core: team invite create/accept/revoke/remove + door-staff plan limit covered in `packages/core` tests (58 passing).
- Worker: Resend sender skips dummy key; bilingual `teamInviteEmail`; email processor (5 passing).
- Web API `test/team-api.test.ts`: link `https://dcard.test/invite/<token>`, one `team-invite` job when email given, accept once then 410, unknown 404, revoked 410, door staff over Msingi limit 409 `plan_limit`, host-only listing/removal.
- Web UI `test/team-ui.test.tsx` (6): sw labels, email validation, create + copy link, plan-limit message, revoke + remove, accept → `/events/{id}`, gone → invalid message. Web total 70/70.
- Manual: `/invite/not-a-real-token` renders the not-found message on the dev server.
- `validate_workflow.py` → WORKFLOW:ok.
