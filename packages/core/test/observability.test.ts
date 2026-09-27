import { describe, expect, it } from "vitest";
import { createLogger, scrub, scrubText } from "../src/index.js";

describe("scrub", () => {
  it("removes phones, tokens, keys and emails from text", () => {
    expect(scrubText("SMS to 255754123456 and 0713000001 failed")).toBe("SMS to [phone] and [phone] failed");
    expect(scrubText("GET /c/AbCdEfGhIjKlMnOpQrStUvWx 404")).toBe("GET /c/[token] 404");
    expect(scrubText("/api/v1/cards/AbCdEfGhIjKlMnOpQrStUvWx/media")).toBe("/api/v1/cards/[token]/media");
    expect(scrubText("Authorization: Bearer eyJhbGciOi.abc.def")).toBe("Authorization: Bearer [token]");
    expect(scrubText("key snp_live_123 for asha@example.com")).toBe("key [key] for [email]");
    expect(scrubText("amount 50000 TZS, event 2026")).toBe("amount 50000 TZS, event 2026");
  });

  it("removes secret fields by name at any depth", () => {
    expect(scrub({ headers: { authorization: "x", cookie: "y", accept: "json" }, data: [{ guestPhone: "255754123456", count: 2 }] })).toEqual({
      headers: { authorization: "[removed]", cookie: "[removed]", accept: "json" },
      data: [{ guestPhone: "[removed]", count: 2 }],
    });
  });
});

describe("createLogger", () => {
  it("writes scrubbed JSON lines with base fields", () => {
    const lines: string[] = [];
    const log = createLogger({ service: "worker" }, (l) => lines.push(l)).child({ queue: "sms" });
    log.error("send failed to 255754123456", { jobId: "j1", err: new Error("boom") });
    const entry = JSON.parse(lines[0]!);
    expect(entry).toMatchObject({ level: "error", msg: "send failed to [phone]", service: "worker", queue: "sms", jobId: "j1", err: { message: "boom" } });
  });
});
