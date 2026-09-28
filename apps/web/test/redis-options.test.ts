import { describe, expect, it } from "vitest";
import { redisOptions } from "../src/server/queue";

describe("redisOptions", () => {
  it("uses plain options locally and pins the CA when REDIS_TLS_CA_B64 is set", () => {
    expect(redisOptions({})).toEqual({ maxRetriesPerRequest: null });
    const pem = "-----BEGIN CERTIFICATE-----\nMIIB\n-----END CERTIFICATE-----\n";
    const opts = redisOptions({ REDIS_TLS_CA_B64: Buffer.from(pem).toString("base64") });
    expect(opts.tls?.ca).toBe(pem);
    expect(opts.tls?.checkServerIdentity?.("host", {} as never)).toBeUndefined();
  });
});
