# T04-07 — Live event dashboard and printable backup list

## Status

- `done`
- Last updated: 2026-09-26

## Linked Phase

- Phase: `docs/implementation/phases/phase-04-confirmation-check-in.md`
- Feature-inventory subfeature(s): `docs/implementation/feature-inventory/events/event-dashboard.md`, `docs/implementation/feature-inventory/check-in/printable-backup-list.md`

## Agent Context

- Owner: Subagent (web)
- Skills: `vercel:nextjs`
- Design docs: `docs/design/features/events.md` (dashboard), `docs/design/features/check-in.md` (CHK-9, CHK-10)
- Constraints: live updates by Server-Sent Events with automatic reconnect (Vercel function time limits), falling back to polling; host and committee only; the backup list is a print-friendly page with names, card numbers, type and table, sorted by name; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution); phone numbers stored as `255` + 9 digits; sw/en for every user-facing string; web UI Tailwind only
- Do not touch: `docs/design/` (except recording adopted decisions), `.agents/workflows/`, other tasks' in-scope paths, task statuses (the lead records them)

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

The host watches check-ins against the expected headcount live, with device sync status and alerts, and can print a backup guest list.

## Scope Boundary

**In scope:**
- `apps/web/src/app/api/v1/events/[id]/dashboard/**`
- `apps/web/src/features/dashboard/**`
- `apps/web/src/app/(app)/events/[id]/dashboard/**`, `.../backup-list/**`
- `packages/core/src/checkin/dashboard.ts`
- `dashboard` namespace in `apps/web/messages/{en,sw}.json`

**Out of scope:**
- Contribution dashboard changes (phase 02 views stay)

## Acceptance Criteria

- [x] The dashboard shows admitted vs expected, confirmation breakdown, pending walk-ins, devices with unsynced entries and last sync, over-used and lockout alerts.
- [x] Updates arrive within a few seconds of a check-in without reload (SSE, reconnecting).
- [x] The backup list prints cleanly (A4, sw/en).
- [x] Tests cover the dashboard numbers and the stream endpoint.

## Dependencies

- T04-01, T04-02, T04-03 and T04-06 done.

## Implementation Checklist

- [x] Dashboard service + API.
- [x] SSE stream.
- [x] Dashboard page.
- [x] Backup list page.
- [x] Tests + pipeline.

## Verification

- Command: `pnpm turbo run typecheck lint test build`
- Evidence:

- 2026-09-26 (built by a web subagent, verified by the lead): `pnpm turbo run typecheck lint test build --force` → 27/27 tasks (core 147, web 174).
  - Core `packages/core/test/dashboard.test.ts`: admitted split card/walk-in and online/offline, expected headcount (GST-14 via `calculateConfirmationSummary`), cards issued/checked in/not arrived, walk-ins pending/needing review, stale device (pending > 0 and last sync > 10 min), over-used and 24 h lockout alerts, backup list sorted by name.
  - Web `apps/web/test/dashboard-api.test.ts` (JSON for host/committee, 403 others, stream answers `text/event-stream` with a first `event: dashboard` frame) and `dashboard-ui.test.tsx` (numbers, alerts, sw, host-only revoke).
  - Live updates: SSE stream re-checks every 3 s, sends only when the payload `version` changes, pings every 15 s and ends after ~50 s (client reconnects; polling fallback every 10 s). The browser reads it with `fetch()` because `EventSource` cannot send the required `X-API-Key` header.
  - Backup list: A4 print page (small print `<style>` for page size; seating table column waits for GST-15, P2).
  - Browser check 2026-09-26 on the local dev server (demo event: 6 cards, 2 gates, offline sync with an over-used card, pending + offline walk-ins, a lockout): dashboard numbers, alerts and devices table render in sw; admitting a guest through the API updated the open page without reload (7 → 8 admitted, 125 % → 143 %, new device listed); backup list sorted by name with EAT date. Deployed-app check waits for Firebase sign-in on `api.dcard.danfordchris.dev`.
