# Attendance Confirmation

## Context

- WhatsApp quick-reply buttons; SMS guests confirm by contacting the event contact.

## Workflow: Attendance Confirmation
- Optional per event. Default timing is 2 days before.
- **WhatsApp:** a utility template with two **quick-reply buttons**, **Approve / Decline** (Swahili: *Nitahudhuria / Sitahudhuria*). Each button's payload is set when sending and carries an opaque token for **one invitation** (e.g. `cnf:<token>:yes`), so the answer always maps to the right guest and event. Meta's webhook returns the payload when the guest taps. **The first answer counts.** Later taps get a short "answer already recorded" reply.
- After a tap, D-Card sends a short acknowledgement (*"Asante, tumepokea jibu lako"*) inside the 24 h window that the tap opened.
- **SMS (MVP):** an **information SMS** asking the guest to confirm by calling or texting the **event contact**. SMS replies are **not processed automatically** in the MVP (see W7, backlog).
- The **host or a committee member** records answers received by phone, and can override any status manually (audited).
- Example SMS: *"Harusi ya Juma & Neema, Sat 12 Dec, Diamond Hall. Kadi yako: 005-4827 (Double). Thibitisha kuhudhuria: piga/tuma SMS kwa Asha 0754 123 456."*
- **Non-responders are assumed to be coming and are never blocked at the door.**

## Requirements
| ID | Requirement | Pri |
|----|-------------|-----|
| CNF-1 | Optional per event, default 2 days before. | M |
| CNF-2 | WhatsApp: Approve/Decline, first answer counts. SMS: information message asking the guest to contact the event contact. | M |
| CNF-3 | Host or committee records confirmations received by phone, and can override any status (audited). | M |
| CNF-4 | SMS reply `1`/`0` with reply windows, queuing (24 h expiry), "Please reply 1 or 0", stray replies logged and ignored. | Backlog |
| CNF-5 | Non-responders never blocked at the door. | M |

## Confirmation States
`not_sent → sent → approved | declined` (first answer, either channel), or `sent → no_response` on expiry. The host override can set any value.

## Deferred: SMS Reply Routing (backlog)
Kept for later, once an inbound SMS number is available (NextSMS or a second provider).
1. A confirmation SMS opens a reply window for **(phone, invitation)**.
2. Only **one open window per phone** at a time. An incoming `1`/`0` applies to that window's invitation.
3. Confirmations from other events for the same phone **wait in a queue** until the window is answered or expires (default 24 h).
4. A window closes when answered by SMS **or by WhatsApp**. Then the next queued confirmation is sent.
5. A `1`/`0` with **no open window is logged and ignored**. No reply is sent. The host can see it in the message log.

## Deferred: SMS Reply Window States (backlog)
`queued → open → answered | expired`. At most one `open` per phone.
