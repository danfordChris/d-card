# Authentication and Accounts

## Context

- Login provider: Firebase Auth (ADR 0003). Roles and permissions live in Postgres.

## Requirements
| ID | Requirement | Pri |
|----|-------------|-----|
| AUTH-1 | Management roles sign up and log in with email + password. | M |
| AUTH-2 | Email verification and password reset. | M |
| AUTH-3 | Guests can optionally sign in with **Google or Apple only**. | M |
| AUTH-4 | A link token connects a signed-in guest account to their Person record. | M |
| AUTH-5 | The card is viewable through its link token **without login**. | M |
| AUTH-6 | Every API call checks the caller's role for the specific event. | M |
| AUTH-7 | 2FA for Admin accounts. | M |
| AUTH-8 | Host invites and removes treasurers, committee, door staff and walk-in approvers by email. | M |
| AUTH-9 | D-Card Door sessions are tied to one event and one device. The host can revoke a device. | M |
