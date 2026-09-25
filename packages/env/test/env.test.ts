import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import { ALL_KEYS, checkEnv, requireKeys, requireProvider } from "../src/index.js";

const examplePath = fileURLToPath(new URL("../../../.env.example", import.meta.url));

function parseEnvFile(text: string): Record<string, string> {
  const env: Record<string, string> = {};
  for (const line of text.split("\n")) {
    const m = /^([A-Z0-9_]+)=(.*)$/.exec(line.trim());
    if (m) env[m[1]!] = m[2]!.replace(/^"(.*)"$/, "$1");
  }
  return env;
}

const example = parseEnvFile(readFileSync(examplePath, "utf8"));

describe(".env.example", () => {
  it("declares exactly the keys in the schema", () => {
    const schemaKeys = ALL_KEYS.map((k) => k.key).sort();
    const exampleKeys = Object.keys(example).sort();
    expect(exampleKeys).toEqual(schemaKeys);
  });

  it("passes env:check with dummy provider values", () => {
    const report = checkEnv(example);
    expect(report.ok).toBe(true);
    const whatsapp = report.groups.find((g) => g.group.id === "whatsapp");
    expect(whatsapp?.configured).toBe(false);
    expect(whatsapp?.dummy).toContain("WHATSAPP_ACCESS_TOKEN");
  });
});

describe("checkEnv", () => {
  it("fails and names a missing required key", () => {
    const { REDIS_URL: _removed, ...rest } = example;
    const report = checkEnv(rest);
    expect(report.ok).toBe(false);
    expect(report.groups.find((g) => g.group.id === "core")?.missing).toEqual(["REDIS_URL"]);
  });

  it("fails on an invalid non-dummy value", () => {
    const report = checkEnv({ ...example, SNIPPE_API_KEY: "not-a-snippe-key" });
    expect(report.ok).toBe(false);
    expect(report.groups.find((g) => g.group.id === "snippe")?.invalid).toEqual(["SNIPPE_API_KEY"]);
  });
});

describe("requireProvider / requireKeys", () => {
  it("refuses dummy provider values", () => {
    expect(() => requireProvider(example, "snippe")).toThrow(/SNIPPE_API_KEY \(dummy value\)/);
  });

  it("returns values once real keys are set", () => {
    const env = { ...example, SNIPPE_API_KEY: "snp_live_123", SNIPPE_WEBHOOK_SECRET: "whsec" };
    expect(requireProvider(env, "snippe").SNIPPE_API_KEY).toBe("snp_live_123");
  });

  it("requireKeys refuses dummy spike keys", () => {
    expect(() => requireKeys(example, ["SPIKE_TEST_PHONE"])).toThrow(/SPIKE_TEST_PHONE/);
  });
});
