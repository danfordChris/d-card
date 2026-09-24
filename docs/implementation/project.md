# Project Implementation — D-Card MVP

## Overview

- Deliver the MVP defined in `docs/design/domain/overview.md#release-scope` in ~16 weeks (8 two-week phases).
- Team: 3+ developers in three workstreams (below).
- Stack and codebase: `docs/adr/0003-technical-stack.md`, `docs/design/architecture/codebase.md`.

### MVP outcome

A host can run a real event end-to-end on D-Card:

1. Sign up, create an event (any type), choose a plan, **pay by mobile money (Snippe)**.
2. Add the committee and door staff. Add guests (form, Excel/CSV, phone contacts, copy from past event).
3. Record pledges and payments. **Cards are issued and sent automatically** (WhatsApp + SMS) on full payment. Cards can also be issued directly.
4. Customise messages (on/off, channel, wording, timing) within plan limits.
5. Guests open their card link (no login), RSVP, and confirm on WhatsApp with buttons. Basic-phone guests get SMS with the event contact.
6. Kawaida/Premium: card media, story page, guest gallery and slideshow in the **host's Google Drive**.
7. On the day, **D-Card Door** checks guests in online or **offline** (CRDT sync), with double cards, walk-ins and lockout.
8. The host watches a live dashboard. Everything is audited. Retention and privacy rules run automatically.

**Not in the MVP:** seating, menu, polls, programme, guest event history (Phase 2); automatic SMS replies, photo studio and catering packages (backlog); payment gateway for **contributions** and planner subscriptions (Phase 3).

## Current Priorities

- Phase 00 foundations: tasks T00-01 → T00-06 (T00-07 and T00-08 blocked).
- Start external approvals in week 1 (table below).

## Active Phases

- [ ] `docs/implementation/phases/phase-00-foundations.md` (in-progress)

## Deferred Phases

- [ ] `docs/implementation/phases/phase-01-events-guests.md`
- [ ] `docs/implementation/phases/phase-02-contributions-cards.md`
- [ ] `docs/implementation/phases/phase-03-messaging.md`
- [ ] `docs/implementation/phases/phase-04-confirmation-check-in.md`
- [ ] `docs/implementation/phases/phase-05-payments-media.md`
- [ ] `docs/implementation/phases/phase-06-completion.md`
- [ ] `docs/implementation/phases/phase-07-hardening-pilot.md`

## Dependencies

- Flutter SDK on build machines (blocks T00-07).
- Provider accounts and credentials: Meta, NextSMS, Google Cloud/Firebase, Snippe (block T00-08 and later phases).

### Workstreams

| Workstream | Owns | Typical people |
|------------|------|----------------|
| **A. Platform & backend** | `packages/core`, `db`, `integrations`, `apps/worker`, API routes, webhooks | 1–2 backend devs |
| **B. Web** | `apps/web` UI: host/committee dashboard, event wizard, message editor, admin panel, guest card pages, slideshow | 1 frontend/full-stack dev |
| **C. Mobile** | `apps/door`, `apps/mobile`, `dart_packages` | 1–2 Flutter devs |
| **Shared (rotating)** | External accounts and approvals (section 5), QA, release | Tech lead / PM |

**Working agreements:**
- **Contract first:** each feature starts with a PR to `api-contract` (reviewed by A, B and C). Mocks are generated from it so B and C aren't blocked.
- **Domain rules live only in `packages/core`** (never in route handlers or UI), with unit tests.
- **Every state-changing action writes an audit entry** (a helper in `core/audit`, enforced in code review).
- Feature flags for anything unfinished that has been merged.

### External tasks (start in week 1)

These gate the launch more than the code does. The tech lead owns this list.

| Task | Why it gates | Start by |
|------|-------------|----------|
| **Meta Business verification**, WhatsApp Business account, D-Card number + display name | Required to send at scale and to raise messaging limits | Week 1 |
| **WhatsApp templates** (sw + en, all NTF types, utility wording) submitted for approval | Approval and category decisions take days; wording may need rework | Week 3 (after the wording draft) |
| **NextSMS** account + **sender ID `DCARD` registration** | Sender IDs need registration before bulk SMS | Week 1 |
| **Snippe merchant onboarding (KYC)** | Needed for production payments | Week 1 |
| **Google Cloud project**: OAuth consent screen, Drive API, Sign-in; app verification | The consent screen must be verified for public users | Week 2 |
| **Apple Developer + Sign in with Apple**, **Google Play Console** | Store releases and Apple sign-in | Week 1 |
| **Domain + email sending** (SPF/DKIM) | Account emails | Week 1 |
| **Legal:** Personal Data Protection Act 2022 review, privacy notice, terms | Launch blocker (O3) | Week 2 |
| Firebase project (FCM) + APNs keys | Push notifications | Week 2 |

### Key technical risks

| Risk | Where it's handled | Mitigation |
|------|--------------------|-----------|
| Double admission across gates | Sprint 4 | Online: single conditional `UPDATE`. Offline: G-Set + over-use flag + host alert. Test with Testcontainers. |
| WhatsApp template rejection or marketing category | Sprints 0, 3 + external | Early spike, utility wording, category guard, SMS always sent too |
| WhatsApp messaging limits on a new number | Sprint 3 | Early verification, throttled queues, spread sending |
| Drive limits during the slideshow | Sprints 5, 7 | Thumbnails, browser cache, private-mode proxy, load test |
| Offline sync bugs | Sprint 4 | Idempotent entries, property tests for merge, field test with airplane mode |
| Payment webhook reliability | Sprint 5 | Idempotency keys, status polling fallback, reconciliation job |
| SMS cost overruns (2-segment messages) | Sprint 3 | Segment counter, plan caps, internal cost report |

### Definition of done

- Domain logic in `packages/core` with unit tests. API in the contract with the Dart client regenerated.
- Audit entries for state changes. Role checks per event.
- Swahili + English strings.
- Works on a slow 3G profile (guest pages) and small Android screens (apps).
- Feature documented in `docs/` if it changes a workflow.

## Linked Artifacts

- phases: `docs/implementation/phases/`
- tasks: `docs/implementation/tasks/` (index: `docs/implementation/tasks/backlog.md`)
- feature inventory: `docs/implementation/feature-inventory/README.md`
- status: `docs/implementation/status/weekly-status.md`
