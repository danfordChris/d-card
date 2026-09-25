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
| AUTH-8 | Host invites and removes treasurers, committee, door staff and walk-in approvers with an **invite link** (the host can copy/share it anywhere) and, when an email address is given, **by email** (Resend). | M |
| AUTH-9 | D-Card Door sessions are tied to one event and one device. The host can revoke a device. | M |

## Workflow: Team Invitation

1. Host opens the event team screen and chooses a role (treasurer, committee, door staff, walk-in approver), optionally with an email address.
2. D-Card creates an invite with a long random token (stored hashed), valid for **7 days**, usable **once**.
3. D-Card shows the invite link to copy or share (WhatsApp, SMS, any app). If an email was given, D-Card also emails the link.
4. The invitee opens the link, signs in or signs up (email + password), and accepts. The role is granted for that event only.
5. The host sees pending invites and current members, and can revoke an invite or remove a member at any time.
6. Door staff roles are limited by the plan (Msingi 2, Kawaida 5, Premium unlimited); creating an invite beyond the limit is refused.
7. Every invite, acceptance, revocation and removal is audited.
