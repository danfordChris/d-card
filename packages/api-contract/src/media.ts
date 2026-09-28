import type { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { ErrorResponse } from "./schemas.js";

// T05-04 media: docs/design/features/media.md, docs/design/integrations/google-drive.md.
// Files live in the host's Google Drive; D-Card keeps ids and metadata only.

export const MediaKindSchema = z.enum(["card", "story", "gallery"]).openapi("MediaKind");
export const MediaTypeSchema = z.enum(["photo", "video"]).openapi("MediaType");
export const MediaStatusSchema = z.enum(["uploading", "visible", "hidden", "reported", "deleted", "missing"]).openapi("MediaStatus");
export const SharingModeSchema = z.enum(["private", "link"]).openapi("SharingMode");

export const MediaLimitsSchema = z
  .object({
    cardPhotos: z.number().int(),
    cardVideos: z.number().int(),
    cardVideoSeconds: z.number().int(),
    storyPhotos: z.number().int(),
    storyVideos: z.number().int(),
    storyVideoSeconds: z.number().int(),
    galleryEnabled: z.boolean(),
    galleryVideoSeconds: z.number().int(),
    galleryUploadsPerGuest: z.number().int(),
    /** Days after the event that guests may still upload. */
    galleryUploadDays: z.number().int(),
    /** Months after the event that the gallery page stays open. */
    galleryOpenMonths: z.number().int(),
    maxPhotoBytes: z.number().int(),
    maxVideoBytes: z.number().int(),
    slideshow: z.boolean(),
  })
  .openapi("MediaLimits");

export const MediaSettingsSchema = z
  .object({
    /** false on Msingi (only the Google Photos link). */
    mediaEnabled: z.boolean(),
    connected: z.boolean(),
    googleEmail: z.string().nullable(),
    /** Access was revoked or files went missing: the host must reconnect. */
    needsReconnect: z.boolean(),
    sharingMode: SharingModeSchema,
    folderUrl: z.string().nullable(),
    quotaUsedBytes: z.number().nullable(),
    quotaLimitBytes: z.number().nullable(),
    /** Space left looks too small for the expected uploads. */
    quotaWarning: z.boolean(),
    googlePhotosUrl: z.string().nullable(),
    limits: MediaLimitsSchema,
    counts: z.object({ cardPhotos: z.number().int(), cardVideos: z.number().int(), storyPhotos: z.number().int(), storyVideos: z.number().int(), gallery: z.number().int() }),
  })
  .openapi("MediaSettings");

export const MediaSettingsInput = z
  .object({
    sharingMode: SharingModeSchema.nullish(),
    /** Google Photos shared-album link (all plans); empty string clears it. */
    googlePhotosUrl: z.string().trim().max(500).nullish(),
  })
  .strict()
  .openapi("MediaSettingsInput");

export const UploadSessionInput = z
  .object({
    kind: MediaKindSchema,
    fileName: z.string().trim().min(1).max(200),
    mimeType: z.string().trim().min(3).max(100),
    sizeBytes: z.number().int().min(1),
    /** Required for videos (checked on the device before upload). */
    durationSeconds: z.number().int().min(0).nullish(),
  })
  .strict()
  .openapi("UploadSessionInput");

export const UploadSessionSchema = z
  .object({
    mediaItemId: z.uuid(),
    /** Google Drive resumable upload URL: PUT the bytes here directly (Content-Range for chunks). */
    uploadUrl: z.string(),
    expiresAt: z.iso.datetime(),
  })
  .openapi("UploadSession");

export const UploadCompleteInput = z
  .object({
    /** The `id` from Drive's final upload response. */
    driveFileId: z.string().trim().min(5).max(200),
  })
  .strict()
  .openapi("UploadCompleteInput");

export const MediaItemSchema = z
  .object({
    id: z.uuid(),
    kind: MediaKindSchema,
    type: MediaTypeSchema,
    mimeType: z.string(),
    sizeBytes: z.number(),
    durationSeconds: z.number().int().nullable(),
    status: MediaStatusSchema,
    /** Guest name for gallery uploads; null for the host's own media. */
    uploadedBy: z.string().nullable(),
    /** True when the current guest uploaded it (card-link views). */
    mine: z.boolean(),
    /** Private mode: D-Card proxy URL; link mode: Drive URL. */
    thumbnailUrl: z.string(),
    url: z.string(),
    createdAt: z.iso.datetime(),
  })
  .openapi("MediaItem");

export const MediaStatusInput = z.object({ status: z.enum(["visible", "hidden"]) }).strict().openapi("MediaStatusInput");

export const GuestMediaSchema = z
  .object({
    story: z.array(MediaItemSchema),
    gallery: z.array(MediaItemSchema),
    galleryEnabled: z.boolean(),
    /** Guests can upload now (window open, Drive not full, page open). */
    uploadsOpen: z.boolean(),
    /** Why uploads are closed: not_started | window_closed | drive_full | gallery_closed | not_available */
    uploadsClosedReason: z.string().nullable(),
    uploadsClosesAt: z.iso.datetime().nullable(),
    myUploadsLeft: z.number().int(),
    limits: MediaLimitsSchema,
  })
  .openapi("GuestMedia");

export type UploadSessionInput = z.infer<typeof UploadSessionInput>;
export type MediaSettingsInput = z.infer<typeof MediaSettingsInput>;

export function registerMediaPaths(registry: OpenAPIRegistry, secured: Record<string, string[]>[]): void {
  const error = (description: string) => ({ description, content: { "application/json": { schema: ErrorResponse } } });
  const json = (schema: z.ZodType, description: string) => ({ description, content: { "application/json": { schema } } });
  const eventParams = z.object({ id: z.uuid() });
  const itemParams = z.object({ id: z.uuid(), itemId: z.uuid() });
  const cardParams = z.object({ token: z.string() });
  const cardItemParams = z.object({ token: z.string(), itemId: z.uuid() });
  registry.registerPath({
    method: "get",
    path: "/api/v1/media/google/connect",
    operationId: "connectGoogleDrive",
    summary: "Redirects the host to Google consent (drive.file) for an event",
    security: secured,
    request: { query: z.object({ eventId: z.uuid() }) },
    responses: { 302: { description: "Redirect to Google" }, 403: error("Host only or plan without media") },
  });
  registry.registerPath({
    method: "delete",
    path: "/api/v1/media/google",
    operationId: "disconnectGoogleDrive",
    summary: "Disconnect Google Drive (files stay in the host's Drive)",
    security: secured,
    responses: { 204: { description: "Disconnected" } },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/media/settings",
    operationId: "getMediaSettings",
    summary: "Drive connection, sharing mode, quota, plan limits and counts (host, committee)",
    security: secured,
    request: { params: eventParams },
    responses: { 200: json(MediaSettingsSchema, "Settings"), 403: error("No access") },
  });
  registry.registerPath({
    method: "put",
    path: "/api/v1/events/{id}/media/settings",
    operationId: "updateMediaSettings",
    summary: "Change sharing mode or the Google Photos link (host, audited)",
    security: secured,
    request: { params: eventParams, body: { content: { "application/json": { schema: MediaSettingsInput } } } },
    responses: { 200: json(MediaSettingsSchema, "Saved"), 403: error("Host only"), 409: error("drive_not_connected"), 422: error("Validation error") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/media",
    operationId: "listEventMedia",
    summary: "Media of an event for the host (all statuses except deleted)",
    security: secured,
    request: { params: eventParams, query: z.object({ kind: MediaKindSchema.optional() }) },
    responses: { 200: json(z.object({ items: z.array(MediaItemSchema) }), "Items"), 403: error("No access") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/media/upload-sessions",
    operationId: "createHostUploadSession",
    summary: "Host upload (card or story): returns a Drive resumable URL within plan limits",
    security: secured,
    request: { params: eventParams, body: { content: { "application/json": { schema: UploadSessionInput } } } },
    responses: { 201: json(UploadSessionSchema, "Session"), 403: error("Host only"), 409: error("plan_limit, drive_not_connected or drive_full"), 422: error("Validation error (type, size, length)") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/events/{id}/media/{itemId}/complete",
    operationId: "completeHostUpload",
    summary: "Register the Drive file after the upload finished",
    security: secured,
    request: { params: itemParams, body: { content: { "application/json": { schema: UploadCompleteInput } } } },
    responses: { 200: json(MediaItemSchema, "Item"), 403: error("Host only"), 404: error("Unknown item"), 422: error("File not found in Drive") },
  });
  registry.registerPath({
    method: "patch",
    path: "/api/v1/events/{id}/media/{itemId}",
    operationId: "setMediaStatus",
    summary: "Hide or show an item (host moderation, audited)",
    security: secured,
    request: { params: itemParams, body: { content: { "application/json": { schema: MediaStatusInput } } } },
    responses: { 200: json(MediaItemSchema, "Item"), 403: error("Host only"), 404: error("Unknown item") },
  });
  registry.registerPath({
    method: "delete",
    path: "/api/v1/events/{id}/media/{itemId}",
    operationId: "deleteEventMedia",
    summary: "Delete an item (also deletes the Drive file D-Card created)",
    security: secured,
    request: { params: itemParams },
    responses: { 204: { description: "Deleted" }, 403: error("Host only"), 404: error("Unknown item") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/media/{itemId}/content",
    operationId: "getEventMediaContent",
    summary: "Private mode: streams the thumbnail or file for the host (?size=thumb|full)",
    security: secured,
    request: { params: itemParams, query: z.object({ size: z.enum(["thumb", "full"]).optional() }) },
    responses: { 200: { description: "Image or video bytes" }, 403: error("No access"), 404: error("Missing") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/cards/{token}/media",
    operationId: "getGuestMedia",
    summary: "Story and gallery for a card link (no login); upload window and the guest's remaining uploads",
    security: secured,
    request: { params: cardParams },
    responses: { 200: json(GuestMediaSchema, "Media"), 404: error("Unknown card"), 410: error("Gallery closed") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/cards/{token}/media/upload-sessions",
    operationId: "createGuestUploadSession",
    summary: "Guest gallery upload from the card link: Drive resumable URL within window and per-guest limits",
    security: secured,
    request: { params: cardParams, body: { content: { "application/json": { schema: UploadSessionInput } } } },
    responses: { 201: json(UploadSessionSchema, "Session"), 404: error("Unknown card"), 409: error("uploads_closed, upload_limit or drive_full"), 422: error("Validation error"), 429: error("Rate limited") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/cards/{token}/media/{itemId}/complete",
    operationId: "completeGuestUpload",
    summary: "Register the guest's Drive file after upload",
    security: secured,
    request: { params: cardItemParams, body: { content: { "application/json": { schema: UploadCompleteInput } } } },
    responses: { 200: json(MediaItemSchema, "Item"), 404: error("Unknown card or item") },
  });
  registry.registerPath({
    method: "delete",
    path: "/api/v1/cards/{token}/media/{itemId}",
    operationId: "deleteGuestMedia",
    summary: "Guest deletes their own upload",
    security: secured,
    request: { params: cardItemParams },
    responses: { 204: { description: "Deleted" }, 403: error("Not your upload"), 404: error("Unknown item") },
  });
  registry.registerPath({
    method: "post",
    path: "/api/v1/cards/{token}/media/{itemId}/report",
    operationId: "reportGuestMedia",
    summary: "Report an item to the host",
    security: secured,
    request: { params: cardItemParams },
    responses: { 204: { description: "Reported" }, 404: error("Unknown item") },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/cards/{token}/media/{itemId}/content",
    operationId: "getGuestMediaContent",
    summary: "Private mode: streams a visible item for a valid card link (?size=thumb|full)",
    security: secured,
    request: { params: cardItemParams, query: z.object({ size: z.enum(["thumb", "full"]).optional() }) },
    responses: { 200: { description: "Image or video bytes" }, 404: error("Unknown or hidden"), 410: error("Gallery closed") },
  });
}
