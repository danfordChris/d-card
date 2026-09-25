# Phase 03 — Messaging (weeks 7–8)

## Status

- `in-progress`
- Last updated: 2026-09-25

## Objective

- all NTF messages send on both channels per settings. Delivery statuses and costs are logged. STOP works.

## Scope

| A | B | C |
|---|---|---|
| Notifications module: NextSMS + Meta adapters, per-channel queues, retries, message_log + cost; delivery webhooks | **Messages step:** on/off, channel, SMS editor (segment counter, GSM check, placeholders, required contact), WhatsApp template styles + note, timing/frequency, quiet hours, test send | Push notifications setup (FCM/APNs) |
| event_message_setting, scheduling (confirmation, reminders, contribution reminders), quiet hours, plan limits (MSG-12) | Manual send to groups | |
| Templates registry + category guard (MSG-15); **STOP** handling (MSG-14) | Message log view for the host | |

## Included Features

- `docs/implementation/feature-inventory/contributions/contribution-reminders.md`
- `docs/implementation/feature-inventory/notifications/nextsms-adapter.md`
- `docs/implementation/feature-inventory/notifications/whatsapp-adapter.md`
- `docs/implementation/feature-inventory/notifications/message-scheduling.md`
- `docs/implementation/feature-inventory/notifications/message-settings.md`
- `docs/implementation/feature-inventory/notifications/sms-editor.md`
- `docs/implementation/feature-inventory/notifications/whatsapp-templates.md`
- `docs/implementation/feature-inventory/notifications/quiet-hours.md`
- `docs/implementation/feature-inventory/notifications/manual-send.md`
- `docs/implementation/feature-inventory/notifications/stop-optout.md`
- `docs/implementation/feature-inventory/notifications/template-category-guard.md`
- `docs/implementation/feature-inventory/notifications/message-log-and-cost.md`
- `docs/implementation/feature-inventory/plans-and-billing/plan-limits.md`

## Task Checklist

- [x] T03-01 — Messaging foundation: schema, templates, adapters, send queue, message log (`docs/implementation/tasks/t03-01-messaging-foundation.md`)
- [ ] T03-02 — Transactional messages: contribution request, thank-you, card, upgrade (`docs/implementation/tasks/t03-02-transactional-messages.md`)
- [ ] T03-03 — Provider webhooks: delivery status, button replies, STOP, template category guard (`docs/implementation/tasks/t03-03-webhooks-stop.md`)
- [ ] T03-04 — Scheduled messages: reminders, confirmation, event reminder, thank-you, quiet hours, plan limits (`docs/implementation/tasks/t03-04-scheduled-messages.md`)
- [ ] T03-05 — Web message settings, SMS editor and test send (`docs/implementation/tasks/t03-05-web-message-settings.md`)
- [ ] T03-06 — Manual send to groups and host message log (`docs/implementation/tasks/t03-06-manual-send-and-log.md`)
- [ ] T03-07 — Admin WhatsApp template registry and provider rates (`docs/implementation/tasks/t03-07-admin-templates-rates.md`)
- [ ] T03-08 — Push notification setup (device tokens, FCM sender) (`docs/implementation/tasks/t03-08-push-setup.md`)

## Acceptance Criteria

- [ ] all NTF messages send on both channels per settings. Delivery statuses and costs are logged. STOP works.
- [ ] Every linked task is `done` with verification evidence.
- [ ] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- None for building and testing (fakes). Live sends need real NextSMS/Meta keys, a registered sender ID and approved templates (T00-10).

## Linked Tasks

- docs/implementation/tasks/t03-01-messaging-foundation.md
- docs/implementation/tasks/t03-02-transactional-messages.md
- docs/implementation/tasks/t03-03-webhooks-stop.md
- docs/implementation/tasks/t03-04-scheduled-messages.md
- docs/implementation/tasks/t03-05-web-message-settings.md
- docs/implementation/tasks/t03-06-manual-send-and-log.md
- docs/implementation/tasks/t03-07-admin-templates-rates.md
- docs/implementation/tasks/t03-08-push-setup.md
