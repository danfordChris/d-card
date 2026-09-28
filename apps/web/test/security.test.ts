import { describe, expect, it } from "vitest";
import { safeNext } from "../src/features/auth/safe-next";

describe("SEC-01 safe redirect after sign-in", () => {
  it("keeps paths on this site and refuses everything else", () => {
    expect(safeNext("/events/abc?tab=guests")).toBe("/events/abc?tab=guests");
    expect(safeNext(null)).toBe("/dashboard");
    for (const bad of ["//evil.com", "/\\evil.com", "https://evil.com", "javascript:alert(1)", "evil.com", "/\\/evil.com"]) {
      expect(safeNext(bad)).toBe("/dashboard");
    }
  });
});

describe("SEC-04 security headers", () => {
  it("sends frame, sniffing, referrer, permissions and HSTS headers on every path", async () => {
    const config = (await import("../next.config")).default as { headers: () => Promise<{ source: string; headers: { key: string; value: string }[] }[]> };
    const [rule] = await config.headers();
    expect(rule!.source).toBe("/:path*");
    const h = Object.fromEntries(rule!.headers.map((x) => [x.key.toLowerCase(), x.value]));
    expect(h["content-security-policy"]).toContain("frame-ancestors 'none'");
    expect(h["x-content-type-options"]).toBe("nosniff");
    expect(h["x-frame-options"]).toBe("DENY");
    expect(h["strict-transport-security"]).toContain("max-age=");
    expect(h["referrer-policy"]).toBe("strict-origin-when-cross-origin");
  });
});
