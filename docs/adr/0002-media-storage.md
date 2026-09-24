# ADR 0002 — Media Storage in the Host's Google Drive

## Date

2026-09-24

## Decision

- Event photos and videos are stored in the **host's Google Drive** via the Drive API (`drive.file` scope). D-Card stores only file IDs and metadata.
- Uploads go directly from the client to Drive using resumable upload sessions created by the server.
- The host chooses per event: `private` (default; D-Card serves media to valid card links) or `link` (anyone with the link can view).
- The Google Photos album link stays available on all plans.

## Reason

- The product owner does not want to store media on D-Card servers or pay for media storage.
- Pixieset has no public API. The Google Photos API removed album sharing on 31 Mar 2025. Drive supports upload, folders and link sharing.

## Impacted Docs

- `docs/design/features/media.md`
- `docs/design/integrations/google-drive.md`
- `docs/design/data-models/postgres.md`
