import { NextRequest } from "next/server";
import { describe, expect, it, vi } from "vitest";
import { apiFetch } from "../src/lib/api-fetch";
import { clientForApiKey } from "../src/server/api-key";
import { proxy } from "../src/proxy";

const WEB = "test_web_key_0123456789abcdefghijklmnop";
const MOBILE = "test_mobile_key_0123456789abcdefghijk";

describe("API keys", () => {
  it("maps valid keys to their client and rejects others (including dummy placeholders)", () => {
    expect(clientForApiKey(WEB)).toBe("web");
    expect(clientForApiKey(MOBILE)).toBe("mobile");
    expect(clientForApiKey("dummy_door_key")).toBeNull();
    expect(clientForApiKey(`${WEB}x`)).toBeNull();
    expect(clientForApiKey("")).toBeNull();
    expect(clientForApiKey(null)).toBeNull();
  });

  it("proxy returns 401 invalid_api_key for API calls without a valid key", async () => {
    for (const headers of [{}, { "x-api-key": "wrong" }] as Record<string, string>[]) {
      const res = proxy(new NextRequest("http://localhost/api/v1/health", { headers }));
      expect(res.status).toBe(401);
      expect(await res.json()).toEqual({ error: { code: "invalid_api_key", message: "Send a valid X-API-Key header." } });
    }
  });

  it("proxy lets API calls with a valid key through and tags the client", () => {
    const res = proxy(new NextRequest("http://localhost/api/v1/cards/abc", { headers: { "x-api-key": MOBILE } }));
    expect(res.status).toBe(200);
    expect(res.headers.get("x-middleware-request-x-dcard-client")).toBe("mobile");
  });

  it("pages do not need a key (only API routes)", () => {
    const res = proxy(new NextRequest("http://localhost/dashboard", { headers: { cookie: "dcard_session=x" } }));
    expect(res.status).toBe(200);
  });

  it("apiFetch adds the web key and keeps other headers", async () => {
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response("{}"));
    await apiFetch("/api/v1/me", { method: "POST", headers: { "content-type": "application/json" } });
    const headers = new Headers(fetchMock.mock.calls[0]![1]!.headers);
    expect(headers.get("x-api-key")).toBe(WEB);
    expect(headers.get("content-type")).toBe("application/json");
    fetchMock.mockRestore();
  });
});
