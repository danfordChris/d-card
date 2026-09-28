# Google Drive Integration

## Context

- Research: `docs/research/media-storage.md`.
- Behavior: `docs/design/features/media.md`. Decision: `docs/adr/0002-media-storage.md`.

## Requirements

- OAuth scope: `drive.file` only (files D-Card creates).
- Folder per event: `D-Card – {event title}/` with `card/`, `story/`, `gallery/`.
- Sharing mode per event: `private` (default, D-Card serves media) or `link` (anyone with the link can view).
- Uploads: server creates a resumable upload session; the client uploads bytes directly to Drive.
- D-Card stores file IDs and metadata only.
- Refresh tokens encrypted at rest.

## Decisions

- Private-mode content for guests is served at `/api/v1/cards/{token}/media/{id}/content`; the card token is the credential (no API key), so `<img>`/`<video>` load directly and videos stream with Range requests. Host content keeps the API key. The Drive connect/callback routes are also keyless (browser navigation, Google redirect) and use the session cookie plus a signed, expiring state.
- Upload sessions are created with the web app's `Origin` so the browser can PUT to Google directly (CORS).

- Pixieset rejected: no public API.
- Google Photos rejected: API album sharing removed on 31 Mar 2025.
- Storage access sits behind a `MediaStore` interface.

## Contracts

- `POST /api/v1/events/{id}/media/upload-sessions` → returns a Drive resumable upload URL.
- `GET /api/v1/events/{id}/media` → lists visible items (proxied URLs in private mode).

## Acceptance Criteria

- An uploaded file appears in the host's Drive event folder and in `media_item` with its `drive_file_id`.
- No media bytes are written to D-Card storage.
