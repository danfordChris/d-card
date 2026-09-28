import { eventMedia, eventRole, googleConnection, invitation, mediaItem, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  addGuest,
  completeGoogleConnect,
  completeGuestUpload,
  completeHostUpload,
  createGuestUploadSession,
  createHostUploadSession,
  decryptSecret,
  deleteGuestMedia,
  disconnectGoogle,
  FakeMediaStore,
  ForbiddenError,
  galleryWindow,
  getGuestMedia,
  getMediaSettings,
  guestMediaContent,
  issueCard,
  listEventMedia,
  MediaError,
  mediaLimits,
  reportGuestMedia,
  setMediaStatus,
  signOAuthState,
  updateMediaSettings,
  ValidationError,
  verifyOAuthState,
  type GoogleOAuth,
} from "../src/index.js";
import { createPaidEvent } from "./helpers.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let committeeId: string;
const store = new FakeMediaStore();
const oauth: GoogleOAuth = { exchange: async (code) => ({ refreshToken: `refresh-${code}`, email: "host@gmail.com", scopes: "https://www.googleapis.com/auth/drive.file openid email" }) };
const ORIGIN = "https://api.dcard.test";
const DURING = new Date("2026-12-12T15:00:00Z");
let n = 0;

const code = (e: unknown) => (e instanceof MediaError ? e.code : e);
const photo = (kind: "card" | "story" | "gallery" = "story", sizeBytes = 2_000_000) => ({ kind, fileName: "picha.jpg", mimeType: "image/jpeg", sizeBytes });

async function newEvent(planKey: "msingi" | "kawaida" | "premium" = "kawaida") {
  const eventId = await createPaidEvent(handle.db, hostId, {
    planKey,
    eventTypeKey: "wedding",
    title: `Harusi ${++n}`,
    startsAt: new Date("2026-12-12T12:00:00Z"),
    endsAt: new Date("2026-12-12T20:00:00Z"),
    contactName: "Asha",
    contactPhone: "0754123456",
  });
  return eventId;
}
async function guestCard(eventId: string) {
  const { guest } = await addGuest(handle.db, hostId, eventId, { name: `Mgeni ${++n}`, phone: `07131${String(n).padStart(5, "0")}`, consent: true });
  await issueCard(handle.db, hostId, eventId, guest.id);
  const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, guest.id));
  return { invitationId: guest.id, token: decryptSecret(row!.linkTokenEnc!) };
}
async function folders(eventId: string) {
  const [em] = await handle.db.select().from(eventMedia).where(eq(eventMedia.eventId, eventId));
  return em!;
}
/** Simulates the browser upload finishing in Drive, then registers it. */
async function uploadAsHost(eventId: string, input = photo()) {
  const s = await createHostUploadSession(handle.db, store, hostId, eventId, input, ORIGIN);
  const em = await folders(eventId);
  const fileId = store.addUploadedFile(input.kind === "card" ? em.cardFolderId! : em.storyFolderId!, { name: "x", mimeType: input.mimeType, size: input.sizeBytes });
  return completeHostUpload(handle.db, store, hostId, eventId, s.mediaItemId, fileId);
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_media", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "committee"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  [hostId, committeeId] = users.map((u) => u.id) as [string, string];
});

afterAll(async () => {
  await handle?.close();
});

describe("connect and settings", () => {
  it("signs OAuth state and rejects tampering or expiry", () => {
    const s = signOAuthState({ userId: "u1", eventId: "e1" }, "secret");
    expect(verifyOAuthState(s, "secret")).toEqual({ userId: "u1", eventId: "e1" });
    expect(verifyOAuthState(s, "other")).toBeNull();
    expect(verifyOAuthState(s.replace(/.$/, "x"), "secret")).toBeNull();
    expect(verifyOAuthState(s, "secret", Date.now() + 20 * 60_000)).toBeNull();
  });

  it("connects Drive once per event with card/story/gallery folders, encrypted token, and switches sharing mode", async () => {
    const eventId = await newEvent("kawaida");
    await handle.db.insert(eventRole).values({ eventId, userId: committeeId, role: "committee" });
    const before = await getMediaSettings(handle.db, store, committeeId, eventId);
    expect(before).toMatchObject({ mediaEnabled: true, connected: false, sharingMode: "private" });
    await completeGoogleConnect(handle.db, store, oauth, { userId: hostId, eventId, code: "c1" });
    const em = await folders(eventId);
    expect(em.cardFolderId && em.storyFolderId && em.galleryFolderId).toBeTruthy();
    expect(store.files.get(em.folderId!)!.name).toMatch(/^D-Card – Harusi/);
    const [conn] = await handle.db.select().from(googleConnection).where(eq(googleConnection.userId, hostId));
    expect(conn!.refreshTokenEnc).not.toContain("refresh-c1");
    const s = await getMediaSettings(handle.db, store, hostId, eventId);
    expect(s).toMatchObject({ connected: true, googleEmail: "host@gmail.com", quotaLimitBytes: store.quota.limitBytes, folderUrl: expect.stringContaining(em.folderId!) });
    await expect(updateMediaSettings(handle.db, store, committeeId, eventId, { sharingMode: "link" })).rejects.toBeInstanceOf(ForbiddenError);
    await updateMediaSettings(handle.db, store, hostId, eventId, { sharingMode: "link" });
    expect(store.files.get(em.folderId!)!.anyone).toBe(true);
    // Reconnecting keeps the existing folders.
    await completeGoogleConnect(handle.db, store, oauth, { userId: hostId, eventId, code: "c2" });
    expect((await folders(eventId)).folderId).toBe(em.folderId);
    await expect(updateMediaSettings(handle.db, store, hostId, eventId, { googlePhotosUrl: "https://evil.example/album" })).rejects.toBeInstanceOf(ValidationError);
    expect((await updateMediaSettings(handle.db, store, hostId, eventId, { googlePhotosUrl: "https://photos.app.goo.gl/abc" })).googlePhotosUrl).toBe("https://photos.app.goo.gl/abc");
  });

  it("offers only the Google Photos link on Msingi", async () => {
    const eventId = await newEvent("msingi");
    expect((await getMediaSettings(handle.db, store, hostId, eventId)).mediaEnabled).toBe(false);
    await expect(completeGoogleConnect(handle.db, store, oauth, { userId: hostId, eventId, code: "m" }).catch(code)).resolves.toBe("plan_limit");
  });
});

describe("host uploads", () => {
  it("issues resumable sessions within plan limits and registers only files in the event folder", async () => {
    const eventId = await newEvent("kawaida");
    await expect(createHostUploadSession(handle.db, store, hostId, eventId, photo("card"), ORIGIN).catch(code)).resolves.toBe("drive_not_connected");
    await completeGoogleConnect(handle.db, store, oauth, { userId: hostId, eventId, code: "h1" });
    const s = await createHostUploadSession(handle.db, store, hostId, eventId, photo("card"), ORIGIN);
    expect(s.uploadUrl).toMatch(/^https:\/\/upload\.fake-drive/);
    expect(store.sessions.at(-1)).toMatchObject({ origin: ORIGIN, mimeType: "image/jpeg" });
    // A file outside the event folder cannot be registered.
    const stray = store.addUploadedFile("some-other-folder", { name: "x", mimeType: "image/jpeg", size: 10 });
    await expect(completeHostUpload(handle.db, store, hostId, eventId, s.mediaItemId, stray)).rejects.toBeInstanceOf(ValidationError);
    const fileId = store.addUploadedFile((await folders(eventId)).cardFolderId!, { name: "x", mimeType: "image/jpeg", size: 10 });
    expect(await completeHostUpload(handle.db, store, hostId, eventId, s.mediaItemId, fileId)).toMatchObject({ kind: "card", status: "visible", thumbnailUrl: `/api/v1/events/${eventId}/media/${s.mediaItemId}/content?size=thumb` });
    // Kawaida: 5 card photos, 1 video ≤ 30 s.
    for (let i = 0; i < 4; i++) await uploadAsHost(eventId, photo("card"));
    await expect(createHostUploadSession(handle.db, store, hostId, eventId, photo("card"), ORIGIN).catch(code)).resolves.toBe("plan_limit");
    const longVideo = { kind: "card" as const, fileName: "v.mp4", mimeType: "video/mp4", sizeBytes: 5_000_000, durationSeconds: 45 };
    await expect(createHostUploadSession(handle.db, store, hostId, eventId, longVideo, ORIGIN)).rejects.toBeInstanceOf(ValidationError);
    await createHostUploadSession(handle.db, store, hostId, eventId, { ...longVideo, durationSeconds: 25 }, ORIGIN);
    await expect(createHostUploadSession(handle.db, store, hostId, eventId, { ...photo("story"), mimeType: "application/pdf" }, ORIGIN)).rejects.toBeInstanceOf(ValidationError);
    expect((await listEventMedia(handle.db, hostId, eventId, "card")).length).toBe(5);
  });

  it("pauses uploads when the Drive is full and flags reconnect when access is revoked", async () => {
    const eventId = await newEvent("kawaida");
    await completeGoogleConnect(handle.db, store, oauth, { userId: hostId, eventId, code: "q1" });
    const saved = store.quota;
    store.quota = { limitBytes: 100, usageBytes: 100 };
    await expect(createHostUploadSession(handle.db, store, hostId, eventId, photo("story"), ORIGIN).catch(code)).resolves.toBe("drive_full");
    expect((await folders(eventId)).driveFull).toBe(true);
    store.quota = saved;
    expect((await getMediaSettings(handle.db, store, hostId, eventId)).quotaWarning).toBe(false);
    expect((await folders(eventId)).driveFull).toBe(false);
    store.revoked = true;
    expect((await getMediaSettings(handle.db, store, hostId, eventId)).needsReconnect).toBe(true);
    store.revoked = false;
    await disconnectGoogle(handle.db, hostId);
    expect((await getMediaSettings(handle.db, store, hostId, eventId)).connected).toBe(false);
  });
});

describe("guest gallery", () => {
  it("lets guests upload within the window and their limit, delete their own, report others", async () => {
    const eventId = await newEvent("kawaida");
    await completeGoogleConnect(handle.db, store, oauth, { userId: hostId, eventId, code: "g1" });
    const a = await guestCard(eventId);
    const b = await guestCard(eventId);
    const w = galleryWindow({ startsAt: new Date("2026-12-12T12:00:00Z"), endsAt: new Date("2026-12-12T20:00:00Z") }, mediaLimits({ cardPhotos: 5, cardVideoSeconds: 30, animatedCard: false, storyPhotos: 20, storyVideos: 1, storyVideoSeconds: 60, gallery: true, galleryVideoSeconds: 30, galleryUploadDaysAfter: 3, galleryPageMonths: 3, galleryUploadsPerGuest: 20, slideshow: false }));
    expect(w.closesAt.toISOString()).toBe("2026-12-15T20:00:00.000Z");
    expect(await getGuestMedia(handle.db, a.token, new Date("2026-12-01T00:00:00Z"))).toMatchObject({ uploadsOpen: false, uploadsClosedReason: "not_started" });
    await expect(createGuestUploadSession(handle.db, store, a.token, photo("gallery"), ORIGIN, new Date("2026-12-20T00:00:00Z")).catch(code)).resolves.toBe("uploads_closed");

    const s = await createGuestUploadSession(handle.db, store, a.token, photo("gallery"), ORIGIN, DURING);
    const fileId = store.addUploadedFile((await folders(eventId)).galleryFolderId!, { name: "x", mimeType: "image/jpeg", size: 10 });
    const item = await completeGuestUpload(handle.db, store, a.token, s.mediaItemId, fileId);
    expect(item).toMatchObject({ kind: "gallery", mine: true, uploadedBy: expect.stringMatching(/^Mgeni/), thumbnailUrl: `/api/v1/cards/${a.token}/media/${s.mediaItemId}/content?size=thumb` });
    const seenByB = await getGuestMedia(handle.db, b.token, DURING);
    expect(seenByB.gallery).toHaveLength(1);
    expect(seenByB.gallery[0]).toMatchObject({ mine: false });
    expect(seenByB).toMatchObject({ uploadsOpen: true, myUploadsLeft: 20 });
    // Private mode streams through D-Card for a valid card link.
    expect((await guestMediaContent(handle.db, store, b.token, s.mediaItemId, "thumb", null, DURING)).status).toBe(200);
    await expect(deleteGuestMedia(handle.db, store, b.token, s.mediaItemId).catch(code)).resolves.toBe("forbidden");
    await reportGuestMedia(handle.db, b.token, s.mediaItemId);
    expect((await getGuestMedia(handle.db, b.token, DURING)).gallery).toHaveLength(0);
    const hostView = await listEventMedia(handle.db, hostId, eventId, "gallery");
    expect(hostView[0]).toMatchObject({ status: "reported" });
    await setMediaStatus(handle.db, hostId, eventId, s.mediaItemId, "visible");
    await deleteGuestMedia(handle.db, store, a.token, s.mediaItemId);
    expect(store.files.has(fileId)).toBe(false);
    // Per-guest limit.
    await handle.db.insert(mediaItem).values(
      Array.from({ length: 20 }, (_, i) => ({ eventId, kind: "gallery" as const, type: "photo" as const, invitationId: b.invitationId, fileName: `p${i}.jpg`, mimeType: "image/jpeg", sizeBytes: 10, status: "visible" as const })),
    );
    await expect(createGuestUploadSession(handle.db, store, b.token, photo("gallery"), ORIGIN, DURING).catch(code)).resolves.toBe("upload_limit");
    // After the plan period the gallery page closes (Kawaida: 3 months).
    await expect(getGuestMedia(handle.db, b.token, new Date("2027-03-20T00:00:00Z")).catch(code)).resolves.toBe("gallery_closed");
  });

  it("marks files deleted in Drive as missing and serves link-mode items straight from Drive", async () => {
    const eventId = await newEvent("premium");
    await completeGoogleConnect(handle.db, store, oauth, { userId: hostId, eventId, code: "l1" });
    const g = await guestCard(eventId);
    const item = await uploadAsHost(eventId, photo("story"));
    const [row] = await handle.db.select().from(mediaItem).where(eq(mediaItem.id, item.id));
    store.files.delete(row!.driveFileId!);
    expect((await guestMediaContent(handle.db, store, g.token, item.id, "full", null, DURING)).status).toBe(404);
    expect((await handle.db.select().from(mediaItem).where(and(eq(mediaItem.id, item.id))))[0]!.status).toBe("missing");
    const second = await uploadAsHost(eventId, photo("story"));
    await updateMediaSettings(handle.db, store, hostId, eventId, { sharingMode: "link" });
    const story = (await getGuestMedia(handle.db, g.token, DURING)).story.find((s) => s.id === second.id)!;
    expect(story.thumbnailUrl).toMatch(/^https:\/\/drive\.google\.com\/thumbnail\?id=/);
    expect((await getMediaSettings(handle.db, store, hostId, eventId)).limits).toMatchObject({ slideshow: true, galleryUploadsPerGuest: 50 });
  });
});
