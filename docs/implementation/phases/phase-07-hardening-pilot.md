# Phase 07 — Hardening and pilot (weeks 15–16)

## Status

- `pending`
- Last updated: 2026-09-24

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

- [ ] T07-01 — Marketing site (`docs/implementation/tasks/t07-01-marketing-site.md`) — started early at the owner's request
- [ ] Break the rest of the scope into task files before the phase starts (vertical slices, per `task-spec.md`).

## Acceptance Criteria

- [ ] All phase items verified.
- [ ] Every linked task is `done` with verification evidence.
- [ ] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- Previous phase not done.

## Linked Tasks

- docs/implementation/tasks/t07-01-marketing-site.md
