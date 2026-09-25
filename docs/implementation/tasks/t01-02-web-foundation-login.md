# T01-02 — Web Foundation and Management Login

## Status

- `done`
- Last updated: 2026-09-24

## Linked Phase

- Phase: `docs/implementation/phases/phase-01-events-guests.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/auth/management-login.md`

## Agent Context

- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/auth.md`, `docs/design/integrations/firebase.md`, `docs/adr/0003-technical-stack.md`
- Constraints: Tailwind CSS only (no component library); `next-intl` Swahili + English; Firebase JS SDK for sign-in; httpOnly session cookie; fake auth only outside production; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/`, `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The web app has a Tailwind + sw/en shell, sign-up/login/email-verification/password-reset pages, and cookie sessions that API routes accept.

## Scope Boundary

**In scope:**
- `apps/web/src/app/(auth)/**`, `apps/web/src/app/(app)/layout.tsx`, `apps/web/src/app/layout.tsx`, `apps/web/src/app/globals.css`
- `apps/web/src/i18n/**`, `apps/web/messages/**`
- `apps/web/src/components/ui/**`
- `apps/web/src/lib/firebase-client.ts`
- `apps/web/src/app/api/v1/session/**`
- `apps/web/src/server/auth/**`
- `apps/web/src/proxy.ts`
- `packages/env/src/schema.ts` (if new keys)

**Out of scope:**
- Event and guest screens (T01-03, T01-05)

## Acceptance Criteria

- [x] `POST /api/v1/session` with a valid ID token sets an httpOnly, secure (in production), SameSite=Lax cookie and returns 204; `DELETE /api/v1/session` clears it.
- [x] API routes authenticate with either `Authorization: Bearer` or the session cookie (tests for both).
- [x] Unauthenticated requests to `/dashboard` redirect to `/login`.
- [x] `/login`, `/signup`, `/reset-password` render in Swahili and English (locale switch persists via cookie).
- [x] Shared Tailwind components (Button, Input, Field, Card, Alert) exist with keyboard focus styles.
- [x] `pnpm --filter @dcard/web build` passes.

## Dependencies

- T00-04 done.

## Implementation Checklist

- [x] Install Tailwind v4 and next-intl; set up locale messages.
- [x] Build base UI components.
- [x] Add Firebase client helper (config from `NEXT_PUBLIC_FIREBASE_*`).
- [x] Add session route + cookie verification (firebase-admin; fake in tests).
- [x] Add auth pages and protected app layout.
- [x] Tests + build.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

```
$ pnpm --filter @dcard/web test → 34 passed
  session.test: POST /api/v1/session → 204 + "dcard_session=…; HttpOnly; SameSite=Lax; Max-Age=432000" (no Secure outside production);
                invalid token 401, missing token 422; DELETE → Max-Age=0; API accepts cookie and bearer; tampered cookie 401;
                proxy: /dashboard without cookie → 307 /login?next=%2Fdashboard, with cookie → passes
  messages.test: sw/en same keys; locale cookie falls back to sw
  auth-ui.test (jsdom): Field aria wiring; LoginForm renders + validates in Swahili and English; Firebase error mapping
$ pnpm turbo run typecheck lint test build → 23 successful, 23 total (routes: /login, /signup, /reset-password, /dashboard, /api/v1/session, Proxy)
$ next start (production): /login sw "Ingia D-Card", en "Sign in to D-Card"; /dashboard no cookie → 307 /login;
  fake session refused (401) in production
$ next dev: session cookie → POST /api/v1/me 201 → /dashboard "Welcome, live@example.com" (en) / "Karibu, live@example.com" (sw)
```
- Shared components: Button, Input, Field, Card, Alert (`apps/web/src/components/ui`), focus-visible outlines.
- jsdom pinned to 29 (30 needs Node ≥ 24.15; local Node is 24.3).
