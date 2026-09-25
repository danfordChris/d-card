import { createServer, type IncomingMessage, type Server } from "node:http";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { MetaWhatsAppSender, NextSmsSender, PermanentSendError, sendersFromEnv, UnconfiguredSmsSender } from "../src/messaging/senders.js";

type Seen = { method: string; url: string; headers: IncomingMessage["headers"]; body: string };
let server: Server;
let base: string;
const seen: Seen[] = [];
let reply: (s: Seen) => { status: number; body: unknown } = () => ({ status: 200, body: {} });

beforeAll(async () => {
  server = createServer((req, res) => {
    let body = "";
    req.on("data", (c) => (body += c));
    req.on("end", () => {
      const s = { method: req.method!, url: req.url!, headers: req.headers, body };
      seen.push(s);
      const r = reply(s);
      res.writeHead(r.status, { "content-type": "application/json" }).end(JSON.stringify(r.body));
    });
  });
  await new Promise<void>((r) => server.listen(0, "127.0.0.1", r));
  const addr = server.address() as { port: number };
  base = `http://127.0.0.1:${addr.port}`;
});

afterAll(() => new Promise<void>((r) => server.close(() => r())));

describe("NextSmsSender", () => {
  const sms = (live = true) => new NextSmsSender({ baseUrl: `${base}/`, token: "dGVzdDE6MTIzNDU2", senderId: "DCARD", live });

  it("posts to /api/sms/v1/text/single with Basic auth and our reference; returns the reference and smsCount", async () => {
    reply = () => ({ status: 200, body: { messages: [{ to: "255713000001", status: { groupId: 1, groupName: "PENDING", id: 7, name: "PENDING_ENROUTE" }, smsCount: 2 }] } });
    expect(await sms().send("255713000001", "Habari", "log-123")).toEqual({ providerMessageId: "log-123", segments: 2 });
    const s = seen.at(-1)!;
    expect([s.method, s.url, s.headers.authorization, s.headers.accept]).toEqual(["POST", "/api/sms/v1/text/single", "Basic dGVzdDE6MTIzNDU2", "application/json"]);
    expect(JSON.parse(s.body)).toEqual({ from: "DCARD", to: "255713000001", text: "Habari", reference: "log-123" });
  });

  it("uses the test endpoint (no delivery) unless live sending is on", async () => {
    reply = () => ({ status: 200, body: { messages: [{ status: { groupName: "PENDING" }, smsCount: 1 }] } });
    await sms(false).send("255713000001", "Habari", "log-124");
    expect(seen.at(-1)!.url).toBe("/api/sms/v1/test/text/single");
    const fromEnv = (live?: string) =>
      sendersFromEnv({ NEXTSMS_BASE_URL: base, NEXTSMS_API_TOKEN: "dGVzdDE6MTIzNDU2", NEXTSMS_SENDER_ID: "DCARD", ...(live ? { NEXTSMS_LIVE: live } : {}) }).sms;
    await fromEnv().send("255713000001", "Habari", "log-125");
    expect(seen.at(-1)!.url).toBe("/api/sms/v1/test/text/single");
    await fromEnv("true").send("255713000001", "Habari", "log-126");
    expect(seen.at(-1)!.url).toBe("/api/sms/v1/text/single");
  });

  it("treats REJECTED at submission and 4xx as permanent, 5xx as retryable", async () => {
    reply = () => ({ status: 200, body: { messages: [{ status: { groupName: "REJECTED", name: "REJECTED_NOT_ENOUGH_CREDITS", description: "Not enough credits" }, smsCount: 1 }] } });
    await expect(sms().send("1", "x", "r")).rejects.toThrow(/REJECTED_NOT_ENOUGH_CREDITS/);
    reply = () => ({ status: 400, body: { error: "invalid number" } });
    await expect(sms().send("1", "x", "r")).rejects.toBeInstanceOf(PermanentSendError);
    reply = () => ({ status: 503, body: {} });
    const err = await sms().send("1", "x", "r").catch((e: Error) => e);
    expect(err).toBeInstanceOf(Error);
    expect(err).not.toBeInstanceOf(PermanentSendError);
  });

  it("looks up delivery status by reference in the sent-SMS logs", async () => {
    reply = () => ({
      status: 200,
      body: { results: [{ messageId: "28089492984101631440", doneAt: "2026-10-01 12:28:51", to: "255713000001", status: { groupName: "DELIVERED", description: "Message delivered to handset" } }] },
    });
    expect(await sms().lookup("log-123")).toEqual({ messageId: "28089492984101631440", group: "DELIVERED", doneAt: "2026-10-01 12:28:51", description: "Message delivered to handset" });
    expect(seen.at(-1)!.url).toBe("/api/sms/v1/logs?reference=log-123");
    reply = () => ({ status: 200, body: { results: [] } });
    expect(await sms().lookup("unknown")).toBeNull();
  });
});

describe("MetaWhatsAppSender", () => {
  const wa = () => new MetaWhatsAppSender({ apiVersion: "v23.0", phoneNumberId: "123", token: "meta", baseUrl: base });

  it("sends a template with image header, body params and quick-reply payloads", async () => {
    reply = () => ({ status: 200, body: { messages: [{ id: "wamid.X" }] } });
    const res = await wa().sendTemplate({
      to: "255713000001",
      templateName: "dcard_attendance_confirmation_standard",
      language: "sw",
      bodyParams: ["Juma", "Harusi"],
      headerImageId: "media-1",
      confirmPayloads: ["cnf:t:yes", "cnf:t:no"],
    });
    expect(res).toEqual({ providerMessageId: "wamid.X" });
    const s = seen.at(-1)!;
    expect(s.url).toBe("/v23.0/123/messages");
    expect(s.headers.authorization).toBe("Bearer meta");
    expect(JSON.parse(s.body)).toEqual({
      messaging_product: "whatsapp",
      to: "255713000001",
      type: "template",
      template: {
        name: "dcard_attendance_confirmation_standard",
        language: { code: "sw" },
        components: [
          { type: "header", parameters: [{ type: "image", image: { id: "media-1" } }] },
          { type: "body", parameters: [{ type: "text", text: "Juma" }, { type: "text", text: "Harusi" }] },
          { type: "button", sub_type: "quick_reply", index: "0", parameters: [{ type: "payload", payload: "cnf:t:yes" }] },
          { type: "button", sub_type: "quick_reply", index: "1", parameters: [{ type: "payload", payload: "cnf:t:no" }] },
        ],
      },
    });
  });

  it("uploads a PNG as multipart and returns the media id", async () => {
    reply = () => ({ status: 200, body: { id: "media-9" } });
    expect(await wa().uploadImage(new Uint8Array([137, 80, 78, 71]), "card.png")).toBe("media-9");
    const s = seen.at(-1)!;
    expect(s.url).toBe("/v23.0/123/media");
    expect(s.headers["content-type"]).toMatch(/^multipart\/form-data/);
    expect(s.body).toContain('name="messaging_product"');
    expect(s.body).toContain('filename="card.png"');
  });
});

describe("sendersFromEnv", () => {
  it("uses placeholder senders while keys are dummy", async () => {
    const s = sendersFromEnv({ NEXTSMS_API_TOKEN: "dummy_x", NEXTSMS_BASE_URL: "https://x", WHATSAPP_ACCESS_TOKEN: "dummy_y" });
    expect(s.sms).toBeInstanceOf(UnconfiguredSmsSender);
    await expect(s.sms.send("1", "x", "r")).rejects.toThrow(/not configured/);
  });
});

describe("fetchCardImage", () => {
  it("fetches the PNG with the worker key and rejects non-images", async () => {
    const { fetchCardImage } = await import("../src/messaging/card-image.js");
    const png = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
    const fakeFetch = async (url: string | URL | Request, init?: RequestInit) => {
      seen.push({ method: "GET", url: String(url), headers: Object.fromEntries(new Headers(init?.headers).entries()), body: "" });
      return String(url).includes("bad") ? new Response("{}", { headers: { "content-type": "application/json" } }) : new Response(png, { headers: { "content-type": "image/png" } });
    };
    const out = await fetchCardImage({ appUrl: "https://dcard.test/", apiKey: "dk_worker_x" }, "tok", "en", fakeFetch as typeof fetch);
    expect(Buffer.from(out)).toEqual(png);
    expect(seen.at(-1)).toMatchObject({ url: "https://dcard.test/api/v1/cards/tok/image?lang=en", headers: { "x-api-key": "dk_worker_x" } });
    await expect(fetchCardImage({ appUrl: "https://dcard.test", apiKey: "k" }, "bad", "sw", fakeFetch as typeof fetch)).rejects.toThrow(/not a PNG/);
  });
});
