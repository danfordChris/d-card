# D-Card – Messaging Provider Research (O1)

**Date:** 24 September 2026
**Decision already made:** SMS provider = **NextSMS** (nextsms.co.tz).

---

## 1. What D-Card needs from messaging

| Need | Channel | Direction |
|------|---------|-----------|
| Contribution request, thank-you, reminders, card, event reminder | SMS + WhatsApp | Outbound |
| Card image with QR code | WhatsApp | Outbound (media template) |
| Attendance confirmation: Approve / Decline | WhatsApp | Outbound + **inbound answer** |
| Attendance confirmation: reply `1` / `0` | SMS | Outbound + **inbound reply** |
| Delivery status (for retries, costs, host visibility) | Both | Inbound webhook |

The **inbound** parts are what limit the provider choice.

---

## 2. NextSMS: what it offers

Source: NextSMS pricing page, Mobile SMS page, and the official Postman API documentation (base URL `https://messaging-service.co.tz`).

### 2.1 Products and prices
| Product | How it works | Price (TZS / message) |
|---------|-------------|-----------------------|
| **Internet SMS** | Bulk SMS from a registered **sender ID** (e.g. `DCARD`) | 16 (1–5k) · 15 (5k–50k) · 14 (50k–100k) · 13 (100k–250k) · 12 (250k–500k) · 10.5 (500k–2M) |
| **Mobile SMS** | Sends from **real SIM cards** in an Android phone running the NextSMS Mobile Agent app. Recipients see a normal phone number and can reply. | 5 flat |
| **WhatsApp SMS** | Template messages through a WhatsApp Business account connected to NextSMS | 12 **+ Meta's fee** |

### 2.2 API capabilities (from the API docs)
| Capability | Supported? |
|------------|-----------|
| Send single / multiple SMS (sender ID) | ✅ `POST /api/sms/v2/text/single`, `/multi` |
| Scheduled sending | ✅ |
| Send via SIM (Mobile SMS) | ✅ `POST /api/mobile/v2/text/single`, `/multi` |
| WhatsApp **template** messages with personalisation, image/PDF header, buttons (copy code, OTP, URL) | ✅ `POST /api/whatsapp/v2/text/single` |
| WhatsApp template with a **QR code drawn onto the image** (`qr_code_url` personalisation with position/size) | ✅ Useful for invitation cards |
| Delivery reports | ✅ **Webhook** (Delivery Callback URL + verify token, set in the dashboard) or polling `GET /api/v2/reports` |
| Balance check | ✅ `GET /api/v2/balance` |
| Test endpoint (no sending) | ✅ for WhatsApp |
| **Incoming SMS (replies) by webhook/API** | ❌ **Not documented.** Mobile SMS replies appear in the NextSMS **dashboard inbox** only. |
| **Incoming WhatsApp messages / button answers** | ❌ Not documented |
| **WhatsApp Flows** | ❌ Not documented |

### 2.3 What this means for D-Card
- ✅ NextSMS covers **all outbound SMS** well: sender ID, bulk, scheduling, delivery webhooks.
- ⚠️ **SMS replies (`1`/`0`) cannot reach D-Card automatically today.** Sender-ID SMS cannot be replied to at all. Mobile SMS replies can be received, but only in the NextSMS inbox, with no documented webhook.
- ⚠️ Sending bulk SMS through **SIM cards** (Mobile SMS) is cheap, but it depends on an Android phone staying online, and operators may throttle or block SIMs used for bulk sending. It should not carry critical messages such as cards.
- ❌ NextSMS WhatsApp can send cards, but **cannot receive confirmations**, so it cannot handle the Approve/Decline step.

---

## 3. WhatsApp options

| | **Meta WhatsApp Cloud API (direct)** | **NextSMS WhatsApp** |
|---|---|---|
| Cost | Meta rate only | TZS 12 + Meta rate |
| Templates with image/document | ✅ | ✅ (plus built-in QR overlay) |
| Receive messages and button answers (webhook) | ✅ | ❌ not documented |
| Interactive quick-reply buttons | ✅ | Partly (buttons on templates; answers not returned) |
| WhatsApp Flows | ✅ | ❌ |
| Setup | Meta Business verification, phone number, template approval, webhook | Done through the NextSMS dashboard |
| Vendor | Meta directly | Local support, same account as SMS |

### Meta pricing (Tanzania = "Rest of Africa" market on Meta's rate card)
- Meta charges **per delivered template message**, by category and country.
- Reported "Rest of Africa" rates: **marketing ≈ US$0.0225**, **utility ≈ US$0.004**. ⚠️ Confirm against Meta's official rate-card CSV before pricing, because Meta has been moving countries out of "Rest of" regions during 2026.
- **Utility templates sent while a customer-service window is open are free** (Meta docs).
- ⚠️ **Conflicting information:** The Citizen (Tanzania) reports that from **1 October 2026**, business replies inside the 24-hour window will also be charged for Tanzanian numbers. Meta's pricing page does not list Tanzania for that date. **Confirm before launch.**
- **Category matters:** cards, payment thank-yous and event reminders should be approved as **utility**. A contribution request (asking for money) may be classed as **marketing** by Meta, which costs about 5× more. Template wording should be written with this in mind.

---

## 4. Options for SMS replies (`1` / `0`)

| Option | How | Pros | Cons |
|--------|-----|------|------|
| **A. Ask NextSMS for inbound** | Ask whether they offer an incoming-SMS webhook, a two-way short code or a long number | One provider, one bill | Unknown until they answer |
| **B. NextSMS outbound + second provider for inbound** | Send from `DCARD` via NextSMS. The text says "Reply 1 or 0 to **15XXX**" (a short code or long number rented from a two-way provider, e.g. Africa's Talking or Beem) | Reliable, fully automatic | Two providers; guest replies to a number different from the sender; short code has setup and monthly fees |
| **C. NextSMS Mobile SMS for confirmations only** | Send the confirmation SMS from a SIM so guests can reply, and read replies from NextSMS | Cheap (TZS 5), guest replies to the same number | No inbound API documented; depends on a phone staying online; operator blocking risk |
| **D. Drop SMS replies** | Basic-phone guests are never asked to confirm (they are counted at the 70% no-response rate) | Simplest | Loses the confirmation for basic-phone guests (goes against "nobody left out") |

---

> **Decision (24 Sep 2026):** automatic SMS replies are moved to the **backlog**. In the MVP, every SMS includes the **event contact** (name + phone set when the event is created). Basic-phone guests confirm by calling or texting that person, and the host/committee records the answer. NextSMS outbound alone is enough for the MVP. Because of the contact line, keep SMS templates short so they fit in one 160-character segment.

## 5. Recommendation

1. **SMS outbound:** **NextSMS Internet SMS** with a registered sender ID (e.g. `DCARD`) for all SMS. Use the delivery-report webhook.
2. **SMS replies:** **ask NextSMS first (option A).** If they have no inbound webhook, use **option B** (a second provider only for the reply number). Build the Notification module with separate `SmsSender` and `SmsReplyReceiver` interfaces so either works without code changes elsewhere.
3. **WhatsApp:** **Meta WhatsApp Cloud API directly.** It is the only option that returns Approve/Decline answers (Flows or quick-reply buttons) and it avoids NextSMS's TZS 12 per-message markup. NextSMS WhatsApp stays a fallback for send-only use.
4. **Decided (24 Sep 2026):** use **quick-reply buttons** (Approve / Decline) on a template instead of a WhatsApp Flow. They do the same job for a two-choice answer, are easier to build and review, and work the same way through the webhook. Flows are still possible later.

### Questions to send to NextSMS
1. Do you offer **incoming SMS** (a two-way short code or long number) with a **webhook** to our server? What are the setup and monthly costs?
2. Is there an **API or webhook for replies received on Mobile SMS**?
3. What is the **sender ID registration** process and cost, and how long does it take?
4. What is the sending throughput (messages per second) for Internet SMS?
5. Are you an official Meta **BSP**, and do you (or will you) support WhatsApp **incoming messages, buttons and Flows**?

---

## 6. Rough messaging cost per guest

Assumptions: one invitation per guest; about 8 messages over the event (contribution request, 2 thank-yous, 2 reminders, card, confirmation, event reminder); **sent on both channels** (decision Q9/O8); 1 SMS segment each at TZS 15; WhatsApp utility ≈ US$0.004 ≈ TZS 10–11 (exchange rate to confirm).

| Item | Per message | × 8 messages |
|------|-------------|--------------|
| SMS (NextSMS, 1 segment) | ~TZS 15 | ~TZS 120 |
| WhatsApp (Meta utility) | ~TZS 10–11 | ~TZS 85 |
| **Total per guest** | | **≈ TZS 200** |

- If SMS messages run over **160 characters** (e.g. card details with names and venue), each one costs 2 segments, and the total rises to about **TZS 320**.
- **Avoid emojis and special characters in SMS.** They switch the encoding and cut the limit to 70 characters per segment.
- If Meta classes the contribution request as marketing, add roughly TZS 50 per guest.
- Compared with competitors charging **TZS 1,000–1,800 per card**, this leaves room for margin. This feeds into the pricing proposal (O2).

---

## Sources
- [NextSMS – Pricing](https://nextsms.co.tz/pricing/)
- [NextSMS – Mobile SMS](https://nextsms.co.tz/service/mobile)
- [NextSMS – Home](https://nextsms.co.tz/)
- [NextSMS – API documentation (Postman)](https://documenter.getpostman.com/view/1679195/2sAYkDP1XN)
- [Meta – Pricing on the WhatsApp Business Platform](https://developers.facebook.com/documentation/business-messaging/whatsapp/pricing)
- [The Citizen – WhatsApp charges: new fees to affect Tanzanian businesses](https://www.thecitizen.co.tz/tanzania/business/whatsapp-charges-new-fees-to-affect-tanzanian-businesses-5580516)
- [Authgear – WhatsApp API pricing explained (2026)](https://www.authgear.com/post/whatsapp-api-pricing/)
- [Africa's Talking – Two-way SMS](https://africastalking.com/sms/twowaysms)
