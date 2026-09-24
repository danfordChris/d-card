# D-Card Domain Overview

## Context

- Product: D-Card, self-service digital invitation cards for events in Tanzania (formerly "Mwaliko").
- Source: approved decisions of 24 Sep 2026 (see `docs/adr/`).

## Purpose
D-Card is a self-service platform for **digital event invitation cards**. It lets a host and their committee (kamati):

- collect and track contributions (michango),
- issue digital cards (single or double) **automatically once a contribution is fully paid**,
- know who is coming (RSVP, attendance confirmation, expected headcount),
- control entry at the door, online or offline,
- give guests everything they need on the day: programme, table, menu, venue and photos.

## Event Types
**Any event type.** Examples: wedding, send-off, kitchen party, birthday, graduation, other. The admin manages the list of event types, and each type can have its own card templates and message wording. Every feature works the same for all types.

## Guiding Principles
| # | Principle | Meaning |
|---|-----------|---------|
| P1 | Nobody is left out | Invitation, confirmation and entry must work on a **basic phone** (SMS only). |
| P2 | One event at a time | Every message, answer, card and payment belongs to exactly **one event**. |
| P3 | Online-first, offline-capable | The server is the authority whenever it can be reached. The door app keeps working without network and syncs later (`docs/design/architecture/offline-sync.md`). |
| P4 | Keep costs low | **No media storage on D-Card servers** (photos and videos live in the host's Google Drive), no OTP logins, modular monolith first. |
| P5 | Everything is traceable | Important actions are written to an append-only audit log. |
| P6 | Keep only what is needed | Guest data without an account is anonymised 2 weeks after the event (`docs/design/features/privacy-and-audit.md`). |

## Out of Scope
- Holding or moving money. D-Card only **records** payments made outside the platform.
- Payment gateway integration (Phase 3).
- **All-in-one event packages** with a photo studio and catering (food and drinks) from partner vendors: **backlog**.
- Creating WhatsApp groups (the API does not support it).

## Users and Roles
Roles are assigned **per event**. The same person can be treasurer at one event and a guest at another.

| Role | Client | Login | Summary of permissions |
|------|--------|-------|------------------------|
| **Host** | Web, D-Card app | Email + password | Full control of their event: settings, cards, guests, contribution amounts, **recording payments**, committee and staff, walk-in approvers, confirmations, headcount, seating, menu, programme, polls, photo link, walk-in approvals, cancelling and reinstating cards, the event audit log. |
| **Treasurer** (kamati), **one or more per event** | Web, D-Card app | Email + password | Record payments and refunds, view the contributions dashboard, send balance reminders. |
| **Committee member** (kamati) | Web, D-Card app | Email + password | Add contributors and pledges, view the contributions dashboard, send reminders. **Cannot** record payments. |
| **Walk-in approver** | D-Card app | Email + password | Approve or refuse walk-in requests. Named by the host (e.g. MC, head of committee). |
| **Door staff** | **D-Card Door app** (primary), Web | Email + password | Check guests in (QR, card number, name) online or offline, Admit 1 / Admit 2, send walk-in requests, view attendance counts. |
| **Guest – smartphone** | Web, D-Card app | **None needed to view the card.** Optional Google/Apple sign-in. | **Without login (through the card link):** view the card, QR code, date, venue, programme, table and menu, **RSVP, dietary needs**, confirm attendance, add to calendar. **With login:** polls and song requests, event details saved to their account, and an event history they can come back to in future. |
| **Guest – basic phone** | SMS | None | Receive SMS (each includes the **event contact**), call or text the contact person with questions or to confirm attendance, enter using the card number. |
| **Admin** (platform) | Web | Email + password + 2FA | Platform management, support, event types, templates, pricing, monitoring, all audit logs. |

## Core Concepts
| Concept | Definition |
|---------|-----------|
| **Person** | A real human, identified by phone number (`255XXXXXXXXX`). Platform-wide. |
| **User account** | A login. Email/password for management roles, Google/Apple for guests. Linked to a Person for guests. |
| **Registered guest** | A guest whose Person record is linked to a user account (they signed in at least once). They keep an event history. |
| **Event** | One event of any type, owned by a host. |
| **Event role** | A user's role in one event: treasurer, committee member, door staff or walk-in approver. |
| **Invitation** | The link between one Person and one Event. **At most one per person per event.** It holds the card, RSVP, confirmation, pledge, entries and table, plus a host-owned snapshot of the guest's name and phone. |
| **Card type** | `single` = 1 entry, `double` = 2 entries. Can change **before** issue (auto-upgrade). **Never changes after issue.** |
| **Card number** | `NNN-PPPP`: 3-digit guest sequence within the event + random 4-digit PIN. Example `005-4827`. |
| **QR token** | Long random token encoded in the QR code. |
| **Link token** | Long random token in the guest's card link. |
| **Pledge (ahadi)** | A contributor's promised amount and card type. |
| **Payment record** | One payment (or refund) toward a pledge, recorded by a treasurer or the host. |
| **Extra contribution** | Money paid beyond the pledge amount. |
| **Event contact** | The name and phone number of the person guests should contact about the event (e.g. the host or committee chair). Set when the event is created and **included in every SMS**. |
| **Reply window** *(backlog)* | The period during which an SMS `1`/`0` from a phone is applied to one specific invitation. |
| **Entry** | One admission at the door (1 or 2 people). It gets a globally unique ID **created on the device**, so the same entry can be synced safely more than once. |
| **Over-used card** | A card whose recorded entries exceed its allowance. This can only happen through offline check-ins at several gates. |
| **Walk-in** | A person admitted without a valid card, or beyond their card's entries, with approval. |

## Release Scope

| Release | Scope |
|---------|-------|
| **MVP (Phase 1)** | Auth and per-event roles · any event type with templates · Person/Invitation, all 4 ways of adding guests · contributions with auto-upgrade, auto-issue, refunds · cards, cancel/reinstate · D-Card Door with online + offline check-in and CRDT sync, lockout, walk-ins · WhatsApp + SMS messaging (every SMS includes the event contact), WhatsApp confirmations, manual confirmation recording, headcount · message customisation · plans and Snippe payment · card media, story page, guest gallery, slideshow (host's Google Drive) · audit logs · retention job · privacy basics |
| **Phase 2** | Seating, menu, dietary export, polls, programme/countdown, guest event history |
| **Phase 3** | Payment gateway for contributions, planner subscriptions and analytics, splitting into services if needed |
| **Deferred (backlog)** | Automatic SMS replies (`1`/`0`) with reply windows · all-in-one packages with partner photo studios and caterers |
