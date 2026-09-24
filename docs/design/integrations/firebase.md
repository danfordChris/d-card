# Firebase Integration

## Context

- Decision: `docs/adr/0003-technical-stack.md`.
- Behavior: `docs/design/features/auth.md`.

## Requirements

- **Firebase Auth:** email/password (host, treasurer, committee, door staff, approvers, admin); Google and Apple sign-in (guests, optional).
- Admin second factor: TOTP (Identity Platform).
- **FCM/APNs:** push notifications (walk-in requests, alerts) from the same Firebase project.
- Postgres `user_account.firebase_uid` links Firebase users to D-Card data. Roles and per-event permissions live only in Postgres.

## Contracts

- Every `/api/v1/*` request carries `Authorization: Bearer <Firebase ID token>`.
- The API verifies the token with `firebase-admin`, loads `user_account` by UID, then checks the per-event role.
- Account provisioning: after Firebase sign-up, the client calls `POST /api/v1/me` once to create the D-Card `user_account`.
- `GET /api/v1/me` returns the caller's account, or 404 if it is not provisioned yet.

## Acceptance Criteria

- A request with a missing or invalid ID token to `/api/v1/me` returns 401.
- `POST /api/v1/me` with a valid token for an unknown UID creates one `user_account` (UID, email, provider) and returns 201; repeating it returns 200 with the same account.
