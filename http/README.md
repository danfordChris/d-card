# D-Card API — HTTP request docs

Runnable API documentation for `apps/web` (`/api/v1`). Every endpoint has a request with its purpose, who may call it, the body, and the responses to expect.

The machine-readable contract is `packages/api-contract/openapi.json` (generated from Zod: `pnpm --filter @dcard/api-contract openapi`). These files are the human-friendly companion; keep both in step when an endpoint changes.

## Setup

1. Use the **JetBrains HTTP Client** (IntelliJ IDEA, WebStorm, etc.) or, in VS Code, the **httpYac** extension. Both read `http-client.env.json` and run the response handlers (`> {% client.global.set(...) %}`) that pass ids from one request to the next.
2. Copy `http/http-client.private.env.example.json` to `http/http-client.private.env.json` (git-ignored) and fill in the values for the environments you use. For local work only `apiKey` is needed: the `tools:` key from the root `.env` `API_KEYS`.
3. Start the stack locally (root `.env` with `AUTH_VERIFIER=dev`):
   ```bash
   pnpm infra:up
   set -a && . ./.env && set +a
   pnpm --filter @dcard/db db:migrate && pnpm --filter @dcard/db db:seed
   pnpm --filter @dcard/web dev
   ```
4. Choose the environment in the run selector at the top of the `.http` file (JetBrains) or the environment picker (httpYac): `local`, `dev` or `production`.
5. Run each request in order, top to bottom. Each file creates what it needs (event, guests…) and saves ids for the next requests, so it runs on its own.

## Environments

Values that change between environments, or change often, live in two JSON files next to the `.http` files. The client merges them; the private file wins where both define a value.

| File | Committed? | Holds |
|---|---|---|
| `http-client.env.json` | yes | `baseUrl`, `locale`, `firebaseWebApiKey` (public by design), local `fake:` tokens |
| `http-client.private.env.json` | no (git-ignored) | `apiKey`, dev/production Firebase ID tokens, test user email/password |
| `http-client.private.env.example.json` | yes | Template for the private file |

Every environment (`local`, `dev`, `production`) defines:

| Variable | Used as | Notes |
|---|---|---|
| `baseUrl` | request URLs | `http://localhost:3000`, the Vercel preview URL, or the production domain |
| `apiKey` | `X-API-Key: {{apiKey}}` on every request | The `tools:` key from that environment's `API_KEYS` |
| `hostToken`, `committeeToken`, `treasurerToken`, `strangerToken`, `adminToken` | `Authorization: Bearer …` | Local: `fake:<uid>:<email>` (public file). Dev/production: Firebase ID tokens, valid 1 hour, from `00-system-and-auth.http` › *Get a Firebase ID token* (private file) |
| `locale` | `NEXT_LOCALE` cookie on exports, `?lang=` on card images | `sw` or `en` |
| `firebaseWebApiKey`, `testUserEmail`, `testUserPassword` | Token helper only | Sign in an existing test user of that environment's Firebase project |

To add another value that changes often (for example a new header), add it to each environment in the right JSON file (public or private) and use it as `{{name}}` in the requests. No other change is needed.

Ids created while running (event, guest, pledge, invite token, card token…) are stored with `client.global.set(...)` in response handlers and used as `{{eventId}}`, `{{guestId}}`, etc. They are not part of the environment files.

## API key

Every `/api/v1` request must send `X-API-Key: <key>`. Keys are listed per client in `API_KEYS` (`web:…,mobile:…,door:…,tools:…`) so one client's key can be rotated or revoked on its own. A missing or wrong key returns `401` with `code: invalid_api_key` before the route runs. The key identifies the calling app; it does not replace sign-in (the web key is visible in the browser). Every request in these files sends `X-API-Key: {{apiKey}}`.

## Authentication

- Apps send `Authorization: Bearer <Firebase ID token>`. The web app exchanges the ID token for an httpOnly `dcard_session` cookie (`POST /api/v1/session`); every route accepts either.
- Locally, with `AUTH_VERIFIER=fake` (refused in production), a token is `fake:<uid>:<email>`. The environment defines five users: host, committee, treasurer, stranger and admin.
- A new user must call `POST /api/v1/me` once before anything else (account provisioning). Each file does this first.
- Admin endpoints need `user_account.is_admin = true`. Locally:
  `docker compose -f infra/docker-compose.yml exec postgres psql -U dcard -c "update user_account set is_admin = true where firebase_uid = 'http-admin';"`

## Roles

Each file runs as the host so it works on its own. Committee, treasurer and door-staff tokens only have access after the host invites them and they accept (`06-team.http`: copy the token from the invite link, then accept with that user's token).

| Action | Host | Committee | Treasurer | Door staff / approver |
|---|---|---|---|---|
| Create/edit/cancel event, team | ✅ | — | — | — |
| Add/edit/remove/import guests | ✅ | ✅ | read only | — |
| Issue/cancel/reinstate cards | ✅ | — | — | — |
| Card link | ✅ | ✅ | — | — |
| Add contributors | ✅ | ✅ | — | — |
| Record payments, edit pledges | ✅ | — | ✅ | — |
| See contribution amounts, export | ✅ | ✅ | ✅ | — |

## Errors

Every error has the same shape:

```json
{ "error": { "code": "validation_error", "message": "Some fields are invalid.", "issues": [{ "path": "phone", "message": "Required." }] } }
```

| Status | `code` |
|---|---|
| 401 | `invalid_api_key` (missing/wrong `X-API-Key`), `unauthorized` (missing/invalid token) |
| 403 | `forbidden`, `account_not_provisioned` (call `POST /me` first) |
| 404 | `not_found` (also for malformed ids) |
| 409 | `conflict` (wrong state, duplicates), `plan_limit` |
| 410 | `invite_gone` (used, revoked or expired invite) |
| 422 | `validation_error`, `invalid_phone`, `consent_required` |
| 429 | `rate_limited` |
| 500 | `internal` (no details leaked) |

## Conventions

- Phones are accepted as `0754 123 456`, `+255754123456`, `255754123456` or `754123456` and stored as `255` + 9 digits.
- Amounts are whole Tanzanian shillings (integers). Refunds are stored as negative payments.
- Times are ISO 8601 with offset; events are in `Africa/Dar_es_Salaam` (UTC+03:00).
- Ids are UUIDs; public card links use a 43-character token.

## Files

| File | Covers |
|---|---|
| `00-system-and-auth.http` | health, account provisioning, web session |
| `01-catalogue.http` | plans, event types |
| `02-events.http` | events CRUD and cancel |
| `03-guests.http` | guests, bulk add (contacts), search, edit, remove |
| `04-imports.http` | Excel/CSV preview + confirm, copy from a past event |
| `05-cards.http` | issue, card link, cancel, reinstate |
| `06-team.http` | team invites (link + email), accept, members |
| `07-contributions.http` | contributors, payments, refunds, auto-upgrade, auto-issue, pledge edits, export |
| `08-public-card.http` | guest card by link (no login), RSVP, calendar, card image |
| `09-admin.http` | admin event types |
