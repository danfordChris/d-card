# Photos and Videos

## Feature

- Photos and Videos (`docs/design/features/media.md`)

## Description

- Card media, story page, guest gallery and slideshow stored in the host's Google Drive.

## Capability Leverage

- Richer events at zero storage cost to D-Card.

## Status

- Pending

## Subfeature Index

| Subfeature | Description | Status | Evidence |
|---|---|---|---|
| [`drive-connect`](./drive-connect.md) | Host connects Google Drive; event folder created with drive.file scope. | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`sharing-modes`](./sharing-modes.md) | Private (default) or anyone-with-link folder sharing per event. | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`direct-uploads`](./direct-uploads.md) | Resumable upload sessions; clients upload straight to Drive. | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`card-media`](./card-media.md) | Photos, video and animated card within plan limits. | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`story-page`](./story-page.md) | Host/couple photos and videos on the card link. | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`guest-gallery`](./guest-gallery.md) | Guest uploads from the card link, moderation, report, download from Drive. | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`slideshow`](./slideshow.md) | Live venue slideshow of new uploads (Premium). | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
| [`drive-quota`](./drive-quota.md) | Show space left, warn early, pause uploads when full; handle missing files. | In Progress | `P05` (`docs/implementation/phases/phase-05-payments-media.md`) |
