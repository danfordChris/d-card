import { afterEach, describe, expect, it, vi } from "vitest";
import { createSessionCookie, getVerifier, verifySessionCookie } from "../src/server/auth/verifier";

// setup-env sets AUTH_VERIFIER=fake; each test switches mode explicitly.
afterEach(() => {
  process.env.AUTH_VERIFIER = "fake";
  vi.unstubAllEnvs();
});

describe("AUTH_VERIFIER modes", () => {
  it("dev accepts fake tokens and sends other tokens to Firebase", async () => {
    process.env.AUTH_VERIFIER = "dev";
    expect(await getVerifier()("fake:u1:a@example.com")).toMatchObject({ uid: "u1", email: "a@example.com" });
    // A non-fake token goes to firebase-admin; without credentials in tests it is rejected as unauthorized.
    await expect(getVerifier()("not-a-real-jwt")).rejects.toMatchObject({ code: "unauthorized" });
  });

  it("dev keeps fake session cookies working", async () => {
    process.env.AUTH_VERIFIER = "dev";
    const { value } = await createSessionCookie("fake:u2:b@example.com");
    expect(value).toBe("fake:u2:b@example.com");
    expect((await verifySessionCookie(value)).uid).toBe("u2");
  });

  it("fake rejects non-fake tokens without calling Firebase", async () => {
    process.env.AUTH_VERIFIER = "fake";
    await expect(getVerifier()("eyJhbGciOi.x.y")).rejects.toMatchObject({ code: "unauthorized" });
  });

  it("refuses dev and fake in production", () => {
    vi.stubEnv("NODE_ENV", "production");
    for (const mode of ["dev", "fake"]) {
      process.env.AUTH_VERIFIER = mode;
      expect(() => getVerifier()).toThrow(/not allowed in production/);
    }
  });
});
