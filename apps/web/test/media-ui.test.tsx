// @vitest-environment jsdom
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { DrivePanel } from "../src/features/media/drive-panel";
import { GalleryModeration } from "../src/features/media/gallery-moderation";
import { LiveSlideshow, mergeSlides } from "../src/features/media/live-slideshow";
import { MediaEditor } from "../src/features/media/media-editor";
import { MediaManager } from "../src/features/media/media-manager";
import type { MediaItem, MediaSettings } from "../src/features/media/types";
import { CHUNK_BYTES, mediaDeps, putToDrive } from "../src/features/media/upload";

vi.mock("next/link", () => ({
  default: ({ href, children, ...rest }: { href: string; children: React.ReactNode }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

const EVENT = "e1";
const UPLOAD_URL = "https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable&upload_id=abc";

beforeEach(() => {
  URL.createObjectURL = vi.fn(() => `blob:mock-${Math.random()}`);
  URL.revokeObjectURL = vi.fn();
});

afterEach(() => {
  cleanup();
  vi.useRealTimers();
  vi.restoreAllMocks();
});

function wrap(node: React.ReactNode, locale: "en" | "sw" = "en") {
  return render(
    <NextIntlClientProvider locale={locale} messages={locale === "sw" ? sw : en} timeZone="Africa/Dar_es_Salaam">
      {node}
    </NextIntlClientProvider>,
  );
}

/** Response-like object (no stream timers, so fake timers stay simple). */
function reply(body: unknown, status = 200, headers: Record<string, string> = {}): Response {
  return {
    ok: status >= 200 && status < 300,
    status,
    headers: new Headers(headers),
    json: async () => body,
    blob: async () => new Blob(["img"], { type: "image/jpeg" }),
  } as unknown as Response;
}

type Call = { method: string; url: string; body: unknown; headers: Headers };

/** Routes fetch calls to `handler`; records every call. */
function mockFetch(handler: (c: Call) => Response | undefined) {
  const calls: Call[] = [];
  const spy = vi.spyOn(globalThis, "fetch").mockImplementation(async (input, init) => {
    const body = typeof init?.body === "string" ? (JSON.parse(init.body) as unknown) : (init?.body ?? null);
    const call = { method: init?.method ?? "GET", url: String(input), body, headers: new Headers(init?.headers) };
    calls.push(call);
    return handler(call) ?? reply({ error: { code: "not_found", message: "no route" } }, 404);
  });
  return { calls, spy };
}

const limits = {
  cardPhotos: 5,
  cardVideos: 1,
  cardVideoSeconds: 30,
  storyPhotos: 20,
  storyVideos: 1,
  storyVideoSeconds: 60,
  galleryEnabled: true,
  galleryVideoSeconds: 30,
  galleryUploadsPerGuest: 20,
  galleryUploadDays: 3,
  galleryOpenMonths: 3,
  maxPhotoBytes: 10_000_000,
  maxVideoBytes: 200_000_000,
  slideshow: false,
};

function settings(patch: Partial<MediaSettings> = {}): MediaSettings {
  return {
    mediaEnabled: true,
    connected: true,
    googleEmail: "host@gmail.com",
    needsReconnect: false,
    sharingMode: "private",
    folderUrl: "https://drive.google.com/drive/folders/f1",
    quotaUsedBytes: 14 * 1024 ** 3,
    quotaLimitBytes: 15 * 1024 ** 3,
    quotaWarning: true,
    googlePhotosUrl: null,
    limits,
    counts: { cardPhotos: 0, cardVideos: 0, storyPhotos: 0, storyVideos: 0, gallery: 0 },
    ...patch,
  };
}

function item(id: string, patch: Partial<MediaItem> = {}): MediaItem {
  return {
    id,
    kind: "card",
    type: "photo",
    mimeType: "image/jpeg",
    sizeBytes: 1000,
    durationSeconds: null,
    status: "visible",
    uploadedBy: null,
    mine: false,
    thumbnailUrl: `https://drive.google.com/thumbnail?id=${id}`,
    url: `https://drive.google.com/uc?id=${id}`,
    createdAt: "2026-09-20T10:00:00.000Z",
    ...patch,
  };
}

describe("Drive panel", () => {
  it("connect is a full-page link to the Google connect endpoint for the event", () => {
    mockFetch(() => undefined);
    wrap(<DrivePanel eventId={EVENT} settings={settings({ connected: false, googleEmail: null, quotaUsedBytes: null })} canEdit onSaved={() => {}} onReload={async () => {}} />);
    const link = screen.getByRole("link", { name: en.media.drive.connect });
    expect(link.getAttribute("href")).toBe(`/api/v1/media/google/connect?eventId=${EVENT}`);
    // Sharing cannot be saved before Drive is connected.
    expect((screen.getByRole("button", { name: en.media.drive.sharing.save }) as HTMLButtonElement).disabled).toBe(true);
  });

  it("shows the connected account, folder link and quota warning; saves the sharing mode", async () => {
    const saved = settings({ sharingMode: "link" });
    const { calls } = mockFetch((c) => (c.method === "PUT" ? reply(saved) : undefined));
    const onSaved = vi.fn();
    wrap(<DrivePanel eventId={EVENT} settings={settings()} canEdit onSaved={onSaved} onReload={async () => {}} />);

    expect(screen.getByText("Connected as host@gmail.com")).toBeTruthy();
    expect(screen.getByRole("link", { name: en.media.drive.openFolder }).getAttribute("href")).toBe("https://drive.google.com/drive/folders/f1");
    expect(screen.getByTestId("media-quota").textContent).toContain("14 GB of 15 GB used");
    expect(screen.getByText(en.media.drive.quota.warning)).toBeTruthy();
    expect(screen.getByText(en.media.drive.sharing.private.body)).toBeTruthy();

    fireEvent.click(screen.getByRole("radio", { name: new RegExp(en.media.drive.sharing.link.title) }));
    fireEvent.click(screen.getByRole("button", { name: en.media.drive.sharing.save }));
    await screen.findByText(en.media.drive.modeSaved);
    const put = calls.find((c) => c.method === "PUT")!;
    expect(put.url).toBe(`/api/v1/events/${EVENT}/media/settings`);
    expect(put.body).toEqual({ sharingMode: "link" });
    expect(onSaved).toHaveBeenCalledWith(saved);
  });

  it("prompts to reconnect when Drive access was lost", () => {
    mockFetch(() => undefined);
    wrap(<DrivePanel eventId={EVENT} settings={settings({ needsReconnect: true, connected: false })} canEdit onSaved={() => {}} onReload={async () => {}} />);
    expect(screen.getByText(en.media.drive.needsReconnect)).toBeTruthy();
    expect(screen.getByRole("link", { name: en.media.drive.reconnect }).getAttribute("href")).toContain("/api/v1/media/google/connect?eventId=e1");
  });

  it("Msingi shows only the Google Photos link", async () => {
    const msingi = settings({ mediaEnabled: false, connected: false });
    const { calls } = mockFetch((c) =>
      c.url.endsWith("/media/settings") ? reply(c.method === "PUT" ? { ...msingi, googlePhotosUrl: "https://photos.app.goo.gl/abc" } : msingi) : undefined,
    );
    wrap(<MediaManager eventId={EVENT} canEdit />);
    await screen.findByTestId("media-photos-link");
    expect(screen.queryByTestId("media-drive")).toBeNull();
    expect(screen.queryByTestId("media-editor-card")).toBeNull();
    expect(screen.queryByRole("link", { name: en.media.drive.connect })).toBeNull();

    fireEvent.change(screen.getByLabelText(en.media.photosLink.label), { target: { value: "https://photos.app.goo.gl/abc" } });
    fireEvent.click(screen.getByRole("button", { name: en.media.photosLink.save }));
    await screen.findByText(en.media.photosLink.saved);
    expect(calls.find((c) => c.method === "PUT")!.body).toEqual({ googlePhotosUrl: "https://photos.app.goo.gl/abc" });
    expect(calls.some((c) => c.url.includes("/media?kind="))).toBe(false);
  });
});

describe("Card media and story editors", () => {
  it("disables adding photos when the plan limit is reached, with counts", async () => {
    const photos = [item("a"), item("b")];
    mockFetch((c) => (c.url.includes("kind=card") ? reply({ items: [...photos, item("v", { type: "video" })] }) : undefined));
    wrap(<MediaEditor eventId={EVENT} kind="card" settings={settings({ limits: { ...limits, cardPhotos: 2, cardVideos: 2 } })} canEdit />);
    await screen.findByTestId("media-item-a");
    expect(screen.getByTestId("media-counts-card").textContent).toBe("Photos 2/2 · Videos 1/2");
    expect((screen.getByRole("button", { name: en.media.editor.addPhotos }) as HTMLButtonElement).disabled).toBe(true);
    expect((screen.getByRole("button", { name: en.media.editor.addVideo }) as HTMLButtonElement).disabled).toBe(false);
  });

  it("disables adding until Drive is connected", async () => {
    mockFetch(() => reply({ items: [] }));
    wrap(<MediaEditor eventId={EVENT} kind="story" settings={settings({ connected: false })} canEdit />);
    await screen.findByText(en.media.editor.empty);
    expect((screen.getByRole("button", { name: en.media.editor.addPhotos }) as HTMLButtonElement).disabled).toBe(true);
  });

  it("resizes a photo, opens a session, PUTs the bytes to Drive and completes", async () => {
    const resized = new Blob(["small-jpeg"], { type: "image/jpeg" });
    const resize = vi.spyOn(mediaDeps, "resizeImage").mockResolvedValue(resized);
    const done = item("new1", { kind: "story" });
    const { calls } = mockFetch((c) => {
      if (c.url.includes("kind=story")) return reply({ items: [] });
      if (c.url.endsWith("/upload-sessions")) return reply({ mediaItemId: "new1", uploadUrl: UPLOAD_URL, expiresAt: "2026-09-27T00:00:00.000Z" }, 201);
      if (c.url === UPLOAD_URL) return reply({ id: "drive-file-123" }, 200);
      if (c.url.endsWith("/new1/complete")) return reply(done);
      return undefined;
    });
    wrap(<MediaEditor eventId={EVENT} kind="story" settings={settings()} canEdit />);
    await screen.findByText(en.media.editor.empty);

    const file = new File(["original-big-png"], "beach.png", { type: "image/png" });
    fireEvent.change(screen.getByTestId("media-photo-input-story"), { target: { files: [file] } });

    await screen.findByTestId("media-item-new1");
    expect(resize).toHaveBeenCalledWith(file);
    const session = calls.find((c) => c.url.endsWith("/upload-sessions"))!;
    expect(session.url).toBe(`/api/v1/events/${EVENT}/media/upload-sessions`);
    expect(session.body).toEqual({ kind: "story", fileName: "beach.jpg", mimeType: "image/jpeg", sizeBytes: resized.size, durationSeconds: null });
    expect(session.headers.get("x-api-key")).toBeTruthy();

    const put = calls.find((c) => c.url === UPLOAD_URL)!;
    expect(put.method).toBe("PUT");
    expect(put.body).toBe(resized);
    expect(put.headers.get("content-type")).toBe("image/jpeg");
    // Straight to Google: no D-Card API key on the Drive request.
    expect(put.headers.get("x-api-key")).toBeNull();

    const complete = calls.find((c) => c.url.endsWith("/complete"))!;
    expect(complete.url).toBe(`/api/v1/events/${EVENT}/media/new1/complete`);
    expect(complete.body).toEqual({ driveFileId: "drive-file-123" });
    expect(screen.queryByTestId("media-uploads-story")).toBeNull();
  });

  it("shows a retry after a failed Drive upload, and retry succeeds", async () => {
    vi.spyOn(mediaDeps, "resizeImage").mockImplementation(async (f) => f);
    let drivePuts = 0;
    mockFetch((c) => {
      if (c.url.includes("kind=card")) return reply({ items: [] });
      if (c.url.endsWith("/upload-sessions")) return reply({ mediaItemId: "n2", uploadUrl: UPLOAD_URL, expiresAt: "2026-09-27T00:00:00.000Z" }, 201);
      if (c.url === UPLOAD_URL) return (drivePuts += 1) === 1 ? reply({}, 503) : reply({ id: "drive-2" });
      if (c.url.endsWith("/complete")) return reply(item("n2"));
      return undefined;
    });
    wrap(<MediaEditor eventId={EVENT} kind="card" settings={settings()} canEdit />);
    await screen.findByText(en.media.editor.empty);
    fireEvent.change(screen.getByTestId("media-photo-input-card"), { target: { files: [new File(["x"], "a.jpg", { type: "image/jpeg" })] } });

    await screen.findByText(en.media.editor.errors.drive);
    fireEvent.click(screen.getByRole("button", { name: en.media.editor.retry }));
    await screen.findByTestId("media-item-n2");
    expect(drivePuts).toBe(2);
  });

  it("rejects a video longer than the plan allows before asking for a session", async () => {
    vi.spyOn(mediaDeps, "readVideoDuration").mockResolvedValue(45.2);
    const { calls } = mockFetch((c) => (c.url.includes("kind=card") ? reply({ items: [] }) : undefined));
    wrap(<MediaEditor eventId={EVENT} kind="card" settings={settings()} canEdit />);
    await screen.findByText(en.media.editor.empty);
    fireEvent.change(screen.getByTestId("media-video-input-card"), { target: { files: [new File(["v"], "clip.mp4", { type: "video/mp4" })] } });
    await screen.findByText("This video is longer than 30 seconds. Trim it and try again.");
    expect(calls.some((c) => c.url.endsWith("/upload-sessions"))).toBe(false);
  });

  it("uploads large files to Drive in 8 MiB chunks, resuming after 308", async () => {
    const total = CHUNK_BYTES + 1000;
    const blob = new Blob([new Uint8Array(total)], { type: "video/mp4" });
    const { calls } = mockFetch((c) => {
      const range = c.headers.get("content-range")!;
      return range.startsWith("bytes 0-") ? reply(null, 308, { range: `bytes=0-${CHUNK_BYTES - 1}` }) : reply({ id: "big-file" }, 200);
    });
    const progress: number[] = [];
    await expect(putToDrive(UPLOAD_URL, blob, (p) => progress.push(p))).resolves.toBe("big-file");
    expect(calls.map((c) => c.headers.get("content-range"))).toEqual([`bytes 0-${CHUNK_BYTES - 1}/${total}`, `bytes ${CHUNK_BYTES}-${total - 1}/${total}`]);
    expect(progress.at(-1)).toBe(1);
  });

  it("deletes an item after confirmation", async () => {
    const { calls } = mockFetch((c) => {
      if (c.method === "DELETE") return reply(null, 204);
      return c.url.includes("kind=card") ? reply({ items: [item("a")] }) : undefined;
    });
    wrap(<MediaEditor eventId={EVENT} kind="card" settings={settings()} canEdit />);
    const tile = await screen.findByTestId("media-item-a");
    fireEvent.click(within(tile).getByRole("button", { name: en.media.editor.delete }));
    fireEvent.click(within(screen.getByRole("dialog")).getByRole("button", { name: en.media.editor.delete }));
    await waitFor(() => expect(screen.queryByTestId("media-item-a")).toBeNull());
    expect(calls.find((c) => c.method === "DELETE")!.url).toBe(`/api/v1/events/${EVENT}/media/a`);
  });
});

describe("Gallery moderation", () => {
  const gallery = () => [
    item("g1", { kind: "gallery", uploadedBy: "Asha", createdAt: "2026-09-20T12:00:00.000Z" }),
    item("g2", { kind: "gallery", uploadedBy: "Juma", status: "reported", createdAt: "2026-09-20T09:00:00.000Z" }),
    item("g3", { kind: "gallery", uploadedBy: "Neema", status: "hidden", createdAt: "2026-09-20T11:00:00.000Z" }),
  ];

  it("lists reported items first with the uploader, hides and deletes with confirmation", async () => {
    const { calls } = mockFetch((c) => {
      if (c.method === "PATCH") return reply({ ...gallery()[0], status: "hidden" });
      if (c.method === "DELETE") return reply(null, 204);
      return c.url.includes("kind=gallery") ? reply({ items: gallery() }) : undefined;
    });
    wrap(<GalleryModeration eventId={EVENT} canEdit />);
    await screen.findByTestId("gallery-item-g1");
    const order = screen.getAllByTestId(/^gallery-item-/).map((el) => el.dataset.testid);
    expect(order).toEqual(["gallery-item-g2", "gallery-item-g1", "gallery-item-g3"]);
    expect(screen.getByText("1 item was reported by a guest.")).toBeTruthy();
    expect(screen.getByTestId("gallery-item-g2").textContent).toContain("Juma");

    // Hide a visible item.
    fireEvent.click(within(screen.getByTestId("gallery-item-g1")).getByRole("button", { name: en.media.gallery.hide }));
    await waitFor(() => expect(screen.getByTestId("gallery-item-g1").textContent).toContain(en.media.gallery.status.hidden));
    const patch = calls.find((c) => c.method === "PATCH")!;
    expect(patch.url).toBe(`/api/v1/events/${EVENT}/media/g1`);
    expect(patch.body).toEqual({ status: "hidden" });

    // Delete the reported item, only after confirming.
    fireEvent.click(within(screen.getByTestId("gallery-item-g2")).getByRole("button", { name: en.media.gallery.delete }));
    const dialog = screen.getByRole("dialog");
    expect(dialog.textContent).toContain("Delete the upload from Juma?");
    expect(calls.some((c) => c.method === "DELETE")).toBe(false);
    fireEvent.click(within(dialog).getByRole("button", { name: en.media.gallery.delete }));
    await waitFor(() => expect(screen.queryByTestId("gallery-item-g2")).toBeNull());
    expect(calls.find((c) => c.method === "DELETE")!.url).toBe(`/api/v1/events/${EVENT}/media/g2`);
  });

  it("shows a hidden item again", async () => {
    const { calls } = mockFetch((c) => {
      if (c.method === "PATCH") return reply({ ...gallery()[2], status: "visible" });
      return reply({ items: gallery() });
    });
    wrap(<GalleryModeration eventId={EVENT} canEdit />);
    const row = await screen.findByTestId("gallery-item-g3");
    fireEvent.click(within(row).getByRole("button", { name: en.media.gallery.show }));
    await waitFor(() => expect(screen.getByTestId("gallery-item-g3").textContent).toContain(en.media.gallery.status.visible));
    expect(calls.find((c) => c.method === "PATCH")!.body).toEqual({ status: "visible" });
  });
});

describe("Live slideshow", () => {
  const photo = (id: string, minute: number, patch: Partial<MediaItem> = {}) =>
    item(id, { kind: "gallery", uploadedBy: `Guest ${id}`, createdAt: `2026-09-20T12:${String(minute).padStart(2, "0")}:00.000Z`, ...patch });

  const flush = () => act(async () => void (await vi.advanceTimersByTimeAsync(0)));
  const advance = (ms: number) => act(async () => void (await vi.advanceTimersByTimeAsync(ms)));
  const shown = () => screen.queryByTestId("slide")?.getAttribute("data-item-id");

  it("queues new uploads right after the current slide", () => {
    const [a, b, c] = [photo("a", 1), photo("b", 2), photo("c", 3)];
    expect(mergeSlides({ slides: [a, b], pos: 0 }, [a, b, c]).slides.map((i) => i.id)).toEqual(["a", "c", "b"]);
    // Hidden items leave the rotation.
    expect(mergeSlides({ slides: [a, b], pos: 1 }, [a, { ...b, status: "hidden" }])).toEqual({ slides: [a], pos: 0 });
  });

  it("cycles photos every 6 s and shows new uploads after a poll", async () => {
    vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout", "setInterval", "clearInterval"] });
    let polls = 0;
    mockFetch((c) => {
      if (c.url.endsWith("/media/settings")) return reply(settings({ limits: { ...limits, slideshow: true } }));
      if (c.url.includes("kind=gallery")) {
        polls += 1;
        const hidden = photo("h", 0, { status: "hidden" });
        return reply({ items: polls === 1 ? [photo("p1", 1), photo("p2", 2), hidden] : [photo("p1", 1), photo("p2", 2), photo("p3", 3), hidden] });
      }
      return undefined;
    });
    wrap(<LiveSlideshow eventId={EVENT} />);
    await flush();
    expect(shown()).toBe("p1");
    await advance(6000);
    expect(shown()).toBe("p2");
    await advance(4000); // 10 s: poll finds p3
    expect(polls).toBe(2);
    await advance(6000);
    expect(shown()).toBe("p3");
    expect(screen.getByText("Guest p3")).toBeTruthy();
    expect(screen.getByRole("link", { name: en.media.slideshowPage.exit }).getAttribute("href")).toBe(`/events/${EVENT}/media`);
  });

  it("preloads the next three images through the API in private mode", async () => {
    vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout", "setInterval", "clearInterval"] });
    const proxied = (id: string, minute: number) =>
      photo(id, minute, { thumbnailUrl: `/api/v1/events/${EVENT}/media/${id}/content?size=thumb`, url: `/api/v1/events/${EVENT}/media/${id}/content` });
    const { calls } = mockFetch((c) => {
      if (c.url.endsWith("/media/settings")) return reply(settings({ limits: { ...limits, slideshow: true } }));
      if (c.url.includes("kind=gallery")) return reply({ items: [1, 2, 3, 4, 5].map((n) => proxied(`p${n}`, n)) });
      if (c.url.includes("/content")) return reply(null);
      return undefined;
    });
    wrap(<LiveSlideshow eventId={EVENT} />);
    await flush();
    await flush();
    const loaded = calls.filter((c) => c.url.includes("/content")).map((c) => c.url.split("/")[6]);
    expect(loaded).toEqual(["p1", "p2", "p3", "p4"]);
    expect(calls.find((c) => c.url.includes("/content"))!.headers.get("x-api-key")).toBeTruthy();
    expect(shown()).toBe("p1");
  });

  it("is only available with the Premium slideshow", async () => {
    mockFetch((c) => (c.url.endsWith("/media/settings") ? reply(settings()) : undefined));
    wrap(<LiveSlideshow eventId={EVENT} />);
    await screen.findByText(en.media.slideshowPage.notAvailable);
  });
});

describe("Swahili", () => {
  it("renders the media page in Swahili", async () => {
    mockFetch((c) => {
      if (c.url.endsWith("/media/settings")) return reply(settings({ connected: false, googleEmail: null, quotaUsedBytes: null, quotaWarning: false }));
      return reply({ items: [] });
    });
    wrap(<MediaManager eventId={EVENT} canEdit />, "sw");
    expect((await screen.findByRole("link", { name: sw.media.drive.connect })).textContent).toBe("Unganisha Google Drive");
    expect(screen.getByText(sw.media.drive.sharing.private.body)).toBeTruthy();
    expect(screen.getByText(sw.media.editor.card.title)).toBeTruthy();
    expect((await screen.findAllByText(sw.media.editor.empty)).length).toBe(2);
  });
});
