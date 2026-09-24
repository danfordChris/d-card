# Plans and Billing

## Context

- Flat price per guest card; host pays via Snippe before cards are sent.

## Plans and Pricing
**Model: flat price per guest card** (single or double, same price). **All normal messages are included.** There are no message credits, and the host never sees per-message costs. D-Card pays Meta, NextSMS and storage, and bounds the cost with **plan limits** (MSG-12, MED-9). Market comparison: [research/market-pricing.md](../../research/market-pricing.md).

### Plans (decided)
| | **Msingi** | **Kawaida** ⭐ | **Premium** |
|---|---|---|---|
| **Price per guest card** | **Tsh 1,000** | **Tsh 1,500** | **Tsh 2,000** |
| *Market reference* | *Kadijanja Basic 1,000* | *RedPoint White / Kadijanja Standard 1,500* | *RedPoint Black / Kadijanja Premium 2,000* |
| **Cards and door** | | | |
| Card (WhatsApp + SMS), QR / card number, D-Card Door (online + offline) | ✅ | ✅ | ✅ |
| RSVP, WhatsApp confirmation buttons, event reminder | ✅ | ✅ | ✅ |
| Door staff accounts | 2 | 5 | Unlimited |
| **Contributions (michango)** | | | |
| Pledges, payments, receipts, balances, card auto-issued on full payment | ✅ | ✅ | ✅ |
| Auto-upgrade Single → Double | — | ✅ | ✅ |
| Contribution reminders per contributor (max) | — | 3 | 6 |
| **Messages** | | | |
| Turn messages on/off | ✅ | ✅ | ✅ |
| Channel per message | Both only | ✅ | ✅ |
| Edit SMS wording | — | ✅ (1 SMS segment) | ✅ (up to 2 segments) |
| WhatsApp template styles + personal note | — | ✅ | ✅ |
| Custom timing and frequency | Defaults only | ✅ | ✅ |
| Manual sends to groups (per event) | — | 2 | 5 |
| Post-event thank-you (marketing category) | — | — | ✅ |
| **Photos and videos** (`docs/design/features/media.md`) | | | |
| Card media | Template design only, **no photos/videos** | Up to 5 host photos (slideshow) + 1 video (≤ 30 s) | Animated/video card: up to 10 photos + 1 video (≤ 60 s) with music |
| Story page (couple/host photos and videos on the card link) | — | Up to 20 photos + 1 video (≤ 60 s) | Up to 50 photos + 5 videos (≤ 2 min each) |
| Guest-upload event gallery (files in the **host's Google Drive**) | — | ✅ photos + videos (≤ 30 s), uploads open until 3 days after the event, **gallery page open 3 months**, max 20 uploads per guest | ✅ photos + videos (≤ 60 s), uploads open until 7 days after, **gallery page open 12 months**, max 50 uploads per guest, original quality |
| Live slideshow on the venue screen | — | — | ✅ |
| Download whole gallery (from the host's Drive) | — | ✅ | ✅ |
| Google Photos album link (no storage) | ✅ | ✅ | ✅ |

### Pricing rules (decided)
- **Minimum charge: Tsh 50,000 per event** (e.g. 50 cards on Msingi).
- **Extra guests** are bought in **blocks of 10** at the plan's per-guest price, at any time.
- **Upgrade anytime:** the host pays the per-guest difference for all cards.
- **Full payment before cards are sent** (mobile money, recorded as `host_payment`). No deposit/balance split.
- **Launch offer:** **20% off the host's first event** (admin can change or switch off the offer).
- Not included: ushers, security, scanning staff (the host's own people use D-Card Door).
- Planner subscriptions: Phase 3.

### Cost check (worst case per guest card, D-Card's direct costs)
| Plan | Price | Messaging (worst case) | Media storage | Gross margin |
|------|-------|------------------------|---------------|--------------|
| Msingi | 1,000 | ≈ 210 (contributor, no reminders) | 0 | ≈ 79% |
| Kawaida | 1,500 | ≈ 290 | **0** (host's Drive) | ≈ 81% |
| Premium | 2,000 | ≈ 630 | **0** (host's Drive) | ≈ 68% |

Messaging figures come from [research/whatsapp-pricing.md](../../research/whatsapp-pricing.md). Media costs D-Card nothing because files live in the host's Google Drive (the host's free 15 GB, or their paid Google storage). Hosting, support and mobile-money fees come out of the margin.
