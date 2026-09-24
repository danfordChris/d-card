# Authentication and Accounts

## Feature

- Authentication and Accounts (`docs/design/features/auth.md`)

## Description

- Firebase-based login for management roles and guests, with per-event roles in Postgres.

## Capability Leverage

- Every other feature relies on knowing who acts and in which event role.

## Status

- In Progress

## Subfeature Index

| Subfeature | Description | Status | Evidence |
|---|---|---|---|
| [`account-provisioning`](./account-provisioning.md) | Firebase token verification and D-Card account creation via POST /api/v1/me. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-04` |
| [`management-login`](./management-login.md) | Email/password login, verification and reset for hosts, committee, staff and admins. | Pending | `P01` (`docs/implementation/phases/phase-01-events-guests.md`) |
| [`guest-social-login`](./guest-social-login.md) | Optional Google/Apple sign-in for guests linked to their Person via card token. | Pending | `P06` (`docs/implementation/phases/phase-06-completion.md`) |
| [`per-event-roles`](./per-event-roles.md) | Role checks per event for treasurer, committee, door staff and walk-in approver. | Done | `P00` (`docs/implementation/phases/phase-00-foundations.md`), `T00-03` |
| [`team-invitations`](./team-invitations.md) | Host invites and removes committee, staff and approvers by email. | Pending | `P01` (`docs/implementation/phases/phase-01-events-guests.md`) |
| [`admin-2fa`](./admin-2fa.md) | TOTP second factor for admin accounts. | Pending | `P06` (`docs/implementation/phases/phase-06-completion.md`) |
| [`door-device-sessions`](./door-device-sessions.md) | Door sessions tied to one event and device; host can revoke. | Pending | `P06` (`docs/implementation/phases/phase-06-completion.md`) |
