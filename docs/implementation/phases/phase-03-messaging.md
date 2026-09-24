# Phase 03 — Messaging (weeks 7–8)

## Status

- `pending`
- Last updated: 2026-09-24

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

- [ ] Break the scope below into task files before the phase starts (vertical slices, per `task-spec.md`).

## Acceptance Criteria

- [ ] all NTF messages send on both channels per settings. Delivery statuses and costs are logged. STOP works.
- [ ] Every linked task is `done` with verification evidence.
- [ ] `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py` prints `WORKFLOW:ok`.

## Blockers

- Previous phase not done.

## Linked Tasks

- None yet.
