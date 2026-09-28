# D-Card – Media Storage Research (O14)

**Date:** 24 September 2026
**Goal:** keep event photos and videos **off D-Card's servers** and avoid paying for media storage.

| | Pixieset | Google Photos (Library API) | **Google Drive (Drive API)** |
|---|---|---|---|
| Public API | ❌ None. No developer program, keys or webhooks (only unofficial reverse-engineered docs) | ✅ Restricted since 31 Mar 2025 | ✅ Full |
| Upload into the host's account | ❌ | ✅ `photoslibrary.appendonly` | ✅ `drive.file` |
| Share with guests via API | ❌ | ❌ **Sharing removed** (and the `photoslibrary.sharing` scope) | ✅ "Anyone with the link" permission |
| Read back what we uploaded | ❌ | ✅ App-created media only (`readonly.appcreateddata`); URLs expire after about 60 min | ✅ Files D-Card created |
| Google verification burden | — | Higher (Photos scopes) | Low (`drive.file` is the lightest Drive scope) |
| Direct device → cloud upload | — | Via the server | ✅ Resumable upload session link |
| Host downloads everything | — | In Google Photos | ✅ Drive folder download |

## Decision
**Host's Google Drive.** D-Card creates an event folder in the host's Drive, phones upload straight to it, and D-Card stores only file IDs. D-Card's media storage cost is **zero**, and the host keeps the files.

## Risks and mitigations
| Risk | Mitigation |
|------|-----------|
| The host's free Google storage (15 GB, shared with Gmail) fills up | Show space left, warn before the event, per-plan upload limits, resize images on the device, cap video length (MED-10, MED-12) |
| Google slows heavy viewing of shared files (e.g. slideshow at a big venue) | Load thumbnails, not originals; cache in the browser; **load-test the slideshow before launch** |
| The host deletes files or disconnects Drive | D-Card marks items missing and prompts reconnection (MED-13) |
| Some hosts have no Google account | Required for Kawaida/Premium media features only. Creating one is free. |
| Drive later becomes unsuitable | `MediaStore` interface (MED-16) allows adding another backend, e.g. R2 object storage |

## Sources
- [Google Photos APIs – Updates (March 2025 changes)](https://developers.google.com/photos/support/updates)
- [Google Developers Blog – Picker API launch and Library API changes](https://developers.googleblog.com/en/google-photos-picker-api-launch-and-library-api-updates/)
- [Pixieset API profile (API Evangelist, third-party)](https://github.com/api-evangelist/pixieset)
- [Pixieset – Uploading to Client Gallery](https://help.pixieset.com/hc/en-us/articles/115003740132-Uploading-to-Client-Gallery)
