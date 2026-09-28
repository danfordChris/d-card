# Audit, Privacy and Data Retention

## Feature

- Audit, Privacy and Data Retention (`docs/design/features/privacy-and-audit.md`)

## Description

- Append-only audit log, post-event anonymisation and guest privacy rights.

## Capability Leverage

- Trust and legal compliance across all features.

## Status

- In Progress

## Subfeature Index

| Subfeature | Description | Status | Evidence |
|---|---|---|---|
| [`audit-log`](./audit-log.md) | Append-only audit entries for every state change. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-03` |
| [`retention-anonymisation`](./retention-anonymisation.md) | Anonymise non-registered guests 2 weeks after the event, keep host records. | Done | `P06` (`docs/implementation/phases/phase-06-completion.md`) |
| [`gallery-page-closing`](./gallery-page-closing.md) | Close gallery pages after the plan period. | Done | `P06` (`docs/implementation/phases/phase-06-completion.md`) |
| [`guest-data-export-delete`](./guest-data-export-delete.md) | Registered guests download or delete their data. | Done | `P06` (`docs/implementation/phases/phase-06-completion.md`) |
| [`privacy-notice`](./privacy-notice.md) | Privacy notice for guests and consent wording. | Done | `P06` (`docs/implementation/phases/phase-06-completion.md`) |
