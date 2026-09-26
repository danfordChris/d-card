# Backlog

## Status

in-progress

## Objective

- Ordered list of MVP work by phase. Behavior lives in `docs/design/`; subfeatures in `docs/implementation/feature-inventory/`.

## Implementation Checklist

### P00

- [x] T00-01 Monorepo, CI and local infrastructure
- [x] T00-02 Database foundation
- [x] T00-03 Core utilities: phone, audit, roles
- [x] T00-04 API skeleton and account provisioning
- [x] T00-05 Worker runtime
- [x] T00-06 Dart core package
- [x] T00-07 Flutter workspace and app shells
- [x] T00-08 Environment config, spike scripts, README
- [x] T00-09 CI/CD: web + API to Vercel with Neon
- [ ] T00-10 Live integration spikes (blocked: provider keys)

### P01

- [x] T01-01 Events API
- [x] T01-02 Web foundation and management login
- [x] T01-03 Web event wizard, list, summary
- [x] T01-04 Guests API
- [x] T01-05 Web guest list
- [x] T01-06 Guest import and copy from past event
- [x] T01-07 Team invitations and members
- [x] T01-08 Mobile host login and events
- [x] T01-09 Mobile contacts import
- [x] T01-10 Admin event types

### P02

- [x] T02-01 Card issue, numbers, tokens, cancel/reinstate
- [x] T02-02 Pledges, payments, auto-upgrade and auto-issue
- [x] T02-03 Guest card page, RSVP, dietary and calendar
- [x] T02-04 Card image renderer
- [x] T02-05 Web contributions dashboard, payments, pledge edit, export
- [x] T02-06 Web direct card issue, cancel/reinstate, card link
- [x] T02-07 Mobile treasurer: contributors and record payment
- [x] Extra: API client keys (`X-API-Key`), local `AUTH_VERIFIER=dev`, root `.env` loading, `http/` API docs with JetBrains env files

### P03

- [x] T03-01 Messaging foundation: schema, templates, adapters, send queue, message log
- [ ] T03-02 Transactional messages: contribution request, thank-you, card, upgrade
- [ ] T03-03 Provider webhooks: delivery status, button replies, STOP, template category guard
- [ ] T03-04 Scheduled messages: reminders, confirmation, event reminder, thank-you, quiet hours, plan limits
- [ ] T03-05 Web message settings, SMS editor and test send
- [ ] T03-06 Manual send to groups and host message log
- [ ] T03-07 Admin WhatsApp template registry and provider rates
- [ ] T03-08 Push notification setup (device tokens, FCM sender)

### P04

- [x] Confirmations and check-in — `docs/implementation/phases/phase-04-confirmation-check-in.md`

### P05

- [ ] Payments and media — `docs/implementation/phases/phase-05-payments-media.md`

### P06

- [ ] Completion — `docs/implementation/phases/phase-06-completion.md`

### P07

- [ ] T07-01 Marketing site (started early, owner request 2026-09-25)
- [ ] Hardening and pilot — `docs/implementation/phases/phase-07-hardening-pilot.md`

### Owner requests (2026-09-25) — to design and schedule

Raised after reviewing the web app. Each needs a design decision (order, scope, prototype approval) before it becomes tasks.

- [ ] **App navigation and a polished UI.** App shell with a side navigation: My events (hosting and team roles), Events I'm invited to, Contributions overview across events, Card designs. Always-visible "New event" and a clear way back. Goal: an interface hosts love; research market apps first and approve a clickable prototype before building.
- [ ] **Card templates and picker.** Admin-managed templates per event type (EVT-5) and a host template picker with live preview; replaces the built-in design (ADR 0001 O20).
- [ ] **Google Drive folders created automatically.** When the host connects Google, create the event folders (card, story, gallery) with the private/link sharing choice (`docs/design/integrations/google-drive.md`). Planned in P05; owner expects it earlier.
- [ ] **Events I'm invited to.** Needs guest sign-in with Google/Apple linked to the Person (AUTH-3, GST-16 event history).
- [x] **"Host can only create one event"** — checked 2026-09-25: two events created back to back in the web wizard both appear on the dashboard. The reported block came from the broken sign-in (`/events/new` redirected to `/login`) and the missing navigation (covered above).

### Owner direction (2026-09-26) — UI/UX and cost

Proposal: `docs/changes/proposed/ui-design-system.md`; sources: `docs/research/ui-reference-projects.md`. Refinement work, scheduled after the owner answers the proposal's open questions (colours, starter pack, dark mode, prototype).

- [ ] **Design tokens, font and icons** — Plus Jakarta Sans, Hugeicons only (replace emoji/Material icons), colour/spacing/radius/type tokens in `dcard_ui` and web `@theme`; lint against hex literals and emoji icons; no decorative gradients/glows/shadows.
- [ ] **Shared component set** — mobile (from Notify): button, input family, search + filter sheet + active chips, card, status badge, detail rows, bottom sheet, confirm sheet, toast, empty/success views, layout shell, haptics. Web (from Solomon web): Button, inputs, Badge, Card, TableSection + typed table + pagination, Modal, SlideOver, ConfirmProvider, Toast, EmptyState, Skeleton, Tabs.
- [ ] **Clickable prototype for approval** — host app dashboard + event screen, web shell with side navigation (merges the 2026-09-25 "App navigation" request).
- [ ] **Roll out** — web shell and lists/forms, mobile shell and dashboard, door result screens, admin area; four states (loading/empty/no results/error) on every async surface.
- [ ] **Money flows** — review → confirm → receipt pattern for payments and plan checkout (P05), one currency formatter.
- [ ] **Worker hosting at lowest cost** — choose and set up the worker host (Railway or cheaper equivalent) with `NEXTSMS_LIVE`/`WHATSAPP_LIVE` only there; record monthly cost.
- [ ] **Service boundaries** — keep bounded contexts separable in `packages/core` (events, guests, contributions, cards, messaging, check-in, confirmations, admin); document which could split first when scaling.
