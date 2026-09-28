# Photos and Videos

## Context

- Media lives in the host's Google Drive (ADR 0002, O14/O15).

## Requirements
What the host gets depends on the plan (`docs/design/features/plans-and-billing.md`). **Msingi has no photos or videos** (template card, plus an optional Google Photos link).

**Storage decision:** D-Card **does not store photos or videos on its own servers.** All media lives in the **host's Google Drive**, uploaded through the Google Drive API. D-Card keeps only file IDs and metadata. (Pixieset has no public API. Since March 2025 the Google Photos API can no longer share albums. See [research/media-storage.md](../../research/media-storage.md).)

| ID | Requirement | Pri |
|----|-------------|-----|
| MED-1 | **Connect Google Drive:** on Kawaida/Premium, the host connects their Google account once (OAuth, `drive.file` scope, which only gives access to files D-Card creates). D-Card creates a folder **"D-Card – {event title}"** with `card/`, `story/` and `gallery/` subfolders. D-Card can only see and change files it created, never the host's other files. The host can disconnect at any time. | M |
| MED-1a | **Sharing mode, chosen by the host when creating the event** (changeable later, audited). The screen explains both options. **Private** (default): only the host can open the folder in Drive. Guests see media only through D-Card with a valid card link, D-Card streams thumbnails and files using the host's permission, and access ends when the gallery page closes. **Anyone with the link:** D-Card shares the folder as "anyone with the link can view" and guests load media straight from Drive. It's simpler and costs D-Card no bandwidth, but forwarded links give access to anyone, and access continues until the host changes it. | M |
| MED-2 | **Direct uploads:** D-Card's server starts a **resumable upload session** on the host's Drive and gives the upload link to the phone or browser, which uploads **directly to Google Drive**. File bytes never pass through or stay on D-Card's servers. | M |
| MED-3 | **Card media:** the host adds photos (slideshow) and a short video to the card, within plan limits. Photos are resized on the device before upload. Video length and size are checked. | M |
| MED-4 | **Animated/video card** with background music (Premium). The WhatsApp card message uses a still card image with the QR code, **rendered on demand** by D-Card and uploaded to Meta when sending (not stored). The full card (with video) opens from the card link. | M |
| MED-5 | **Story page:** photos and videos from the host or couple shown on the card link, within plan limits. | M |
| MED-6 | **Guest-upload gallery:** guests upload photos and videos from the **card link, no login needed** (uploads are tied to their invitation), during the plan's upload window and within per-guest limits. The window opens 12 hours before the event starts and closes the plan's number of days after the event ends (implementation choice 2026-09-26; owner to confirm). | M |
| MED-7 | **Gallery viewing:** anyone with a valid card link to the event sees the gallery (thumbnails, full view on tap, videos). Media is served **through D-Card** in private mode, or **directly from Drive** in link mode (MED-1a). The host can hide or delete any item. Guests can delete their own uploads and report an item. | M |
| MED-8 | **Live slideshow** (Premium): a full-screen venue page showing new uploads as they arrive. It preloads and caches thumbnails in the browser to stay within Google's download limits. | M |
| MED-9 | **Download all:** the host opens the event folder in Google Drive and uses Drive's own download. D-Card shows a link to the folder. | M |
| MED-10 | **Storage space:** D-Card reads the host's Drive quota, shows the space left, **warns before the event** if space looks too small for the expected uploads, and pauses guest uploads (with a clear message) if the Drive is full. | M |
| MED-11 | **Plan period:** the gallery **page** on D-Card stays open for the plan's period (3 or 12 months after the event), then closes. **The files stay in the host's Drive for good**, since the host owns them. | M |
| MED-12 | **Cost and abuse guards:** max file size and video length per plan, image resizing on the device, per-guest upload limits, file-type checks. | M |
| MED-13 | **Missing files:** if the host deletes files or disconnects Drive, D-Card hides the missing items and shows the host a reconnect prompt. | M |
| MED-14 | **Google Photos link:** available on all plans. The host pastes a shared-album link and D-Card stores nothing. | M |
| MED-15 | For anonymised guests (W13), their uploads stay in the host's Drive, and D-Card removes the uploader's name from its records. | M |
| MED-16 | The storage layer sits behind a `MediaStore` interface, so a different backend could be added later without changing the rest of the system. | M |
