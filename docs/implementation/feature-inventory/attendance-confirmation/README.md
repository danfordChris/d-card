# Attendance Confirmation

## Feature

- Attendance Confirmation (`docs/design/features/attendance-confirmation.md`)

## Description

- WhatsApp Approve/Decline buttons, SMS contact-based confirmation and manual recording.

## Capability Leverage

- Gives hosts a realistic expected headcount.

## Status

- Pending

## Subfeature Index

| Subfeature | Description | Status | Evidence |
|---|---|---|---|
| [`whatsapp-buttons`](./whatsapp-buttons.md) | Quick-reply buttons with per-invitation payload; first answer counts; acknowledgement. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
| [`sms-contact-confirmation`](./sms-contact-confirmation.md) | Information SMS asking basic-phone guests to contact the event contact. | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
| [`manual-confirmation`](./manual-confirmation.md) | Host/committee record phone confirmations and override status (audited). | Pending | `P04` (`docs/implementation/phases/phase-04-confirmation-check-in.md`) |
