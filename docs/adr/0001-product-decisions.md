# ADR 0001 — Product Decisions (MVP)

## Date

2026-09-24

## Decision

### Carried over from the Mwaliko spec
| Topic | Decision |
|-------|----------|
| QR codes | Random token checked by the server (online) or against the local cache (offline) |
| Guests at many events | One Person, separate Invitation per event |
| SMS replies for several events | One open reply window per phone, others queued (**moved to backlog**) |
| Phone format | `255XXXXXXXXX` |
| Card type | Never changes once issued |
| Headcount | 70% default, host-adjustable |
| Wrong card numbers | Locked after 3 attempts for 5 minutes |
| Photos | ~~Only a Google Photos link~~ **Replaced:** card media, story pages and a guest gallery on Kawaida/Premium, **stored in the host's Google Drive** (O14). The Google Photos link stays available on all plans. |
| WhatsApp groups | Not supported; individual messages with quick-reply buttons |
| Login | Email/password for management; Google/Apple for guests |
| Double cards | Two separate entries; Admit 1 / Admit 2 |
| Architecture | Modular monolith first |

### Decided on 2026-09-24
| # | Topic | Decision |
|---|-------|----------|
| — | Name | **D-Card** (was Mwaliko) |
| — | Stack | Next.js (web + backend), Flutter (mobile), PostgreSQL, Redis |
| Q1 | Event types | **Any event type**, admin-managed |
| Q2 | Card trigger | **Card auto-issued and sent when fully paid.** No separate confirm step. |
| Q3 | Duplicates | **At most one invitation per person per event** |
| Q4 | Payments | **Host + one or more treasurers** record payments |
| Q5 | Pledge vs payment | **Auto-upgrade Single → Double** before issue when total paid ≥ Double amount |
| Q6 | Cancellation | **Payments kept; refunds recorded; card can be reinstated** |
| Q7 | Stray SMS replies | **Logged and ignored** |
| Q8 | Network failure | **Offline check-in in the app with CRDT-based sync.** Reverses the earlier "online-only" decision. |
| Q9 | Channels | **Always send on both WhatsApp and SMS** |
| Q10/11 | Providers | **SMS: NextSMS** (user choice). WhatsApp: Meta Cloud API direct (recommended; see research) |
| Q12 | Adding guests | **Form, Excel/CSV, phone contacts, copy from past event**, all in the MVP |
| Q13 | Data law | **Build privacy basics now; confirm with a lawyer before launch** |
| Q14 | Walk-ins | **Host + named approvers; first answer decides** |
| Q15 | Hosting | **Managed cloud:** Vercel (Cape Town) + managed worker + managed Postgres + managed Redis |
| Q16 | Mobile apps | **Two apps: D-Card and D-Card Door** |
| Q17 | Guest login | **No login needed to view the card.** Login keeps event history. **Non-registered guests are anonymised 2 weeks after the event.** |
| Q17b | Host records | **Anonymise the guest, keep the host's records** |
| Q18 | Pricing | Research and propose (after provider costs are known) |
| O4 | Guest login | **RSVP and dietary needs through the card link without login; polls and event history need login** |
| O5 | Offline walk-ins | **Staff admit with a mandatory reason; host/approver reviews after sync (accept or flag)** |
| O6 | Manual pledge edits | **Host and treasurers can edit amount and card type before issue** (audited) |
| O7 | Auto-upgrade setting | **Per-event setting, on by default** |
| O8 | Dual sending | ~~Always both~~ **Superseded by O9:** both channels is the **default**; the host can change the channel per message. |
| O10 | WhatsApp sender | **One D-Card WhatsApp Business number for all events now** (verified business, display name "D-Card"); hosts' own numbers later (planners). |
| O11 | Host billing | **Flat price per guest**, with all normal messages included. No message credits. Cost is bounded by plan limits (MSG-12). |
| O2 | Plans and prices | **Msingi Tsh 1,000 · Kawaida Tsh 1,500 · Premium Tsh 2,000 per guest card.** Msingi includes contributions without reminders or auto-upgrade, and no photos/videos. Kawaida and Premium include card media, story page and guest gallery (Premium: longer storage, longer videos, slideshow). Min Tsh 50,000/event, extra guests in blocks of 10, full payment before sending, 20% off the first event. See `docs/design/features/plans-and-billing.md`. |
| O14 | Media storage | **Host's Google Drive** via the Drive API (`drive.file`). Direct uploads from devices to Drive; D-Card stores only file IDs. Pixieset rejected (no public API); Google Photos rejected (API sharing removed March 2025). |
| O15 | Drive folder sharing | **Host chooses per event** when creating it: **private** (default; D-Card serves media only to valid card links, pays a little bandwidth) or **anyone with the link** (served directly by Drive). |
| O16 | Payment gateway (host plan payments) | **Snippe** (snippe.sh): USSD push on M-Pesa, Airtel Money, Mixx by Yas, Halotel; hosted checkout incl. cards; 2.5% per mobile-money payment, no monthly fee; webhooks + idempotency. Payouts available for Phase 3 contributions. |
| O17 | Authentication | **Firebase Auth** for all logins; **Postgres + Drizzle** for all data, including roles and per-event permissions (keyed by Firebase UID). |
| O13 | Photo studio and catering packages | **Backlog:** future all-in-one packages with partner photo studios and caterers. |
| O12 | WhatsApp consent | **Host confirms guests agreed to receive messages; every WhatsApp message offers STOP; stopped guests get SMS only.** |
| O9 | Message control | **Full message customisation per event:** on/off, channel, wording (SMS full text; WhatsApp through approved template variants + editable parts), timing and frequency, quiet hours, cost estimate, test send, manual send. **Which controls and how many messages are available depends on the subscription plan.** The invitation card cannot be turned off. |
| O1b | WhatsApp confirmation | **Quick-reply buttons** (Approve / Decline) with a per-invitation payload. WhatsApp Flows are not used. |
| O1a | SMS replies | **Backlog.** Every SMS includes the **event contact** (set at event creation); basic-phone guests confirm by calling/texting them, and the host/committee records it. |

## Reason

- Each decision was approved by the product owner in the requirements sessions of 2026-09-24, after market and provider research (`docs/research/`).

## Impacted Docs

- `docs/design/domain/overview.md`
- `docs/design/features/*`
- `docs/design/integrations/*`
