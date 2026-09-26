// @vitest-environment jsdom
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import type { GuestMedia, GuestMediaItem } from "../src/features/card-page/guest-media-api";

vi.mock("../src/features/card-page/guest-media-api", async (importOriginal) => {
  const actual = await importOriginal<typeof import("../src/features/card-page/guest-media-api")>();
  return {
    ...actual,
    resizeImage: vi.fn(async () => new Blob(["r".repeat(100)], { type: "image/jpeg" })),
    readVideoDuration: vi.fn(async () => 120),
  };
});

const { GuestMediaSections } = await import("../src/features/card-page/guest-media");

const ID = (n: number) => `00000000-0000-4000-8000-00000000000${n}`;

function item(n: number, over: Partial<GuestMediaItem> = {}): GuestMediaItem {
  return {
    id: ID(n),
    kind: "gallery",
    type: "photo",
    mimeType: "image/jpeg",
    sizeBytes: 1000,
    durationSeconds: null,
    status: "visible",
    uploadedBy: "Asha",
    mine: false,
    thumbnailUrl: `https://drive.example/thumb/${n}`,
    url: `https://drive.example/full/${n}`,
    createdAt: "2026-09-20T10:00:00.000Z",
    ...over,
  };
}

const limits = {
  cardPhotos: 3,
  cardVideos: 1,
  cardVideoSeconds: 30,
  storyPhotos: 20,
  storyVideos: 2,
  storyVideoSeconds: 60,
  galleryEnabled: true,
  galleryVideoSeconds: 60,
  galleryUploadsPerGuest: 10,
  galleryUploadDays: 7,
  galleryOpenMonths: 3,
  maxPhotoBytes: 10 * 1024 * 1024,
  maxVideoBytes: 200 * 1024 * 1024,
  slideshow: false,
};

function media(over: Partial<GuestMedia> = {}): GuestMedia {
  return {
    story: [],
    gallery: [],
    galleryEnabled: true,
    uploadsOpen: true,
    uploadsClosedReason: null,
    uploadsClosesAt: null,
    myUploadsLeft: 5,
    limits,
    ...over,
  };
}

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });

type Route = (url: string, init: RequestInit) => Response | Promise<Response> | undefined;
let routes: Route[] = [];
let fetchMock: ReturnType<typeof vi.spyOn>;

function mockApi(...r: Route[]) {
  routes = r;
}

// Minimal XMLHttpRequest stand-in for the direct Drive PUT.
type XhrCall = { method: string; url: string; headers: Record<string, string>; body: unknown };
let xhrCalls: XhrCall[] = [];
let xhrResponses: Array<{ status: number; body: string } | "error"> = [];

class FakeXhr {
  status = 0;
  responseText = "";
  upload: { onprogress: ((e: { loaded: number }) => void) | null } = { onprogress: null };
  onload: (() => void) | null = null;
  onerror: (() => void) | null = null;
  ontimeout: (() => void) | null = null;
  private call: XhrCall = { method: "", url: "", headers: {}, body: null };
  open(method: string, url: string) {
    this.call = { method, url, headers: {}, body: null };
  }
  setRequestHeader(k: string, v: string) {
    this.call.headers[k] = v;
  }
  getResponseHeader() {
    return null;
  }
  send(body: unknown) {
    this.call.body = body;
    xhrCalls.push(this.call);
    const next = xhrResponses.shift() ?? { status: 200, body: JSON.stringify({ id: "drive-file-1" }) };
    setTimeout(() => {
      if (next === "error") return this.onerror?.();
      this.upload.onprogress?.({ loaded: (body as Blob | null)?.size ?? 0 });
      this.status = next.status;
      this.responseText = next.body;
      this.onload?.();
    }, 0);
  }
}

beforeEach(() => {
  xhrCalls = [];
  xhrResponses = [];
  vi.stubGlobal("XMLHttpRequest", FakeXhr);
  URL.createObjectURL = vi.fn(() => "blob:thumb");
  URL.revokeObjectURL = vi.fn();
  fetchMock = vi.spyOn(globalThis, "fetch").mockImplementation(async (input, init = {}) => {
    const url = String(input);
    for (const route of routes) {
      const res = await route(url, init);
      if (res) return res;
    }
    return json({ error: { code: "not_found", message: "no route" } }, 404);
  });
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

const get = (m: GuestMedia | Response): Route => (url, init) =>
  url === "/api/v1/cards/tok/media" && (init.method ?? "GET") === "GET" ? (m instanceof Response ? m : json(m)) : undefined;

function renderSections(locale: "en" | "sw" = "en") {
  render(
    <NextIntlClientProvider locale={locale} messages={locale === "en" ? en : sw}>
      <GuestMediaSections token="tok" />
    </NextIntlClientProvider>,
  );
}

function pick(files: File[]) {
  fireEvent.change(screen.getByTestId("gallery-file-input"), { target: { files } });
}

function callsTo(suffix: string, method: string) {
  return fetchMock.mock.calls.filter(([u, i]: [unknown, unknown]) => String(u).endsWith(suffix) && ((i as RequestInit | undefined)?.method ?? "GET") === method);
}

describe("GuestMediaSections", () => {
  it("renders the host story and the gallery; private card-link thumbnails load directly (card token, no API key)", async () => {
    const privateThumb = "/api/v1/cards/tok/media/" + ID(3) + "/content?size=thumb";
    mockApi(
      get(
        media({
          story: [item(1, { kind: "story", uploadedBy: null }), item(2, { kind: "story", type: "video", uploadedBy: null })],
          gallery: [item(3, { thumbnailUrl: privateThumb, url: privateThumb.replace("thumb", "full") }), item(4, { mine: true })],
        }),
      ),
      (url) => (url.includes("/content?size=") ? new Response(new Blob(["img"], { type: "image/jpeg" })) : undefined),
    );
    renderSections();
    expect(await screen.findByRole("heading", { name: "Our story" })).toBeTruthy();
    expect(screen.getByRole("heading", { name: "Event gallery" })).toBeTruthy();
    expect(screen.getAllByRole("button", { name: "Video" })).toHaveLength(1);
    expect(screen.getAllByRole("button", { name: "Photo" })).toHaveLength(3);
    await waitFor(() => expect(document.querySelectorAll(`img[src="${privateThumb}"]`)).toHaveLength(1));
    expect(callsTo("size=thumb", "GET")).toHaveLength(0);
    expect(document.querySelector('img[src="https://drive.example/thumb/1"]')).toBeTruthy();
    expect(screen.getByText("You can add 5 more.", { exact: false })).toBeTruthy();

    // Viewer: open the first story item, move next, then close.
    fireEvent.click(screen.getAllByRole("button", { name: "Photo" })[0]!);
    const viewer = screen.getByRole("dialog");
    expect(within(viewer).getByText("1 of 2")).toBeTruthy();
    expect(within(viewer).queryByRole("button", { name: "Report" })).toBeNull();
    fireEvent.keyDown(document, { key: "ArrowRight" });
    expect(within(screen.getByRole("dialog")).getByTestId("viewer-video")).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Close" }));
    expect(screen.queryByRole("dialog")).toBeNull();
  });

  it("explains each closed state and hides the upload button", async () => {
    mockApi(get(media({ uploadsOpen: false, uploadsClosedReason: "window_closed" })));
    renderSections();
    expect(await screen.findByText("The time for uploading photos and videos has ended.")).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Add photos/videos" })).toBeNull();
    cleanup();

    mockApi(get(media({ uploadsOpen: false, uploadsClosedReason: "drive_full" })));
    renderSections();
    expect(await screen.findByText("The host's storage is full, so uploads are paused.")).toBeTruthy();
    cleanup();

    mockApi(get(media({ uploadsOpen: false, uploadsClosedReason: "not_started" })));
    renderSections();
    expect(await screen.findByText("Uploads are not open yet. Please come back later.")).toBeTruthy();
    cleanup();

    mockApi(get(json({ error: { code: "gallery_closed", message: "closed" } }, 410)));
    renderSections();
    expect(await screen.findByText("The gallery for this event has closed. The photos and videos stay with the host.")).toBeTruthy();
    cleanup();

    mockApi(get(media({ galleryEnabled: false })));
    renderSections();
    await waitFor(() => expect(callsTo("/media", "GET")).toHaveLength(5));
    expect(screen.queryByRole("heading")).toBeNull();
  });

  it("uploads a resized photo: session, direct PUT to Drive, then complete", async () => {
    const saved = item(9, { mine: true, uploadedBy: "Juma" });
    mockApi(
      get(media()),
      (url, init) => (url.endsWith("/media/upload-sessions") && init.method === "POST" ? json({ mediaItemId: ID(9), uploadUrl: "https://upload.drive.example/s1", expiresAt: "2026-09-27T00:00:00.000Z" }, 201) : undefined),
      (url, init) => (url.endsWith(`/media/${ID(9)}/complete`) && init.method === "POST" ? json(saved) : undefined),
    );
    renderSections();
    await screen.findByRole("button", { name: "Add photos/videos" });
    pick([new File(["x".repeat(5000)], "IMG_001.png", { type: "image/png" })]);

    expect(await screen.findByText("Uploaded")).toBeTruthy();
    const session = callsTo("/media/upload-sessions", "POST")[0]![1] as RequestInit;
    expect(JSON.parse(session.body as string)).toEqual({ kind: "gallery", fileName: "IMG_001.jpg", mimeType: "image/jpeg", sizeBytes: 100, durationSeconds: null });
    expect(xhrCalls).toHaveLength(1);
    expect(xhrCalls[0]!.method).toBe("PUT");
    expect(xhrCalls[0]!.url).toBe("https://upload.drive.example/s1");
    expect(xhrCalls[0]!.headers).toEqual({ "Content-Type": "image/jpeg" });
    expect((xhrCalls[0]!.body as Blob).size).toBe(100);
    const complete = callsTo(`/media/${ID(9)}/complete`, "POST")[0]![1] as RequestInit;
    expect(JSON.parse(complete.body as string)).toEqual({ driveFileId: "drive-file-1" });
    expect(screen.getAllByRole("button", { name: "Photo" })).toHaveLength(1);
    expect(screen.getByText("You can add 4 more.", { exact: false })).toBeTruthy();
  });

  it("rejects bad files on the device and retries after a rate limit", async () => {
    let sessions = 0;
    mockApi(
      get(media()),
      (url, init) => {
        if (!(url.endsWith("/media/upload-sessions") && init.method === "POST")) return undefined;
        sessions += 1;
        return sessions === 1 ? json({ error: { code: "rate_limited", message: "slow" } }, 429) : json({ mediaItemId: ID(8), uploadUrl: "https://upload.drive.example/s2", expiresAt: "2026-09-27T00:00:00.000Z" }, 201);
      },
      (url, init) => (url.endsWith(`/media/${ID(8)}/complete`) && init.method === "POST" ? json(item(8, { mine: true })) : undefined),
    );
    renderSections();
    await screen.findByRole("button", { name: "Add photos/videos" });
    pick([new File(["doc"], "notes.pdf", { type: "application/pdf" }), new File(["v"], "clip.mp4", { type: "video/mp4" })]);
    expect(await screen.findByText("This file type is not supported. Choose a photo or a video.")).toBeTruthy();
    expect(await screen.findByText("This video is too long (maximum 60 seconds).")).toBeTruthy();

    pick([new File(["p"], "a.jpg", { type: "image/jpeg" })]);
    expect(await screen.findByText("Too many uploads at once. Wait a moment, then retry.")).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Retry" }));
    expect(await screen.findByText("Uploaded")).toBeTruthy();
    expect(sessions).toBe(2);
  });

  it("stops at the per-guest limit, on the device and from the server", async () => {
    mockApi(
      get(media({ myUploadsLeft: 1 })),
      (url, init) => (url.endsWith("/media/upload-sessions") && init.method === "POST" ? json({ error: { code: "upload_limit", message: "limit" } }, 409) : undefined),
    );
    renderSections();
    await screen.findByRole("button", { name: "Add photos/videos" });
    pick([new File(["a"], "a.jpg", { type: "image/jpeg" }), new File(["b"], "b.jpg", { type: "image/jpeg" })]);
    await waitFor(() => expect(screen.getAllByText("You have reached your upload limit.")).toHaveLength(2));
    expect(callsTo("/media/upload-sessions", "POST")).toHaveLength(1);
    expect(xhrCalls).toHaveLength(0);
    expect(screen.getByText("You have used all 10 of your uploads. Thank you for sharing.")).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Add photos/videos" })).toBeNull();
  });

  it("lets a guest delete their own upload after confirming", async () => {
    mockApi(get(media({ gallery: [item(1, { mine: true })], myUploadsLeft: 4 })), (url, init) =>
      url.endsWith(`/media/${ID(1)}`) && init.method === "DELETE" ? new Response(null, { status: 204 }) : undefined,
    );
    renderSections();
    fireEvent.click(await screen.findByRole("button", { name: "Photo" }));
    expect(screen.queryByRole("button", { name: "Report" })).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Delete" }));
    expect(screen.getByText("Delete your upload? This cannot be undone.")).toBeTruthy();
    expect(callsTo(`/media/${ID(1)}`, "DELETE")).toHaveLength(0);
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: "Delete" }));
    });
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    expect(callsTo(`/media/${ID(1)}`, "DELETE")).toHaveLength(1);
    expect(screen.queryByRole("button", { name: "Photo" })).toBeNull();
    expect(screen.getByText("You can add 5 more.", { exact: false })).toBeTruthy();
  });

  it("lets a guest report someone else's item after confirming", async () => {
    mockApi(get(media({ gallery: [item(2)] })), (url, init) =>
      url.endsWith(`/media/${ID(2)}/report`) && init.method === "POST" ? new Response(null, { status: 204 }) : undefined,
    );
    renderSections();
    fireEvent.click(await screen.findByRole("button", { name: "Photo" }));
    expect(screen.getByText("Shared by Asha")).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Delete" })).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Report" }));
    fireEvent.click(screen.getByRole("button", { name: "Cancel" }));
    expect(callsTo("/report", "POST")).toHaveLength(0);
    fireEvent.click(screen.getByRole("button", { name: "Report" }));
    expect(screen.getByText("Report this item to the host?")).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Report" }));
    expect(await screen.findByText("Thank you. The host has been told.")).toBeTruthy();
    expect(callsTo(`/media/${ID(2)}/report`, "POST")).toHaveLength(1);
  });

  it("sends files over 8 MB to Drive in 8 MB chunks, continuing after 308", async () => {
    const { uploadToDrive, CHUNK_BYTES } = await import("../src/features/card-page/guest-media-api");
    xhrResponses = [{ status: 308, body: "" }, { status: 200, body: JSON.stringify({ id: "drive-big" }) }];
    const total = CHUNK_BYTES + 1000;
    const progress: number[] = [];
    const id = await uploadToDrive("https://upload.drive.example/big", new Blob([new Uint8Array(total)]), "video/mp4", (f) => progress.push(f));
    expect(id).toBe("drive-big");
    expect(xhrCalls.map((c) => c.headers["Content-Range"])).toEqual([`bytes 0-${CHUNK_BYTES - 1}/${total}`, `bytes ${CHUNK_BYTES}-${total - 1}/${total}`]);
    expect(xhrCalls.every((c) => c.headers["Content-Type"] === "video/mp4" && !("x-api-key" in c.headers))).toBe(true);
    expect(progress.at(-1)).toBe(1);
  });

  it("renders in Swahili", async () => {
    mockApi(get(media({ story: [item(1, { kind: "story", uploadedBy: null })], gallery: [] })));
    renderSections("sw");
    expect(await screen.findByRole("heading", { name: "Hadithi yetu" })).toBeTruthy();
    expect(screen.getByRole("heading", { name: "Picha na video za tukio" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Ongeza picha/video" })).toBeTruthy();
    expect(screen.getByText("Bado hakuna picha wala video. Kuwa wa kwanza kushiriki.")).toBeTruthy();
  });
});
