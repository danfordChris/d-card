import { eventMedia, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { NextRequest } from "next/server";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import type { FakeMediaStore } from "@dcard/core";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let store: FakeMediaStore;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let guests: typeof import("../src/app/api/v1/events/[id]/guests/route");
let connect: typeof import("../src/app/api/v1/media/google/connect/route");
let callback: typeof import("../src/app/api/v1/media/google/callback/route");
let settings: typeof import("../src/app/api/v1/events/[id]/media/settings/route");
let sessions: typeof import("../src/app/api/v1/events/[id]/media/upload-sessions/route");
let complete: typeof import("../src/app/api/v1/events/[id]/media/[itemId]/complete/route");
let list: typeof import("../src/app/api/v1/events/[id]/media/route");
let guestMedia: typeof import("../src/app/api/v1/cards/[token]/media/route");
let guestSessions: typeof import("../src/app/api/v1/cards/[token]/media/upload-sessions/route");
let guestComplete: typeof import("../src/app/api/v1/cards/[token]/media/[itemId]/complete/route");
let guestContent: typeof import("../src/app/api/v1/cards/[token]/media/[itemId]/content/route");
let resetDb: () => Promise<void>;
let eventId: string;
let token: string;

const HOST = "fake:md-host:host@example.com";
const OTHER = "fake:md-other:o@example.com";
function req(method: string, t: string | null, body?: unknown, url = "http://localhost/x"): Request {
  return new Request(url, {
    method,
    headers: { ...(t ? { authorization: `Bearer ${t}` } : {}), "content-type": "application/json" },
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });
}
const p = () => ({ params: Promise.resolve({ id: eventId }) });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_media", { seed: true });
  process.env.DATABASE_URL = handle.url;
  process.env.APP_URL = "https://api.dcard.test";
  const core = await import("@dcard/core");
  store = new core.FakeMediaStore();
  const { setMediaStore } = await import("../src/server/media");
  setMediaStore(store, { exchange: async (c) => ({ refreshToken: `r-${c}`, email: "host@gmail.com", scopes: "drive.file" }) });
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  guests = await import("../src/app/api/v1/events/[id]/guests/route");
  connect = await import("../src/app/api/v1/media/google/connect/route");
  callback = await import("../src/app/api/v1/media/google/callback/route");
  settings = await import("../src/app/api/v1/events/[id]/media/settings/route");
  sessions = await import("../src/app/api/v1/events/[id]/media/upload-sessions/route");
  complete = await import("../src/app/api/v1/events/[id]/media/[itemId]/complete/route");
  list = await import("../src/app/api/v1/events/[id]/media/route");
  guestMedia = await import("../src/app/api/v1/cards/[token]/media/route");
  guestSessions = await import("../src/app/api/v1/cards/[token]/media/upload-sessions/route");
  guestComplete = await import("../src/app/api/v1/cards/[token]/media/[itemId]/complete/route");
  guestContent = await import("../src/app/api/v1/cards/[token]/media/[itemId]/content/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [HOST, OTHER]) await me.POST(req("POST", t));
  // An event happening now, so the guest upload window is open.
  const now = Date.now();
  const created = await events.POST(
    req("POST", HOST, { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi", startsAt: new Date(now - 3600_000).toISOString(), endsAt: new Date(now + 3600_000).toISOString(), contactName: "Asha", contactPhone: "0754123456" }),
  );
  eventId = (await created.json()).id;
  await core.grantGuestCards(handle.db, eventId, 500);
  const g = await (await guests.POST(req("POST", HOST, { name: "Juma", phone: "0713900001", consent: true }), p())).json();
  const [host] = await handle.db.select().from(userAccount).where(eq(userAccount.firebaseUid, "md-host"));
  await core.issueCard(handle.db, host!.id, eventId, g.guest.id);
  const [inv] = await handle.db.select().from(invitation).where(eq(invitation.id, g.guest.id));
  token = core.decryptSecret(inv!.linkTokenEnc!);
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("media API", () => {
  it("lets only the Drive connect/callback and card-link content skip the API key", async () => {
    const { proxy } = await import("../src/proxy");
    const status = (path: string) => proxy(new NextRequest(`http://localhost${path}`)).status;
    expect(status("/api/v1/media/google/connect")).toBe(200);
    expect(status("/api/v1/media/google/callback")).toBe(200);
    expect(status(`/api/v1/cards/${"a".repeat(43)}/media/0b1e2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d/content`)).toBe(200);
    expect(status(`/api/v1/cards/${"a".repeat(43)}/media`)).toBe(401);
    expect(status("/api/v1/events")).toBe(401);
  });

  it("connects Drive through Google consent and the signed callback", async () => {
    const res = await connect.GET(req("GET", HOST, undefined, `http://localhost/x?eventId=${eventId}`));
    expect(res.status).toBe(302);
    const google = new URL(res.headers.get("location")!);
    expect(google.hostname).toBe("accounts.google.com");
    expect(google.searchParams.get("scope")).toContain("drive.file");
    expect((await connect.GET(req("GET", OTHER, undefined, `http://localhost/x?eventId=${eventId}`))).status).toBe(403);
    const stateUrl = `http://localhost/x?code=abc&state=${encodeURIComponent(google.searchParams.get("state")!)}`;
    // SEC-13: the callback must come from the same signed-in user who started the flow.
    expect((await callback.GET(new Request(stateUrl))).headers.get("location")).toContain("drive=failed");
    expect((await callback.GET(new Request(stateUrl, { headers: { cookie: `dcard_session=${OTHER}` } }))).headers.get("location")).toContain("drive=failed");
    const back = await callback.GET(new Request(stateUrl, { headers: { cookie: `dcard_session=${HOST}` } }));
    expect(back.headers.get("location")).toBe(`https://api.dcard.test/events/${eventId}/media?drive=connected`);
    expect((await callback.GET(new Request("http://localhost/x?code=abc&state=forged.sig"))).headers.get("location")).toContain("drive=expired");
    expect(await (await settings.GET(req("GET", HOST), p())).json()).toMatchObject({ connected: true, googleEmail: "host@gmail.com", sharingMode: "private" });
  });

  it("uploads host story media and guest gallery media, streaming private items by card token", async () => {
    const s = await sessions.POST(req("POST", HOST, { kind: "story", fileName: "a.jpg", mimeType: "image/jpeg", sizeBytes: 1000 }), p());
    expect(s.status).toBe(201);
    const session = await s.json();
    expect(store.sessions.at(-1)!.origin).toBe("https://api.dcard.test");
    const [em] = await handle.db.select().from(eventMedia).where(eq(eventMedia.eventId, eventId));
    const fileId = store.addUploadedFile(em!.storyFolderId!, { name: "a", mimeType: "image/jpeg", size: 1000 });
    const done = await complete.POST(req("POST", HOST, { driveFileId: fileId }), { params: Promise.resolve({ id: eventId, itemId: session.mediaItemId }) });
    expect((await done.json()).status).toBe("visible");
    expect((await (await list.GET(req("GET", HOST, undefined, "http://localhost/x?kind=story"), p())).json()).items).toHaveLength(1);

    const tp = { params: Promise.resolve({ token }) };
    const g = await guestSessions.POST(req("POST", null, { kind: "gallery", fileName: "b.jpg", mimeType: "image/jpeg", sizeBytes: 500 }), tp);
    expect(g.status).toBe(201);
    const gs = await g.json();
    const gFile = store.addUploadedFile(em!.galleryFolderId!, { name: "b", mimeType: "image/jpeg", size: 500 });
    await guestComplete.POST(req("POST", null, { driveFileId: gFile }), { params: Promise.resolve({ token, itemId: gs.mediaItemId }) });
    const view = await (await guestMedia.GET(req("GET", null), tp)).json();
    expect(view).toMatchObject({ uploadsOpen: true, myUploadsLeft: 19 });
    expect(view.story).toHaveLength(1);
    expect(view.gallery[0]).toMatchObject({ mine: true, uploadedBy: "Juma" });
    const content = await guestContent.GET(req("GET", null, undefined, "http://localhost/x?size=thumb"), { params: Promise.resolve({ token, itemId: gs.mediaItemId }) });
    expect(content.status).toBe(200);
    expect(content.headers.get("cache-control")).toContain("private");
    expect((await guestMedia.GET(req("GET", null), { params: Promise.resolve({ token: "x".repeat(43) }) })).status).toBe(404);
  });
});
