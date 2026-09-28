# Phase 07 — Hardening and pilot (weeks 15–16)

## Status

- `in-progress`
- Last updated: 2026-09-27

## Objective

- All phase items verified.

## Scope

- **Load tests:** 1,000 guests, 4 gates checking in concurrently (online + offline); slideshow on Drive in both sharing modes; message fan-out within WhatsApp limits.
- **Security review:** auth and roles per event, token hashing, webhook signatures, Drive scope, encrypted Door cache, OWASP checks.
- **Pilot:** 2–3 real events (e.g. a kitchen party + a wedding) with friendly hosts, on production with real providers.
- Fix-only period; store submissions; launch checklist.

---

## Included Features

- Hardening covers all features.

## Task Checklist

- [x] T07-01 — Marketing site (`docs/implementation/tasks/t07-01-marketing-site.md`) — started early at the owner's request
- [x] Break the rest of the scope into task files (T07-02…T07-05).
- [x] T07-02 load tests · T07-03 security review · T07-04 launch checklist (review: `docs/implementation/reviews/2026-09-27-phase-07-review.md`)
- [ ] T07-05 pilots (owner: hosts, dates, launch checklist)

## Acceptance Criteria

- [ ] All phase items verified.
- [ ] Every linked task is `done` with verification evidence.
- [ ] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- Phases 05/06 wait only on owner setup and the staging deploy; pilots (T07-05) need production providers live.

## Linked Tasks

- docs/implementation/tasks/t07-01-marketing-site.md
- docs/implementation/tasks/t07-02-load-tests.md
- docs/implementation/tasks/t07-03-security-review.md
- docs/implementation/tasks/t07-04-launch-checklist.md
- docs/implementation/tasks/t07-05-pilot-events.md
