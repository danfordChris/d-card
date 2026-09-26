import { event, eventMedia, eventPlan, googleConnection, invitation, mediaItem, plan, type PlanEntitlements } from "@dcard/db";
import { and, asc, count, desc, eq, inArray, isNull, ne } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { decryptSecret, encryptSecret } from "../crypto/secrets.js";
import type { DbExecutor } from "../db-types.js";
import { DomainError, NotFoundError, ValidationError } from "../errors.js";
import { hashToken } from "../tokens.js";
import { DriveAccessError, type GoogleOAuth, type MediaStore } from "./store.js";

// Photos and videos in the host's Google Drive (docs/design/features/media.md). D-Card keeps
// ids and metadata; uploads go device → Drive through resumable sessions (MED-2).

export class MediaError extends DomainError {}
const err = (code: string, message: string) => new MediaError(code, message);

export type MediaKind = "card" | "story" | "gallery";
type ItemRow = typeof mediaItem.$inferSelect;
type EventMediaRow = typeof eventMedia.$inferSelect;

const PHOTO_TYPES = new Set(["image/jpeg", "image/png", "image/webp", "image/heic", "image/heif"]);
const VIDEO_TYPES = new Set(["video/mp4", "video/quicktime", "video/webm", "video/3gpp"]);
const MB = 1024 * 1024;
const DAY = 24 * 60 * 60 * 1000;
/** Drive resumable sessions stay valid for a week. */
const SESSION_LIFETIME = 7 * DAY;

export type MediaLimits = {
  cardPhotos: number;
  cardVideos: number;
  cardVideoSeconds: number;
  storyPhotos: number;
  storyVideos: number;
  storyVideoSeconds: number;
  galleryEnabled: boolean;
  galleryVideoSeconds: number;
  galleryUploadsPerGuest: number;
  galleryUploadDays: number;
  galleryOpenMonths: number;
  maxPhotoBytes: number;
  maxVideoBytes: number;
  slideshow: boolean;
};

export function mediaLimits(e: PlanEntitlements["media"]): MediaLimits {
  return {
    cardPhotos: e.cardPhotos,
    cardVideos: e.cardVideoSeconds > 0 ? 1 : 0,
    cardVideoSeconds: e.cardVideoSeconds,
    storyPhotos: e.storyPhotos,
    storyVideos: e.storyVideos,
    storyVideoSeconds: e.storyVideoSeconds,
    galleryEnabled: e.gallery,
    galleryVideoSeconds: e.galleryVideoSeconds,
    galleryUploadsPerGuest: e.galleryUploadsPerGuest,
    galleryUploadDays: e.galleryUploadDaysAfter,
    galleryOpenMonths: e.galleryPageMonths,
    // MED-12: photos are resized on the device; videos are bounded by length and size.
    maxPhotoBytes: 15 * MB,
    maxVideoBytes: e.galleryVideoSeconds > 30 || e.storyVideoSeconds > 60 ? 500 * MB : 200 * MB,
    slideshow: e.slideshow,
  };
}

const mediaEnabled = (l: MediaLimits) => l.galleryEnabled || l.cardPhotos > 0 || l.storyPhotos > 0;

async function loadContext(db: DbExecutor, eventId: string) {
  const [row] = await db
    .select({ ev: event, entitlements: plan.entitlements, em: eventMedia })
    .from(event)
    .innerJoin(eventPlan, eq(eventPlan.eventId, event.id))
    .innerJoin(plan, eq(plan.id, eventPlan.planId))
    .leftJoin(eventMedia, eq(eventMedia.eventId, event.id))
    .where(eq(event.id, eventId));
  if (!row) throw new NotFoundError("Event not found.");
  return { ev: row.ev, limits: mediaLimits(row.entitlements.media), em: row.em };
}

async function connectionToken(db: DbExecutor, em: EventMediaRow | null): Promise<{ refreshToken: string; email: string } | null> {
  if (!em?.connectionId) return null;
  const [c] = await db.select().from(googleConnection).where(and(eq(googleConnection.id, em.connectionId), isNull(googleConnection.revokedAt)));
  return c ? { refreshToken: decryptSecret(c.refreshTokenEnc), email: c.googleEmail } : null;
}

async function markDriveProblem(db: DbExecutor, eventId: string, e: unknown): Promise<never> {
  if (e instanceof DriveAccessError) {
    if (e.driveFull) {
      await db.update(eventMedia).set({ driveFull: true }).where(eq(eventMedia.eventId, eventId));
      throw err("drive_full", "The host's Google Drive is full. Uploads are paused.");
    }
    if (e.needsReconnect) {
      await db.update(eventMedia).set({ needsReconnect: true }).where(eq(eventMedia.eventId, eventId));
      throw err("drive_not_connected", "Google Drive needs to be reconnected by the host.");
    }
    throw err("drive_unavailable", "Google Drive is not responding. Try again.");
  }
  throw e;
}

// ── URLs ─────────────────────────────────────────────────────────────────────

export type MediaUrlBase = { kind: "host"; eventId: string } | { kind: "card"; token: string };

function urlsFor(item: ItemRow, mode: "private" | "link", base: MediaUrlBase) {
  if (mode === "link" && item.driveFileId) {
    const id = encodeURIComponent(item.driveFileId);
    return {
      thumbnailUrl: `https://drive.google.com/thumbnail?id=${id}&sz=w1600`,
      url: item.type === "video" ? `https://drive.google.com/uc?export=download&id=${id}` : `https://drive.google.com/uc?export=view&id=${id}`,
    };
  }
  const root = base.kind === "host" ? `/api/v1/events/${base.eventId}/media/${item.id}/content` : `/api/v1/cards/${base.token}/media/${item.id}/content`;
  return { thumbnailUrl: `${root}?size=thumb`, url: `${root}?size=full` };
}

function itemView(item: ItemRow & { uploaderName?: string | null }, mode: "private" | "link", base: MediaUrlBase, mineInvitationId: string | null = null) {
  return {
    id: item.id,
    kind: item.kind,
    type: item.type,
    mimeType: item.mimeType,
    sizeBytes: item.sizeBytes,
    durationSeconds: item.durationSeconds,
    status: item.status,
    uploadedBy: item.kind === "gallery" ? (item.uploaderName ?? null) : null,
    mine: Boolean(mineInvitationId && item.invitationId === mineInvitationId),
    ...urlsFor(item, mode, base),
    createdAt: item.createdAt,
  };
}

// ── Settings and connection ─────────────────────────────────────────────────

async function counts(db: DbExecutor, eventId: string) {
  const rows = await db
    .select({ kind: mediaItem.kind, type: mediaItem.type, n: count() })
    .from(mediaItem)
    .where(and(eq(mediaItem.eventId, eventId), inArray(mediaItem.status, ["uploading", "visible", "hidden", "reported", "missing"])))
    .groupBy(mediaItem.kind, mediaItem.type);
  const get = (k: MediaKind, t: "photo" | "video") => rows.find((r) => r.kind === k && r.type === t)?.n ?? 0;
  return { cardPhotos: get("card", "photo"), cardVideos: get("card", "video"), storyPhotos: get("story", "photo"), storyVideos: get("story", "video"), gallery: get("gallery", "photo") + get("gallery", "video") };
}

export async function getMediaSettings(db: DbExecutor, store: MediaStore, userId: string, eventId: string) {
  await requireEventRole(db, { userId, eventId, roles: ["committee"] });
  const { ev, limits, em } = await loadContext(db, eventId);
  const conn = await connectionToken(db, em);
  let quota: { limitBytes: number | null; usageBytes: number } | null = null;
  let needsReconnect = em?.needsReconnect ?? false;
  if (conn && !needsReconnect) {
    try {
      quota = await store.getQuota(conn.refreshToken);
    } catch (e) {
      if (e instanceof DriveAccessError && e.needsReconnect) {
        needsReconnect = true;
        await db.update(eventMedia).set({ needsReconnect: true }).where(eq(eventMedia.eventId, eventId));
      }
    }
  }
  const [issued] = await db.select({ n: count() }).from(invitation).where(and(eq(invitation.eventId, eventId), eq(invitation.status, "issued")));
  // MED-10: warn when the space left looks small for the expected uploads (~20 MB per guest card).
  const left = quota?.limitBytes != null ? quota.limitBytes - quota.usageBytes : null;
  const quotaWarning = left !== null && limits.galleryEnabled && left < Math.max(1024 * MB, (issued?.n ?? 0) * 20 * MB);
  if (quota && left !== null) {
    const full = left <= 0;
    if (full !== (em?.driveFull ?? false)) await db.update(eventMedia).set({ driveFull: full }).where(eq(eventMedia.eventId, eventId));
  }
  return {
    mediaEnabled: mediaEnabled(limits),
    connected: Boolean(conn),
    googleEmail: conn?.email ?? null,
    needsReconnect,
    sharingMode: em?.sharingMode ?? "private",
    folderUrl: em?.folderId ? `https://drive.google.com/drive/folders/${em.folderId}` : null,
    quotaUsedBytes: quota?.usageBytes ?? null,
    quotaLimitBytes: quota?.limitBytes ?? null,
    quotaWarning,
    googlePhotosUrl: ev.photoAlbumUrl,
    limits,
    counts: await counts(db, eventId),
  };
}

/** Creates the event folder and subfolders once, and applies the sharing mode (MED-1, MED-1a). */
async function ensureFolders(db: DbExecutor, store: MediaStore, refreshToken: string, eventId: string, title: string): Promise<void> {
  const [em] = await db.select().from(eventMedia).where(eq(eventMedia.eventId, eventId));
  if (em?.folderId && (await store.getFile(refreshToken, em.folderId))) return;
  const root = await store.createFolder(refreshToken, `D-Card – ${title}`);
  const [card, story, gallery] = [
    await store.createFolder(refreshToken, "card", root.id),
    await store.createFolder(refreshToken, "story", root.id),
    await store.createFolder(refreshToken, "gallery", root.id),
  ];
  await db
    .update(eventMedia)
    .set({ folderId: root.id, cardFolderId: card.id, storyFolderId: story.id, galleryFolderId: gallery.id })
    .where(eq(eventMedia.eventId, eventId));
  if ((em?.sharingMode ?? "private") === "link") await store.setLinkSharing(refreshToken, root.id, true);
}

export async function completeGoogleConnect(db: DbExecutor, store: MediaStore, oauth: GoogleOAuth, params: { userId: string; eventId: string; code: string }): Promise<void> {
  await requireEventRole(db, { userId: params.userId, eventId: params.eventId, roles: [] });
  const { ev, limits } = await loadContext(db, params.eventId);
  if (!mediaEnabled(limits)) throw err("plan_limit", "This plan has no photos or videos.");
  const granted = await oauth.exchange(params.code);
  await db.update(googleConnection).set({ revokedAt: new Date() }).where(and(eq(googleConnection.userId, params.userId), isNull(googleConnection.revokedAt)));
  const [conn] = await db
    .insert(googleConnection)
    .values({ userId: params.userId, googleEmail: granted.email, refreshTokenEnc: encryptSecret(granted.refreshToken), scopes: granted.scopes })
    .returning();
  // The host's other events keep using the account they were connected with; this event moves to the new one.
  await db
    .insert(eventMedia)
    .values({ eventId: params.eventId, connectionId: conn!.id })
    .onConflictDoUpdate({ target: eventMedia.eventId, set: { connectionId: conn!.id, needsReconnect: false, driveFull: false } });
  await db
    .update(eventMedia)
    .set({ connectionId: conn!.id, needsReconnect: false })
    .where(and(inArray(eventMedia.eventId, db.select({ id: event.id }).from(event).where(eq(event.hostUserId, params.userId))), eq(eventMedia.needsReconnect, true)));
  try {
    await ensureFolders(db, store, granted.refreshToken, params.eventId, ev.title);
  } catch (e) {
    await markDriveProblem(db, params.eventId, e);
  }
  await recordAudit(db, { actorUserId: params.userId, eventId: params.eventId, action: "media.drive_connected", targetType: "google_connection", targetId: conn!.id, newValue: { email: granted.email } });
}

/** MED-1: disconnect; files stay in the host's Drive, D-Card shows a reconnect prompt. */
export async function disconnectGoogle(db: DbExecutor, userId: string): Promise<void> {
  const active = await db.select().from(googleConnection).where(and(eq(googleConnection.userId, userId), isNull(googleConnection.revokedAt)));
  if (!active.length) return;
  await db.update(googleConnection).set({ revokedAt: new Date() }).where(inArray(googleConnection.id, active.map((c) => c.id)));
  await db.update(eventMedia).set({ needsReconnect: true }).where(inArray(eventMedia.connectionId, active.map((c) => c.id)));
  await recordAudit(db, { actorUserId: userId, action: "media.drive_disconnected", targetType: "google_connection", targetId: active[0]!.id });
}

export async function updateMediaSettings(
  db: DbExecutor,
  store: MediaStore,
  userId: string,
  eventId: string,
  input: { sharingMode?: "private" | "link" | null; googlePhotosUrl?: string | null },
) {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const { em } = await loadContext(db, eventId);
  if (input.googlePhotosUrl !== undefined && input.googlePhotosUrl !== null) {
    const url = input.googlePhotosUrl.trim();
    if (url && !/^https:\/\/(photos\.app\.goo\.gl|photos\.google\.com)\//.test(url)) {
      throw new ValidationError("Use a Google Photos shared-album link.", [{ path: "googlePhotosUrl", message: "Google Photos link only." }]);
    }
    await db.update(event).set({ photoAlbumUrl: url || null }).where(eq(event.id, eventId));
  }
  if (input.sharingMode && input.sharingMode !== (em?.sharingMode ?? "private")) {
    const conn = await connectionToken(db, em);
    if (!conn || !em?.folderId) throw err("drive_not_connected", "Connect Google Drive first.");
    try {
      await store.setLinkSharing(conn.refreshToken, em.folderId, input.sharingMode === "link");
    } catch (e) {
      await markDriveProblem(db, eventId, e);
    }
    await db.update(eventMedia).set({ sharingMode: input.sharingMode }).where(eq(eventMedia.eventId, eventId));
    await recordAudit(db, { actorUserId: userId, eventId, action: "media.sharing_changed", targetType: "event", targetId: eventId, oldValue: { sharingMode: em.sharingMode }, newValue: { sharingMode: input.sharingMode } });
  }
  return getMediaSettings(db, store, userId, eventId);
}

// ── Uploads ──────────────────────────────────────────────────────────────────

type UploadInput = { kind: MediaKind; fileName: string; mimeType: string; sizeBytes: number; durationSeconds?: number | null };

function classify(input: UploadInput, limits: MediaLimits, maxVideoSeconds: number): "photo" | "video" {
  const mime = input.mimeType.toLowerCase();
  const type = PHOTO_TYPES.has(mime) ? "photo" : VIDEO_TYPES.has(mime) ? "video" : null;
  if (!type) throw new ValidationError("Only photos (JPEG, PNG, WebP, HEIC) and videos (MP4, MOV, WebM) can be added.", [{ path: "mimeType", message: "Unsupported type." }]);
  if (type === "photo" && input.sizeBytes > limits.maxPhotoBytes) throw new ValidationError("This photo is too large.", [{ path: "sizeBytes", message: "Too large." }]);
  if (type === "video") {
    if (input.sizeBytes > limits.maxVideoBytes) throw new ValidationError("This video is too large.", [{ path: "sizeBytes", message: "Too large." }]);
    if (input.durationSeconds == null) throw new ValidationError("Video length is required.", [{ path: "durationSeconds", message: "Required." }]);
    if (input.durationSeconds > maxVideoSeconds) throw new ValidationError(`Videos can be at most ${maxVideoSeconds} seconds.`, [{ path: "durationSeconds", message: "Too long." }]);
  }
  return type;
}

async function startSession(
  db: DbExecutor,
  store: MediaStore,
  ctx: { eventId: string; em: EventMediaRow | null; origin: string },
  input: UploadInput,
  type: "photo" | "video",
  owner: { invitationId?: string; userId?: string },
) {
  const conn = await connectionToken(db, ctx.em);
  if (!conn || !ctx.em || ctx.em.needsReconnect) throw err("drive_not_connected", "Google Drive is not connected for this event.");
  if (ctx.em.driveFull) throw err("drive_full", "The host's Google Drive is full. Uploads are paused.");
  const folderId = input.kind === "card" ? ctx.em.cardFolderId : input.kind === "story" ? ctx.em.storyFolderId : ctx.em.galleryFolderId;
  if (!folderId) throw err("drive_not_connected", "The event folder is missing. Reconnect Google Drive.");
  const [item] = await db
    .insert(mediaItem)
    .values({
      eventId: ctx.eventId,
      kind: input.kind,
      type,
      invitationId: owner.invitationId ?? null,
      uploadedByUserId: owner.userId ?? null,
      fileName: input.fileName.slice(0, 200),
      mimeType: input.mimeType.toLowerCase(),
      sizeBytes: input.sizeBytes,
      durationSeconds: input.durationSeconds ?? null,
    })
    .returning();
  try {
    const safeName = input.fileName.replace(/[^\w.\- ]+/g, "_").slice(0, 120);
    const uploadUrl = await store.createUploadSession(conn.refreshToken, { folderId, name: `${input.kind}-${item!.id.slice(0, 8)}-${safeName}`, mimeType: input.mimeType, size: input.sizeBytes }, ctx.origin);
    return { mediaItemId: item!.id, uploadUrl, expiresAt: new Date(Date.now() + SESSION_LIFETIME) };
  } catch (e) {
    await db.update(mediaItem).set({ status: "deleted" }).where(eq(mediaItem.id, item!.id));
    return markDriveProblem(db, ctx.eventId, e);
  }
}

/** Host uploads for the card and story (MED-3, MED-5) within the plan's counts. */
export async function createHostUploadSession(db: DbExecutor, store: MediaStore, userId: string, eventId: string, input: UploadInput, origin: string) {
  await requireEventRole(db, { userId, eventId, roles: [] });
  if (input.kind === "gallery") throw new ValidationError("Gallery uploads come from guests' card links.", [{ path: "kind", message: "card or story" }]);
  const { limits, em } = await loadContext(db, eventId);
  const maxSeconds = input.kind === "card" ? limits.cardVideoSeconds : limits.storyVideoSeconds;
  const type = classify(input, limits, maxSeconds);
  const c = await counts(db, eventId);
  const [used, allowed] =
    input.kind === "card"
      ? type === "photo"
        ? [c.cardPhotos, limits.cardPhotos]
        : [c.cardVideos, limits.cardVideos]
      : type === "photo"
        ? [c.storyPhotos, limits.storyPhotos]
        : [c.storyVideos, limits.storyVideos];
  if (used >= allowed) throw err("plan_limit", allowed === 0 ? "This plan does not include this." : `This plan allows ${allowed} here.`);
  return startSession(db, store, { eventId, em, origin }, input, type, { userId });
}

async function completeItem(db: DbExecutor, store: MediaStore, eventId: string, item: ItemRow, driveFileId: string) {
  if (item.status !== "uploading") return item;
  const { em } = await loadContext(db, eventId);
  const conn = await connectionToken(db, em);
  if (!conn || !em) throw err("drive_not_connected", "Google Drive is not connected for this event.");
  const folderId = item.kind === "card" ? em.cardFolderId : item.kind === "story" ? em.storyFolderId : em.galleryFolderId;
  let file;
  try {
    file = await store.getFile(conn.refreshToken, driveFileId);
  } catch (e) {
    return markDriveProblem(db, eventId, e);
  }
  // Only a file D-Card created in this event's folder can be registered (drive.file scope).
  if (!file || file.trashed || !folderId || !file.parents.includes(folderId)) throw new ValidationError("The uploaded file was not found in the event folder.", [{ path: "driveFileId", message: "Not found." }]);
  const [updated] = await db
    .update(mediaItem)
    .set({ driveFileId: file.id, sizeBytes: file.size || item.sizeBytes, status: "visible", completedAt: new Date() })
    .where(and(eq(mediaItem.id, item.id), eq(mediaItem.status, "uploading")))
    .returning();
  return updated ?? item;
}

async function hostItem(db: DbExecutor, eventId: string, itemId: string): Promise<ItemRow> {
  const [item] = await db.select().from(mediaItem).where(and(eq(mediaItem.id, itemId), eq(mediaItem.eventId, eventId), ne(mediaItem.status, "deleted")));
  if (!item) throw new NotFoundError("Media not found.");
  return item;
}

export async function completeHostUpload(db: DbExecutor, store: MediaStore, userId: string, eventId: string, itemId: string, driveFileId: string) {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const item = await completeItem(db, store, eventId, await hostItem(db, eventId, itemId), driveFileId);
  const { em } = await loadContext(db, eventId);
  return itemView(item, em?.sharingMode ?? "private", { kind: "host", eventId });
}

export async function listEventMedia(db: DbExecutor, userId: string, eventId: string, kind?: MediaKind) {
  await requireEventRole(db, { userId, eventId, roles: ["committee"] });
  const { em } = await loadContext(db, eventId);
  const rows = await db
    .select({ item: mediaItem, uploaderName: invitation.guestName })
    .from(mediaItem)
    .leftJoin(invitation, eq(invitation.id, mediaItem.invitationId))
    .where(and(eq(mediaItem.eventId, eventId), inArray(mediaItem.status, ["visible", "hidden", "reported", "missing"]), kind ? eq(mediaItem.kind, kind) : undefined))
    .orderBy(desc(mediaItem.reportedAt), asc(mediaItem.createdAt));
  return rows.map((r) => itemView({ ...r.item, uploaderName: r.uploaderName }, em?.sharingMode ?? "private", { kind: "host", eventId }));
}

export async function setMediaStatus(db: DbExecutor, userId: string, eventId: string, itemId: string, status: "visible" | "hidden") {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const item = await hostItem(db, eventId, itemId);
  const [updated] = await db.update(mediaItem).set({ status, ...(status === "visible" ? { reportedAt: null } : {}) }).where(eq(mediaItem.id, item.id)).returning();
  await recordAudit(db, { actorUserId: userId, eventId, action: `media.${status === "visible" ? "shown" : "hidden"}`, targetType: "media_item", targetId: itemId, oldValue: { status: item.status }, newValue: { status } });
  const { em } = await loadContext(db, eventId);
  return itemView(updated!, em?.sharingMode ?? "private", { kind: "host", eventId });
}

async function removeItem(db: DbExecutor, store: MediaStore, eventId: string, item: ItemRow) {
  const { em } = await loadContext(db, eventId);
  const conn = await connectionToken(db, em);
  if (conn && item.driveFileId) {
    try {
      await store.deleteFile(conn.refreshToken, item.driveFileId);
    } catch (e) {
      if (!(e instanceof DriveAccessError)) throw e; // record the deletion even if Drive is unreachable
    }
  }
  await db.update(mediaItem).set({ status: "deleted" }).where(eq(mediaItem.id, item.id));
}

export async function deleteEventMedia(db: DbExecutor, store: MediaStore, userId: string, eventId: string, itemId: string) {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const item = await hostItem(db, eventId, itemId);
  await removeItem(db, store, eventId, item);
  await recordAudit(db, { actorUserId: userId, eventId, action: "media.deleted", targetType: "media_item", targetId: itemId, oldValue: { kind: item.kind, invitationId: item.invitationId } });
}

// ── Guests (card link, no login) ─────────────────────────────────────────────

async function cardContext(db: DbExecutor, token: string) {
  if (!/^[A-Za-z0-9_-]{20,100}$/.test(token)) throw new NotFoundError("Card not found.");
  const [row] = await db.select({ i: invitation }).from(invitation).where(eq(invitation.linkTokenHash, hashToken(token)));
  if (!row || row.i.status !== "issued") throw new NotFoundError("Card not found.");
  const ctx = await loadContext(db, row.i.eventId);
  return { inv: row.i, ...ctx };
}

const addMonths = (d: Date, months: number) => {
  const x = new Date(d);
  x.setUTCMonth(x.getUTCMonth() + months);
  return x;
};

/** Upload window: from the start of the event day until N days after the event (MED-6); page open for the plan's months (MED-11). */
export function galleryWindow(ev: { startsAt: Date; endsAt: Date | null }, limits: MediaLimits) {
  const end = ev.endsAt ?? new Date(ev.startsAt.getTime() + 12 * 60 * 60 * 1000);
  const opensAt = new Date(ev.startsAt.getTime() - 12 * 60 * 60 * 1000);
  return { opensAt, closesAt: new Date(end.getTime() + limits.galleryUploadDays * DAY), pageClosesAt: addMonths(end, limits.galleryOpenMonths) };
}

function uploadsClosedReason(ctx: Awaited<ReturnType<typeof cardContext>>, now: Date): string | null {
  if (!ctx.limits.galleryEnabled) return "not_available";
  if (!ctx.em?.connectionId || ctx.em.needsReconnect || !ctx.em.galleryFolderId) return "not_available";
  const w = galleryWindow(ctx.ev, ctx.limits);
  if (now >= w.pageClosesAt) return "gallery_closed";
  if (now < w.opensAt) return "not_started";
  if (now >= w.closesAt) return "window_closed";
  if (ctx.em.driveFull) return "drive_full";
  return null;
}

async function myUploads(db: DbExecutor, invitationId: string): Promise<number> {
  const [r] = await db.select({ n: count() }).from(mediaItem).where(and(eq(mediaItem.invitationId, invitationId), eq(mediaItem.kind, "gallery"), ne(mediaItem.status, "deleted")));
  return r?.n ?? 0;
}

export async function getGuestMedia(db: DbExecutor, token: string, now = new Date()) {
  const ctx = await cardContext(db, token);
  const w = galleryWindow(ctx.ev, ctx.limits);
  if (ctx.limits.galleryEnabled && now >= w.pageClosesAt) throw err("gallery_closed", "This gallery has closed.");
  const mode = ctx.em?.sharingMode ?? "private";
  const base: MediaUrlBase = { kind: "card", token };
  const rows = await db
    .select({ item: mediaItem, uploaderName: invitation.guestName })
    .from(mediaItem)
    .leftJoin(invitation, eq(invitation.id, mediaItem.invitationId))
    .where(and(eq(mediaItem.eventId, ctx.ev.id), inArray(mediaItem.kind, ["story", "gallery"]), eq(mediaItem.status, "visible")))
    .orderBy(asc(mediaItem.createdAt));
  const reason = uploadsClosedReason(ctx, now);
  const used = await myUploads(db, ctx.inv.id);
  return {
    story: rows.filter((r) => r.item.kind === "story").map((r) => itemView(r.item, mode, base, ctx.inv.id)),
    gallery: ctx.limits.galleryEnabled ? rows.filter((r) => r.item.kind === "gallery").map((r) => itemView({ ...r.item, uploaderName: r.uploaderName }, mode, base, ctx.inv.id)) : [],
    galleryEnabled: ctx.limits.galleryEnabled,
    uploadsOpen: reason === null,
    uploadsClosedReason: reason,
    uploadsClosesAt: ctx.limits.galleryEnabled ? w.closesAt : null,
    myUploadsLeft: Math.max(0, ctx.limits.galleryUploadsPerGuest - used),
    limits: ctx.limits,
  };
}

export async function createGuestUploadSession(db: DbExecutor, store: MediaStore, token: string, input: UploadInput, origin: string, now = new Date()) {
  const ctx = await cardContext(db, token);
  const reason = uploadsClosedReason(ctx, now);
  if (reason) throw err(reason === "drive_full" ? "drive_full" : "uploads_closed", "Uploads are closed for this event.");
  const type = classify({ ...input, kind: "gallery" }, ctx.limits, ctx.limits.galleryVideoSeconds);
  if ((await myUploads(db, ctx.inv.id)) >= ctx.limits.galleryUploadsPerGuest) throw err("upload_limit", `You can add up to ${ctx.limits.galleryUploadsPerGuest} photos and videos.`);
  return startSession(db, store, { eventId: ctx.ev.id, em: ctx.em, origin }, { ...input, kind: "gallery" }, type, { invitationId: ctx.inv.id });
}

async function guestItem(db: DbExecutor, token: string, itemId: string) {
  const ctx = await cardContext(db, token);
  const [item] = await db.select().from(mediaItem).where(and(eq(mediaItem.id, itemId), eq(mediaItem.eventId, ctx.ev.id), ne(mediaItem.status, "deleted")));
  if (!item) throw new NotFoundError("Media not found.");
  return { ctx, item };
}

export async function completeGuestUpload(db: DbExecutor, store: MediaStore, token: string, itemId: string, driveFileId: string) {
  const { ctx, item } = await guestItem(db, token, itemId);
  if (item.invitationId !== ctx.inv.id) throw new NotFoundError("Media not found.");
  const done = await completeItem(db, store, ctx.ev.id, item, driveFileId);
  return itemView({ ...done, uploaderName: ctx.inv.guestName }, ctx.em?.sharingMode ?? "private", { kind: "card", token }, ctx.inv.id);
}

export async function deleteGuestMedia(db: DbExecutor, store: MediaStore, token: string, itemId: string) {
  const { ctx, item } = await guestItem(db, token, itemId);
  if (item.invitationId !== ctx.inv.id) throw err("forbidden", "You can only delete your own uploads.");
  await removeItem(db, store, ctx.ev.id, item);
  await recordAudit(db, { actorUserId: null, eventId: ctx.ev.id, action: "media.deleted_by_guest", targetType: "media_item", targetId: itemId, newValue: { invitationId: ctx.inv.id } });
}

export async function reportGuestMedia(db: DbExecutor, token: string, itemId: string) {
  const { ctx, item } = await guestItem(db, token, itemId);
  if (item.status !== "visible") return;
  await db.update(mediaItem).set({ status: "reported", reportedAt: new Date() }).where(eq(mediaItem.id, item.id));
  await recordAudit(db, { actorUserId: null, eventId: ctx.ev.id, action: "media.reported", targetType: "media_item", targetId: itemId, newValue: { byInvitationId: ctx.inv.id } });
}

// ── Private-mode streaming (MED-1a, MED-7) ───────────────────────────────────

async function streamItem(db: DbExecutor, store: MediaStore, eventId: string, em: EventMediaRow | null, item: ItemRow, size: "thumb" | "full", range?: string | null): Promise<Response> {
  const conn = await connectionToken(db, em);
  if (!conn || !item.driveFileId) return new Response(null, { status: 404 });
  let res: Response;
  try {
    res = await store.stream(conn.refreshToken, item.driveFileId, { thumbnail: size === "thumb" && item.type === "photo", range });
  } catch (e) {
    if (e instanceof DriveAccessError && e.needsReconnect) await db.update(eventMedia).set({ needsReconnect: true }).where(eq(eventMedia.eventId, eventId));
    return new Response(null, { status: 404 });
  }
  if (res.status === 404) {
    // MED-13: the host deleted the file in Drive; hide it and let the host see it as missing.
    await db.update(mediaItem).set({ status: "missing" }).where(eq(mediaItem.id, item.id));
    return new Response(null, { status: 404 });
  }
  const headers = new Headers();
  for (const h of ["content-type", "content-length", "content-range", "accept-ranges"]) {
    const v = res.headers.get(h);
    if (v) headers.set(h, v);
  }
  headers.set("cache-control", "private, max-age=3600");
  return new Response(res.body, { status: res.status, headers });
}

export async function hostMediaContent(db: DbExecutor, store: MediaStore, userId: string, eventId: string, itemId: string, size: "thumb" | "full", range?: string | null) {
  await requireEventRole(db, { userId, eventId, roles: ["committee"] });
  const item = await hostItem(db, eventId, itemId);
  const { em } = await loadContext(db, eventId);
  return streamItem(db, store, eventId, em, item, size, range);
}

export async function guestMediaContent(db: DbExecutor, store: MediaStore, token: string, itemId: string, size: "thumb" | "full", range?: string | null, now = new Date()) {
  const { ctx, item } = await guestItem(db, token, itemId);
  if (item.status !== "visible" || item.kind === "card") return new Response(null, { status: 404 });
  if (ctx.limits.galleryEnabled && now >= galleryWindow(ctx.ev, ctx.limits).pageClosesAt) return new Response(null, { status: 410 });
  return streamItem(db, store, ctx.ev.id, ctx.em, item, size, range);
}

/** Visible card media for the host's card page and renderers (MED-3). */
export async function cardMediaIds(db: DbExecutor, eventId: string): Promise<string[]> {
  const rows = await db.select({ id: mediaItem.id }).from(mediaItem).where(and(eq(mediaItem.eventId, eventId), eq(mediaItem.kind, "card"), eq(mediaItem.status, "visible")));
  return rows.map((r) => r.id);
}

