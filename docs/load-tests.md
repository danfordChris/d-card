# Load tests (T07-02)

Pilot-scale checks on the local stack with fake providers. No real SMS, WhatsApp or Drive calls are made.

## How to run

```bash
pnpm infra:up
set -a && . ./.env && set +a
pnpm load:all            # LOAD_GUESTS=1000 by default; SMS_MAX_PER_SECOND=100 for the fan-out run
```

The script is `apps/worker/load/run.ts`. It creates its own database (`dcard_test_load_<pid>`) and drops it afterwards. It prints `PASS`/`FAIL` for each check and a JSON result, and exits non-zero on any failure.

## Results (2026-09-27, Apple M5, 16 GB, Postgres 17 and Redis 7 in OrbStack)

Core functions were called directly, so HTTP and Vercel overhead is not included. Add roughly one network round trip (Dar es Salaam to fra1, about 150–250 ms) per request.

| Scenario | Load | Result |
|---|---|---|
| Seed | 1,000 guests, 30% double cards, all issued | 6.7 s (6.7 ms per guest) |
| Online check-in | 4 gates at once, 1,300 allowed entries + about 100 repeat scans | 260 admits/s. Latency p50 14 ms, p95 24 ms, p99 45 ms. **0 over-admits**; every repeat scan refused `fully_used` |
| Offline sync | 4 gates upload about 1,040 entries in batches of 100 at once, then replay every batch | Merge took 0.6 s (batch p95 360 ms). Every entry was stored once; the replay added nothing. **Over-used cards flagged exactly** (34 of 34) |
| Message fan-out | 1,000 reminders, outbox → dispatch → SMS queue, cap 100/s | One dispatch tick took 2.0 s. All 1,000 sent in 9.9 s at an average of 101/s. The busiest one-second span had 115, within the 1.25× burst limit |
| Gallery and slideshow | 500 photos, 20 guests viewing at once plus slideshow polling, private and link modes | Guest gallery p95 85 ms (private) and 68 ms (link); slideshow list p95 50–58 ms |

## Problems found and fixed

1. **Over-use missed under concurrent offline uploads.** Two gates uploading the same single card at the same moment each saw only their own entry, so the card was not flagged (18 of 35 flagged).
   - Fix: `doorSyncUpload` now locks the cards it touches (sorted order, no deadlocks) before merging, as online admits already did.
   - Regression test: `packages/core/test/checkin-sync.test.ts`, "flags over-use when two gates upload the same card at the same moment".
2. **Dispatch capped fan-out at about 6.7 messages/s.** Each 15-second tick moved only 100 outbox rows, so 1,000 messages needed 10 ticks, about 2.5 minutes.
   - Fix: a tick now drains up to 2,000 messages in batches of 100.
3. **Send rate caps.** There was no cap before, and Meta's throughput errors (HTTP 400, code 130429 and similar) were treated as permanent failures.
   - The WhatsApp cap now defaults to 60/s (`WHATSAPP_MAX_PER_SECOND`) and SMS to 20/s (`SMS_MAX_PER_SECOND`). The caps are shared across worker processes through Redis.
   - The limiter uses quarter-second windows, so any one second holds at most 1.25× the cap. At 60/s that is 75, under Meta's 80.
   - Meta codes 130429, 131056, 80007 and 4 are now retried with backoff.

## Provider limits to know before a pilot

- **WhatsApp throughput:** 80 messages/second per phone number by default, counting inbound messages. Meta raises it automatically to 1,000 for eligible numbers. Error 130429 means over the limit.
- **WhatsApp messaging limit:** a daily cap on unique recipients of business-initiated messages. It starts low for businesses that are not yet verified. Check the current tier in WhatsApp Manager, and complete business verification before a pilot with more guests than the tier allows (`docs/launch/launch-checklist.md`).
- **SMS:** NextSMS publishes no rate. The 20/s default is conservative; raise it after checking with NextSMS.

## Not covered

- Real-network latency and Vercel cold starts. Measure these during the pilot (T07-05).
- Real Google Drive download limits for the slideshow. It already preloads and caches thumbnails (MED-8); check during the pilot in both sharing modes.
