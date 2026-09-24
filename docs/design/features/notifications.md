# Notifications and Message Customisation

## Context

- Providers: NextSMS (SMS), Meta WhatsApp Cloud API. See `docs/design/integrations/messaging.md`.

## Messages
**Default:** every guest message is sent on **both WhatsApp and SMS**. The host can change this for each message (`docs/design/features/notifications.md`), within what their plan allows.

| ID | Message | Trigger (default) | Default channels | Host can turn off? | Pri |
|----|---------|-------------------|------------------|--------------------|-----|
| NTF-1 | Contribution request | Contributor added | WhatsApp + SMS | Yes | M |
| NTF-2 | Thank-you + balance | Payment recorded | WhatsApp + SMS | Yes | M |
| NTF-3 | Contribution reminder | Every 2 weeks, balances only | WhatsApp + SMS | Yes | M |
| NTF-4 | **Invitation card** | Auto-issue or direct issue | WhatsApp + SMS | **No** (at least one channel is required) | M |
| NTF-5 | Card upgraded to Double | Auto-upgrade | WhatsApp + SMS | Yes | M |
| NTF-6 | Attendance confirmation | 2 days before, 10:00 (if confirmation is on) | WhatsApp quick-reply buttons + SMS (contact the event contact) | Yes | M |
| NTF-7 | Event reminder | 1 day before, 09:00 | WhatsApp + SMS | Yes | M |
| NTF-8 | Thank-you after the event | 1 day after, 10:00 | WhatsApp + SMS | Yes (**off** by default) | M |
| NTF-9 | Walk-in request | Staff request | Push to host + approvers | No | M |
| NTF-10 | Lockout / over-used card alerts | Event | Push to host | No | M |
| NTF-11 | Account emails | Sign-up, reset, role invitations | Email | No | M |

Rules: **every SMS includes the event contact** (name + local-format phone) · SMS text kept to plain GSM characters (no emojis) · Meta-approved templates for WhatsApp outside the 24 h window · every message logged with cost per event · automatic retries · language per Person (sw/en).

## Message Customisation
The host controls **every guest message** for their event: while creating the event (a "Messages" step, pre-filled with defaults) and at any time afterwards. **The subscription plan decides which of these controls are available** and how many messages are included (`docs/design/features/plans-and-billing.md`).

| ID | Requirement | Pri |
|----|-------------|-----|
| MSG-1 | **On/off per message** (NTF-1 to NTF-8). The invitation card (NTF-4) cannot be turned off. | M |
| MSG-2 | **Channel per message:** WhatsApp, SMS or both. The card must go on at least one channel. The host is warned that **WhatsApp-only** messages will not reach basic-phone guests. | M |
| MSG-3 | **SMS wording:** the host edits the full text in Swahili and English, using placeholders (`{guest_name}`, `{event_title}`, `{date}`, `{time}`, `{venue}`, `{card_number}`, `{card_type}`, `{table}`, `{amount_paid}`, `{balance}`, `{payment_details}`, `{contact_name}`, `{contact_phone}`, `{card_link}`). | M |
| MSG-4 | **SMS editor checks:** a live character and segment counter (160 per segment), a warning for characters that break GSM encoding (emojis, curly quotes), unknown placeholders blocked, `{contact_phone}` required (it can't be removed), preview with a sample guest. | M |
| MSG-5 | **WhatsApp wording:** WhatsApp messages must use **Meta-approved templates**, so the host (a) chooses from the approved template variants for that message type (e.g. formal, friendly, religious) and (b) fills the editable parts inside them (e.g. a personal note, up to about 200 characters). Admins create new variants and submit them to Meta. Free-text WhatsApp wording is not possible. | M |
| MSG-6 | **Timing:** send time for scheduled messages (confirmation, event reminder, post-event thank-you), expressed as "N days before/after" plus a time of day in the event time zone. | M |
| MSG-7 | **Frequency:** contribution reminders every N days/weeks, with an optional maximum count and an optional stop date (e.g. stop 3 days before the event). | M |
| MSG-8 | **Quiet hours:** no guest messages between 21:00 and 07:00 by default (the host can adjust within limits). Messages due in quiet hours are delayed to the next allowed time. | M |
| MSG-9 | **Plan usage view:** while editing settings, the host sees which controls their plan allows and how close they are to its limits (e.g. reminders used, manual sends left). **Internally**, D-Card estimates and records the real messaging cost per event (by channel, Meta category and SMS segments) so admins can track margin per plan. | M |
| MSG-10 | **Send a test** of any message to the host's own phone before publishing. | M |
| MSG-11 | Changes apply to messages **not yet sent**. Scheduled jobs are rescheduled when timing changes. Every settings change is audited. | M |
| MSG-12 | **Plan limits (flat per-guest pricing):** each plan sets which controls are unlocked and the limits that bound messaging cost: max contribution reminders per contributor, max SMS segments per message, max manual sends per event, whether marketing-category messages (post-event thank-you) are allowed, and the guest limit. Locked controls are shown with an upgrade prompt. **The invitation card is always sent.** | M |
| MSG-14 | **WhatsApp consent:** when adding or importing guests, the host confirms the guests agreed to receive event messages (stored and audited per event). Every WhatsApp message offers **STOP**. A guest who stops gets **SMS only** for that event (the card still arrives by SMS), and the host sees who stopped. | M |
| MSG-15 | **Template category guard:** D-Card stores the category Meta approved for each template and re-checks it (template-status webhook). If a utility template is re-categorised as marketing, sends using it pause and admins are alerted. | M |
| MSG-13 | **Manual send:** the host can send a chosen message now to all guests or a filtered group (e.g. unpaid, not confirmed), within plan limits. | M |
