# Pilot runbook

> Task: `docs/implementation/tasks/t07-04-launch-checklist.md`. Pilots: `docs/implementation/tasks/t07-05-pilot-events.md`. Go-live list: `docs/launch/launch-checklist.md`. Door behavior: `docs/design/features/check-in.md`. Last checked: 2026-09-27.

Use one copy of this runbook per pilot event. Pilots run on production with real providers, so every message and payment is real.

- **Owner** = the business owner (talks to the host, handles money and support).
- **Lead** = the lead developer (checks the system, fixes issues).
- **Host** = the pilot event's host.

Before the first pilot, the launch checklist must be signed off, including the WhatsApp messaging limit (item 1.4). The limit must be above this event's guest count.

## Event sheet

| | |
|---|---|
| Event name / type | |
| Date, start and end time (EAT) | |
| Venue, number of gates | |
| Host name, phone (`255` + 9 digits) | |
| Expected guests / cards | |
| Plan and amount paid | |
| Door staff (names, phones) | |
| Walk-in approvers | |
| Owner on site? Lead on call? | |

---

## T-14 days

| # | Step | Who | How to verify |
|---|---|---|---|
| 1 | **Host onboarding.** Host signs up on the web or the D-Card app, creates the event, adds treasurer/committee if any. Walk them through once by phone or in person. | Owner with host | Event appears in Admin → Events with the right date and time zone. |
| 2 | **Plan checkout.** Host picks a plan for the guest count and pays by mobile money. | Host, Owner watches | Admin → Billing shows the payment `completed`; event shows as paid. If pending over 1 h, see incident 2. |
| 3 | **Guest import with consent.** Host adds guests from contacts or file, ticks the consent box, and confirms they have told guests they will receive a card. Phones stored as `255` + 9 digits. | Host, Owner helps | Guest count matches the host's list. No rejected rows left unexplained. |
| 4 | **Card design.** Host picks the design, text, Single/Double, tables. Optional: connect Google Drive for story and gallery. | Host, Owner reviews | Card preview looks right in sw and en. If Drive is used, one test photo shows on the card page. |
| 5 | **Test send to the host's own phone.** Send the invitation to the host only, on WhatsApp and SMS. | Owner | Host receives both. Card link opens, QR shows. Confirmation buttons work and the answer shows on the dashboard. |
| 6 | Take a manual backup of the database (launch checklist 4.4). | Lead | Backup file or Neon branch with today's date. |

## T-7 days

| # | Step | Who | How to verify |
|---|---|---|---|
| 1 | **Message schedule check.** Review message settings: invitation send time, confirmation, reminder (1 day before, 09:00), contribution reminders, thank-you (off by default; marketing cost). | Owner with host | Each scheduled message shows the expected date and channel. Estimated cost looks right. |
| 2 | **Invitations sent** (if not already). Watch the first batch. | Owner, Lead | Admin → Queues: `whatsapp` and `sms` queues drain; failed count stays near 0. Delivery failures listed per guest. |
| 3 | **Door staff invited.** Host invites door staff and walk-in approvers by email. | Host | Each invite accepted; staff appear as members with the right role. |
| 4 | **Door devices registered.** Each staff member installs D-Card Door (internal testing / TestFlight), signs in, opens the event. | Owner with staff | Event dashboard lists one device per gate. |
| 5 | **Offline drill.** On each device: open the event online, switch to airplane mode, scan 2 test cards, admit, then go back online. Use test guests added for this (for example the owner and the host); entries cannot be undone, so never use real guests' cards. | Owner with staff | "N waiting to sync" goes to 0 after reconnect. Entries show on the dashboard with their original times. |
| 6 | Walk-in drill: staff send one test walk-in; host approves on the app. | Owner | Push arrives on host and approvers; decision shows on the door device. |
| 7 | Print the backup guest list with card numbers and give it to the host. | Host | Paper list exists at the venue. |

## Event day

| # | Step | Who | How to verify |
|---|---|---|---|
| 1 | **Gate setup** 1 hour before. Phones charged, power bank, mobile data on, camera works. Gate name set on each device. | Owner / door staff | Each device scans a test QR. |
| 2 | **Sync check.** Each device online, last sync under 1 minute. | Owner | Dashboard device table shows every gate recently synced. |
| 3 | **Check-in.** Scan QR first; card number or name search if the QR fails. Admit 1 or Admit 2. Refusals: fully used, cancelled, not found. | Door staff | Admitted count on the dashboard rises. |
| 4 | **Walk-ins.** Staff send a request; the host or an approver decides. If the device is offline, staff may admit with a written reason; it syncs as "needs review". | Door staff, host | Walk-ins show on the dashboard; offline ones are reviewed after the event. |
| 5 | **Live dashboard.** Host or owner watches attendance vs expected, device sync, alerts (lockouts, over-used cards). | Owner | Dashboard updates without reload. |
| 6 | **If the network drops:** keep scanning. The app checks cards from its encrypted local copy and syncs later. Do not sign out (unsynced entries warn). If a device fails completely, use another device or the paper list. | Door staff | After reconnect, "waiting to sync" goes to 0. Over-used cards (two gates admitting the same card offline) show as alerts; host reviews them later. |
| 7 | **Incident contacts** on one card at each gate: owner phone, lead phone, host phone. | Owner | Staff can name who to call. |

## After the event

| # | Step | Who | How to verify |
|---|---|---|---|
| 1 | **Thank-you messages** (NTF-8) only if the host turned them on and the plan allows. Sent 1 day after, 10:00. | Owner checks | Admin → Queues shows them sent; cost recorded. |
| 2 | Host reviews offline walk-ins and over-used cards. | Host | No items left "needs review". |
| 3 | **Retention.** At 14 days after the event, the daily 03:00 job anonymises guests without an account. Door device caches wipe 24 h after the event. | Lead | Day 15: guest names for this event are masked; registered guests keep their link; audit log has the retention run. |
| 4 | **Feedback** within 3 days (questions below): host and 5 guests (mix of WhatsApp and SMS-only guests). | Owner | Answers recorded in the pilot notes. |
| 5 | **Metrics** collected (table below). | Owner, Lead | Pilot notes filled in. |
| 6 | New issues filed for the fix-only period. | Lead | Each issue has an owner and priority. |

### Feedback questions

Host:
1. How easy was it to set up the event and add guests? (1–5)
2. Was the price clear and fair?
3. Did guests get their cards? Any complaints?
4. How did the door go? Any queue or confusion?
5. Would you use D-Card again or recommend it? Why?

Guests (5):
1. Did you receive the card? On WhatsApp, SMS or both?
2. Was it clear what to do with it?
3. How fast was entry at the gate?
4. Anything confusing or wrong?

### Metrics to collect

| Metric | Where |
|---|---|
| Guests invited | Event dashboard / guest list |
| Cards issued (Single / Double) | Event dashboard |
| Check-ins (people admitted), walk-ins, refusals | Live dashboard / audit log |
| Messages sent per channel, and cost | Admin → Cost report |
| Delivery failures (WhatsApp failed, SMS undeliverable) | Admin → Cost report / message log per guest |
| Time per check-in | Door audit timestamps (median gap per gate at peak), plus a stopwatch on 10 guests |
| Offline entries and over-used cards | Dashboard alerts |
| Issues found (what, when, fix) | Pilot notes |

---

## Incidents

Where to look:

| Tool | Shows |
|---|---|
| Admin → Queues | Waiting, active, delayed, failed jobs per queue; retry failed jobs |
| Sentry | New errors from API and worker (no personal data) |
| Vercel → `dcard-web` → Logs | API and webhook requests; search by `x-request-id` |
| Railway → `worker` → Logs | Sends, provider errors, alerts |
| Alert email (`ALERT_EMAIL`) | >100 waiting jobs, >10 failed in an hour, payment pending >1 h |

| # | Problem | Steps | Who |
|---|---|---|---|
| 1 | **Messages not sending** | 1. Check the event is paid (unpaid events keep messages in the outbox). 2. Admin → Queues: jobs waiting and none active → worker is down; check Railway worker logs and redeploy. 3. Many failed → open one job; check Railway logs. WhatsApp errors: token expired, template not approved or paused (re-categorised), messaging limit reached (WhatsApp Manager). SMS errors: NextSMS balance or sender ID. 4. Check `WHATSAPP_LIVE` / `NEXTSMS_LIVE` are set on the worker. 5. Fix, then retry failed jobs from Admin → Queues. If WhatsApp is blocked, send by SMS only for this event. | Lead; Owner for provider dashboards |
| 2 | **Payment pending** | 1. Ask the host if they confirmed the USSD prompt with their PIN. 2. Snippe dashboard: is the payment there, and its status? 3. Vercel logs for `/api/webhooks/snippe`: 401 means wrong `SNIPPE_WEBHOOK_SECRET`. 4. The worker also polls Snippe; check Railway logs. 5. If Snippe says paid but D-Card does not after 1 h, tell the lead; do not ask the host to pay again. If the payment failed, the host starts a new checkout. | Owner, Lead |
| 3 | **Door app revoked by mistake** | The revoked device signs out and its cache is wiped (unsynced entries on it are lost). 1. Host checks the dashboard device list. 2. Staff sign in again on the device and open the event; it registers again. 3. Meanwhile use another gate's device or the paper list. 4. Revoke only lost or stolen phones. | Host, Owner |
| 4 | **Drive disconnected** | Guests see the card without missing media; the host sees a reconnect prompt. 1. Host reconnects Google Drive from the event's media page. 2. If Google refuses, check the OAuth consent screen (test users / published) and the redirect URI. 3. Deleted files in Drive cannot be restored by D-Card; host re-uploads. | Host, Owner; Lead for OAuth |
| 5 | **API down or bad deploy** | Vercel instant rollback (launch checklist section 12). Door devices keep working offline meanwhile. | Lead |

After any incident: note what happened, time, impact, fix, in the pilot notes.
