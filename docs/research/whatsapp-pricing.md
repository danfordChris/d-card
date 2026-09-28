# D-Card – WhatsApp Pricing Analysis (Meta, effective 1 October 2026)

**Date:** 24 September 2026
**Inputs:** Meta's rate card "Cost per message in USD on the WhatsApp Business Platform, effective October 1, 2026" (Excel + PDF, including the volume-tier pages), Meta's pricing documentation, and The Citizen (Tanzania).

---

## 1. How Meta charges

### 1.1 The basics
| Rule | What it means for D-Card |
|------|--------------------------|
| **Charged per delivered message**, not per conversation | A WhatsApp message to a guest who isn't on WhatsApp (e.g. a basic-phone guest) **is not delivered and costs nothing**. So "send on both channels" does **not** double the WhatsApp bill for basic-phone guests. |
| **Price depends on the recipient's country + the template category** | All our guests are `+255`, so Tanzania is the only market we pay for. |
| **Tanzania = "Rest of Africa"** on the rate card | It has no standalone country rate. |
| **Categories:** Marketing, Utility, Authentication, and (new from 1 Oct 2026) **Service** | Each template is approved into a category, and **the business pays the category applied at the time of sending**. Meta can change a template's category. |
| **Business-initiated messages must be templates** | Every message D-Card starts (card, reminder, confirmation) is a template. Free-form text is only possible inside a 24 h customer-service window opened by the guest. |

### 1.2 Tanzania rates from 1 October 2026 (Rest of Africa, USD per delivered message)
| Category | USD | ≈ TZS* | Used by D-Card for |
|----------|-----|--------|--------------------|
| **Marketing** | **0.0225** | **≈ 58.5** | Anything Meta sees as promotional (risk: contribution request, post-event thank-you) |
| **Utility** | **0.0040** | **≈ 10.4** | Payment receipts, balance reminders, card/ticket, confirmation, event reminder |
| Authentication | 0.0040 | ≈ 10.4 | Not used (no OTP logins) |
| **Service** (new) | **0.0040** | **≈ 10.4** | Free-form replies inside the 24 h window, e.g. "Asante, tumepokea jibu lako" after a button tap |

\* Using **1 USD ≈ TZS 2,600** as a planning assumption. The exchange rate must be a configurable setting.

> **Marketing costs 5.6× more than utility.** Getting templates approved as **utility** is the biggest single cost lever.

### 1.3 The "Service" change (what's new on 1 October 2026)
- Until now, messages inside the 24 h customer-service window were **free**.
- The new rate card adds a **Service** price (US$0.004 for Rest of Africa). The Citizen reports that Tanzanian businesses will be charged for replies inside the window from 1 Oct 2026, which matches it.
- ⚠️ Meta's pricing documentation page still says that non-template messages and utility templates inside an open window are free. **The two sources conflict.** Plan with the rate card (i.e. assume we pay), and check the first invoices in WhatsApp Manager after 1 October.
- **Impact on D-Card:** small. The only in-window message we send is the acknowledgement after a guest taps Approve/Decline (about Tsh 10 each). The host can turn it off.

### 1.4 Volume tiers (utility & authentication only)
Rest of Africa, **utility**, messages per calendar month, counted across the **whole business portfolio**:

| Messages / month | Rate (USD) | Discount |
|------------------|-----------|----------|
| 0 – 100,000 | 0.0040 | list |
| 100,001 – 1,000,000 | 0.0038 | −5% |
| 1,000,001 – 4,500,000 | 0.0036 | −10% |
| 4,500,001 – 40,000,000 | 0.0034 | −15% |
| 40,000,001 – 80,000,000 | 0.0032 | −20% |
| 80,000,001+ | 0.0030 | −25% |

- Tiers reset at the start of each month. Only **charged** messages count. Marketing has **no** tiers.
- Because tiers are counted per portfolio, **one D-Card WhatsApp account for all hosts** pools every event's volume and reaches the discounts sooner. Example: 100 events/month × 300 guests × ~4 utility messages ≈ 120,000 → the 5% tier.
- The discounts are small, so they're a bonus rather than something to plan around.

---

## 2. Mapping D-Card messages to Meta categories

| D-Card message | Target category | Risk | How to keep it utility |
|----------------|-----------------|------|------------------------|
| NTF-1 Contribution request | Utility (target) | **High:** asking for money can look promotional | Word it as a **confirmation of a pledge the contributor already made**: "Ahadi yako ya Tsh 100,000 kwa Harusi ya Juma & Neema imerekodiwa. Lipa kwa M-Pesa 07xx…". This matches how committees work (pledges are collected first, then recorded). No persuasive or promotional wording. |
| NTF-2 Thank-you + balance | Utility | Low | A payment receipt |
| NTF-3 Contribution reminder | Utility | Medium | A balance due on an existing pledge, stated as facts. Frequency limits apply (MSG-7). |
| NTF-4 Invitation card | Utility | Low–Medium | Framed as an **entry pass/ticket** with card number, QR, date and venue |
| NTF-5 Card upgraded | Utility | Low | An update to an existing card |
| NTF-6 Attendance confirmation (buttons) | Utility | Low | A confirmation request about an existing invitation |
| Acknowledgement after a tap | Service | — | Free-form text inside the window |
| NTF-7 Event reminder | Utility | Low | An event/appointment reminder |
| NTF-8 Post-event thank-you | **Marketing** (likely) | High | It has no transaction behind it. It's **off by default**, and if the host turns it on we price it as marketing. |

**Rule for the admin:** every template variant (MSG-5) is written and reviewed for its target category before submission. D-Card records the category Meta approves and **re-reads it before sending** (Meta can re-categorise). If a utility template is re-categorised as marketing, sending pauses and the admin is alerted.

---

## 3. What a guest costs D-Card (default settings, both channels)

Assumptions: SMS via NextSMS ≈ Tsh 15 per 160-character segment; WhatsApp as above; 2 payments and 2 reminders per contributor; confirmation on; post-event thank-you off.

### 3.1 Contributor guest (pledges, pays, gets a card)
| Message | WhatsApp | SMS |
|---------|----------|-----|
| Contribution request | 10.4 (utility) / **58.5 (if marketing)** | 15 |
| 2 × thank-you + balance | 20.8 | 30 |
| 2 × balance reminder | 20.8 | 30 |
| Invitation card | 10.4 | 15 |
| Attendance confirmation | 10.4 | 15 |
| Acknowledgement after tap (service) | 10.4 | — |
| Event reminder | 10.4 | 15 |
| **Total** | **93.6** (≈ 141.7 if NTF-1 is marketing) | **120** |
| **Per guest, has WhatsApp** | **≈ Tsh 214** (≈ 262 worst case) | |
| **Per guest, basic phone only** | **Tsh 120** (WhatsApp not delivered, so not charged) | |

### 3.2 Guest with a card issued directly (no contribution)
Card + confirmation + acknowledgement + reminder: WhatsApp ≈ 41.6 + SMS 45 = **≈ Tsh 87** (SMS only: Tsh 45).

### 3.3 Example event: 300 invitations
200 contributors and 100 direct cards, 80% of guests on WhatsApp, 1-segment SMS, worst case (NTF-1 marketing):

| Group | Guests | Cost each | Total |
|-------|--------|-----------|-------|
| Contributors on WhatsApp | 160 | 262 | 41,900 |
| Contributors, basic phone | 40 | 120 | 4,800 |
| Direct cards on WhatsApp | 80 | 87 | 6,950 |
| Direct cards, basic phone | 20 | 45 | 900 |
| **Event total** | 300 | | **≈ Tsh 54,500 (≈ Tsh 182 per invitation)** |

**Sensitivity:**
- **2-segment SMS** (messages over 160 characters) add about +Tsh 120 per contributor and +45 per direct guest. The event total rises to about **Tsh 83,000**. *Keeping SMS within 160 characters matters more than anything on the WhatsApp side.*
- If NTF-1 is approved as utility, the event total falls by about Tsh 7,700.
- Competitors charge **Tsh 1,000–1,800 per card**, so our messaging cost is roughly **10–20% of the market price**.

---

## 4. Other Meta rules that affect the design

| Rule | Impact | What we do |
|------|--------|-----------|
| **Opt-in required.** WhatsApp policy requires recipients to have agreed to receive messages from the business. | Hosts upload guest lists we have never contacted. | The host confirms (checkbox on add/import, stored with the event) that guests agreed to receive event messages. Every WhatsApp message lets guests stop messages (a "STOP" reply or button). Stopped guests get SMS only (the card is still sent by SMS). |
| **Quality rating and blocks.** Many blocks or reports lower the number's quality and can restrict sending. | One bad host could hurt every event on a shared number. | Frequency caps (MSG-7, MSG-8 quiet hours), monitor the quality rating via webhook, and automatically slow a host's event if blocks spike. |
| **Messaging limits.** A new business number can only start conversations with a limited number of unique users per 24 h. The limit grows with business verification and good quality. | A 1,000-guest event can't send every card at once on a new number. | Complete **Meta business verification before launch**. The worker **throttles** sends per the current limit and queues the rest (the Redis queue already supports this). |
| **Delivered-only charging** | Undelivered messages cost nothing. | Debit host credits for WhatsApp when **Meta confirms delivery** (status webhook), not at send time. SMS is debited per segment at send (NextSMS charges on send). |
| **Rates change** (country moves, category changes, new charges like Service) | Hard-coded prices go stale. | A **provider rate table** with effective dates, updated by the admin. Message logs store the rate used. |
| **Billing in USD** (TZS is not a Meta billing currency) | Exchange-rate risk. | Charge hosts in TZS with an **FX buffer (~10–15%)** and review the table monthly. |

---

## 5. What D-Card should do (recommendations)

1. **Decided: one D-Card WhatsApp Business account** (verified business, display name "D-Card") sends for all events. Pooled volume, one set of templates, simple onboarding. *(Hosts bringing their own WhatsApp number can come later.)*
2. **Utility-first templates:** every guest message is written as a transactional update (pledge confirmation, receipt, balance, entry pass, reminder). Only the post-event thank-you is marketing.
3. ~~Credits in TZS~~ **Decided: flat price per guest** (all normal messages included). D-Card carries the messaging cost and bounds it with plan limits (max reminders, max SMS segments, max manual sends, marketing messages only on the top plan). The per-type costs above feed the internal margin tracking and the per-guest price in O2.
4. **Internal cost tracking (MSG-9)** uses these per-type costs, SMS segment counts, and the share of guests on WhatsApp to show admins the margin per event and per plan.
5. **Later optimisation:** when a guest's 24 h window is already open (e.g. they just tapped Approve), send any pending utility message inside it, since the docs say that's free. This only saves money if Meta keeps utility templates free inside the window after 1 October.

---

## 6. Still to confirm
- Whether messages inside the window are charged for Tanzania from 1 October 2026 (rate card says yes, docs say no). Check actual invoices after 1 October.
- The categories Meta actually approves for our templates, especially NTF-1 (submit them early).
- The current TZS/USD rate for the rate table.
- The current messaging-limit steps for a newly verified business.

## Sources
- Meta rate card, effective 1 October 2026 (Excel "Facebook Data Export" and PDF provided by the user), including volume tiers for Rest of Africa
- [Meta – Pricing on the WhatsApp Business Platform](https://developers.facebook.com/documentation/business-messaging/whatsapp/pricing#rate-cards-effective-october-1-2026)
- [The Citizen – WhatsApp charges: new fees to affect Tanzanian businesses](https://www.thecitizen.co.tz/tanzania/business/whatsapp-charges-new-fees-to-affect-tanzanian-businesses-5580516)
- [NextSMS – Pricing](https://nextsms.co.tz/pricing/)
