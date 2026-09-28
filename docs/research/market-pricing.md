# D-Card – Market Pricing Analysis (O2)

**Date:** 24 September 2026
**Purpose:** see how Tanzanian digital-invitation providers price their services before setting D-Card's price per guest (decision O11: flat price per guest, all normal messages included).

---

## 1. Competitor prices (Tanzania, public websites, September 2026)

| Provider | Model | Price | What drives the higher tiers | Service type |
|----------|-------|-------|------------------------------|--------------|
| **Kadijanja** | Per card | **Basic 1,000 · Standard 1,500 · Premium 2,000 · Executive 2,500** | Verification calls and check-in (Standard) · **pledge reminders (3×)** and reminder SMS (Premium) · event webpage (Executive). Minimum 200 cards on some tiers. Scanner 35,000 or their app. | Mixed |
| **RedPoint** | Per card | **White 1,500 · Black 2,000 (best-selling) · Red 2,500** | SMS caps: **6 / 12 / 18 SMS per recipient** · fundraising SMS and reminder calls (Black) · **pledge cards**, unlimited SMS, reception help (Red) | **Self-service** web + app |
| **Sherehe Digital** | Per card issued (**single or double, same price**) | **Silver 2,000 · Bronze 2,500 · Diamond 3,500 · Platinum 4,000** | Message bundles (2,000 SMS + 1,000 WhatsApp … unlimited) · **security staff and ushers** | Done-for-you with staff. Extras: SMS 30, WhatsApp 300 per message. 50% deposit. |
| **Golden eCards** | Per package | **350k/250 cards (1,400 each) · 450k/300 (1,500) · 650k/400 (1,625, most popular) · 950k/500 (1,900) · 1.3M/600 (2,167)** · extra cards **1,500** | **Contribution campaign** from the "Premium" package up · scanners/receptionists → ushers (6–10) | Done-for-you with staff |
| **Hamia Digital** | Per card | About **1,000–1,800** (from the original spec; site unreachable) | Thank-you SMS, printed data sheet | Done-for-you |
| **M-Kadi** | **Commission on contributions** (not disclosed) | — | Online pledges and mobile-money collection | Platform |
| **Foras Tech** | Quote only | — | — | Custom |

### 1.1 Patterns
1. **Charging per card is the norm** (the host already thinks "how many cards?"). Sherehe charges **the same price for single and double cards**.
2. **The market runs from Tsh 1,000 to 2,500 per card** for software-led offers. Prices above 2,500 include **people** (ushers, security).
3. **The most popular tier is around Tsh 1,500–2,000** (RedPoint Black 2,000, Golden Premium ≈ 1,625, Kadijanja Standard/Premium).
4. **Contribution (michango) features sit in the upper tiers** everywhere: Kadijanja Premium, RedPoint Black/Red, Golden Premium+. It's what hosts pay extra for.
5. **Tiers are separated by message volume** (SMS per recipient, reminder counts) and **human services**, not by software features.
6. **Minimum sizes** (e.g. 200 cards) and **deposits** (50%) are common for done-for-you services.
7. Nobody publicly charges a commission on contributions except M-Kadi, and that's because M-Kadi actually collects the money.

---

## 2. D-Card's position

| | Competitors | D-Card |
|---|---|---|
| Service type | Mostly done-for-you (staff, ushers, calls) | **Self-service.** No staff costs; the host and committee run it. |
| Contributions | Upper tiers; mostly reminders only | **Full michango module:** pledges, receipts, balances, **automatic card on full payment**, auto-upgrade |
| Door | Their scanners/staff | **D-Card Door app** with offline check-in; the host's own people scan |
| Basic phones | SMS with serial number | SMS card number + event contact in every SMS |
| Messaging | Capped SMS counts | WhatsApp + SMS on every message, host-controlled |

**Implication:** D-Card's costs are close to messaging only (≈ Tsh 87–262 per guest, see [whatsapp-pricing.md](whatsapp-pricing.md)). It can **price at or slightly below the self-service market (RedPoint, Kadijanja)** and still keep roughly 70–90% gross margin on messaging. It should **not** match the done-for-you prices (Sherehe, Golden VIP), because those include staff.

---

## 3. Recommended plans

> **Decided (24 Sep 2026):** prices 1,000 / 1,500 / 2,000 accepted. Changes from this proposal: **Msingi includes contributions** (pledges, receipts, auto-issued card) but no reminders or auto-upgrade; **photos and videos** were added to the plans (Msingi none; Kawaida and Premium get card media, story page and guest gallery). The final plan table is in the requirements, `docs/design/features/plans-and-billing.md`.


Priced **per guest card** (single or double, same price, following market practice). Paid by the host **before cards are sent**.

| | **Msingi** (Basic) | **Kawaida** (Standard) ⭐ | **Premium** |
|---|---|---|---|
| **Price per guest** | **Tsh 1,000** | **Tsh 1,500** | **Tsh 2,000** |
| Compared with | Kadijanja Basic 1,000 | RedPoint White 1,500 / Kadijanja Standard 1,500, **with** full contributions | RedPoint Black 2,000 / Kadijanja Premium 2,000 |
| Card (WhatsApp + SMS), QR / card number, D-Card Door check-in | ✅ | ✅ | ✅ |
| RSVP, WhatsApp confirmation buttons, event reminder | ✅ | ✅ | ✅ |
| **Contributions module** (pledges, receipts, balances, auto-issued card, auto-upgrade) | — (direct cards only) | ✅ | ✅ |
| Contribution reminders per contributor (max) | — | 3 | 6 |
| Messages on/off | ✅ | ✅ | ✅ |
| Channel per message | Both only | ✅ | ✅ |
| Edit SMS wording | — | ✅ (1 SMS segment) | ✅ (up to 2 segments) |
| WhatsApp template styles + personal note | — | ✅ | ✅ |
| Custom timing and frequency | Defaults only | ✅ | ✅ |
| Manual sends to groups (per event) | — | 2 | 5 |
| Post-event thank-you (marketing category) | — | — | ✅ |
| Premium/video card designs | — | — | ✅ |
| Door staff accounts | 2 | 5 | Unlimited |

### 3.1 Other rules
- **Minimum charge:** **Tsh 50,000 per event** (e.g. 50 guests on Msingi). This covers support and fixed costs for small events such as kitchen parties.
- **Extra guests:** bought in **blocks of 10** at the same per-guest price, at any time.
- **Upgrade anytime:** the host pays only the difference per guest.
- **Payment:** the full amount for the guest count before cards are sent (self-service, so no deposit/balance split). Payment is by mobile money and recorded as a `host_payment`.
- **Launch offer (optional):** 20% off the first event, or the first 50 guests free, to win hosts from done-for-you providers.
- **Not included:** ushers, security, physical scanning staff. D-Card can partner with local usher services later.

### 3.2 Margin check (D-Card messaging cost per guest, worst case)
| Plan | Price | Worst-case cost/guest* | Gross margin |
|------|-------|------------------------|--------------|
| Msingi | 1,000 | ≈ 90 (direct cards only) | **≈ 91%** |
| Kawaida | 1,500 | ≈ 290 (contributor, 3 reminders, marketing-priced request, 1 segment) | **≈ 81%** |
| Premium | 2,000 | ≈ 630 (contributor, 6 reminders, 2-segment SMS, post-event thank-you) | **≈ 68%** |

\* Messaging only (Meta + NextSMS). Hosting, support and payment fees come out of the margin. Real averages will be lower: not every guest is a contributor, basic-phone guests don't cost WhatsApp, and most SMS fit one segment.

---

## Sources
- [Kadijanja – pricing](https://kadijanja.co.tz/)
- [RedPoint Tanzania – packages](https://www.redpoint.co.tz/home)
- [Sherehe Digital – packages](https://www.sherehe.co.tz/)
- [Golden eCards – packages](https://goldencreationss.com/)
- [M-Kadi – Digital Impact Awards profile](https://www.digital-impact-awards.com/2023/12/m-kadi-is-digitizing-wedding-contributions-fundraising-and-invitations-40-days-40-fintechs-tanzania-day-14/)
- [Foras Tech – Invitation system](https://foras.co.tz/solutions/invitation-system/)

## RSVP options

Checked 2026-09-25.

- Wedding RSVP tools and etiquette guides ask for a firm **yes or no** by a deadline; "maybe" is discouraged because caterers and venues need a final number ([The Knot](https://www.theknot.com/content/wedding-rsvp-questions), [Zola](https://www.zola.com/expert-advice/best-online-wedding-rsvp-tools), [WeddingWire forum](https://www.weddingwire.com/wedding-forums/maybe-on-a-rsvp/a0a1bc60364fd6fd.html)).
- WhatsApp-card services with QR entry (e.g. [Da3wa](https://da3wa.online/en/blog/electronic-invitations-for-events-create-a-whatsapp-invitation-card-digital-wedding-invite-69a9f45409d0a)) pair the card with an attend / not-attend RSVP.
- Result for D-Card: Yes / No plus a dietary note (ADR 0001 O19).

