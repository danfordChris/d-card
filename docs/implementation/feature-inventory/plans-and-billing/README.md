# Plans and Billing

## Feature

- Plans and Billing (`docs/design/features/plans-and-billing.md`)

## Description

- Msingi/Kawaida/Premium per-guest plans, Snippe payment and plan limits.

## Capability Leverage

- Revenue and bounded cost per event.

## Status

- Pending

## Subfeature Index

| Subfeature | Description | Status | Evidence |
|---|---|---|---|
| [`plans-and-entitlements`](./plans-and-entitlements.md) | Plan catalogue with entitlements and limits. | In Review | `P01` (`docs/implementation/phases/phase-01-events-guests.md`) |
| [`snippe-checkout`](./snippe-checkout.md) | USSD push and hosted checkout via Snippe; webhook confirms payment. | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`pricing-rules`](./pricing-rules.md) | Minimum charge, guest blocks of 10, upgrades, pay before sending. | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`launch-offer`](./launch-offer.md) | 20% off the host's first event (admin-configurable). | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`plan-limits`](./plan-limits.md) | Enforce reminders, SMS segments, manual sends and marketing per plan. | In Progress | `P03` (`docs/implementation/phases/phase-03-messaging.md`) |
| [`cost-margin-report`](./cost-margin-report.md) | Internal cost and margin per event and plan from provider rates. | Pending | `P06` (`docs/implementation/phases/phase-06-completion.md`) |
