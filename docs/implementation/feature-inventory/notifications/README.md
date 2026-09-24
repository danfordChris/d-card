# Notifications and Message Customisation

## Feature

- Notifications and Message Customisation (`docs/design/features/notifications.md`)

## Description

- Guest messages on WhatsApp and SMS with host-controlled content, channel and timing.

## Capability Leverage

- Keeps guests informed at low, bounded cost.

## Status

- Pending

## Subfeature Index

| Subfeature | Description | Status | Evidence |
|---|---|---|---|
| [`nextsms-adapter`](./nextsms-adapter.md) | Send SMS via NextSMS with delivery webhook. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`whatsapp-adapter`](./whatsapp-adapter.md) | Send templates via Meta Cloud API with status webhooks. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`message-scheduling`](./message-scheduling.md) | Scheduled confirmations, reminders and post-event messages via BullMQ. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`message-settings`](./message-settings.md) | Per-message on/off, channel, timing and frequency per event. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`sms-editor`](./sms-editor.md) | SMS wording editor with placeholders, segment counter and GSM check. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`whatsapp-templates`](./whatsapp-templates.md) | Template styles per message type with personal note; admin submission. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`quiet-hours`](./quiet-hours.md) | No guest messages 21:00–07:00 by default. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`manual-send`](./manual-send.md) | Send a message now to a filtered guest group within plan caps. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`stop-optout`](./stop-optout.md) | STOP on WhatsApp switches the guest to SMS only. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`template-category-guard`](./template-category-guard.md) | Pause sends if Meta re-categorises a utility template. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`message-log-and-cost`](./message-log-and-cost.md) | Log every message with status and cost per event. | Pending | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
